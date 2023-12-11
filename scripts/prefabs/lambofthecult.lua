local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

-- Your character's stats
TUNING.LAMBOFTHECULT_HEALTH = 125
TUNING.LAMBOFTHECULT_HUNGER = 150
TUNING.LAMBOFTHECULT_SANITY = 300

-- Custom starting inventory
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.LAMBOFTHECULT = {
	"lambcrown",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.LAMBOFTHECULT
end
local prefabs = FlattenTree(start_inv, true)

-- When the character is revived from human
local function onbecamehuman(inst)
	-- Set speed when not a ghost (optional)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "lambofthecult_speed_mod", 1)
end

local function onbecameghost(inst)
	-- Remove speed modifier when becoming a ghost
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "lambofthecult_speed_mod")
end

-- When loading or spawning the character
local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
end

local function IsValidVictim(victim)
    return victim ~= nil
        and not ((victim:HasTag("prey") and not victim:HasTag("hostile")) or
                victim:HasTag("veggie") or
                victim:HasTag("structure") or
                victim:HasTag("wall") or
                victim:HasTag("balloon") or
                victim:HasTag("groundspike") or
                victim:HasTag("smashable") or
                victim:HasTag("companion"))
        and victim.components.health ~= nil
        and victim.components.combat ~= nil
end

local function onkilled(inst, data)
    local victim = data.victim
	
    if IsValidVictim(victim) then
        -- local delta = victim.components.combat.defaultdamage * 0.25
        -- inst.components.health:DoDelta(delta, false, "battleborn")
        -- inst.components.sanity:DoDelta(delta)

        if victim:HasTag("epic") then
            local time = victim.components.health.destroytime or 2
			inst:DoTaskInTime(time,function()
			local devotee_token = SpawnPrefab("devotee")
        	devotee_token.Transform:SetPosition(victim.Transform:GetWorldPosition())
        	SpawnPrefab("devotee_ef").Transform:SetPosition(victim.Transform:GetWorldPosition())
        	devotee_token.components.follower:SetLeader(inst)
        	inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_appear")
			end)
        end
    end
end

-- This initializes for both the server and client. Tags can be added here.
local common_postinit = function(inst) 
	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "lambofthecult.tex" )
	--Tags
	inst:AddTag("founderofreligionlamb")
	inst:AddTag("mime")
end

-- This initializes for the server only. Components are added here.
local master_postinit = function(inst)
	-- Set starting inventory
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
	
	-- choose which sounds this character will play
	inst.soundsname = "willow"
	
	-- Uncomment if "wathgrithr"(Wigfrid) or "webber" voice is used
    --inst.talker_path_override = "dontstarve_DLC001/characters/"
	
	-- Stats	
	inst.components.health:SetMaxHealth(TUNING.LAMBOFTHECULT_HEALTH)
	inst.components.hunger:SetMax(TUNING.LAMBOFTHECULT_HUNGER)
	inst.components.sanity:SetMax(TUNING.LAMBOFTHECULT_SANITY)
	
	inst.components.temperature:SetFreezingHurtRate(150/180)
	
	inst:AddComponent("cultenchant")
	
	inst:ListenForEvent("killed", onkilled)
	
	-- Damage multiplier (optional)
    inst.components.combat.damagemultiplier = 1
	
	-- Hunger rate (optional)
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
	
	inst.OnLoad = onload
    inst.OnNewSpawn = onload
	
end

return MakePlayerCharacter("lambofthecult", prefabs, assets, common_postinit, master_postinit, prefabs)
