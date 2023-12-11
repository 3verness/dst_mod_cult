require "behaviours/follow"
require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/panic"
require "behaviours/findfarmplant"
require "behaviours/chaseandattack"

local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 3
local TARGET_FOLLOW_DIST = 5

local MAX_WANDER_DIST = 20

local function IsTauntable(inst, target)
    return target.components.combat ~= nil
        and not target.components.combat:TargetIs(inst)
        and target.components.combat:CanTarget(inst)
end

local SHADOWCREATURE_MUST_TAGS = { "hostile", "_combat", "locomotor" }
local SHADOWCREATURE_CANT_TAGS = { "INLIMBO", "notaunt" }
local function FindShadowCreatures(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 10, SHADOWCREATURE_MUST_TAGS, SHADOWCREATURE_CANT_TAGS)
    for i = #ents, 1, -1 do
        if not IsTauntable(inst, ents[i]) then
            table.remove(ents, i)
        end
    end
    return #ents > 0 and ents or nil
end

local function TauntCreatures(self)
    local taunted = false
    if self._targets ~= nil then
        for i, v in ipairs(self._targets) do
            if IsTauntable(self.inst, v) then
                v.components.combat:SetTarget(self.inst)
                taunted = true
            end
        end
    end
    if taunted then
        self.inst.sg:GoToState("taunt")
    end
end

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function GetFollowPos(inst)
    return inst.components.follower.leader and inst.components.follower.leader:GetPosition() or
        inst:GetPosition()
end

local function FujinHunger(inst)
    return inst.components.follower.leader ~= nil
        
end

local function FindLeader(inst)
    return inst.components.follower.leader
end

local Crown_fBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function NoLeader(inst)
    inst.components.health:Kill()
	inst:AddTag("Noleader")
	inst:DoTaskInTime(1, function()
		SpawnPrefab("maxwell_smoke").Transform:SetPosition(inst.Transform:GetWorldPosition()) 
		inst:Remove()
	end)
end

function Crown_fBrain:OnStart()
    local root =
    PriorityNode(
    {
		ChaseAndAttack(self.inst, 5),
        --Wander(self.inst, GetFollowPos, MAX_WANDER_DIST),
    }, .25)
    self.bt = BT(self.inst, root)
end

return Crown_fBrain