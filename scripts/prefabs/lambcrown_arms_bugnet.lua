local assets =
{
    Asset("ANIM", "anim/swap_lambcrown_arms.zip"),
	Asset("ANIM", "anim/swap_lambcrown_bugnet.zip"),
	
    Asset("ATLAS", "images/inventoryimages/lambcrown_arms_bugnet.xml"),
    Asset("IMAGE", "images/inventoryimages/lambcrown_arms_bugnet.tex"),	
}

local function on_off_use1(owner, inst)
    owner.components.inventory:Equip(SpawnPrefab("lambcrown_arms_knife"), nil, inst:GetPosition())
    inst:DoTaskInTime(0, inst.Remove)
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_lambcrown_bugnet", "swap_bugnet")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
	
	inst:AddComponent("crown_change")
    inst.components.crown_change:ModeChange(on_off_use1)
	owner:AddTag("stronggrip")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
	
	inst:RemoveComponent("crown_change")
	owner:RemoveTag("stronggrip")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("lambcrown_arms_bugnet")
    inst.AnimState:SetBuild("lambcrown_arms_bugnet")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
	inst:AddTag("nosteal")

    inst.entity:SetPristine()
	
	--local swap_data = {sym_build = "swap_lambcrown_bugnet"}
    --MakeInventoryFloatable(inst, "med", 0.09, {0.9, 0.4, 0.9}, true, -14.5, swap_data)

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SPEAR_DAMAGE)
	
	inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.NET)
	
	--inst:AddComponent("crownmode")

    -------
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "lambcrown_arms_bugnet"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/lambcrown_arms_bugnet.xml"
	inst.components.inventoryitem.keepondrown = true
	inst.components.inventoryitem.keepondeath = true
	
	inst.components.inventoryitem.canonlygoinpocket = true
	inst:AddComponent("curseditem")
	inst.components.curseditem.curse = "LAMB"
	
	MakeInventoryFloatable(inst, "med", nil, 0.75)
	
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("lambcrown_arms_bugnet", fn, assets)