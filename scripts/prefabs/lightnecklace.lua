local assets =
{
	Asset("ANIM", "anim/lightnecklace.zip"),
	Asset("ANIM", "anim/lightnecklace2.zip"),
	Asset("ANIM", "anim/torso_defitems.zip"),

	Asset("ATLAS", "images/inventoryimages/lightnecklace.xml"),
	Asset("IMAGE", "images/inventoryimages/lightnecklace.tex"),	
}

local function OnDropped(inst)
    inst.Light:Enable(true)
end

local function OnPickup(inst)
    inst.Light:Enable(false)
end
		
local function onequip(inst, owner) 
	if owner then
    owner.AnimState:OverrideSymbol("swap_body", "lightnecklace", "swap_body")
	inst.Light:Enable(true)
	end
end

local function onunequip(inst, owner) 
	if owner then
    owner.AnimState:ClearOverrideSymbol("swap_body")
	inst.Light:Enable(false)
	end
end

local function necklacelight()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLight()
	inst.entity:AddNetwork()	
	
    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("torso_hawaiian")
    inst.AnimState:SetBuild("lightnecklace2")
    inst.AnimState:PlayAnimation("anim")
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    local light = inst.entity:AddLight()
    inst.Light:SetFalloff(0.6)
    inst.Light:SetIntensity(0.75)
    inst.Light:SetRadius(2)
    inst.Light:SetColour(237/255, 237/255, 209/255)
    inst.Light:Enable(true)
	
	inst.foleysound = "dontstarve/movement/foley/trunksuit"
	
	inst:AddTag("show_spoilage")
    inst:AddTag("icebox_valid")	
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
        return inst
	end
		
	inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/lightnecklace.xml"
	inst.components.inventoryitem.imagename = "lightnecklace"
	inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPickupFn(OnPickup)	

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_TWO_DAY)
    inst.components.perishable.onperishreplacement = "spoiled_food"
	inst.components.perishable:StartPerishing()
	
    inst:AddComponent("equippable")
    if EQUIPSLOTS["NECK"] then --for additional equipslot mods
		inst.components.equippable.equipslot = EQUIPSLOTS.NECK
	else
		inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	end
	inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	inst.components.fuel.fueltype = FUELTYPE.CAVE	
	
    MakeHauntableLaunch(inst)	
	
    return inst
end
	
return Prefab("common/inventory/lightnecklace", necklacelight, assets) 