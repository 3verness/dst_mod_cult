require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/tarotset.zip"),
	Asset("ATLAS", "images/inventoryimages/tarotset.xml"),	
	Asset("IMAGE", "images/inventoryimages/tarotset.tex"),	
}

local prefabs =
{
    "collapse_small",
}

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
    
end

local function onbuilt(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
    inst.AnimState:PlayAnimation("base")
	inst.AnimState:PushAnimation("idle")
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

    inst.AnimState:SetBank("tarotset")
    inst.AnimState:SetBuild("tarotset")
    inst.AnimState:PlayAnimation("idle")
	
	inst.countdown = 0

    inst:AddTag("structure")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    MakeSnowCovered(inst)
	
	inst:AddComponent("tarotset")

    inst:ListenForEvent("onbuilt", onbuilt)

    MakeHauntableWork(inst)

    return inst
end

return Prefab("tarotset", fn, assets, prefabs),
    MakePlacer("tarotset_placer", "tarotset", "tarotset", "idle")
