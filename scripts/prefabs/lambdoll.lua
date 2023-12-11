local assets =
{
    Asset("ANIM", "anim/lambdoll.zip"),
    Asset("ANIM", "anim/swap_lambdoll.zip"),
	
    Asset("ATLAS", "images/inventoryimages/lambdoll.xml"),
    Asset("IMAGE", "images/inventoryimages/lambdoll.tex"),	
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_lambdoll", "swap_lambdoll")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("lambdoll")
    inst.AnimState:SetBuild("lambdoll")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(6.66)
	
	inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP)
    inst.components.tool:SetAction(ACTIONS.NET)
    inst.components.tool:SetAction(ACTIONS.HAMMER)
    inst.components.tool:SetAction(ACTIONS.MINE)
    inst.components.tool:SetAction(ACTIONS.DIG)

    inst:AddComponent("fishingrod")
    inst.components.fishingrod:SetWaitTimes(4, 40)
    inst.components.fishingrod:SetStrainTimes(0, 5)

    -------

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "lambdoll"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/lambdoll.xml"
	
    inst:AddComponent("equippable")
	inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
    -- inst:AddComponent("fuel")
    -- inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)	

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("lambdoll", fn, assets)