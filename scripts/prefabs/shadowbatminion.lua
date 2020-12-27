local assets =
{
    Asset("ANIM", "anim/bat_basic.zip"),
    Asset("SOUND", "sound/bat.fsb"),
}

local prefabs =
{
    "guano",
    "batwing",
    "teamleader",
}

local brain = require "brains/batbrain"

SetSharedLootTable( 'shadowbatminion',
{
    {'batwing',    0.05},
})

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


--[[local function OnIsDay(inst, isday)
    if isday then
	
SpawnPrefab("statue_transition_2").Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst:Remove()
    else


    end
end]]

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

local function OnAttacked(inst, data)
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

    MakeGhostPhysics(inst, 1, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    local scaleFactor = 0.75
    inst.Transform:SetScale(scaleFactor, scaleFactor, scaleFactor)

    inst.AnimState:SetBank("bat")
    inst.AnimState:SetBuild("bat_shadowboss")

    inst:AddTag("cavedweller")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("bat")
    inst:AddTag("scarytoprey")
    inst:AddTag("flying")
	
	inst:AddTag("shadow")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
	inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    --inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    --inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor.walkspeed = TUNING.BAT_WALK_SPEED

    inst:SetStateGraph("SGbat")
    inst:SetBrain(brain)

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.MEAT }, { FOODTYPE.MEAT })
    inst.components.eater.strongstomach = true

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.sleeptestfn = NocturnalSleepTest
    inst.components.sleeper.waketestfn = NocturnalWakeTest

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "bat_body"
    inst.components.combat:SetAttackPeriod(TUNING.BAT_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.BAT_ATTACK_DIST)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(100)
    inst.components.combat:SetDefaultDamage(TUNING.BAT_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.BAT_ATTACK_PERIOD)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('shadowbatminion')

    inst:AddComponent("inventory")

	--[[OnIsDay(inst, TheWorld.state.isday)
    inst:WatchWorldState("isday", OnIsDay)]]
    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")
    inst:DoTaskInTime(1*FRAMES, RememberLocation)

    inst:AddComponent("teamattacker")
    inst.components.teamattacker.team_type = "bat"

    inst:ListenForEvent("attacked", OnAttacked)

    MakeHauntablePanic(inst)

    return inst
end

return Prefab("shadowbatminion", fn, assets, prefabs)
