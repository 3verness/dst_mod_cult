local CultPrayer = Class(function(self, inst)
    self.inst = inst
end)

function CultPrayer:Eating(doer, invobject)
	if doer == nil then return end
	if invobject == nil then return end
	
	--[[local pop_ef = SpawnPrefab("prayer_ef")
	pop_ef.Transform:SetPosition(doer.Transform:GetWorldPosition())]]
	
	if doer.components.health then
		doer.components.health:DoDelta(5)
	end
	if doer.components.sanity then
		doer.components.sanity:DoDelta(30)
	end
	if doer.components.cultenchant then
		doer.components.cultenchant:Cultist_Enchant()
	end
	if invobject.components.stackable ~= nil then
        invobject.components.stackable:Get():Remove()
    else
        invobject:Remove()
    end
end

return CultPrayer