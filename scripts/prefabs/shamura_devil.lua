local friendlybrain = require("brains/shamura_devil_brain")

local sounds = {
    flap = "farming/creatures/lord_fruitfly/LP",
    hurt = "farming/creatures/lord_fruitfly/hit",
    attack = "farming/creatures/lord_fruitfly/attack",
    die = "farming/creatures/lord_fruitfly/die",
    die_ground = "farming/creatures/lord_fruitfly/hit",
    sleep = "farming/creatures/lord_fruitfly/sleep",
    buzz = "farming/creatures/lord_fruitfly/hit",
    spin = "farming/creatures/lord_fruitfly/spin",
    plant_attack = "farming/creatures/lord_fruitfly/plant_attack"
}

local minionsounds = {
    flap = "farming/creatures/minion_fruitfly/LP",
    hurt = "farming/creatures/minion_fruitfly/hit",
    attack = "farming/creatures/minion_fruitfly/attack",
    die = "farming/creatures/minion_fruitfly/die",
    die_ground = "farming/creatures/minion_fruitfly/hit",
    sleep = "farming/creatures/minion_fruitfly/sleep",
    buzz = "farming/creatures/minion_fruitfly/hit",
    spin = "farming/creatures/minion_fruitfly/spin",
    plant_attack = "farming/creatures/minion_fruitfly/plant_attack"
}

local friendlysounds = {
    flap = "farming/creatures/fruitfly/LP",
    hurt = "farming/creatures/fruitfly/hit",
    die = "farming/creatures/fruitfly/die",
    die_ground = "farming/creatures/fruitfly/die",
    sleep = "farming/creatures/fruitfly/sleep",
    buzz = "farming/creatures/fruitfly/hit",
}

local function common()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(0.5, 0.75)
    inst.Transform:SetFourFaced()

    MakeGhostPhysics(inst, 1, 0.5)

    inst.AnimState:SetBank("tarotdevil")

    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")
    --inst:AddTag("insect")
    inst:AddTag("small")

    return inst
end

local function common_server(inst)
    inst:AddComponent("inspectable")

    --inst:AddComponent("sleeper")
    --inst.components.sleeper:SetResistance(3)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 10
    inst.components.locomotor.pathcaps = {allowocean = true}

    MakeMediumFreezableCharacter(inst, "fruit2")
    MakeMediumBurnableCharacter(inst, "fruit2")

    MakeHauntablePanic(inst)

    return inst
end

local function FriendlyShouldKeepTarget()
    return false
end

local function KeepTarget(isnt, target)
    return target and target:IsValid()
end

local function checkmaster(inst)
    local owner = inst.components.follower.leader
	if not inst.components.health:IsDead() and owner == nil then
		inst:DoTaskInTime(.1, function()
			if not inst:HasTag("shamura_devil_remove") then
				inst.components.health:Kill()
				inst:AddTag("shamura_devil_remove")
				
			end
		end)
	end
	if owner ~= nil then
		if not owner.components.inventory:Has("tarotcard_shamura", 1) then
			if not inst:HasTag("shamura_devil_remove") then
				inst.components.health:Kill()
				inst:AddTag("shamura_devil_remove")
				
			end
		end
	end
end

local function deathfn(inst)
    local owner = inst.components.follower.leader
	if not inst:HasTag("Noleader") then
		inst:DoTaskInTime(1, function()
			SpawnPrefab("maxwell_smoke").Transform:SetPosition(inst.Transform:GetWorldPosition())
			if owner ~= nil then 
				owner:PushEvent("shamura_devil_defeat")
			end
			inst:Remove()
		end)
	end
end

local friendlyassets =
{
    Asset("ANIM", "anim/tarotdevil.zip"),
}

local function friendlyfn()
    local inst = common()

    inst.sounds = friendlysounds

    inst.AnimState:SetBuild("tarotdevil")
    inst.AnimState:PlayAnimation("idle")

    inst.Transform:SetScale(1, 1, 1)

    MakeInventoryFloatable(inst, "med")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    common_server(inst)
	
	inst:DoPeriodicTask(.5, checkmaster, nil)

    inst:AddComponent("follower")

    inst:AddComponent("health")
	inst.components.health:SetMaxHealth(500)
	inst.components.health:StartRegen(20,1)
    inst.components.health.nofadeout = true
	
	inst:ListenForEvent("death", deathfn)
	
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "fruit2"
    --inst.components.combat:SetKeepTargetFunction(FriendlyShouldKeepTarget)
	inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetAttackPeriod(0.1)
    inst.components.combat:SetRange(2, 3)
    inst.components.combat:SetDefaultDamage(12)

    --[[inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(FriendlyShouldSleep)
    inst.components.sleeper:SetWakeTest(FriendlyShouldWakeUp)]]

    inst:AddComponent("lootdropper")

    inst:SetBrain(friendlybrain)
    inst:SetStateGraph("SGshamura_devil")

    return inst
end

return Prefab("shamura_devil", friendlyfn, friendlyassets)