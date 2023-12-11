local assets=
{
	Asset("ANIM", "anim/cultist_headacc_rabbit.zip"),
	
    Asset("ATLAS", "images/inventoryimages/cultist_headacc_rabbit.xml"),	
	Asset("IMAGE", "images/inventoryimages/cultist_headacc_rabbit.tex"),	
}

local function rabbitOnEquip(inst, owner) 
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")
	owner.AnimState:Hide("HEAD")
	owner.AnimState:Hide("HEAD_HAT_HELM")
	owner.AnimState:Show("HAT")
	owner.AnimState:OverrideSymbol("swap_hat", "cultist_headacc_rabbit", "swap_hat")
end

local function rabbitOnUnequip(inst, owner) 
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")
	owner.AnimState:Show("HEAD")
	owner.AnimState:Show("HEAD_HAT_HELM")
	owner.AnimState:Hide("HAT")
end

 local function rabbitfn() 
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	
	
    MakeInventoryPhysics(inst)
	
	inst:AddComponent("tradable")
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
    inst.AnimState:SetBank("tophat")
    inst.AnimState:SetBuild("cultist_headacc_rabbit")
    inst.AnimState:PlayAnimation("anim")
	
	inst:AddTag("hat")
	inst:AddTag("devotee_head")
	
	MakeHauntableLaunch(inst)
 
    inst:AddComponent("inspectable")
	
	inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_HUGE)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "cultist_headacc_rabbit"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/cultist_headacc_rabbit.xml"
	 
    inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip( rabbitOnEquip )
    inst.components.equippable:SetOnUnequip( rabbitOnUnequip )
	
	inst.components.equippable.insulated = true
 
    return inst
end
return  Prefab("common/inventory/cultist_headacc_rabbit", rabbitfn, assets)
