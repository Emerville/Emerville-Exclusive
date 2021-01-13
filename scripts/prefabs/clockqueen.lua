local clockwork_common = require"prefabs/clockwork_common"

local assets =
{
    Asset("ANIM", "anim/clockqueen.zip"),
    Asset("ANIM", "anim/clockqueen_build.zip"),
    Asset("SOUND", "sound/chess.fsb"),
    Asset("SCRIPT", "scripts/prefabs/clockwork_common.lua"),
}

local prefabs =
{
    "clockqueen_charge",
	"lightning_rod_fx",
	"lavalight",
    "gears",	
    "purplegem",
}

local brain = require "brains/bishopbrain"

SetSharedLootTable('clockqueen',
{
	{'gears',			 1.00},
	{'gears',			 1.00},
	{'gears',			 1.00},
	{'gears',			 1.00},
	{'gears',			 1.00},
	{'gears',			 1.00},
	{'purplegem',	     1.00},
	{'purplegem',	     1.00},
	{'purplegem',		 1.00},		
})

local function CalcSanityAura(inst, observer)
    return inst.components.combat.target ~= nil and -TUNING.SANITYAURA_HUGE or -TUNING.SANITYAURA_LARGE
end

local function ShouldSleep(inst)
    return clockwork_common.ShouldSleep(inst)
end

local function ShouldWake(inst)
    return clockwork_common.ShouldWake(inst)
end

local function Retarget(inst)
    return clockwork_common.Retarget(inst, TUNING.BISHOP_TARGET_DIST)
end

local function KeepTarget(inst, target)
    return clockwork_common.KeepTarget(inst, target)
end

local function CounterSurge(inst)		
    local pt = Vector3(inst.Transform:GetWorldPosition())
    local numtentacles = 20
    
	inst:StartThread(function()
        for k = 1, numtentacles do
        
            local theta = math.random() * 2 * PI
            local radius = math.random(3, 8)

            -- we have to special case this one because birds can't land on creep
            local result_offset = FindValidPositionByFan(theta, radius, 10, function(offset)
                local pos = pt + offset
                local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 1)
                return next(ents) == nil
            end)
			
			--[[Frog ondeathfn]]--			
			local function DoExplosion(inst)
				inst.AnimState:PlayAnimation("disappear")
				if inst.components.combat then
					inst.components.combat:GetAttacked(inst, 50)--kill the star
				end
				inst.SoundEmitter:KillSound("hiss")
				inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
				SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
				local x,y,z = inst.Transform:GetWorldPosition()
				local ents = TheSim:FindEntities(x, y, z, 10, nil, { "INLIMBO", "playerghost", "chess" }) 
				for i,v in pairs(ents) do
					if v.components.combat then
						v.components.combat:GetAttacked(inst, 20)
					end
				end
			end

            if result_offset ~= nil then
                local pos = pt + result_offset
                local frog = SpawnPrefab("stafflight")
				frog.Transform:SetPosition(pos.x, pos.y, pos.z) 
				frog.Transform:SetRotation(math.random(360))
				--frog.sg:GoToState("fall")
				frog.Transform:SetScale(1.25,1.25,1.25)
				MakeCharacterPhysics(frog, 50, .5)
				frog.Physics:Teleport(pos.x, 20, pos.z)
				frog:RemoveComponent("heater")
				frog:RemoveComponent("timer")
				frog:RemoveComponent("cooker")
				frog:RemoveComponent("propagator")
				frog:RemoveComponent("sanityaura")
				frog:AddComponent("timer")
				frog.components.timer:StartTimer("extinguish", 1.0)
				frog:ListenForEvent("timerdone", DoExplosion)
				frog:ListenForEvent("death", DoExplosion)
            end

            Sleep(.01)
        end
    end)
    return true
end

local counterattack = 0.06
local function OnAttacked(inst, data)
   clockwork_common.OnAttacked(inst, data)
		if math.random() < counterattack then
        SpawnPrefab("moose_nest_fx_idle").Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:DoTaskInTime(1, CounterSurge)		
    end	
end

--[[local criticalhit = 0.10
local function OnHitOther(inst, other, damage)
    inst.components.thief:StealItem(other)
        if math.random() < criticalhit then
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
    end
end]]

local function EquipWeapon(inst)
    if inst.components.inventory ~= nil and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local weapon = CreateEntity()
        --[[Non-networked entity]]
        weapon.entity:AddTransform()
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(inst.components.combat.defaultdamage)
        weapon.components.weapon:SetRange(inst.components.combat.attackrange, inst.components.combat.attackrange+4)
        weapon.components.weapon:SetProjectile("clockqueen_charge")
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(inst.Remove)
        weapon:AddComponent("equippable")
        
        inst.components.inventory:Equip(weapon)
    end
end

local function dospawnchest(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")

    local chest = SpawnPrefab("schest")
    local x, y, z = inst.Transform:GetWorldPosition()
    chest.Transform:SetPosition(x, 0, z)

    local fx = SpawnPrefab("sparks")
    if fx ~= nil then
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(1, 2, 1)
    end

    fx = SpawnPrefab("lavalight")
    if fx ~= nil then
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(1, 1.5, 1)
    end

    chest:AddComponent("scenariorunner")
    chest.components.scenariorunner:SetScript("chest_tech")
    chest.components.scenariorunner:Run()
end

local function spawnchest(inst)
    inst:DoTaskInTime(3, dospawnchest)
end

local function RememberKnownLocation(inst)
    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
end

local function common_fn(build, tag)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .5)

	inst.Transform:SetFourFaced()
    inst.DynamicShadow:SetSize(1.5, .75)

    inst.AnimState:SetBank("bishop")
    inst.AnimState:SetBuild("clockqueen_build")

	inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("chess")	
    inst:AddTag("clockqueen")
	inst:AddTag("scarytoprey")	

    if tag ~= nil then
        inst:AddTag(tag)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Transform:SetScale(1.5, 1.5, 1.5)
    inst:AddComponent("lootdropper")
	
	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aurafn = CalcSanityAura	

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.BISHOP_WALK_SPEED

    inst:SetStateGraph("SGbishop")
    inst:SetBrain(brain)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetResistance(3)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "waist"
    inst.components.combat:SetAttackPeriod(1)
    inst.components.combat:SetRange(TUNING.BISHOP_ATTACK_DIST)
    inst.components.combat:SetRetargetFunction(4, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
	
--	inst.components.combat.onhitotherfn = OnHitOther

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(8000)
    inst.components.combat:SetDefaultDamage(40)
    inst.components.combat:SetAttackPeriod(1)

    --[[local light = inst.entity:AddLight()
    inst.Light:Enable(false)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(0/0,0/0,255/255)]]-- 

	inst:AddComponent( "childspawner" )
	inst.components.childspawner:SetRegenPeriod(TUNING.TOTAL_DAY_TIME*math.random(2,3))
	inst.components.childspawner:SetSpawnPeriod(10)
	inst.components.childspawner:SetMaxChildren(4)
	inst.components.childspawner:StartRegen()
	inst.components.childspawner.childname = "mechabat"
    inst.components.childspawner:StartSpawning()
	
	--[[local rot_spawn_list =
	{
		"eel",
		"poop",
		"poop",
		"pigskin",
		"drumstick",
	}]]
	
	--[[inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("eel")
    inst.components.periodicspawner:SetRandomTimes(TUNING.TOTAL_DAY_TIME*2, TUNING.TOTAL_DAY_TIME)
    inst.components.periodicspawner:SetDensityInRange(4, 2)
    inst.components.periodicspawner:SetMinimumSpacing(24)
    inst.components.periodicspawner:Start()]]
	
    inst:ListenForEvent("death", spawnchest)
	
    inst:AddComponent("inventory")

--	inst:AddComponent("thief")
	
    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:DoTaskInTime(0, RememberKnownLocation)

    inst:AddComponent("follower")

    inst:ListenForEvent("attacked", OnAttacked)

    EquipWeapon(inst)

    return inst
end

local function bishop_fn()
    local inst = common_fn("clockqueen_build")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.lootdropper:SetChanceLootTable('clockqueen')
    inst.kind = ""
    inst.soundpath = "dontstarve/creatures/bishop/"
    inst.effortsound = "dontstarve/creatures/bishop/idle"

    return inst
end

return Prefab("forest/animals/clockqueen", bishop_fn, assets, prefabs)
