local assets =
{
    Asset("ANIM", "anim/bat_basic.zip"),
	Asset("ANIM", "anim/bat_shadowboss.zip"),
	
    Asset("SOUND", "sound/bat.fsb"),
}

local prefabs =
{
    "guano",
    "batwing",
    "teamleader",
	"infernalboss",
--	"dubloon",
	"taffy",
	"chocolatebar",
	"scythe",
}

local brain = require "brains/batbrain"

--------------------------------------------------------------------------

SetSharedLootTable( "darkbat",
{
    {'startcandyburst', 1},
	{'batwing', 1},
    {'batwing', 1},
	{'nightmarefuel', 1},	
    {'nightmarefuel', 0.50},
    {'nightmarefuel', 0.50},
--  {'witch_hat', 0.50}, --2019
--  {'scythe', 0.25},	--2019
	{'broomstick', 0.75}, --2020
	{'witch_hat', 0.25}, --2020
 	
    --{'shadowstaff_blueprint', 1},	
})
--------------------------------------------------------------------------

local function PushMusic(inst)
    if ThePlayer ~= nil and ThePlayer:IsNear(inst, 30) then
        ThePlayer:PushEvent("triggeredevent", { name = "shadowchess" })
    end
end

local function OnMusicDirty(inst)
    --Dedicated server does not need to trigger music
    if not TheNet:IsDedicated() then
        if inst._music:value() then
            if inst._musictask == nil then
                inst._musictask = inst:DoPeriodicTask(1, PushMusic, 0)
            end
        elseif inst._musictask ~= nil then
            inst._musictask:Cancel()
            inst._musictask = nil
        end
    end
end

local function StartMusic(inst)
    if not (inst._music:value() or inst.components.health:IsDead()) then
        inst._music:set(true)
        OnMusicDirty(inst)
    end
end

local function StopMusic(inst)
    if inst._music:value() then
        inst._music:set(false)
        OnMusicDirty(inst)
    end
end

--------------------------------------------------------------------------

local SLEEP_DIST_FROMHOME = 1
local SLEEP_DIST_FROMTHREAT = 20
local MAX_CHASEAWAY_DIST = 80
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40

local function MakeTeam(inst, attacker)
    local leader = SpawnPrefab("teamleader")
    leader.components.teamleader:SetUp(attacker, inst)
    leader.components.teamleader:BroadcastDistress(inst)
end

local function Retarget(inst)
    local ta = inst.components.teamattacker

    local newtarget = FindEntity(inst, TUNING.BAT_TARGET_DIST, function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        nil,
        {"bat"},
        {"character", "monster"}
    )

    if newtarget and not ta.inteam and not ta:SearchForTeam() then
        MakeTeam(inst, newtarget)
    end

    if ta.inteam and not ta.teamleader:CanAttack() then
        return newtarget
    end
end

local function KeepTarget(inst, target)
    if (inst.components.teamattacker.inteam and not inst.components.teamattacker.teamleader:CanAttack())
        or inst.components.teamattacker.orders == ORDERS.ATTACK then
        return true
    else
        return false
    end 
end

local function RemoveCooldown(inst)
inst:RemoveTag("cooldownhit")
end

local function CounterSurge(inst)

 local pt = inst:GetPosition()
            local numtentacles = 6



           
         inst:StartThread(function()
                for k = 1, numtentacles do
                
                    local theta = math.random() * 2 * PI
                    local radius = math.random(3, 8)

                   
                    local result_offset = FindValidPositionByFan(theta, radius, 6, function(offset)
                        local pos = pt + offset
                        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 0.1)
                        return next(ents) == nil
                    end)

                    if result_offset ~= nil then
                        local pos = pt + result_offset
                        local tentacle = SpawnPrefab("batdamageability")
                        tentacle.Transform:SetPosition(pos:Get())
                    end

                    Sleep(.20)
                end
            end)
			
            return true
	   


end


local function BatSpawn(inst)

 local pt = inst:GetPosition()
            local numtentacles = 3



           
         inst:StartThread(function()
                for k = 1, numtentacles do
                
                    local theta = math.random() * 2 * PI
                    local radius = math.random(3, 8)

                   
                    local result_offset = FindValidPositionByFan(theta, radius, 6, function(offset)
                        local pos = pt + offset
                        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 0.1)
                        return next(ents) == nil
                    end)

                    if result_offset ~= nil then
                        local pos = pt + result_offset
                        local tentacle = SpawnPrefab("shadowbatminion")
						if tentacle ~= nil then 
                        tentacle.Transform:SetPosition(pos:Get())
				SpawnPrefab("statue_transition_2").Transform:SetPosition(tentacle.Transform:GetWorldPosition())
				end
                    end

                    Sleep(.20)
                end
            end)
			
            return true
	   


end



local counterattack = 0.10
local function OnAttacked(inst, data)
-----------------------------------------------	
 if not inst:HasTag("spawnedbats") and inst.components.health.currenthealth >= 1899 then
 	   	 inst:AddTag("spawnedbats")
		 	 inst.sg:GoToState("taunt")

   inst:DoTaskInTime(1, BatSpawn)	
 else


   end

   -----------------------------------------------	
if math.random() < counterattack and not inst:HasTag("cooldownhit") then

	 inst.sg:GoToState("taunt")

   inst:DoTaskInTime(2, CounterSurge)	
   
   else
   
 end
	

-----------------------------------------------	
 if inst:HasTag("cooldownhit") then
 
 else
 	 inst:AddTag("cooldownhit")
	 		    inst:DoTaskInTime(1.5, RemoveCooldown)	
 end
		 
-----------------------------------------------			 
 --StartMusic(inst)
    if not inst.components.teamattacker.inteam and not inst.components.teamattacker:SearchForTeam() then
        MakeTeam(inst, data.attacker)
    elseif inst.components.teamattacker.teamleader then
        inst.components.teamattacker.teamleader:BroadcastDistress(inst)   --Ask for  help!
    end

    if inst.components.teamattacker.inteam and not inst.components.teamattacker.teamleader:CanAttack() then
        local attacker = data and data.attacker
        inst.components.combat:SetTarget(attacker)
        inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("bat") end, MAX_TARGET_SHARES)
    end
end

local function RememberLocation(inst)
    inst.components.knownlocations:RememberLocation("home", Vector3(inst.Transform:GetWorldPosition()))
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
	
    --MakeCharacterPhysics(inst, 10, PHYS_RADIUS[name])
    --RemovePhysicsColliders(inst)
    --inst.Physics:SetCollisionGroup(COLLISION.SANITY)
    --inst.Physics:CollidesWith(COLLISION.SANITY)
    --inst.Physics:CollidesWith(COLLISION.WORLD)	

    MakeGhostPhysics(inst, 1, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    local scaleFactor = 1.5
    inst.Transform:SetScale(scaleFactor, scaleFactor, scaleFactor)
	
    inst:AddTag("cavedweller")
    inst:AddTag("monster")
    inst:AddTag("hostile")
	inst:AddTag("notraptrigger")
    inst:AddTag("bat")
    inst:AddTag("scarytoprey")
    inst:AddTag("flying")
	inst:AddTag("shadow")
	
    inst.AnimState:SetBank("bat")
    inst.AnimState:SetBuild("bat_shadowboss")
	
	inst._music = net_bool(inst.GUID, "shadowchesspiece._music", "musicdirty")	
	  
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	

    inst:AddComponent("locomotor")
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor.walkspeed = TUNING.BAT_WALK_SPEED
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
	
    inst:AddComponent("inspectable")	
	
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(3000)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.BAT_DAMAGE* 2.5)
    inst.components.combat:SetAttackPeriod(TUNING.BAT_ATTACK_PERIOD*1.5)	
    inst.components.combat.hiteffectsymbol = "bat_body"
    inst.components.combat:SetAttackPeriod(TUNING.BAT_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.BAT_ATTACK_DIST)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)	

    inst:AddComponent("explosiveresist")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("darkbat")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("epicscare")
    inst.components.epicscare:SetRange(TUNING.SHADOW_CHESSPIECE_EPICSCARE_RANGE)

    inst:ListenForEvent("attacked", OnAttacked)	
    inst:ListenForEvent("death", StopMusic)	

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.MEAT }, { FOODTYPE.MEAT })
    inst.components.eater.strongstomach = true

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.sleeptestfn = NocturnalSleepTest
    inst.components.sleeper.waketestfn = NocturnalWakeTest

    inst:AddComponent("inventory")
    inst.sounds =
    {
        --common sounds
        death = "dontstarve/sanity/death_pop",
        --levelup = "dontstarve/sanity/transform/two",
		
    }
	--inst.sounds.attacktimeline = "dontstarve/sanity/bishop/taunt"
    --inst.sounds.deathtimeline = "dontstarve/sanity/death_pop"
    --inst.sounds.idle = "dontstarve/sanity/bishop/idle"
    --inst.sounds.taunt = "dontstarve/sanity/bishop/dissappear"
    --inst.sounds.disappear = "dontstarve/sanity/bishop/dissappear"
    --inst.sounds.hittimeline = "dontstarve/sanity/bishop/hit_response"

    inst:AddComponent("knownlocations")
    inst:DoTaskInTime(1*FRAMES, RememberLocation)
	
    inst:AddComponent("teamattacker")
    inst.components.teamattacker.team_type = "shadowbatenemy"
	
    inst:SetStateGraph("SGshadowbatenemy")
    inst:SetBrain(brain)

    MakeHauntablePanic(inst)	

    return inst
end

return Prefab("shadowbatenemy", fn, assets, prefabs)
