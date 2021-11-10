require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/haunted_house.zip"),
}

local prefabs = 
{
    "spiderden",
	"infernalboss",
	"hound",
    "houndcorpse",
}

--For regular tents

local function PlaySleepLoopSoundTask(inst, stopfn)
    inst.SoundEmitter:PlaySound("dontstarve/common/tent_sleep")
end

local function stopsleepsound(inst)
    if inst.sleep_tasks ~= nil then
        for i, v in ipairs(inst.sleep_tasks) do
            v:Cancel()
        end
        inst.sleep_tasks = nil
    end
end

local function startsleepsound(inst, len)
    stopsleepsound(inst)
    inst.sleep_tasks =
    {
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 33 * FRAMES),
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 47 * FRAMES),
    }
end

local function onnear(inst)
    inst.components.childspawner:StartSpawning()
    inst.components.periodicspawner:Start()
               --[[local lightning = SpawnPrefab("collapse_small")
               local hound = SpawnPrefab("hound")
               local player = GetPlayer()
               local player = GetClosestInstWithTag("player", inst, MyRadius)			   
               local pos = player:GetPosition()
               pos.x = pos.x - 4
               pos.z = pos.z - 4
               hound.Transform:SetPosition(pos:Get())      
                lightning.Transform:SetPosition(pos:Get())]]
        inst.AnimState:PlayAnimation("near")
       --inst.Light:Enable(true)

       --SpawnPrefab("spider_dropper").Transform:SetPosition(inst.Transform:GetWorldPosition(0,10,0))
       --SpawnPrefab("ghost").Transform:SetPosition(inst.Transform:GetWorldPosition(0,100,0))
end


local function onfar(inst)
    inst.AnimState:PlayAnimation("far")     
--   inst.Light:Enable(false)
    inst.components.childspawner:StopSpawning()
    inst.components.periodicspawner:Stop()       
end
       
local function ReturnChildren(inst)
	inst.components.childspawner:StopSpawning()
	inst.components.childspawner:StartRegen()  
end

----------------------------------------------------
--[[local function onbuilt(inst)
--	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("near", false)
--    SpawnPrefab("dropperweb")
end]]

local function onignite(inst)
    inst.components.sleepingbag:DoWakeUp()
end

--We don't watch "stop'phase'" because that
--would not work in a clock without 'phase'
local function wakeuptest(inst, phase)
    if phase ~= inst.sleep_phase then
        inst.components.sleepingbag:DoWakeUp()
    end
end

local function onwake(inst, sleeper, nostatechange)
    if inst.sleeptask ~= nil then
        inst.sleeptask:Cancel()
        inst.sleeptask = nil
    end

    inst:StopWatchingWorldState("phase", wakeuptest)
    sleeper:RemoveEventCallback("onignite", onignite, inst)

    if not nostatechange then
        if sleeper.sg:HasStateTag("tent") then
            sleeper.sg.statemem.iswaking = true
        end
        sleeper.sg:GoToState("wakeup")
    end

    if inst.sleep_anim ~= nil then
        inst.AnimState:PushAnimation("far", true)
        stopsleepsound(inst)
    end		
	
    inst.components.finiteuses:Use()
end

local function onsleeptick(inst, sleeper)
    local isstarving = sleeper.components.beaverness ~= nil and sleeper.components.beaverness:IsStarving()

    if sleeper.components.hunger ~= nil then
        sleeper.components.hunger:DoDelta(inst.hunger_tick, true, true)
        isstarving = sleeper.components.hunger:IsStarving()
    end

    if sleeper.components.sanity ~= nil and sleeper.components.sanity:GetPercentWithPenalty() < 1 then
        sleeper.components.sanity:DoDelta(TUNING.SLEEP_SANITY_PER_TICK, true)
    end

    if not isstarving and sleeper.components.health ~= nil then
        sleeper.components.health:DoDelta(TUNING.SLEEP_HEALTH_PER_TICK * 2, true, inst.prefab, true)
    end

    if sleeper.components.temperature ~= nil then
        if inst.is_cooling then
            if sleeper.components.temperature:GetCurrent() > TUNING.SLEEP_TARGET_TEMP_TENT then
                sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() - TUNING.SLEEP_TEMP_PER_TICK)
            end
        elseif sleeper.components.temperature:GetCurrent() < TUNING.SLEEP_TARGET_TEMP_TENT then
            sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() + TUNING.SLEEP_TEMP_PER_TICK)
        end
    end

    if isstarving then
        inst.components.sleepingbag:DoWakeUp()
    end
end


local function onsleep(inst, sleeper)
    inst:WatchWorldState("phase", wakeuptest)
    sleeper:ListenForEvent("onignite", onignite, inst)

    if inst.sleep_anim ~= nil then
        inst.AnimState:PlayAnimation(inst.sleep_anim, true)
        startsleepsound(inst, inst.AnimState:GetCurrentAnimationLength())
    end

    if inst.sleeptask ~= nil then
        inst.sleeptask:Cancel()
    end
    inst.sleeptask = inst:DoPeriodicTask(TUNING.SLEEP_TICK_PERIOD, onsleeptick, nil, sleeper)
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddLight()	
    inst.entity:AddNetwork()	
	
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(6.5)	
    inst.Light:SetColour(235/255,121/255,12/255)
    inst.Light:Enable(true)    

	inst:AddTag("tent") 	
    inst:AddTag("structure")
    inst:AddTag("light")
	
    inst.AnimState:SetBank("haunted_house")
    inst.AnimState:SetBuild("haunted_house")
    inst.AnimState:PlayAnimation("far")
    
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("haunted_house.tex")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	
	
    inst:AddComponent("inspectable")	
	
	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED   
	
	inst:AddComponent("childspawner")
	inst.components.childspawner:SetMaxChildren(3)
	inst.components.childspawner.childname = "spider_moon"
	inst.components.childspawner:SetRegenPeriod(30)

    inst.entity:AddGroundCreepEntity()
    inst.GroundCreepEntity:SetRadius(8)

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("infernalboss")
    inst.components.periodicspawner:SetRandomTimes(30,45)
    inst.components.periodicspawner:SetDensityInRange(30, 5)
    inst.components.periodicspawner:SetMinimumSpacing(60)
    --inst.components.periodicspawner:Start()
	
	inst.sleep_phase = "night"
    inst.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK
    --inst.is_cooling = false
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(1000)
    inst.components.finiteuses:SetUses(1000)
    inst.components.finiteuses:SetOnFinished(inst.Remove)	    
		    
	inst:AddComponent("sleepingbag")
	inst.components.sleepingbag.onsleep = onsleep
    inst.components.sleepingbag.onwake = onwake
    --convert wetness delta to drying rate
    inst.components.sleepingbag.dryingrate = math.max(0, -TUNING.SLEEP_WETNESS_PER_TICK / TUNING.SLEEP_TICK_PERIOD)
    
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(10,17)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)
	
--	inst:ListenForEvent("onbuilt", onbuilt)

    return inst
end

return Prefab("common/haunted_house", fn, assets, prefabs),
	   MakePlacer("common/haunted_house_placer", "haunted_house", "haunted_house", "far") 