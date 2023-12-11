local assets =
{
    Asset("ANIM", "anim/tarotcard_leshy.zip"),
	Asset("ANIM", "anim/tarotcard_shamura.zip"),
	Asset("ANIM", "anim/tarotcard_kallamar.zip"),
	Asset("ANIM", "anim/tarotcard_heket.zip"),
	Asset("ANIM", "anim/tarotcard_narinder.zip"),
	
	Asset("ANIM", "anim/tarotcard_fx.zip"),
	
    Asset("ATLAS", "images/inventoryimages/tarotcardheket.xml"),
    Asset("IMAGE", "images/inventoryimages/tarotcardheket.tex"),	
	
	Asset("ATLAS", "images/inventoryimages/tarotcardkallamar.xml"),
    Asset("IMAGE", "images/inventoryimages/tarotcardkallamar.tex"),	
	
	Asset("ATLAS", "images/inventoryimages/tarotcardleshy.xml"),
    Asset("IMAGE", "images/inventoryimages/tarotcardleshy.tex"),	
	
	Asset("ATLAS", "images/inventoryimages/tarotcardnarinder.xml"),
    Asset("IMAGE", "images/inventoryimages/tarotcardnarinder.tex"),	
	
	Asset("ATLAS", "images/inventoryimages/tarotcardshamura.xml"),
    Asset("IMAGE", "images/inventoryimages/tarotcardshamura.tex"),	
}

local function OnDropped(inst)
    SpawnPrefab("maxwell_smoke").Transform:SetPosition(inst.Transform:GetWorldPosition())
	--[[local x, y, z = inst.Transform:GetWorldPosition()
    local range = 2
    local ents = TheSim:FindEntities(x, y, z, range, nil, { "INLIMBO"})
    for i, v in ipairs(ents) do
        if v ~= inst and v:IsValid() and not v:IsInLimbo() then
            if v:HasTag("founderofreligionlamb") and v:HasTag("player") and v.components.tarotenchant then
				v.components.tarotenchant:GetTime()
    			SpawnPrefab("maxwell_smoke").Transform:SetPosition(v.Transform:GetWorldPosition())
    			crown_follower.components.follower:SetLeader(v)
				crown_follower.sg:GoToState("okiagari")
    			v.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_appear")
				inst:DoTaskInTime(0.1, function() inst:Remove() end)
				inst:RemoveEventCallback("ondropped", OnDropped)
			end
        end
    end]]
    inst:Remove()
end

local function checktime(inst, owner)
	local owner = inst.components.inventoryitem.owner
	if owner ~= nil then
		if owner.components.tarotenchant then
			local currentfuel = owner.components.tarotenchant:GetTime()
			inst.components.finiteuses:SetUses(math.max(math.min(currentfuel, 480), 0))
			if currentfuel == 0 then
				inst:Remove()
				owner.components.tarotenchant:Tarot_Clear()
			end
		end
	end
end

local function regentime(inst, owner)
	local owner = inst.components.inventoryitem.owner
	if owner ~= nil then
		if owner.components.tarotenchant then
			if owner.components.health then
				if not owner.components.health:IsDead() then
					owner.components.health:DoDelta(10)
				end
			end
			if owner.components.sanity then
				if not owner.components.health:IsDead() then
					owner.components.sanity:DoDelta(20)
				end
			end
		end
	end
end

local function refreshtime(inst, owner)
	local owner = inst.components.inventoryitem.owner
	if owner ~= nil then
		if owner.components.temperature then
			owner.components.temperature:SetTemperature(TUNING.BOOK_TEMPERATURE_AMOUNT)
		end
		if owner.components.moisture then
        	owner.components.moisture:SetMoistureLevel(0)
		end
	end
end

--Shamura Vacuum

local function vacuum(inst)
    local owner = inst.components.inventoryitem.owner
    local x, y, z = owner.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 3, { "_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
    for i, v in ipairs(ents) do
        if v.components.inventoryitem ~= nil and
            v.components.inventoryitem.canbepickedup and
            v.components.inventoryitem.cangoincontainer and
            not v.components.inventoryitem:IsHeld() and
            owner.components.inventory:CanAcceptCount(v, 1) > 0 then

            --Amulet will only ever pick up items one at a time. Even from stacks.
            SpawnPrefab("sand_puff").Transform:SetPosition(v.Transform:GetWorldPosition())

            local v_pos = v:GetPosition()
            if v.components.stackable ~= nil then
                v = v.components.stackable:Get()
            end

            if v.components.trap ~= nil and v.components.trap:IsSprung() then
                v.components.trap:Harvest(owner)
            else
                owner.components.inventory:GiveItem(v, nil, v_pos)
            end
            return
        end
    end
end

local function vacuum_onoff(inst)
    local owner = inst.components.inventoryitem.owner
	if inst.task_vacuum == nil then
		inst.task_vacuum = inst:DoPeriodicTask(.25, vacuum)
	else
        inst.task_vacuum:Cancel()
        inst.task_vacuum = nil
	end
	inst.components.useableitem:StopUsingItem()
end

-- Shamura

local function OnPutInInventory(inst)
    local owner = inst.components.inventoryitem.owner
	if owner.components.tarotenchant_enchant_shamura == false then
		local shamura_devil = SpawnPrefab("shamura_devil")
		shamura_devil.Transform:SetPosition(inst.Transform:GetWorldPosition())
		owner.components.tarotenchant_enchant_shamura = true
    	SpawnPrefab("maxwell_smoke").Transform:SetPosition(inst.Transform:GetWorldPosition())
    	shamura_devil.components.follower:SetLeader(owner)
		shamura_devil.sg:GoToState("okiagari")
    	owner.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_appear")
	end
end

local function GetStatus(inst)
    return inst.respawntask ~= nil and "WAITING" or nil
end

function crown_reborn(inst, haunter)
	inst:DoTaskInTime(0, inst.Remove)
	inst:PushEvent("respawnfromghost", { source = inst })
    return true
end

local function leshyfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("tarotcard_leshy")
    inst.AnimState:SetBuild("tarotcard_leshy")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "tarotcardleshy"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/tarotcardleshy.xml"	
	
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(480)
    inst.components.finiteuses:SetUses(0)
	
	inst:DoPeriodicTask(.5,checktime)
	inst:DoPeriodicTask(5,regentime)
	
	inst:ListenForEvent("ondropped", OnDropped)
	

    MakeHauntableLaunch(inst)

    return inst
end

local function heketfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("tarotcard_heket")
    inst.AnimState:SetBuild("tarotcard_heket")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "tarotcardheket"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/tarotcardheket.xml"	
	
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(480)
    inst.components.finiteuses:SetUses(0)
	
	inst:DoPeriodicTask(.5,checktime)
	
	inst:ListenForEvent("ondropped", OnDropped)
	

    MakeHauntableLaunch(inst)

    return inst
end

local function kallamarfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("tarotcard_kallamar")
    inst.AnimState:SetBuild("tarotcard_kallamar")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "tarotcardkallamar"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/tarotcardkallamar.xml"	
	
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(480)
    inst.components.finiteuses:SetUses(0)
	
	inst:DoPeriodicTask(.5,checktime)
	inst:DoPeriodicTask(.5,refreshtime)
	
	inst:ListenForEvent("ondropped", OnDropped)
	

    MakeHauntableLaunch(inst)

    return inst
end

local function shamurafn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("tarotcard_shamura")
    inst.AnimState:SetBuild("tarotcard_shamura")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "tarotcardshamura"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/tarotcardshamura.xml"	
	--inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(480)
    inst.components.finiteuses:SetUses(0)
	
	inst:DoPeriodicTask(.5,checktime)
	
	inst:AddComponent("shamura_use")
	inst.task_vacuum = inst:DoPeriodicTask(.25, vacuum)
	
	inst:ListenForEvent("ondropped", OnDropped)
	

    MakeHauntableLaunch(inst)

    return inst
end

local function narinderfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("tarotcard_narinder")
    inst.AnimState:SetBuild("tarotcard_narinder")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "tarotcardnarinder"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/tarotcardnarinder.xml"	
	
	inst:AddComponent("hauntable")
    inst.components.hauntable:SetOnHauntFn(crown_reborn)
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)

    --MakeHauntableLaunch(inst)

    return inst
end

local function fx_leshyfn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
	inst.AnimState:SetBank("tarotcard_fx")
    inst.AnimState:SetBuild("tarotcard_fx")
    inst.AnimState:PlayAnimation("drawcard_0")
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

local function fx_heketfn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
	inst.AnimState:SetBank("tarotcard_fx")
    inst.AnimState:SetBuild("tarotcard_fx")
    inst.AnimState:PlayAnimation("drawcard_1")
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

local function fx_kallamarfn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
	inst.AnimState:SetBank("tarotcard_fx")
    inst.AnimState:SetBuild("tarotcard_fx")
    inst.AnimState:PlayAnimation("drawcard_2")
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

local function fx_shamurafn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
	inst.AnimState:SetBank("tarotcard_fx")
    inst.AnimState:SetBuild("tarotcard_fx")
    inst.AnimState:PlayAnimation("drawcard_3")
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

local function fx_narinderfn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
	inst.AnimState:SetBank("tarotcard_fx")
    inst.AnimState:SetBuild("tarotcard_fx")
    inst.AnimState:PlayAnimation("drawcard_4")
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

return Prefab("tarotcard_leshy", leshyfn, assets),
Prefab("tarotcard_shamura", shamurafn, assets),
Prefab("tarotcard_kallamar", kallamarfn, assets),
Prefab("tarotcard_heket", heketfn, assets),
Prefab("tarotcard_narinder", narinderfn, assets),
Prefab("tarotcard_fx_leshy", fx_leshyfn, assets),
Prefab("tarotcard_fx_shamura", fx_shamurafn, assets),
Prefab("tarotcard_fx_kallamar", fx_kallamarfn, assets),
Prefab("tarotcard_fx_heket", fx_heketfn, assets),
Prefab("tarotcard_fx_narinder", fx_narinderfn, assets)