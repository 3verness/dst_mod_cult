local TarotEnchant = Class(function(self, inst)
    self.inst = inst
	
	self.enchant_heket = false
	self.enchant_kallamar = false
	self.enchant_shamura = false
	
	self.started_speed = false
	self.started_light = false
	
	self.lefttime_taort = 0
	
end)

--taort
function TarotEnchant:GetTime()
	return self.lefttime_taort
end

function TarotEnchant:Cultist_SetLefttime(amount)
    self.lefttime_taort = amount
end

function TarotEnchant:Heket_Start()
    self.inst.components.combat.externaldamagemultipliers:SetModifier(self.inst, 2, "heket")
end

function TarotEnchant:Heket_Clear()
	self.inst.components.combat.externaldamagemultipliers:RemoveModifier(self.inst, "heket")
end

local function EmitLightLight(inst, self)
    local lightlight = SpawnPrefab("lamblight")
	if lightlight then
        local follower = lightlight.entity:AddFollower()
        follower:FollowSymbol(self.inst.GUID, "swap_body", 0,0,1)
    end
end

function TarotEnchant:Kallamar_Start()
    if self.started_speed == false then
		self.started_speed = true
		if self.inst.components.locomotor then
			self.inst.components.locomotor.runspeed = self.inst.components.locomotor.runspeed * 1.5
			self.inst.components.locomotor.walkspeed = self.inst.components.locomotor.walkspeed * 1.5
		end
	end
	if self.started_light == false then
		self.started_light = true
		if self.lightlighttask == nil then
			self.lightlighttask = self.inst:DoPeriodicTask(1, EmitLightLight, nil, self)
		end
	end
end

function TarotEnchant:Kallamar_Clear()
	if self.started_speed == true then
		self.started_speed = false
		if self.inst.components.locomotor then
			self.inst.components.locomotor.runspeed = self.inst.components.locomotor.runspeed / 1.5
			self.inst.components.locomotor.walkspeed = self.inst.components.locomotor.walkspeed / 1.5
		end
	end
	if self.started_light == true then
		self.started_light = false
		if self.lightlighttask ~= nil then
        	self.lightlighttask:Cancel()
            self.lightlighttask = nil
        end
	end
	
end

function TarotEnchant:Tarot_Clear()
	if self.task_taort ~= nil then
        self.task_taort:Cancel()
        self.task_taort = nil
    end
	self.lefttime_taort = 0
	self:Heket_Clear()
	self:Kallamar_Clear()
	self.enchant_heket = false
	self.enchant_kallamar = false
	if self.inst:HasTag("tarot_draw") then
		self.inst:RemoveTag("tarot_draw")
	end
end

function TarotEnchant:Tarot_Start()
	self.task_taort = self.inst:DoPeriodicTask(1, function()
	self.lefttime_taort = (math.max(self.lefttime_taort - 1, 0))
	if self.lefttime_taort <= 0 then
		self:Tarot_Clear()
	end
	if self.enchant_heket == true then
		if not self.inst.components.inventory:Has("tarotcard_heket", 1) then
			self:Heket_Clear()
		else
			self:Heket_Start()
		end
	end
	if self.enchant_kallamar == true then
		if not self.inst.components.inventory:Has("tarotcard_kallamar", 1) then
			self:Kallamar_Clear()
		else
			self:Kallamar_Start()
		end
	end
	end)
	if not self.inst:HasTag("tarot_draw") then
		self.inst:AddTag("tarot_draw")
	end
	--self.inst:DoTaskInTime(0.1,function() if self.lefttime_taort < 1 then self:Tarot_Clear() end end)
	
end

function TarotEnchant:OnSave()
	self.lefttime_taort = self.lefttime_taort or 0
	self.enchant_heket = self.enchant_heket or false
	self.enchant_kallamar = self.enchant_kallamar or false
	self.enchant_shamura = self.enchant_shamura or false
	return {
        lefttime_taort = self.lefttime_taort,
		enchant_heket = self.enchant_heket,
		enchant_kallamar = self.enchant_kallamar,
		enchant_shamura = self.enchant_shamura,
    }
end

function TarotEnchant:OnLoad(data)
    self.lefttime_taort = data.lefttime_taort or 0
	self.enchant_heket = data.enchant_heket or false
	self.enchant_kallamar = data.enchant_kallamar or false
	self.enchant_shamura = data.enchant_shamura or false
	
	self.inst:DoTaskInTime(0.1,function()
	if self.lefttime_taort > 0 then
		self:Tarot_Start()
		self.inst:DoTaskInTime(0.1,function()self:Cultist_SetLefttime(self.lefttime_taort) end)
	end
	end)
end

return TarotEnchant