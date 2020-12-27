require("stategraphs/commonstates")



local events =
{
    CommonHandlers.OnLocomote(true, true),
    EventHandler("doattack", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then inst.sg:GoToState("attack") end end),
    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("attack") then
            inst.sg:GoToState("hit")
        end
    end),
	EventHandler("death", function(inst) inst.sg:GoToState("dissipate") end),
}

local function getidleanim(inst)
     if inst.components.combat.target or inst.components.combat.attacker then
        return "angry"
    elseif inst.components.health:GetPercent() < .25 then
        return "shy"
    else
        return "idle"
    end
end

local states =
{
    State
    {
        name = "idle",
        tags = {"idle", "canrotate", "canslide"},
        onenter = function(inst)

            inst.AnimState:PlayAnimation(getidleanim(inst), true)
        end,
    },
    
    State
    {
        name = "appear",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("appear")
            if inst:HasTag("girl") then
                inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_girl_howl")
            else
                inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                  
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },    
    
	 State{
        name = "attack",
        tags = {"attack", "canrotate", "canslide"},
        
        onenter = function(inst, cb)
         
            inst.components.combat:StartAttack()
						    inst.Physics:Stop()
             inst.AnimState:PlayAnimation("dissipate")


        end,
        
        timeline=
        {
          
            TimeEvent(10*FRAMES, function(inst) inst.components.combat:DoAttack() inst.sg:RemoveStateTag("attack") inst.sg:RemoveStateTag("busy") end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("appear") end),
        },
    },
	
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            if inst:HasTag("girl") then
                inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_girl_howl")
            else
                inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl")
            end

            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()            
        end,
        
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "haunted",
        tags = {"busy"},
        
        onenter = function(inst)
            if inst:HasTag("girl") then
                inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_girl_attack_LP", "haunted")
            else
                inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_attack_LP", "haunted")
            end
                
            inst.AnimState:PlayAnimation("angry")
            inst.Physics:Stop()            
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("haunted")
        end
    },

    State
    {
        name = "dissipate",
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("dissipate")
            if inst:HasTag("girl") then
                inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_girl_howl")
            else
                inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl")
            end
            
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.components.lootdropper then
                        inst.components.lootdropper:DropLoot()
                    end
                    inst:PushEvent("detachchild")
                    inst:Remove()
                end
            end)
        },
    },
}

CommonStates.AddSimpleWalkStates(states, getidleanim)
CommonStates.AddSimpleRunStates(states, getidleanim)
    
return StateGraph("ghost", states, events, "appear")