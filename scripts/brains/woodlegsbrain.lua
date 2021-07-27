require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/chattynode"

local BrainCommon = require "brains/braincommon"

local START_RUN_DIST = 3
local STOP_RUN_DIST = 5
local MAX_WANDER_DIST = 10

local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8

local function GoHomeAction(inst)
    if inst.components.homeseeker and 
       inst.components.homeseeker.home and 
       inst.components.homeseeker.home:IsValid() then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end	
end

local WoodlegsBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function WoodlegsBrain:OnStart()
    --print(self.inst, "PigBrain:OnStart")
	
    local day = WhileNode( function() return TheWorld.state.isday end, "IsDay",
        PriorityNode{
            ChattyNode(self.inst, "PIG_TALK_RUN_FROM_SPIDER",
                RunAway(self.inst, "spider", 4, 8)),
			Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST)
        }, 3)

    local night = WhileNode( function() return not TheWorld.state.isday end, "IsNight",
        PriorityNode{
            ChattyNode(self.inst, "PIG_TALK_RUN_FROM_SPIDER",
                RunAway(self.inst, "spider", 4, 8)),
			Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST)
        }, 3)

    local root =
        PriorityNode(
        {
            BrainCommon.PanicWhenScared(self.inst, .25, "PIG_TALK_PANICBOSS"),
            WhileNode( function() return self.inst.components.hauntable and self.inst.components.hauntable.panic end, "PanicHaunted",
                ChattyNode(self.inst, "PIG_TALK_PANICHAUNT",
                    Panic(self.inst))),
            day,
            night,
        }, .5)

    self.bt = BT(self.inst, root)
end

return WoodlegsBrain