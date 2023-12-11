local Shamura_Use = Class(function(self, inst)
    self.inst = inst
end)

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

function Shamura_Use:OnOff(doer, invobject)
	if doer == nil then return end
	if invobject == nil then return end
	
	if invobject.task_vacuum == nil then
		invobject.task_vacuum = invobject:DoPeriodicTask(.25, vacuum)
	else
        invobject.task_vacuum:Cancel()
        invobject.task_vacuum = nil
	end
end

return Shamura_Use