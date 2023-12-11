local assets =
{
    Asset("ANIM", "anim/swap_lambcrown_arms.zip"),
	Asset("ANIM", "anim/swap_lambcrown_picaxe_anm.zip"),
	Asset("ANIM", "anim/curseshot.zip"),
	
    Asset("ATLAS", "images/inventoryimages/lambcrown_arms_knife.xml"),
    Asset("IMAGE", "images/inventoryimages/lambcrown_arms_knife.tex"),	
}

local attack_damage = 23

local function on_off_use1(owner, inst)
    owner.components.inventory:Equip(SpawnPrefab("lambcrown"), nil, inst:GetPosition())
    inst:DoTaskInTime(0, inst.Remove)
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_lambcrown_arms", "swap_lambcrown_knife")
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

local function onattack(inst, attacker, target)
    local slash = SpawnPrefab("crown_knife_ef")
    local pt = Vector3(target.Transform:GetWorldPosition()) + Vector3(math.random() * 2 - 1, 1 + math.random() * 2 - 1, 0.5)
	slash.Transform:SetPosition(pt:Get())
	inst:DoTaskInTime(0.2,function()
	if target ~= nil and target:IsValid() and attacker ~= nil and attacker:IsValid() then
        local slash = SpawnPrefab("crown_knife_ef")
        local pt = Vector3(target.Transform:GetWorldPosition()) + Vector3(math.random() * 2 - 1, 1 + math.random() * 2 - 1, 0.5)
        slash.Transform:SetPosition(pt:Get())
		local total_attack = attack_damage * attacker.components.combat.damagemultiplier
		target.components.combat:GetAttacked(attacker, total_attack, nil)
    end
	end)
	inst:DoTaskInTime(0.4,function()
	if target ~= nil and target:IsValid() and attacker ~= nil and attacker:IsValid() then
        local slash = SpawnPrefab("crown_knife_ef")
        local pt = Vector3(target.Transform:GetWorldPosition()) + Vector3(math.random() * 2 - 1, 1 + math.random() * 2 - 1,0.5)
        slash.Transform:SetPosition(pt:Get())
		local total_attack = attack_damage * attacker.components.combat.damagemultiplier
		target.components.combat:GetAttacked(attacker, total_attack, nil)
    end
	end)
	inst:DoTaskInTime(0.6,function()
	if attacker.components.cultenchant and attacker.components.cultenchant.enchant_cultist == true and
	target ~= nil and target:IsValid() and attacker ~= nil and attacker:IsValid() then
        local slash = SpawnPrefab("crown_knife_ef")
        local pt = Vector3(target.Transform:GetWorldPosition()) + Vector3(math.random() * 2 - 1, 1 + math.random() * 2 - 1, 0.5)
        slash.Transform:SetPosition(pt:Get())
		local total_attack = attack_damage * attacker.components.combat.damagemultiplier
		target.components.combat:GetAttacked(attacker, total_attack, nil)
    end
	end)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("lambcrown_arms")
    inst.AnimState:SetBuild("lambcrown")
    inst.AnimState:PlayAnimation("equip_knife")

    inst:AddTag("sharp")
	inst:AddTag("nosteal")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(attack_damage)
	inst.components.weapon:SetOnAttack(onattack)
	
	--[[inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP)
    inst.components.tool:SetAction(ACTIONS.MINE)]]
	
	inst:AddComponent("crownmode")

    -------
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "lambcrown_arms_knife"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/lambcrown_arms_knife.xml"
	inst.components.inventoryitem.keepondrown = true
	inst.components.inventoryitem.keepondeath = true
	
    inst.components.inventoryitem.canonlygoinpocket = true
	-- inst:AddComponent("curseditem")
	-- inst.components.curseditem.curse = "LAMB"
	
	MakeInventoryFloatable(inst, "med", nil, 0.75)
	
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst.components.equippable.walkspeedmult = 1.5

    MakeHauntableLaunch(inst)

    return inst
end

local function crown_knife_effn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    --MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("curseshot")
    inst.AnimState:SetBuild("curseshot")
    inst.AnimState:PlayAnimation("knifeslash")
	
	inst:AddTag("FX")
	inst:DoTaskInTime(.36, inst.Remove)

    --inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function curseshot_handfxfn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
	inst.AnimState:SetBank("curseshot")
    inst.AnimState:SetBuild("curseshot")
    inst.AnimState:PlayAnimation("handsigil")
	inst.Transform:SetScale(1, 1, 1)
	inst:DoTaskInTime(0.5, inst.Remove)

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

return Prefab("lambcrown_arms_knife", fn, assets),
Prefab("crown_knife_ef", crown_knife_effn, assets),
Prefab("curseshot_handfx", curseshot_handfxfn, assets)