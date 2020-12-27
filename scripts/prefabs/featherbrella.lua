require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/featherbrella.zip"),
	
	Asset("ATLAS", "images/inventoryimages/featherbrella.xml"),
	Asset("IMAGE", "images/inventoryimages/featherbrella.tex"),
}

local prefabs = 
{
	"collapse_small",
	"featherbrellahammerchecker",
}
--------------------------------

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hammered")
	--if TheWorld.state.issnowcovered then
    --    inst.AnimState:PushAnimation("snow", true)
	--else
		inst.AnimState:PushAnimation("idle", true)
	--end
end

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()	
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	SpawnPrefab("collapse_small").Transform:SetScale(2, 2, 2)
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("building")
	--if TheWorld.state.issnowcovered then
    --    inst.AnimState:PushAnimation("snow", true)
	--else
		inst.AnimState:PushAnimation("idle", true)
	--end
	inst.SoundEmitter:PlaySound("dontstarve/common/tent_craft")
end
	
local loot = {"featherbrellahammerchecker"}

----------------------------------

local function fn()
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
	inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

	MakeObstaclePhysics(inst, .20)
	inst.DynamicShadow:SetSize(5, 5)
	
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("featherbrella.tex")	
	
    inst:AddTag("structure")
	inst:AddTag("shelter")
	inst:AddTag("dryshelter")
	inst:AddTag("featherbrella")
	
    inst.AnimState:SetBank("featherbrella")
    inst.AnimState:SetBuild("featherbrella")
	--if TheWorld.state.issnowcovered then
    --    inst.AnimState:PlayAnimation("snow", true)
	--else
		inst.AnimState:PlayAnimation("idle", true)
	--end
	
	MakeSnowCovered(inst)	

    inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot(loot)
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
	
	inst:AddComponent("playerprox")
	inst.components.playerprox:SetDist(2, 2)
	
	inst:ListenForEvent("onbuilt", onbuilt)
	
	inst:DoPeriodicTask(1/10, function() 
	
	local pt = Vector3(inst.Transform:GetWorldPosition())
--------------------------------FIRST TABLE - GOING IN UMBRELLA'S RANGE------------------------------------------
    local range = 2
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, range)
	
    for k, v in pairs(ents) do
       if v ~= nil and inst.components.playerprox.isclose == true then
		-- We gotta check in case there's a character who has inherentwaterproofness set to a custom value
		-- Though, I check values based on tuning.lua
		-- Cuz I dun care if you're getting 0.10 waterproofness more or less, it's good enough as is
		
        if v.components.moisture and v.components.moisture.inherentWaterproofness == 0 then
			v:AddTag("featherbrelled")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_ABSOLUTE)
		elseif v.components.moisture and v.components.moisture.inherentWaterproofness > 0 and v.components.moisture.inherentWaterproofness <= 0.2 then
			v:AddTag("featherbrelled02")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_ABSOLUTE)
		elseif v.components.moisture and v.components.moisture.inherentWaterproofness > 0.2 and v.components.moisture.inherentWaterproofness <= 0.35 then
			v:AddTag("featherbrelled035")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_ABSOLUTE)
		elseif v.components.moisture and v.components.moisture.inherentWaterproofness > 0.35 and v.components.moisture.inherentWaterproofness <= 0.5 then
			v:AddTag("featherbrelled05")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_ABSOLUTE)
		elseif v.components.moisture and v.components.moisture.inherentWaterproofness > 0.5 and v.components.moisture.inherentWaterproofness <= 0.7 then
			v:AddTag("featherbrelled07")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_ABSOLUTE)
		elseif v.components.moisture and v.components.moisture.inherentWaterproofness > 0.7 and v.components.moisture.inherentWaterproofness <= 0.9 then
			v:AddTag("featherbrelled09")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_ABSOLUTE)
		elseif v.components.moisture and v.components.moisture.inherentWaterproofness > 0.9 and v.components.moisture.inherentWaterproofness < 1 then
			v:AddTag("featherbrelled1")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_ABSOLUTE)
		end
	   end
	   -- If character's temperature is higher than 63 and it's summer, then lower body temperature
	   -- Yes, it's kinda dumb that it also lowers your temperature from fires but I don't care
	   -- Regular player wouldn't even notice
		if v ~= nil and v.components.temperature and v.components.temperature.current > 63 and TheWorld.state.issummer then
			v.components.temperature.current = v.components.temperature.current - 0.1
		end
	   
    end
	
--------------------------------SECOND TABLE - GOING OUT OF UMBRELLA'S RANGE------------------------------------------
	
	local range2 = 5
    local ents2 = TheSim:FindEntities(pt.x, pt.y, pt.z, range2)
	
    for k, v in pairs(ents2) do
		if v ~= nil and inst.components.playerprox.isclose == false then
		
		-- Here player gets his waterproofness (or lack thereof) back
        if v.components.moisture and v:HasTag("featherbrelled") then
			v:RemoveTag("featherbrelled")
			v.components.moisture:SetInherentWaterproofness(0)
		elseif v.components.moisture and v:HasTag("featherbrelled02") then
			v:RemoveTag("featherbrelled02")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_SMALL*0.5)
		elseif v.components.moisture and v:HasTag("featherbrelled035") then
			v:RemoveTag("featherbrelled035")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_SMALL)
		elseif v.components.moisture and v:HasTag("featherbrelled05") then
			v:RemoveTag("featherbrelled05")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_SMALLMED)
		elseif v.components.moisture and v:HasTag("featherbrelled07") then
			v:RemoveTag("featherbrelled07")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_MED)
		elseif v.components.moisture and v:HasTag("featherbrelled09") then
			v:RemoveTag("featherbrelled09")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_LARGE)
		elseif v.components.moisture and v:HasTag("featherbrelled1") then
			v:RemoveTag("featherbrelled1")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_HUGE)
		end
	    end
    end
	end)
	
	MakeHauntableWork(inst)
	
    return inst
end

return Prefab( "common/objects/featherbrella", fn, assets, prefabs),
       MakePlacer( "common/featherbrella_placer", "featherbrella", "featherbrella", "idle" ) 