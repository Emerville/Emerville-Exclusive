local assets =
{
	Asset("ANIM", "anim/des_river_fishinghole.zip"),
}

local prefabs =
{
	"tropical_fish"
}
local day_time = 60 * 8
local total_day_time = day_time
local wilson_attack = 34
local wilson_health = 150
local calories_per_day = 75

local FISHINGHOLE_MIN_FISH = 3
local FISHINGHOLE_MAX_FISH = 15
local FISHING_HOLE_RESPAWN = total_day_time / 4


local FISH_STATES =
{
	FULL = "full",
	HALF = "half",
	GONE = "gone",
}

local function SetFishState(inst, state)
	inst.fish_state = state
end

local function GetFishState(inst)
	return inst.fish_state
end

local function PlayAnimation(inst, anim, loop)
	local state = inst:GetFishState()
	local anim = anim.."_"..state
	inst.AnimState:PlayAnimation(anim, loop)
end

local function PushAnimation(inst, anim, loop)
	local state = inst:GetFishState()
	local anim = anim.."_"..state
	inst.AnimState:PushAnimation(anim, loop)
end

local function getactiveperiod(inst)
	local activeTime = TUNING.TOTAL_DAY_TIME * 2

	--local sm = GetSeasonManager()
	if TheWorld.state.iswinter then
		activeTime = TUNING.TOTAL_DAY_TIME
	elseif TheWorld.state.issummer then
		activeTime = TUNING.TOTAL_DAY_TIME * 3
	else ---if TheWorld.state.iswinter then
		activeTime = TUNING.TOTAL_DAY_TIME * 2
	end

	return activeTime
end

local function getinactiveperiod(inst)
	local inactiveTime = TUNING.TOTAL_DAY_TIME

	if TheWorld.state.iswinter then
		inactiveTime = TUNING.TOTAL_DAY_TIME * 2
	elseif  TheWorld.state.issummer then
		inactiveTime = TUNING.TOTAL_DAY_TIME * 0.5
	else ---if TheWorld.state.iswinter then
		inactiveTime = TUNING.TOTAL_DAY_TIME
	end

	return inactiveTime
end

local function isbeingfished(inst)
	-- Am I currently being fished or does the player have a buffered action to fish me?
	
	for _, player in pairs(AllPlayers) do
		if inst:GetDistanceSqToInst(player)< 4*4 then
			if player.sg and player.sg.HasStateTag("fishing") then
				return true
			end
		end
	end
	
	return false
end

local function scatter(inst)
	--Somehow make sure that we don't go invisible while the player is actually fishing.
	--Maybe the disapear task checks if the player is fishing, and triggers another disapear task to try again soon.
	if inst.task ~= nil then
		inst.task:Cancel()
	end

	if isbeingfished(inst) then
		inst.scatterTime = GetTime() + 2 -- try again in a couple seconds
		inst.task = inst:DoTaskInTime(2, inst.scatter, "scatter")
	else
		inst.regroupTime = getinactiveperiod() + GetTime()
		PlayAnimation(inst, "idle_pst")
		inst.MiniMapEntity:SetEnabled(false)
		inst.active = false
		
		local a = 0.33
		inst:DoTaskInTime(0.33, function()
			inst.AnimState:SetMultColour(a,a,a,a)
		end)
		local a = 0
		inst:DoTaskInTime(1, function()
			inst.AnimState:SetMultColour(a,a,a,a)
			inst:AddTag("NOCLICK")
		end)		

		inst.task = inst:DoTaskInTime(getinactiveperiod(), inst.regroup, "regroup")
		--inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/fish_scatter")
	end
end

local function regroup(inst)
	if inst.task ~= nil then
		inst.task:Cancel()
	end

	inst.scatterTime = getactiveperiod() + GetTime()
	PlayAnimation(inst, "idle_pre")
	PushAnimation(inst, "idle_loop", true)
	inst.MiniMapEntity:SetEnabled(true)
	inst.active = true
	
		local a = 0.66
		inst:DoTaskInTime(0.33, function()
			inst.AnimState:SetMultColour(a,a,a,a)
		end)
		local a = 1
		inst:DoTaskInTime(1, function()
			inst.AnimState:SetMultColour(a,a,a,a)
			inst:RemoveTag("NOCLICK")
		end)	
	
	inst.task = inst:DoTaskInTime(getactiveperiod(), inst.scatter, "scatter")
end

local function onlongupdate(inst, dt)

	if inst.task ~= nil then
		inst.task:Cancel()
	end

	local time = GetTime() + dt
	if inst.active then
		if time > inst.scatterTime then
			inst:scatter()
		else
			inst.task = inst:DoTaskInTime(inst.scatterTime - time, inst.scatter, "scatter")
			inst.scatterTime = inst.scatterTime - dt
		end
	else
		if time > inst.regroupTime then
			inst:regroup()
		else
			inst.task = inst:DoTaskInTime(inst.regroupTime - time, inst.regroup, "regroup")
			inst.regroupTime = inst.regroupTime - dt
		end
	end
end

local function onfishdelta(inst)
	local percent = inst.components.fishable:GetFishPercent()

	if percent >= 0.50 then
		inst:SetFishState(FISH_STATES.FULL)
	elseif percent > 0 then
		inst:SetFishState(FISH_STATES.HALF)
	elseif percent <= 0 then
		inst:SetFishState(FISH_STATES.GONE)
	end

	PushAnimation(inst, "idle_loop", true)

	-- if percent <= 0 then
	-- 	scatter(inst)
	-- end
end

local function onsave(inst, data)
	-- body
	if data == nil then
		data = {}
	end
	data.active = inst.active
	data.fish_state = inst:GetFishState()
	if data.active then
		data.timeuntilscatter = inst.scatterTime - GetTime()
		data.timeuntilregroup = nil
	else
		data.timeuntilregroup = inst.regroupTime - GetTime()
		data.timeuntilscatter = nil
	end

end

local function onload(inst, data)

	if data then
		if data.fish_state then
			inst:SetFishState(data.fish_state)
		end
		if data.active then
			inst.active = true
			inst.MiniMapEntity:SetEnabled(true)
			inst.task = inst:DoTaskInTime(data.timeuntilscatter, inst.scatter, "scatter")
			inst.scatterTime = GetTime() + data.timeuntilscatter
		else
			inst.active = false
			PlayAnimation(inst, "idle_pst", false)
			inst.MiniMapEntity:SetEnabled(false)
			inst.task = inst:DoTaskInTime(data.timeuntilregroup, inst.regroup, "regroup")
			inst.regroupTime = GetTime() + data.timeuntilregroup
		end
	end
end

local function oncollide(inst, other)
	if not inst.active then return end
	--check if the player is coming to fish?
    if other:HasTag("player") and other.sg and other.sg:HasStateTag("running") then-- and inst.sg:HasStateTag("idle") then
    	if not isbeingfished(inst) and inst:IsNear(other,3.5) then
    		scatter(inst)
    	end
    end
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
		
    inst.Physics:SetCylinder(4, 2)
	inst.Physics:SetCollides(false) --Still will get collision callback, just not dynamic collisions.
	inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
	inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	--inst.Physics:CollidesWith(COLLISION.WAVES)
	inst.Physics:SetCollisionCallback(oncollide)

	inst:AddTag("aquatic")
    inst.AnimState:SetBuild("des_river_fishinghole")
    inst.AnimState:SetBank("des_river_fishinghole")
    inst.AnimState:SetRayTestOnBB(true)

	inst.AnimState:SetLayer( LAYER_BACKGROUND )
	inst.AnimState:SetSortOrder( 3 )

	local minimap = inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("pond.png")
    inst.MiniMapEntity:SetPriority(1)
	--minimap:SetIcon( "fish2.png" )

	local scale_fish = 0.4 + math.random()*0.1
	inst.Transform:SetScale(scale_fish,scale_fish,scale_fish,scale_fish)

	inst:AddTag("des_river_water_sourse")

	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	
		
    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "pond"
 --   inst.no_wet_prefix = true

	inst:AddComponent("fishable")
	inst.components.fishable:SetRespawnTime(FISHING_HOLE_RESPAWN)
--	inst.components.fishable:AddFish("fish")

	inst.components.fishable.OnFishDelta = onfishdelta
	local numFish = math.random(FISHINGHOLE_MIN_FISH,FISHINGHOLE_MAX_FISH)
	inst.components.fishable.maxfish = numFish
	inst.components.fishable.fishleft = numFish

	inst.active = true
	local activeTime = getactiveperiod()
	local inactiveTime = getinactiveperiod()
	local currentTime = math.random(0,activeTime + inactiveTime)
	local timeLeft

	
	
	inst.regroup = regroup
	inst.scatter = scatter
	inst.GetFishState = GetFishState
	inst.SetFishState = SetFishState
	inst:SetFishState(FISH_STATES.FULL)
	PlayAnimation(inst, "idle_loop", true)

	if currentTime >= activeTime then
		inst.active = false
		currentTime = currentTime - activeTime
		timeLeft = inactiveTime - currentTime
		inst.regroupTime = timeLeft + GetTime()
		inst.task = inst:DoTaskInTime(timeLeft, inst.regroup, "regroup")
		inst.MiniMapEntity:SetEnabled(false)
	else
		timeLeft = activeTime - currentTime
		inst.scatterTime = timeLeft + GetTime()
		inst.task= inst:DoTaskInTime(timeLeft, inst.scatter, "scatter")
	end

	inst.OnLoad = onload
	inst.OnSave = onsave
	inst.OnLongUpdate = onlongupdate

	return inst
end

return Prefab( "ocean/objects/des_river_fishinghole", fn, assets, prefabs)