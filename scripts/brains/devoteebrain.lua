require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/panic"
require "behaviours/follow"
require "behaviours/attackwall"

local DevoteeBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

--Images will help chop, mine and fight.

local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 4
local MAX_FOLLOW_DIST = 6

local START_FACE_DIST = 6
local KEEP_FACE_DIST = 8

local KEEP_WORKING_DIST = 10
local SEE_WORK_DIST = 15

local SEE_FOOD_DIST = 10

local function HasStateTags(inst, tags)
    for i, v in ipairs(tags) do
        if inst.sg:HasStateTag(v) then
            return true
        end
    end
end

local function GetTraderFn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, 20, true)
    for i, v in ipairs(players) do
        if inst.components.trader:IsTryingToTradeWithMe(v) then
            return v
        end
    end
end

local function KeepTraderFn(inst, target)
    return inst.components.trader:IsTryingToTradeWithMe(target)
end

local function KeepWorkingAction(inst, actiontags)
    return inst.components.follower.leader ~= nil
        and inst.components.follower.leader:IsNear(inst, KEEP_WORKING_DIST)
        and HasStateTags(inst.components.follower.leader, actiontags)
end

local function StartWorkingCondition(inst, actiontags)
    return inst.components.follower.leader ~= nil
        and HasStateTags(inst.components.follower.leader, actiontags)
        and not HasStateTags(inst, actiontags)
end

local function FindObjectToWorkAction(inst, action)
    if inst.sg:HasStateTag("working") then
        return
    end
    local target = FindEntity(inst.components.follower.leader, SEE_WORK_DIST, nil, { action.id.."_workable" }, { "INLIMBO" })
    return target ~= nil
        and BufferedAction(inst, target, action)
        or nil
end

local function GetLeader(inst)
    return inst.components.follower.leader
end

local function GetFaceTargetFn(inst)
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)
    return not target:HasTag("notarget") and inst:IsNear(target, KEEP_FACE_DIST)
end

local FINDFOOD_CANT_TAGS = { "outofreach" }
local function FindFoodAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end

    if inst.components.inventory ~= nil and inst.components.eater ~= nil then
        local target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        if target ~= nil then
            return BufferedAction(inst, target, ACTIONS.EAT)
        end
    end

	if inst.components.minigame_spectator ~= nil then
		return
	end

    local time_since_eat = inst.components.eater:TimeSinceLastEating()
    if time_since_eat ~= nil and time_since_eat <= TUNING.PIG_MIN_POOP_PERIOD * 2 then
        return
    end

    local noveggie = time_since_eat ~= nil and time_since_eat < TUNING.PIG_MIN_POOP_PERIOD * 4

    local target = FindEntity(inst,
        SEE_FOOD_DIST,
        function(item)
            return item:GetTimeAlive() >= 8
                and item.prefab ~= "mandrake"
                and item.components.edible ~= nil
				and (item:HasTag("preparedfood") or item:HasTag("pre-preparedfood"))
                and (not noveggie or item.components.edible.foodtype == FOODTYPE.MEAT)
                and item:IsOnPassablePoint()
                and inst.components.eater:CanEat(item)
        end,
        nil,
        FINDFOOD_CANT_TAGS
    )
    if target ~= nil then
        return BufferedAction(inst, target, ACTIONS.EAT)
    end

    target = FindEntity(inst,
        SEE_FOOD_DIST,
        function(item)
            return item.components.shelf ~= nil
                and item.components.shelf.itemonshelf ~= nil
                and item.components.shelf.cantakeitem
                and item.components.shelf.itemonshelf.components.edible ~= nil
                and (not noveggie or item.components.shelf.itemonshelf.components.edible.foodtype == FOODTYPE.MEAT)
                and item:IsOnPassablePoint()
                and inst.components.eater:CanEat(item.components.shelf.itemonshelf)
        end,
        nil,
        FINDFOOD_CANT_TAGS
    )
    if target ~= nil then
        return BufferedAction(inst, target, ACTIONS.TAKEITEM)
    end
end

function DevoteeBrain:OnStart()
    local root = PriorityNode(
    {
        DoAction(self.inst, FindFoodAction ),
		
		FaceEntity(self.inst, GetTraderFn, KeepTraderFn),
		
		WhileNode(function()
                return StartWorkingCondition(self.inst, { "chopping", "prechop" })
                    and KeepWorkingAction(self.inst, { "chopping", "prechop" })
            end,
            "keep chopping",
            DoAction(self.inst, function() return FindObjectToWorkAction(self.inst, ACTIONS.CHOP) end)),

        WhileNode(function()
                return StartWorkingCondition(self.inst, { "mining", "premine" })
                    and KeepWorkingAction(self.inst, { "mining", "premine" })
            end,
            "keep mining",
            DoAction(self.inst, function() return FindObjectToWorkAction(self.inst, ACTIONS.MINE) end)),

        Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        IfNode(function() return GetLeader(self.inst) end, "has leader",
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)),
    }, .25)

    self.bt = BT(self.inst, root)
end

return DevoteeBrain