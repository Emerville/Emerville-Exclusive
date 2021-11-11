local assets =
{
    Asset("ANIM", "anim/player_ghost_withhat.zip"),
    Asset("ANIM", "anim/infernal_build.zip"),
    Asset("SOUND", "sound/ghost.fsb"),
}

local prefabs =
{
    "shadow_despawn",
}


SetSharedLootTable('infernalboss',
{
    {'shadowbatenemy',  1.0},
    {'nightmarefuel',  1.0},
    {'nightmarefuel',  1.0},
    {'nightmarefuel',  1.0},
	{'nightmarefuel',   0.50},
	{'nightmarefuel',   0.5}, 
--	{'witch_hat',   0.75},
--	{'scythe',   0.25},	
})


local brain = require "brains/offghostbrain"


local bombchance = 0.25
local function SetTarget(inst, data)
	local victim = data.target
	    if math.random() < bombchance then
       SpawnPrefab("shadow_despawn").Transform:SetPosition(victim.Transform:GetWorldPosition())
    end
end

local function AbleToAcceptTest(inst, item)
    return false, item.prefab == "reviver" and "GHOSTHEART" or nil
end

local function RememberLocation(inst)
    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
end


local counterattack = 0.07
local function OnAttacked(inst, data)
      inst.components.combat:SetTarget(data.attacker)
	 if math.random() < counterattack then
	 

   
   
   	 local pt = inst:GetPosition()
            local numtentacles = 1



           
         inst:StartThread(function()
                for k = 1, numtentacles do
                
                    local theta = math.random() * 2 * PI
                    local radius = math.random(3, 8)

                   
                    local result_offset = FindValidPositionByFan(theta, radius, 3, function(offset)
                        local pos = pt + offset
                        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 1)
                        return next(ents) == nil
                    end)

                    if result_offset ~= nil then
                        local pos = pt + result_offset
                        local tentacle = SpawnPrefab("ghost")
                        tentacle.OFFSPELLCASTER = inst
                        tentacle.Transform:SetPosition(pos:Get())
						SpawnPrefab("statue_transition_2").Transform:SetPosition(tentacle.Transform:GetWorldPosition())
						tentacle.components.combat:SetTarget(data.attacker)

                    end

                    Sleep(.20)
                end
            end)
			
            return true
	   
   
end
end

local function OnIsDay(inst, isday)
    if not isday then
	
	else

    end
end


local function OnInit(inst)
    inst:WatchWorldState("isday", OnIsDay)
    OnIsDay(inst, TheWorld.state.isday)
end


local criticalhit = 0.10
local function OnHitOther(inst, other, damage)
    SpawnPrefab("impact").Transform:SetPosition(other.Transform:GetWorldPosition())
    SpawnPrefab("shadow_despawn").Transform:SetPosition(other.Transform:GetWorldPosition())
        if other and other.components.sanity then
        other.components.sanity:DoDelta(-10)
    end

    if math.random() < criticalhit then
        SpawnPrefab("shadow_despawn").Transform:SetPosition(other.Transform:GetWorldPosition())
    end	
end

local function retargetfn(inst)
    if not inst.components.health:IsDead() then
        return FindEntity(inst, TUNING.FROG_TARGET_DIST, function(guy) 
            if not guy.components.health:IsDead() then
                return guy.components.inventory ~= nil
            end
        end,
        {"_combat","_health"} -- see entityreplica.lua
        )
    end
end

	
local function SpawnAnimation(inst)
    SpawnPrefab("shadow_despawn").Transform:SetPosition(inst.Transform:GetWorldPosition())
    SpawnPrefab("statue_transition_2").Transform:SetPosition(inst.Transform:GetWorldPosition())
    SpawnPrefab("spawnlight_multiplayer").Transform:SetPosition(inst.Transform:GetWorldPosition())
    SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function spawnchest(inst)
    SpawnPrefab("shadow_despawn").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_smoke")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, 1.5)
    RemovePhysicsColliders(inst)
    inst.Physics:SetCollisionGroup(COLLISION.SANITY)
    inst.Physics:CollidesWith(COLLISION.SANITY)    

    inst.AnimState:SetBloomEffectHandle("shaders/anim_bloom_ghost.ksh")
    inst.AnimState:SetLightOverride(TUNING.GHOST_LIGHT_OVERRIDE)

    inst.Light:SetIntensity(.6)
    inst.Light:SetRadius(.5)
    inst.Light:SetFalloff(.6)
    inst.Light:Enable(true)
    inst.Light:SetColour(1, 1, 1)
	
    inst.AnimState:SetBank("ghost")
    inst.AnimState:SetBuild("infernal_build")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetMultColour(1, 1, 1, 0.5)

    inst:AddTag("infernalboss")
	inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("ghost")
	inst:AddTag("immune")
    inst:AddTag("noauradamage")
     --   inst:AddTag("shadow")
    inst:AddTag("notraptrigger")

    inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl_LP", "howl")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.Transform:SetScale(2, 2, 2)
    inst:SetBrain(brain)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2
    inst.components.locomotor.runspeed = 2
    inst.components.locomotor.directdrive = true

    inst:SetStateGraph("SGoffghost")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_LARGE

    inst:AddComponent("inspectable")
	
	inst:AddComponent("knownlocations")
	inst:DoTaskInTime(0, RememberLocation)
		    inst:DoTaskInTime(0, OnInit)
	
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(3000)
	
    inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable('infernalboss')
	
	inst:ListenForEvent("death", spawnchest)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(35)
    inst.components.combat:SetAttackPeriod(TUNING.FROG_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, retargetfn)
	inst.components.combat:SetAttackPeriod(2)
	inst.components.combat:SetRange(2.5)
	inst.components.combat.onhitotherfn = OnHitOther
	
    inst:ListenForEvent("newcombattarget", SetTarget)

    inst:DoTaskInTime(0, SpawnAnimation)
    inst:ListenForEvent("attacked", OnAttacked)

  --  inst:AddComponent("aura")
  --  inst.components.aura.radius = 2
   -- inst.components.aura.tickperiod = 1.5

    --Added so you can attempt to give hearts to trigger flavour text when the action fails
    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(AbleToAcceptTest)
	
	return inst
end

return Prefab("infernalboss", fn, assets)