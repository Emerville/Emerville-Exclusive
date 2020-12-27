local assets =
{
    Asset("ANIM", "anim/stimpack.zip"),
	
	Asset("ATLAS", "images/inventoryimages/stimpack.xml"),
	Asset("IMAGE", "images/inventoryimages/stimpack.tex"),
}

local function oneaten(inst, eater)

	--[[if not eater:HasTag("player") then
		return
	end]]
	
	--[[if not eater:HasTag("hasbuff_DC")then
		eater:RemoveTag("hasbuff_DC")
		eater:AddTag("hasbuff_DC")
	else
		return
	end]]
	
	if eater.components.combat then
		eater.components.combat:GetAttacked(inst, 5)
		--eater:PushEvent("thorns")
	end
	
	--eater.components.health:SetAbsorptionAmount(1.00)
	eater.components.locomotor.runspeed = eater.components.locomotor.runspeed + 2
	if eater:HasTag("player") then
	eater.components.talker:Say("Speed boost activated with speed: "..eater.components.locomotor.runspeed, 4)
	end
	local cloud = SpawnPrefab("poopcloud")
    if cloud then
        cloud.Transform:SetPosition(eater.Transform:GetWorldPosition())
    end
	eater:DoTaskInTime(60, function (inst)
		inst.components.locomotor.runspeed = inst.components.locomotor.runspeed - 2
		if eater:HasTag("player") then
		eater.components.talker:Say("Speed boost deactivated with speed: "..eater.components.locomotor.runspeed, 4)
		end
		--inst:RemoveTag("hasbuff_DC")
	end)
	
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("lifepen")
    inst.AnimState:SetBuild("stimpack")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "stimpack"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/stimpack.xml"
	
	inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.MEAT	
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0
	inst.components.edible.sanityvalue = 0
    inst.components.edible:SetOnEatenFn(oneaten)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM	
	
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/stimpack", fn, assets)