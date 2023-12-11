local assets =
{
	Asset("ANIM", "anim/lamb_cultdeliever.zip" ),
    Asset("SOUND", "sound/maxwell.fsb"),
	Asset("ANIM", "anim/swap_deliever_arms.zip"),
	Asset("ANIM", "anim/cultistsummonsigil.zip"),
}

local brain = require "brains/devoteebrain"

local items =
{
    AXE = "swap_deliever_arms",
    PICK = "swap_deliever_arms",
    SWORD = "swap_deliever_arms"
}

local function EquipItem(inst, item)
    if item then
        inst.AnimState:OverrideSymbol("swap_object", "swap_deliever_arms", "swap_deliever_arms")
        inst.AnimState:Show("ARM_carry") 
        inst.AnimState:Hide("ARM_normal")
    end
end

local function die(inst)
    inst.components.health:Kill()
end

local function resume(inst, time)
    if inst.death then
        inst.death:Cancel()
        inst.death = nil
    end
    inst.death = inst:DoTaskInTime(time, die)
end

local function onsave(inst, data)
    
end

local function KeepTarget(isnt, target)
    return target and target:IsValid()
end

local function onload(inst, data)
    
end

local function entitydeathfn(inst, data)
    if data.inst:HasTag("player") then
        inst:DoTaskInTime(math.random(), function() inst.components.health:Kill() end)
    end
end

function reborn_devotee(inst, haunter)
    if haunter.prefab == "lambofthecult" then
	inst:DoTaskInTime(0, inst.components.health:Kill())
		inst:PushEvent("respawnfromghost", { source = inst })
	end
    return true
end

local function OnEat(inst, food)
    if food.components.edible ~= nil then
    	SpawnPrefab("poop").Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst.components.health:DoDelta(300)
    end
end

local function ShouldAcceptItem(inst, item)
    if item.components.equippable ~= nil and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        return true
    end
end

local function OnGetItemFromPlayer(inst, giver, item)
    --I wear hats
    if item.components.equippable ~= nil and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        local current = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if current ~= nil then
            inst.components.inventory:DropItem(current)
        end
        inst.components.inventory:Equip(item)
        --inst.AnimState:Show("hat")
    end
end

local function OnRefuseItem(inst, item)
	inst.AnimState:PlayAnimation("emote_impatient")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	inst.entity:AddDynamicShadow()

    MakeCharacterPhysics(inst, 50, .5)

    inst.Transform:SetFourFaced(inst)
    
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("lamb_cultdeliever")
    inst.AnimState:PlayAnimation("idle")


    -- FROM PLAYER_COMMON
    inst.AnimState:Hide("HAT_HAIR")
    inst.AnimState:Show("HAIR_NOHAT")
    inst.AnimState:Show("HAIR")
    inst.AnimState:Show("HEAD")
    inst.AnimState:Hide("HEAD_HAT")
    inst.AnimState:Hide("ARM_carry")

    --inst:Show()

    
    -- END FROM PLAYER_COMMON

    --inst.AnimState:Hide("ARM_carry")
    --inst.AnimState:Hide("hat")
    --inst.AnimState:Hide("hat_hair")

    inst:AddTag("scarytoprey")
	inst:AddTag("trader")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --inst:AddComponent("colourtweener")
    --inst.components.colourtweener:StartTween({0,0,0,.5}, 0)

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 0.6 )
    inst.components.locomotor.runspeed = TUNING.SHADOWWAXWELL_SPEED

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "torso"
    -- inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetAttackPeriod(TUNING.SHADOWWAXWELL_ATTACK_PERIOD)
    inst.components.combat:SetRange(2, 3)
    inst.components.combat:SetDefaultDamage(6)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(300)

    inst:AddComponent("inventory")
    --inst.components.inventory:DisableDropOnDeath()
	
	inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
	inst.components.trader.onrefuse = OnRefuseItem
	inst.components.trader.deleteitemonaccept = false
	
	inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetPrefersEatingTag("preparedfood")
    inst.components.eater:SetPrefersEatingTag("pre-preparedfood")
    inst.components.eater:SetOnEatFn(OnEat)
	
	--inst:ListenForEvent("death", removetokentag)
	
	inst:AddComponent("devotee_comeon")
	inst:AddComponent("devotee_stay")
	
	inst:DoPeriodicTask(400,function() SpawnPrefab("cultprayer").Transform:SetPosition(inst.Transform:GetWorldPosition()) end)

    MakeHauntablePanic(inst)

    inst.items = items
    inst.equipfn = EquipItem

    inst.OnSave = onsave
    inst.OnLoad = onload

    EquipItem(inst)

    --inst:ListenForEvent("entity_death", function(world, data) entitydeathfn(inst, data) end, TheWorld)

    inst:AddComponent("follower")

    inst:SetBrain(brain)
    inst:SetStateGraph("SGdevotee")
	
	inst:AddComponent("hauntable")
    inst.components.hauntable:SetOnHauntFn( reborn_devotee )
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)

    return inst
end

local function devotee_effn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
	inst.AnimState:SetBank("cultistsummonsigil")
    inst.AnimState:SetBuild("cultistsummonsigil")
    inst.AnimState:PlayAnimation("idle")
	inst.Transform:SetScale(1, 1, 1)

    --inst.Light:SetRadius(2)
    --inst.Light:SetFalloff(.7)
    --inst.Light:SetIntensity(.65)
    --inst.Light:SetColour(223 / 255, 208 / 255, 69 / 255)
	inst:DoTaskInTime(1.2,function() inst:Remove() end)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("common/devotee", fn, assets),
Prefab("devotee_ef", devotee_effn, assets)