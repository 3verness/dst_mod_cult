local GoldenLambStatue = Class(function(self, inst)
    self.inst = inst
	self.devotion = 0
	self.charge = 0
end)

function GoldenLambStatue:SetCharge(amount)
    self.charge = amount
	self.inst:PushEvent("praycharge_check")
end

function GoldenLambStatue:Pray(doer)
	if doer == nil then return end
	if not doer:HasTag("founderofreligionlamb") then
		doer.AnimState:PlayAnimation("emote_swoon")
		self.devotion = math.min(self.devotion + 1, 100)
		if doer:HasTag("devotee") then
			self.devotion = math.min(self.devotion + 1, 100)
		end
		local statuefx = SpawnPrefab("lambstatue_ef")
    	local pt = Vector3(self.inst.Transform:GetWorldPosition()) + Vector3(0, 3, 0)
		statuefx.Transform:SetPosition(pt:Get())
	else
		self.inst:StartThread(function()
		for k = 1, self.devotion do
    	    doer.components.inventory:GiveItem(SpawnPrefab("cultprayer"), nil, doer:GetPosition())	
			Sleep(.05)
    	end
		end)
		self.inst:DoTaskInTime(0.1,function() self.devotion = 0 end)
		doer.AnimState:PlayAnimation("emote_impatient")
		local statuefx = SpawnPrefab("lambstatue_ef2")
    	local pt = Vector3(self.inst.Transform:GetWorldPosition()) + Vector3(0, 3, 0)
		statuefx.Transform:SetPosition(pt:Get())
	end
end

function GoldenLambStatue:OnSave()
	self.devotion = self.devotion or 0
	self.charge = self.charge or 0
	return {
        devotion = self.devotion,
		charge = self.charge
    }
end

function GoldenLambStatue:OnLoad(data)
    self.devotion = data.devotion or 0
	self.charge = data.charge or 0
end

return GoldenLambStatue