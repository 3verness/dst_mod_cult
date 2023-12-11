local CrownMode = Class(function(self, inst)
    self.inst = inst
end)

function CrownMode:Magic(pos, caster)
    local meteorcost = 10
	if caster ~= nil and caster.components.sanity.current >= meteorcost then
        caster.curseshot = SpawnPrefab("curseshot_handfx")
		caster.curseshot.attacker = caster
		caster.curseshot.entity:AddFollower()
		caster.curseshot.Follower:FollowSymbol(caster.GUID, "swap_object", 0, 0, 0)
		caster:DoTaskInTime(0.2,function()
	    caster.sg:GoToState("hammer")
	    caster.SoundEmitter:PlaySound("dontstarve/wilson/hit")
		local meteor = SpawnPrefab("curseshot")
        meteor.Transform:SetPosition(pos:Get())
		meteor:AddComponent("curseshot_master")
		meteor.components.curseshot_master:SetMaster(caster)
		if caster.components.sanity ~= nil then
            caster.components.sanity:DoDelta(-meteorcost)
        end
		end)
		return true
    end
end

function CrownMode:Target(doer, target)
	if doer == nil then return end
	if target == nil then return end
	local meteorcost = 10
	if target.components.workable or target.components.fishable then
		if doer.components.inventory then
			local item = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			item:Remove()
		end
		
		if target.components.workable then		
			if target.components.workable:GetWorkAction() == ACTIONS.CHOP then
				doer.components.inventory:Equip(SpawnPrefab("lambcrown_arms_axe"), nil, doer:GetPosition())
			end
			if target.components.workable:GetWorkAction() == ACTIONS.MINE then
				doer.components.inventory:Equip(SpawnPrefab("lambcrown_arms_picaxe"), nil, doer:GetPosition())
			end
			if target.components.workable:GetWorkAction() == ACTIONS.HAMMER then
				doer.components.inventory:Equip(SpawnPrefab("lambcrown_arms_hammer"), nil, doer:GetPosition())
			end
			if target.components.workable:GetWorkAction() == ACTIONS.DIG then
				doer.components.inventory:Equip(SpawnPrefab("lambcrown_arms_shovel"), nil, doer:GetPosition())
			end
			if target.components.workable:GetWorkAction() == ACTIONS.NET then
				doer.components.inventory:Equip(SpawnPrefab("lambcrown_arms_bugnet"), nil, doer:GetPosition())
			end	
			if target.components.workable:GetWorkAction() == nil then
				doer.components.inventory:Equip(SpawnPrefab("lambcrown_arms_knife"), nil, doer:GetPosition())
			end	
		end	
		
		if target.components.fishable then
			doer.components.inventory:Equip(SpawnPrefab("lambcrown_arms_fishingrod"), nil, doer:GetPosition())
		end
	else
		if doer ~= nil and doer.components.sanity.current >= meteorcost then
        doer.curseshot = SpawnPrefab("curseshot_handfx")
		doer.curseshot.entity:AddFollower()
		doer.curseshot.Follower:FollowSymbol(doer.GUID, "swap_object", 0, 0, 0)
		doer:DoTaskInTime(0.2,function()
	    doer.sg:GoToState("hammer")
	    doer.SoundEmitter:PlaySound("dontstarve/wilson/hit")
		local meteor = SpawnPrefab("curseshot")
		meteor:AddComponent("curseshot_master")
		meteor.components.curseshot_master:SetMaster(doer)
        meteor.Transform:SetPosition(target.Transform:GetWorldPosition())
		if doer.components.sanity ~= nil then
            doer.components.sanity:DoDelta(-meteorcost)
        end
		end)
		end
	
	end
end

return CrownMode
