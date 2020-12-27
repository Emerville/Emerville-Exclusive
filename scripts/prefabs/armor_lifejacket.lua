local assets = 
{
	Asset("ANIM", "anim/armor_lifejacket.zip"),

	Asset("ATLAS", "images/inventoryimages/armor_lifejacket.xml"),
	Asset("IMAGE", "images/inventoryimages/armor_lifejacket.tex"),
}

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_lifejacket", "swap_body")
    inst.components.fueled:StartConsuming()
end

local function OnUnequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst.components.fueled:StopConsuming()
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("armor_lifejacket")
    inst.AnimState:SetBuild("armor_lifejacket")
    inst.AnimState:PlayAnimation("anim")
	
    --waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")

    inst.entity:SetPristine()	

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "armor_lifejacket"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/armor_lifejacket.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL	
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.REFLECTIVEVEST_PERISHTIME)
    inst.components.fueled:SetDepletedFn(inst.Remove)

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
    inst.components.insulator:SetSummer()

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)	
	
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/armor_lifejacket", fn, assets)
