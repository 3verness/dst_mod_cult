local TarotSet = Class(function(self, inst)
    self.inst = inst
end)
local tarot_time = 480
function TarotSet:DrawCard(doer)
	if doer == nil then return end
	doer.AnimState:PlayAnimation("emote_yawn")
	doer:AddTag("tarot_draw")
	doer.SoundEmitter:PlaySound("dontstarve/common/use_book_light")
	local select_tarot = math.random(1 , 9)
	if select_tarot == 1 or select_tarot == 6 then 
		doer:DoTaskInTime(2.5,function()
		if doer.components.tarotenchant then
			doer.components.tarotenchant.lefttime_taort = tarot_time
			doer.components.inventory:GiveItem(SpawnPrefab("tarotcard_leshy"), nil, doer:GetPosition())
			doer.components.tarotenchant:Tarot_Start() 
			doer.SoundEmitter:PlaySound("dontstarve/common/use_book")
		end
		end)
		if doer._enchantlight == nil or not doer._enchantlight:IsValid() then
        	doer._enchantlight = SpawnPrefab("tarotcard_fx_leshy")
			doer._enchantlight.entity:AddFollower()
			doer._enchantlight.Follower:FollowSymbol(doer.GUID, "swap_body", 0, 50, 0)
    	end
		doer:DoTaskInTime(3.5,function()
		if doer._enchantlight ~= nil then
        	if doer._enchantlight:IsValid() then
        	    doer._enchantlight:Remove()
        	end
        	doer._enchantlight = nil
    	end
		
		end)
	end
	if select_tarot == 2 or select_tarot == 7 then 
		doer:DoTaskInTime(2.5,function()
		if doer.components.tarotenchant then
			doer.components.tarotenchant.lefttime_taort = tarot_time
			doer.components.inventory:GiveItem(SpawnPrefab("tarotcard_heket"), nil, doer:GetPosition())
			doer.components.tarotenchant:Tarot_Start() 
			doer.components.tarotenchant.enchant_heket = true
			doer.SoundEmitter:PlaySound("dontstarve/common/use_book")
		end
		end)
		if doer._enchantlight == nil or not doer._enchantlight:IsValid() then
        	doer._enchantlight = SpawnPrefab("tarotcard_fx_heket")
			doer._enchantlight.entity:AddFollower()
			doer._enchantlight.Follower:FollowSymbol(doer.GUID, "swap_body", 0, 50, 0)
    	end
		doer:DoTaskInTime(3.5,function()
		if doer._enchantlight ~= nil then
        	if doer._enchantlight:IsValid() then
        	    doer._enchantlight:Remove()
        	end
        	doer._enchantlight = nil
    	end
		
		end)
	end
	if select_tarot == 3 or select_tarot == 8 then 
		doer:DoTaskInTime(2.5,function()
		if doer.components.tarotenchant then
			doer.components.tarotenchant.lefttime_taort = tarot_time
			doer.components.inventory:GiveItem(SpawnPrefab("tarotcard_kallamar"), nil, doer:GetPosition())
			doer.components.tarotenchant:Tarot_Start()
			doer.components.tarotenchant.enchant_kallamar = true
			doer.SoundEmitter:PlaySound("dontstarve/common/use_book")
		end
		end)
		if doer._enchantlight == nil or not doer._enchantlight:IsValid() then
        	doer._enchantlight = SpawnPrefab("tarotcard_fx_kallamar")
			doer._enchantlight.entity:AddFollower()
			doer._enchantlight.Follower:FollowSymbol(doer.GUID, "swap_body", 0, 50, 0)
    	end
		doer:DoTaskInTime(3.5,function()
		if doer._enchantlight ~= nil then
        	if doer._enchantlight:IsValid() then
        	    doer._enchantlight:Remove()
        	end
        	doer._enchantlight = nil
    	end
		
		end)
	end
	if select_tarot == 4 or select_tarot == 9 then 
		doer:DoTaskInTime(2.5,function()
		if doer.components.tarotenchant then
			doer.components.tarotenchant.lefttime_taort = tarot_time
			doer.components.inventory:GiveItem(SpawnPrefab("tarotcard_shamura"), nil, doer:GetPosition())
			doer.components.tarotenchant:Tarot_Start()
			local shamura_devil = SpawnPrefab("shamura_devil")
			shamura_devil.Transform:SetPosition(doer.Transform:GetWorldPosition())
    		SpawnPrefab("maxwell_smoke").Transform:SetPosition(doer.Transform:GetWorldPosition())
    		shamura_devil.components.follower:SetLeader(doer)
			shamura_devil.sg:GoToState("okiagari")
    		doer.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_appear")
			doer.SoundEmitter:PlaySound("dontstarve/common/use_book")
		end
		end)
		if doer._enchantlight == nil or not doer._enchantlight:IsValid() then
        	doer._enchantlight = SpawnPrefab("tarotcard_fx_shamura")
			doer._enchantlight.entity:AddFollower()
			doer._enchantlight.Follower:FollowSymbol(doer.GUID, "swap_body", 0, 50, 0)
    	end
		doer:DoTaskInTime(3.5,function()
		if doer._enchantlight ~= nil then
        	if doer._enchantlight:IsValid() then
        	    doer._enchantlight:Remove()
        	end
        	doer._enchantlight = nil
    	end
		
		end)
	end
	if select_tarot == 5 then 
		doer:DoTaskInTime(2.5,function()
		doer.components.inventory:GiveItem(SpawnPrefab("tarotcard_narinder"), nil, doer:GetPosition())
		doer.SoundEmitter:PlaySound("dontstarve/common/use_book")
		end)
		if doer._enchantlight == nil or not doer._enchantlight:IsValid() then
        	doer._enchantlight = SpawnPrefab("tarotcard_fx_narinder")
			doer._enchantlight.entity:AddFollower()
			doer._enchantlight.Follower:FollowSymbol(doer.GUID, "swap_body", 0, 50, 0)
    	end
		doer:DoTaskInTime(3.5,function()
		if doer._enchantlight ~= nil then
        	if doer._enchantlight:IsValid() then
        	    doer._enchantlight:Remove()
        	end
        	doer._enchantlight = nil
    	end
		if doer:HasTag("tarot_draw") then
			doer:RemoveTag("tarot_draw")
		end
		end)
	end
	
end

return TarotSet