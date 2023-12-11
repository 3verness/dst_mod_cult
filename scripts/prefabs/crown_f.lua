local friendlybrain = require("brains/crown_fbrain")

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

    inst.AnimState:SetBank("lambcrown_follower")

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

local function checkmaster(inst)
    local owner = inst.components.follower.leader
	if not inst.components.health:IsDead() and owner == nil or owner.components.inventory:Has("tarotcard_heckt", 1) then
		inst:DoTaskInTime(.1, function()
			if not inst:HasTag("crown_f_remove") then
				inst.components.health:Kill()
				inst:AddTag("crown_f_remove")
			end
		end)
	end
end

local function deathfn(inst)
    local owner = inst.components.follower.leader
	if not inst:HasTag("Noleader") then
		inst:DoTaskInTime(1, function()
			SpawnPrefab("maxwell_smoke").Transform:SetPosition(inst.Transform:GetWorldPosition())
			if owner ~= nil then 
				owner:PushEvent("crown_f_defeat")
			end
			inst:Remove()
		end)
	end
end

local friendlyassets =
{
    Asset("ANIM", "anim/lambcrown_follower.zip"),
}

local function friendlyfn()
    local inst = common()

    inst.sounds = friendlysounds

    inst.AnimState:SetBuild("lambcrown_follower")
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
	inst.components.health:SetMaxHealth(99999)
    inst.components.health.nofadeout = true
	inst.components.health:SetInvincible(true)
	
	inst:ListenForEvent("death", deathfn)
	
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "fruit2"
    inst.components.combat:SetKeepTargetFunction(FriendlyShouldKeepTarget)

    --[[inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(FriendlyShouldSleep)
    inst.components.sleeper:SetWakeTest(FriendlyShouldWakeUp)]]

    inst:AddComponent("lootdropper")

    --[[inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY]]

    inst:SetBrain(friendlybrain)
    inst:SetStateGraph("SGcrown_f")

    return inst
end

return Prefab("crown_f", friendlyfn, friendlyassets)