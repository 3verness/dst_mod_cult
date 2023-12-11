local Clown_Change = Class(function(self, inst)
    self.inst = inst
	self.modefn = nil
end)

function Clown_Change:ModeChange(fn)
	self.modefn = fn
end

function Clown_Change:ChangeMode(doer, invobject)
	if self.modefn ~= nil then
		self.modefn(doer, invobject)
	end
end

return Clown_Change