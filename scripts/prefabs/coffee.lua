require "prefabutil"

local Assets =
{
	Asset("ANIM", "anim/coffee.zip"),
}

--[[local function turnoffspeed(inst)
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "caffinated")      
end

local function OnEaten(inst, eater)
    if eater == nil then return end
   
    if eater.components.gfeffectable then
        eater.components.gfeffectable:PushEffect("caffinated", nil, 240)
        return
    end
   
    if eater.components.locomotor then
        eater.components.locomotor.isrunning = true
        eater.components.locomotor:SetExternalSpeedMultiplier(eater, "caffinated", 1.83)
        eater:DoTaskInTime(240, turnoffspeed)
    end
end]]

local function turnoffspeed(inst)
	inst.components.locomotor.groundspeedmultiplier = 1
	inst.components.locomotor.externalspeedmultiplier = 1	 
end


local function OnEaten(inst, eater)
	eater.components.locomotor.isrunning = true
	eater.components.locomotor.groundspeedmultiplier = 1.83
	eater.components.locomotor.externalspeedmultiplier = 1.83
	eater:DoTaskInTime(480, turnoffspeed)
end

local function cooked(Sim)
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("coffee")
	inst.AnimState:SetBuild("coffee")
	inst.AnimState:PlayAnimation("idle")
	
	inst:AddTag("preparedfood")

    inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("edible")
	inst.components.edible.foodtype = "GOODIES"
	inst.components.edible.healthvalue = TUNING.HEALING_SMALL
	inst.components.edible.hungervalue = TUNING.CALORIES_TINY
	inst.components.edible.sanityvalue = -TUNING.SANITY_TINY
	inst.components.edible:SetOnEatenFn(OnEaten)

	inst:AddComponent("inspectable")
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/volcanoinventory.xml" --coffee_cooked.xml

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	MakeHauntableLaunch(inst)
  
	return inst
end

return 	Prefab("coffee", cooked, Assets, prefabs)