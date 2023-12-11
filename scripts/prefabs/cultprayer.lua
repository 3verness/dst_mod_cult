local assets =
{
    Asset("ANIM", "anim/cultprayer.zip"),
	Asset("ANIM", "anim/cultaura.zip"),
	
    Asset("ATLAS", "images/inventoryimages/cultprayer.xml"),
    Asset("IMAGE", "images/inventoryimages/cultprayer.tex"),	
}

local function onsewn(inst, target, doer)
    doer:PushEvent("repair")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cultprayer")
    inst.AnimState:SetBuild("cultprayer")
    inst.AnimState:PlayAnimation("idle",true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "cultprayer"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/cultprayer.xml"	
	--inst.components.inventoryitem.keepondeath = true
	
	inst:AddComponent("boatpatch")
    inst.components.boatpatch.patch_type = "tape"
	
	inst:AddComponent("sewing")
    inst.components.sewing.repair_value = TUNING.SEWING_TAPE_REPAIR_VALUE
    inst.components.sewing.onsewn = onsewn
	
	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	inst:AddComponent("cultprayer")
	

    MakeHauntableLaunch(inst)

    return inst
end

local function prayer_effn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
	inst.AnimState:SetBank("cultaura")
    inst.AnimState:SetBuild("cultaura")
    inst.AnimState:PlayAnimation("idle", true)
	inst.Transform:SetScale(1, 1, 1)

    --inst.Light:SetRadius(2)
    --inst.Light:SetFalloff(.7)
    --inst.Light:SetIntensity(.65)
    --inst.Light:SetColour(223 / 255, 208 / 255, 69 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("cultprayer", fn, assets),
Prefab("prayer_ef", prayer_effn, assets)