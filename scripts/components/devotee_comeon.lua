local Devotee_Comeon = Class(function(self, inst)
    self.inst = inst
end)

function Devotee_Comeon:Command(doer)
	if doer == nil then return	end
	if self.inst.components.follower then
		if self.inst.components.follower.leader ~= doer then
			self.inst.components.follower:SetLeader(doer)
		else
			self.inst.components.follower:SetLeader(nil)
		end
	end
end

return Devotee_Comeon