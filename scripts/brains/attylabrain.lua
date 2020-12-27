require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"

local STOP_RUN_DIST = 0
local SEE_PLAYER_DIST = 1

local STOP_MONSTER_RUN_DIST = 5
local SEE_MONSTER_DIST = 6

local AVOID_PLAYER_DIST = 1
local AVOID_PLAYER_STOP = 1

local AVOID_MONSTER_DIST = 3
local AVOID_MONSTER_STOP = 4

local MIN_FOLLOW = 0
local MAX_FOLLOW = 5
local MED_FOLLOW = 3

local SEE_BAIT_DIST = 3
local MAX_WANDER_DIST = 6


local AttylaBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function ShouldRunAway(guy)
    return not (guy:HasTag("character") or
                guy:HasTag("attyla") or
                guy:HasTag("notarget") or
				guy:HasTag("nightmarecreature"))
        and (guy:HasTag("scarytoprey") or
			guy:HasTag("merm") or
			guy:HasTag("monkey") or
			guy:HasTag("catcoon"))
end

local function EatFoodAction(inst)

    local target = FindEntity(inst, SEE_BAIT_DIST, function(item) return inst.components.eater:CanEat(item) and item.components.bait and not item:HasTag("planted") and not (item.components.inventoryitem and item.components.inventoryitem:IsHeld()) end)
    if target then
        local act = BufferedAction(inst, target, ACTIONS.EAT)
        act.validfn = function() return not (target.components.inventoryitem and target.components.inventoryitem:IsHeld()) end
        return act
    end
end


function AttylaBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.hauntable and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
		Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW, MED_FOLLOW, MAX_FOLLOW, true), -- follow us
		RunAway(self.inst, ShouldRunAway, AVOID_MONSTER_DIST, AVOID_MONSTER_STOP), -- avoid anything that could kill me
        RunAway(self.inst, ShouldRunAway, SEE_MONSTER_DIST, STOP_MONSTER_RUN_DIST),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST),
		DoAction(self.inst, EatFoodAction),
    }, .25)
    self.bt = BT(self.inst, root)
end

return AttylaBrain
