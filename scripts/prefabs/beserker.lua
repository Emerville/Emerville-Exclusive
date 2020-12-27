local easing = require("easing")
local assets =
{
    Asset("ANIM", "anim/beserker.zip"),
	
	Asset("ATLAS", "images/inventoryimages/beserker.xml"),
	Asset("IMAGE", "images/inventoryimages/beserker.tex"),
}

local function oneaten(inst, eater)

	--[[local atk_boost = 0
	if not eater:HasTag("player") then
		atk_boost = 20
	elseif(GetPlayer().prefab == "wathgrithr") then
		atk_boost = TUNING.WATHGRITHR_DAMAGE_MULT
	elseif(GetPlayer().prefab == "wendy") then
		atk_boost = TUNING.WENDY_DAMAGE_MULT
	elseif(GetPlayer().prefab == "wolfgang") then
		eater.components.talker:Say("Too scary to take shot", 4)
		return
	else
		atk_boost = 1
	end]]
	
	--[[if not eater:HasTag("player") then
		return
	end]]
	
	--[[if not eater:HasTag("hasbuff_DC")then
		eater:RemoveTag("hasbuff_DC")
		eater:AddTag("hasbuff_DC")
	else
		return
	end]]
	eater:AddTag("houndfriend")
	
	if eater.components.werebeast ~= nil and not eater.components.werebeast:IsInWereState() then
    eater.components.werebeast:TriggerDelta(4)
	end
	
	if eater.components.combat and eater:HasTag("player") --[[and eater.components.combat.damagemultiplier ~= nil]] then
		local atk_boost = (eater.components.combat.damagemultiplier or 1)*1.3--atk_boost+0.3
		eater.components.combat:GetAttacked(inst, 1)
		eater.components.combat.damagemultiplier = atk_boost--atk_boost+0.3
		eater.components.talker:Say("Attack boost activated with bonus: "..atk_boost.."x", 4)
		eater.components.sanity:DoDelta(-20, true)
		local cloud = SpawnPrefab("poopcloud")
		if cloud then
			cloud.Transform:SetPosition(eater.Transform:GetWorldPosition())
		end
		eater:DoTaskInTime(60, function (inst)
			local atk_boost = (eater.components.combat.damagemultiplier or 1.3)/1.3
			inst.components.combat.damagemultiplier = atk_boost--atk_boost
			inst.components.talker:Say("Attack boost deactivated with bonus: "..atk_boost.."x", 4)
			--inst:RemoveTag("hasbuff_DC")
		end)
		--eater:PushEvent("thorns")
	end
	
	--eater.components.health:SetAbsorptionAmount(1.00)
	--atk_boost = atk_boost - 0.3
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("lifepen")
    inst.AnimState:SetBuild("beserker")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "beserker"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/beserker.xml"
	
	inst:AddComponent("edible") 
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0
	inst.components.edible.sanityvalue = 0
    inst.components.edible.foodtype = FOODTYPE.MEAT
    inst.components.edible:SetOnEatenFn(oneaten)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/beserker", fn, assets)