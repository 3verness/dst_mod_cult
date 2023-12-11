local Curseshoti_Master = Class(function(self, inst)
    self.inst = inst
	self.master = nil
end)

function Curseshoti_Master:SetMaster(master)
	self.master = master
end

return Curseshoti_Master