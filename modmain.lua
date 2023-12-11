PrefabFiles = {
	"lambofthecult",
	"lambofthecult_none",
	"lambcrown",
	"shamura_devil",
	
	"lambcrown_arms_knife",
	"lambcrown_arms_axe",
	"lambcrown_arms_bugnet",
	"lambcrown_arms_fishingrod",
	"lambcrown_arms_hammer",
	"lambcrown_arms_picaxe",
	"lambcrown_arms_shovel",
	
	"curseshot",
	"lamblight",
	
	"poopfood_cl",
	"lambdoll",
	"lambtent",
	"delieverrobe",
	"goldenlambstatue",
	
	"cultprayer",
	
	"tarotset",
	"tarotcard",
	
	"devotee",
	
	--cultist head
	"cultist_headacc_crow",
	"cultist_headacc_heket",
	"cultist_headacc_kallamar",
	"cultist_headacc_leshy",
	"cultist_headacc_narinder",
	"cultist_headacc_rabbit",
	"cultist_headacc_shamura",
	
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/lambofthecult.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/lambofthecult.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/lambofthecult.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/lambofthecult.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/lambofthecult_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/lambofthecult_silho.xml" ),

    Asset( "IMAGE", "bigportraits/lambofthecult.tex" ),
    Asset( "ATLAS", "bigportraits/lambofthecult.xml" ),
	
	Asset( "IMAGE", "images/map_icons/lambofthecult.tex" ),
	Asset( "ATLAS", "images/map_icons/lambofthecult.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_lambofthecult.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_lambofthecult.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_lambofthecult.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_lambofthecult.xml" ),
	
	Asset( "IMAGE", "images/avatars/self_inspect_lambofthecult.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_lambofthecult.xml" ),
	
	Asset( "IMAGE", "images/names_lambofthecult.tex" ),
    Asset( "ATLAS", "images/names_lambofthecult.xml" ),
	
	Asset( "IMAGE", "images/names_gold_lambofthecult.tex" ),
    Asset( "ATLAS", "images/names_gold_lambofthecult.xml" ),
}

AddMinimapAtlas("images/map_icons/lambofthecult.xml")

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local resolvefilepath = GLOBAL.resolvefilepath

local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local Recipe = GLOBAL.Recipe
local TECH = GLOBAL.TECH

local State = GLOBAL.State
local Action = GLOBAL.Action
local ActionHandler = GLOBAL.ActionHandler
local TimeEvent = GLOBAL.TimeEvent
local EventHandler = GLOBAL.EventHandler
local ACTIONS = GLOBAL.ACTIONS
local FRAMES = GLOBAL.FRAMES
local TheWorld = GLOBAL.TheWorld

AddPlayerPostInit(function(inst)
	inst:ListenForEvent("death", function()
		if inst.components.inventory:Has("tarotcard_narinder", 1) then
			local revival = inst.components.inventory:FindItem(function(item) return item.prefab=="tarotcard_narinder" end)
			if revival ~= nil then
        		revival:Remove()
        	end
			inst:DoTaskInTime(2.5, function()
				if inst:HasTag("playerghost") then
					inst:PushEvent("respawnfromghost", { source = revival })
				end
			end)
		end
	end)
	inst:AddComponent("tarotenchant")
end)

AddAction("CROWN_CHANGE", "Mode Change", function(act)
    if act.invobject and act.invobject.components.crown_change and act.doer then
        act.invobject.components.crown_change:ChangeMode(act.doer,act.invobject)
        return true
    end
end)

AddComponentAction("INVENTORY", "crown_change", function(inst, doer, actions)
    table.insert(actions, ACTIONS.CROWN_CHANGE)
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.CROWN_CHANGE, "combat_lunge_start"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.CROWN_CHANGE, "combat_lunge_start"))

--mahoudan

local crownmode_ac = AddAction("CROWNMODE", "Curse Shot", function(act)
	local act_pos = act:GetActionPoint()
    if act.invobject ~= nil then
        if act.invobject.components.crownmode ~= nil then
            return act.invobject.components.crownmode:Magic(act_pos, act.doer, act.invobject)
        end
    end
end)
crownmode_ac.priority = 10
crownmode_ac.rmb=true
crownmode_ac.distance=36
crownmode_ac.mount_valid=true

AddComponentAction("POINT", "crownmode", function(inst, doer, pos, actions, right)
    local x,y,z = pos:Get()
        if right and not doer:HasTag("steeringboat") and doer:HasTag("founderofreligionlamb") then
            table.insert(actions, ACTIONS.CROWNMODE)
        end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.CROWNMODE, "parry_pre"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.CROWNMODE, "parry_pre"))

local crownmode2_ac = AddAction("CROWNMODE2", "Crown Mode Change", function(act)
	if act.doer ~= nil and act.target ~= nil and act.invobject ~= nil and
	act.invobject.components.crownmode then 
		--if act.target.components.workable or act.target.components.fishable then
			act.invobject.components.crownmode:Target(act.doer, act.target)
			return true
		--end
	end
end)

crownmode2_ac.priority = 10
crownmode2_ac.rmb=true
crownmode2_ac.distance=36
crownmode2_ac.mount_valid=true

AddComponentAction("EQUIPPED", "crownmode", function(inst, doer, target, actions, right)
	if right and not doer:HasTag("steeringboat") and doer:HasTag("founderofreligionlamb") then
		table.insert(actions, GLOBAL.ACTIONS.CROWNMODE2)
	end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.CROWNMODE2, "combat_lunge_start"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.CROWNMODE2, "combat_lunge_start"))

AddAction("CULTPRAYER", "Eat Devotion", function(act)
	if act.invobject and act.invobject.components.cultprayer and act.doer then
        act.invobject.components.cultprayer:Eating(act.doer,act.invobject)
		return true
    end
end)

AddComponentAction("INVENTORY", "cultprayer", function(inst, doer, actions)
    if doer:HasTag("founderofreligionlamb") then
		table.insert(actions, ACTIONS.CULTPRAYER)
	end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.CULTPRAYER, "eat"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.CULTPRAYER, "eat"))

AddAction("TAROTSET", "Draw a card", function(act)
	if act.doer ~= nil and act.target ~= nil and act.doer:HasTag("player") and
	act.target.components.tarotset and not act.target:HasTag("burnt") and not act.target:HasTag("fire") then
		act.target.components.tarotset:DrawCard(act.doer)
		return true
	end
end)

AddComponentAction("SCENE", "tarotset", function(inst, doer, actions, right)
	if right and not doer:HasTag("tarot_draw") then
		if not inst:HasTag("burnt") and not inst:HasTag("fire") then
			table.insert(actions, GLOBAL.ACTIONS.TAROTSET)
		end
	end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.TAROTSET, "give"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.TAROTSET, "give"))

AddAction("GOLDENLAMBSTATUE", "Pray", function(act)
	if act.doer ~= nil and act.target ~= nil and act.doer:HasTag("player") and
	act.target.components.goldenlambstatue and not act.target:HasTag("burnt") and not act.target:HasTag("fire") then
		act.target.components.goldenlambstatue:Pray(act.doer)
		return true
	end
end)

AddComponentAction("SCENE", "goldenlambstatue", function(inst, doer, actions, right)
	if right then
		if not inst:HasTag("burnt") and not inst:HasTag("fire") then
			table.insert(actions, GLOBAL.ACTIONS.GOLDENLAMBSTATUE)
		end
	end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.GOLDENLAMBSTATUE, "give"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.GOLDENLAMBSTATUE, "give"))

AddAction("SHAMURA_USE", "Vacuum Start", function(act)
	if act.invobject and act.invobject.components.shamura_use and act.doer then
        act.invobject.components.shamura_use:OnOff(act.doer,act.invobject)
		return true
    end
end)

AddComponentAction("INVENTORY", "shamura_use", function(inst, doer, actions)
	table.insert(actions, ACTIONS.SHAMURA_USE)
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SHAMURA_USE, "doshortaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SHAMURA_USE, "doshortaction"))

local devotee_comeon = AddAction("DEVOTEE_COMEON", "Command", function(act)
	if act.doer ~= nil and act.target ~= nil and act.doer:HasTag("player") and act.target.components.devotee_comeon then
		act.target.components.devotee_comeon:Command(act.doer)
		return true
	end
end)
devotee_comeon.priority = 1
devotee_comeon.rmb=true
devotee_comeon.distance=36
devotee_comeon.mount_valid=true

AddComponentAction("SCENE", "devotee_comeon", function(inst, doer, actions, right)
	if right and doer:HasTag("founderofreligionlamb") then
		table.insert(actions, GLOBAL.ACTIONS.DEVOTEE_COMEON)
	end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.DEVOTEE_COMEON, "give"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.DEVOTEE_COMEON, "give"))

AddRecipe("lambtent", 
{GLOBAL.Ingredient("boards", 15),GLOBAL.Ingredient("goldnugget", 3),GLOBAL.Ingredient("petals", 5)}, 
RECIPETABS.SURVIVAL, TECH.NONE, "lambtent_placer", nil, nil, nil, "founderofreligionlamb", 
"images/inventoryimages/lambtent.xml", "lambtent.tex" )

AddRecipe("goldenlambstatue", 
{GLOBAL.Ingredient("cutstone", 10),GLOBAL.Ingredient("goldnugget", 20)}, 
RECIPETABS.SURVIVAL, TECH.NONE, "goldenlambstatue_placer", nil, nil, nil, "founderofreligionlamb", 
"images/inventoryimages/goldenlambstatue.xml", "goldenlambstatue.tex" )

AddRecipe("tarotset", 
{GLOBAL.Ingredient("cultprayer", 150, "images/inventoryimages/cultprayer.xml"),GLOBAL.Ingredient("papyrus", 30)}, 
--{GLOBAL.Ingredient("log", 1),}, 
RECIPETABS.SURVIVAL, TECH.NONE, "tarotset_placer", nil, nil, nil, "founderofreligionlamb", 
"images/inventoryimages/tarotset.xml", "tarotset.tex" )

AddRecipe("lambdoll", 
{GLOBAL.Ingredient("cultprayer", 30, "images/inventoryimages/cultprayer.xml"),}, 
RECIPETABS.SURVIVAL, TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb", 
"images/inventoryimages/lambdoll.xml", "lambdoll.tex" )

AddRecipe("delieverrobe", 
{GLOBAL.Ingredient("cutgrass", 10),GLOBAL.Ingredient("berries", 1),}, 
RECIPETABS.SURVIVAL, TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb", 
"images/inventoryimages/delieverrobe.xml", "delieverrobe.tex" )

AddRecipe("poopfood_cl", 
{GLOBAL.Ingredient("poop", 3),}, 
RECIPETABS.SURVIVAL, TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb", 
"images/inventoryimages/poopfood_cl.xml", "poopfood_cl.tex" )

local poop_recipe_cl = AddRecipe("poop", { GLOBAL.Ingredient("cultprayer", 10, "images/inventoryimages/cultprayer.xml")},
 RECIPETABS.REFINE,  TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb")
local goldnugget_recipe_cl = AddRecipe("goldnugget", { GLOBAL.Ingredient("cultprayer", 20, "images/inventoryimages/cultprayer.xml")},
 RECIPETABS.REFINE,  TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb")
local redgem_recipe_cl = AddRecipe("redgem", { GLOBAL.Ingredient("cultprayer", 40, "images/inventoryimages/cultprayer.xml")},
 RECIPETABS.REFINE,  TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb")
local bluegem_recipe_cl = AddRecipe("bluegem", { GLOBAL.Ingredient("cultprayer", 40, "images/inventoryimages/cultprayer.xml")},
 RECIPETABS.REFINE,  TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb")
local greengem_recipe_cl = AddRecipe("greengem", { GLOBAL.Ingredient("cultprayer", 100, "images/inventoryimages/cultprayer.xml")},
 RECIPETABS.REFINE,  TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb")
 local yellowgem_recipe_cl = AddRecipe("yellowgem", { GLOBAL.Ingredient("cultprayer", 100, "images/inventoryimages/cultprayer.xml")},
 RECIPETABS.REFINE,  TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb")
 local opalpreciousgem_recipe_cl = AddRecipe("opalpreciousgem", { GLOBAL.Ingredient("cultprayer", 400, "images/inventoryimages/cultprayer.xml")},
 RECIPETABS.REFINE,  TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb")
-- The character select screen lines
STRINGS.CHARACTER_TITLES.lambofthecult = "The Last Lamb"
STRINGS.CHARACTER_NAMES.lambofthecult = "The Lamb"
STRINGS.CHARACTER_DESCRIPTIONS.lambofthecult = "*Wearing a Red Crown of great power.\n*Educate powerful enemies into believers."
STRINGS.CHARACTER_QUOTES.lambofthecult = "\"The great lamb who leads the flock of the cult. -N\""
STRINGS.CHARACTER_SURVIVABILITY.lambofthecult = "Stray Lambs"

GLOBAL.STRINGS.NAMES.LAMBCROWN = "The Crown"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LAMBCROWN = "Wow"
GLOBAL.STRINGS.RECIPE_DESC.LAMBCROWN = "Reset"

TUNING.STARTING_ITEM_IMAGE_OVERRIDE.lambcrown = {
	atlas = "images/inventoryimages/lambcrown.xml",
	image = "lambcrown.tex"
}

GLOBAL.STRINGS.NAMES.CROWN_F = "The Crown"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CROWN_F = "Wow"

GLOBAL.STRINGS.NAMES.LAMBCROWN_ARMS_KNIFE = "The Crown"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LAMBCROWN_ARMS_KNIFE = "Wow"

GLOBAL.STRINGS.NAMES.LAMBCROWN_ARMS_AXE = "The Crown"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LAMBCROWN_ARMS_AXE = "Wow"

GLOBAL.STRINGS.NAMES.LAMBCROWN_ARMS_BUGNET = "The Crown"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LAMBCROWN_ARMS_BUGNET = "Wow"

GLOBAL.STRINGS.NAMES.LAMBCROWN_ARMS_FISHINGROD = "The Crown"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LAMBCROWN_ARMS_FISHINGROD = "Wow"

GLOBAL.STRINGS.NAMES.LAMBCROWN_ARMS_HAMMER = "The Crown"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LAMBCROWN_ARMS_HAMMER = "Wow"

GLOBAL.STRINGS.NAMES.LAMBCROWN_ARMS_PICAXE = "The Crown"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LAMBCROWN_ARMS_PICAXE = "Wow"

GLOBAL.STRINGS.NAMES.LAMBCROWN_ARMS_SHOVEL = "The Crown"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LAMBCROWN_ARMS_SHOVEL = "Wow"

GLOBAL.STRINGS.NAMES.POOPFOOD_CL = "Poop food"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.POOPFOOD_CL = "Wow"
GLOBAL.STRINGS.RECIPE_DESC.POOPFOOD_CL = "Disgusting!"

GLOBAL.STRINGS.NAMES.LAMBDOLL = "Lamb doll"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LAMBDOLL = "It's soooo cute!"
GLOBAL.STRINGS.RECIPE_DESC.LAMBDOLL = "Cute lamb doll."

GLOBAL.STRINGS.NAMES.LAMBTENT = "Cult's tent"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LAMBTENT = "Comfortable!"
GLOBAL.STRINGS.RECIPE_DESC.LAMBTENT = "Can sleep."

GLOBAL.STRINGS.NAMES.DELIEVERROBE = "Devotee's robe"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.DELIEVERROBE = "Comfortable!"
GLOBAL.STRINGS.RECIPE_DESC.DELIEVERROBE = "Manifestation of faith."

GLOBAL.STRINGS.NAMES.GOLDENLAMBSTATUE = "Golden Lamb Statue"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.GOLDENLAMBSTATUE = "Comfortable!"
GLOBAL.STRINGS.RECIPE_DESC.GOLDENLAMBSTATUE = "Collect Devotion Power"

GLOBAL.STRINGS.NAMES.CULTPRAYER = "Devotion Power"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CULTPRAYER = "Comfortable!"
GLOBAL.STRINGS.RECIPE_DESC.CULTPRAYER = "Devotion Power"

GLOBAL.STRINGS.NAMES.TAROTSET = "Tarot Set"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TAROTSET = "Comfortable!"
GLOBAL.STRINGS.RECIPE_DESC.TAROTSET = "Draw a card."

GLOBAL.STRINGS.NAMES.TAROTCARD_LESHY = "Tarot Leshy"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TAROTCARD_LESHY = "Comfortable!"

GLOBAL.STRINGS.NAMES.TAROTCARD_HEKET = "Tarot Heckt"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TAROTCARD_HEKET = "Comfortable!"

GLOBAL.STRINGS.NAMES.TAROTCARD_KALLAMAR = "Tarot Kallamar"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TAROTCARD_KALLAMAR = "Comfortable!"

GLOBAL.STRINGS.NAMES.TAROTCARD_SHAMURA = "Tarot Shamura"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TAROTCARD_SHAMURA = "Comfortable!"

GLOBAL.STRINGS.NAMES.TAROTCARD_NARINDER = "Tarot Narinder"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TAROTCARD_NARINDER = "Comfortable!"

GLOBAL.STRINGS.NAMES.SHAMURA_DEVIL = "Devil"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SHAMURA_DEVIL = "Reliable Devil."

GLOBAL.STRINGS.NAMES.DEVOTEE = "Cultist"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.DEVOTEE = "Cultist."

--cultist head

AddRecipe("cultist_headacc_heket", 
{GLOBAL.Ingredient("cultprayer", 30, "images/inventoryimages/cultprayer.xml"),GLOBAL.Ingredient("froglegs", 4),}, 
RECIPETABS.SURVIVAL, TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb", 
"images/inventoryimages/cultist_headacc_heket.xml", "cultist_headacc_heket.tex" )

GLOBAL.STRINGS.NAMES.CULTIST_HEADACC_HEKET = "CultistDoll Heket"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CULTIST_HEADACC_HEKET = "It's soooo cute!"
GLOBAL.STRINGS.RECIPE_DESC.CULTIST_HEADACC_HEKET = "Vanity Item."

AddRecipe("cultist_headacc_crow", 
{GLOBAL.Ingredient("cultprayer", 30, "images/inventoryimages/cultprayer.xml"),GLOBAL.Ingredient("feather_crow", 4),}, 
RECIPETABS.SURVIVAL, TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb", 
"images/inventoryimages/cultist_headacc_crow.xml", "cultist_headacc_crow.tex" )

GLOBAL.STRINGS.NAMES.CULTIST_HEADACC_CROW = "CultistDoll Crow"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CULTIST_HEADACC_CROW = "It's soooo cute!"
GLOBAL.STRINGS.RECIPE_DESC.CULTIST_HEADACC_CROW = "Vanity Item."

AddRecipe("cultist_headacc_kallamar", 
{GLOBAL.Ingredient("cultprayer", 30, "images/inventoryimages/cultprayer.xml"),GLOBAL.Ingredient("tentaclespots", 2),}, 
RECIPETABS.SURVIVAL, TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb", 
"images/inventoryimages/cultist_headacc_kallamar.xml", "cultist_headacc_kallamar.tex" )

GLOBAL.STRINGS.NAMES.CULTIST_HEADACC_KALLAMAR = "CultistDoll kallamar"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CULTIST_HEADACC_KALLAMAR = "It's soooo cute!"
GLOBAL.STRINGS.RECIPE_DESC.CULTIST_HEADACC_KALLAMAR = "Vanity Item."

AddRecipe("cultist_headacc_leshy", 
{GLOBAL.Ingredient("cultprayer", 30, "images/inventoryimages/cultprayer.xml"),GLOBAL.Ingredient("petals", 4),},  
RECIPETABS.SURVIVAL, TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb", 
"images/inventoryimages/cultist_headacc_leshy.xml", "cultist_headacc_leshy.tex" )

GLOBAL.STRINGS.NAMES.CULTIST_HEADACC_LESHY = "CultistDoll Leshy"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CULTIST_HEADACC_LESHY = "It's soooo cute!"
GLOBAL.STRINGS.RECIPE_DESC.CULTIST_HEADACC_LESHY = "Vanity Item."

AddRecipe("cultist_headacc_narinder", 
{GLOBAL.Ingredient("cultprayer", 30, "images/inventoryimages/cultprayer.xml"),GLOBAL.Ingredient("coontail", 2),}, 
RECIPETABS.SURVIVAL, TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb", 
"images/inventoryimages/cultist_headacc_narinder.xml", "cultist_headacc_narinder.tex" )

GLOBAL.STRINGS.NAMES.CULTIST_HEADACC_NARINDER = "CultistDoll Narinder"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CULTIST_HEADACC_NARINDER = "It's soooo cute!"
GLOBAL.STRINGS.RECIPE_DESC.CULTIST_HEADACC_NARINDER = "Vanity Item."

AddRecipe("cultist_headacc_rabbit", 
{GLOBAL.Ingredient("cultprayer", 30, "images/inventoryimages/cultprayer.xml"),GLOBAL.Ingredient("rabbit", 1),}, 
RECIPETABS.SURVIVAL, TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb", 
"images/inventoryimages/cultist_headacc_rabbit.xml", "cultist_headacc_rabbit.tex" )

GLOBAL.STRINGS.NAMES.CULTIST_HEADACC_RABBIT = "CultistDoll Rabbit"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CULTIST_HEADACC_RABBIT = "It's soooo cute!"
GLOBAL.STRINGS.RECIPE_DESC.CULTIST_HEADACC_RABBIT = "Vanity Item."

AddRecipe("cultist_headacc_shamura", 
{GLOBAL.Ingredient("cultprayer", 30, "images/inventoryimages/cultprayer.xml"),GLOBAL.Ingredient("silk", 4),}, 
RECIPETABS.SURVIVAL, TECH.NONE, nil, nil, nil, nil, "founderofreligionlamb", 
"images/inventoryimages/cultist_headacc_shamura.xml", "cultist_headacc_shamura.tex" )

GLOBAL.STRINGS.NAMES.CULTIST_HEADACC_SHAMURA = "CultistDoll Shamura"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CULTIST_HEADACC_SHAMURA = "It's soooo cute!"
GLOBAL.STRINGS.RECIPE_DESC.CULTIST_HEADACC_SHAMURA = "Vanity Item."

-- Custom speech strings
STRINGS.CHARACTERS.LAMBOFTHECULT = require "speech_lambofthecult"

-- The character's name as appears in-game 
STRINGS.NAMES.LAMBOFTHECULT = "The Lamb"
STRINGS.SKIN_NAMES.lambofthecult_none = "The Lamb"

-- The skins shown in the cycle view window on the character select screen.
-- A good place to see what you can put in here is in skinutils.lua, in the function GetSkinModes
local skin_modes = {
    { 
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle", 
        scale = 0.75, 
        offset = { 0, -25 } 
    },
}

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("lambofthecult", "NEUTRAL", skin_modes)
