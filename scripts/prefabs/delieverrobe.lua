local assets =
{
    Asset("ANIM", "anim/delieverrobe.zip"),
	
	Asset("ATLAS", "images/inventoryimages/delieverrobe.xml"),
    Asset("IMAGE", "images/inventoryimages/delieverrobe.tex"),
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "delieverrobe", "swap_body")
	owner:AddTag("devotee")
	-- inst.components.fueled:StartConsuming()
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
	owner:RemoveTag("devotee")
	-- inst.components.fueled:StopConsuming()
end

local function onequiptomodel(inst)
    -- inst.components.fueled:StopConsuming()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("delieverrobe")
    inst.AnimState:SetBuild("delieverrobe")
    inst.AnimState:PlayAnimation("idle")
    --inst.AnimState:SetMultColour(1, 1, 1, 0.6)
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "delieverrobe"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/delieverrobe.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable:SetOnEquipToModel( onequiptomodel )
	
	-- inst:AddComponent("fueled")
    -- inst.components.fueled.fueltype = FUELTYPE.USAGE
    -- inst.components.fueled:InitializeFuelLevel(TUNING.SWEATERVEST_PERISHTIME)
    -- inst.components.fueled:SetDepletedFn(inst.Remove)

    inst:AddComponent("planardefense")
    inst.components.planardefense:SetBaseDefense(10)
    inst:AddComponent("armor")
    inst.components.armor:InitIndestructible(0.9)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("delieverrobe", fn, assets)