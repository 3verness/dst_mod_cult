local assets=
{
	Asset("ANIM", "anim/lambcrown.zip"),
	Asset("ANIM", "anim/swap_redcrown_cotl.zip"),
	
    Asset("ATLAS", "images/inventoryimages/lambcrown.xml"),	
	Asset("IMAGE", "images/inventoryimages/lambcrown.tex"),	
}

local function OnDropped(inst)
    --inst.SoundEmitter:PlaySound("undyne/undyne/dogsong")
	local x, y, z = inst.Transform:GetWorldPosition()
    local range = 5
    local ents = TheSim:FindEntities(x, y, z, range, nil, { "INLIMBO"})
    for i, v in ipairs(ents) do
        if v ~= inst and v:IsValid() and not v:IsInLimbo() then
            if v:HasTag("founderofreligionlamb") and v:HasTag("player") then
				local crown_follower = SpawnPrefab("crown_f")
    			crown_follower.Transform:SetPosition(inst.Transform:GetWorldPosition())
    			SpawnPrefab("maxwell_smoke").Transform:SetPosition(inst.Transform:GetWorldPosition())
    			crown_follower.components.follower:SetLeader(v)
				crown_follower.sg:GoToState("okiagari")
    			v.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_appear")
				inst:DoTaskInTime(0.1, function() inst:Remove() end)
				inst:RemoveEventCallback("ondropped", OnDropped)
			end
        end
    end
	
end
--equip ability
local function crownability(inst) 
    local owner = inst.components.inventoryitem.owner
	if owner.components.health then
		owner.components.health:DeltaPenalty(-0.01) 
		owner.components.health:DoDelta(3)
	end
end

local function on_off_use1(owner, inst)
    owner.components.inventory:Equip(SpawnPrefab("lambcrown_arms_knife"), nil, inst:GetPosition())
    inst:DoTaskInTime(0, inst.Remove)
end

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", "swap_redcrown_cotl", "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")
        
    if owner:HasTag("player") then
		owner.AnimState:Show("HEAD")
		owner.AnimState:Show("HEAD_HAT")
		owner.AnimState:Show("HAIR_HAT")
	end
	
	inst.crownheal = inst:DoPeriodicTask (10,crownability)
	
	inst:AddComponent("crown_change")
    inst.components.crown_change:ModeChange(on_off_use1)
end

local function OnUnequip(inst, owner) 
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

	if owner:HasTag("player") then
	    owner.AnimState:Show("HEAD")
		owner.AnimState:Hide("HEAD_HAT")
	end
	
		if inst.crownheal ~= nil then
        inst.crownheal:Cancel()
        inst.crownheal = nil
	end
	
	inst:RemoveComponent("crown_change")
	
end

 local function fn() 
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
	--Zimen otita toki no gazou
    inst.AnimState:SetBank("lambcrown")
    inst.AnimState:SetBuild("lambcrown")
    inst.AnimState:PlayAnimation("lambcrown_idle")
	
	--Bousi wo teigi
	inst:AddTag("hat")
	inst:AddTag("nosteal")
	
	--Obake tatti dekiru
	MakeHauntableLaunch(inst)
 
	--Setumei miru yatu
    inst:AddComponent("inspectable")
    --Inbe arutoki no gazou
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "lambcrown"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/lambcrown.xml"
	inst.components.inventoryitem.keepondrown = true
	inst.components.inventoryitem.keepondeath = true
	
    inst.components.inventoryitem.canonlygoinpocket = true
	inst:AddComponent("curseditem")
	inst.components.curseditem.curse = "LAMB"
	
	MakeInventoryFloatable(inst, "med", nil, 0.75)
	
	--inst:ListenForEvent("ondropped", OnDropped)
	
	--Soubi kanouna aitemu toiu kizyutu
    inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
	inst.components.equippable.walkspeedmult = 1.5
 
    return inst
end
return  Prefab("common/inventory/lambcrown", fn, assets)
