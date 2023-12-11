local CultEnchant = Class(function(self, inst)
    self.inst = inst
	
	self.enchant_cultist = false
	
	self.lefttime_cultist = 0
	
end)

--cultist
function CultEnchant:Cultist_SetLefttime(amount)
    self.lefttime_cultist = amount
end

local function onattack(inst, data, self)
    local target = data.target
	target:DoTaskInTime(0.1, function()
	if target and inst.components.health and not inst.components.health:IsDead() and target.components.health and not target.components.health:IsDead() and target.components.combat then
		target.components.combat:GetAttacked(inst, 30, nil)
		local spark =SpawnPrefab("enchanthit")
		spark.Transform:SetPosition(target.Transform:GetWorldPosition())
		spark.Transform:SetScale(1, 1, 1)
	end
	end)
end

function CultEnchant:Cultist_Warning()
	if self.inst._enchantlight ~= nil then
        if self.inst._enchantlight:IsValid() then
            self.inst._enchantlight.AnimState:PlayAnimation("idle_fast",true)
        end
    end
end

function CultEnchant:Cultist_Clear()
	if self.inst._enchantlight ~= nil then
        if self.inst._enchantlight:IsValid() then
            self.inst._enchantlight:Remove()
        end
        self.inst._enchantlight = nil
    end
	
	--self.inst:RemoveEventCallback("onattackother", onattack, self.inst)
	if self.task_cultist ~= nil then
        self.task_cultist:Cancel()
        self.task_cultist = nil
    end
	self.lefttime_cultist = 0
	self.enchant_cultist = false
end

function CultEnchant:Cultist_Start()
    if self.inst._enchantlight == nil or not inst._enchantlight:IsValid() then
        self.inst._enchantlight = SpawnPrefab("prayer_ef")
		self.inst._enchantlight.entity:AddFollower()
		self.inst._enchantlight.Follower:FollowSymbol(self.inst.GUID, "swap_body", 0, 100, 0)
    end
	--self.inst:ListenForEvent("onattackother", onattack)
	self.task_cultist = self.inst:DoPeriodicTask(1, function()
	self.lefttime_cultist = self.lefttime_cultist - 1
	if self.lefttime_cultist <= 0 then
		self:Cultist_Clear()
	end
	end)
	self.lefttime_cultist = 90
	self.enchant_cultist = true
end

function CultEnchant:Cultist_Enchant()
	self.inst:DoTaskInTime(0.0,function()
		self:Cultist_Clear()
	end)
	self.inst:DoTaskInTime(0.1,function()
		self:Cultist_Start()
	end)
end

function CultEnchant:OnSave()
	self.lefttime_cultist = self.lefttime_cultist or 0
	return {
        lefttime_cultist = self.lefttime_cultist,
		lefttime_heart = self.lefttime_heart,
		lefttime_tetonus = self.lefttime_tetonus,
		armor_mount = self.armor_mount
    }
end

function CultEnchant:OnLoad(data)
    self.lefttime_cultist = data.lefttime_cultist or 0
	
	self.inst:DoTaskInTime(0.1,function()
	if self.lefttime_cultist > 0 then
		self:Cultist_Start()
		self.inst:DoTaskInTime(0.1,function()self:Cultist_SetLefttime(self.lefttime_cultist) end)
	end
	end)
end

return CultEnchant