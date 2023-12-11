require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/goldenlambstatue.zip"),
	Asset("ATLAS", "images/inventoryimages/goldenlambstatue.xml"),	
	Asset("IMAGE", "images/inventoryimages/goldenlambstatue.tex"),	
}

local prefabs =
{
    "collapse_small",
}

local charge_devotion = 550

local function startwaiting(inst)
    local chargeamount = inst.components.goldenlambstatue.charge
	local range = 16
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, range, nil, {"INLIMBO", "wall"})
    for i, v in ipairs(ents) do
    	if v ~= inst and v:HasTag("player") and not v:HasTag("founderofreligionlamb") then
			inst.components.goldenlambstatue:SetCharge(chargeamount + 1)
		end
		if v.components.combat ~= nil and v.components.health ~= nil then 
			if not v.components.health:IsDead() then
				inst.components.goldenlambstatue:SetCharge(chargeamount + 1)
			end
		end
	end
	inst.components.goldenlambstatue:SetCharge(chargeamount + 1)
	if inst.components.goldenlambstatue.devotion == 0 then
		inst.AnimState:PlayAnimation("idle_0")
	elseif inst.components.goldenlambstatue.devotion >= 1 and inst.components.goldenlambstatue.devotion <= 49 then
		inst.AnimState:PlayAnimation("idle_1")
	elseif inst.components.goldenlambstatue.devotion >= 50 and inst.components.goldenlambstatue.devotion <= 99 then
		inst.AnimState:PlayAnimation("idle_2")
	elseif inst.components.goldenlambstatue.devotion >= 100 then
		inst.AnimState:PlayAnimation("idle_3")
	end
end

local function on_changekekichi(inst)
	if inst.components.goldenlambstatue.charge >= charge_devotion then
		inst.components.goldenlambstatue.charge = inst.components.goldenlambstatue.charge - charge_devotion
		inst.components.goldenlambstatue.devotion = math.min(inst.components.goldenlambstatue.devotion + 1, 100)
	end
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")
    inst:Remove()
end

local function onhit(inst)
    
end

local function onbuilt(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
    inst.AnimState:PlayAnimation("setup")
	inst.AnimState:PushAnimation("idle_0")
	inst.SoundEmitter:PlaySound("wickerbottom_rework/book_spells/light_upgrade")
    --the global animover handler will restart the check task
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .1)

    inst.AnimState:SetBank("goldenlambstatue")
    inst.AnimState:SetBuild("goldenlambstatue")
    inst.AnimState:PlayAnimation("idle_0")
	
	inst.countdown = 0

    inst:AddTag("structure")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	
	inst:AddComponent("talker")
    inst.components.talker.fontsize = 40
    inst.components.talker.font = TALKINGFONT_HERMIT

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    MakeSnowCovered(inst)
	
	inst:AddComponent("goldenlambstatue")
	inst:DoPeriodicTask(1, startwaiting)
	inst:ListenForEvent("praycharge_check", on_changekekichi)

    inst:ListenForEvent("onbuilt", onbuilt)

    MakeHauntableWork(inst)

    return inst
end

local function lambstatue_effn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    --MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("tarotcard_fx")
    inst.AnimState:SetBuild("tarotcard_fx")
    inst.AnimState:PlayAnimation("summon_devil")
	
	inst:AddTag("FX")
	inst:DoTaskInTime(0.5, inst.Remove)

    inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function lambstatue_ef2fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    --MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("curseshot")
    inst.AnimState:SetBuild("curseshot")
    inst.AnimState:PlayAnimation("handsigil")
	
	inst:AddTag("FX")
	inst:DoTaskInTime(0.5, inst.Remove)

    inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("goldenlambstatue", fn, assets, prefabs),
    MakePlacer("goldenlambstatue_placer", "goldenlambstatue", "goldenlambstatue", "idle_0"),
    Prefab("lambstatue_ef", lambstatue_effn, assets),
	Prefab("lambstatue_ef2", lambstatue_ef2fn, assets)