local assets = 
{
	Asset("ANIM", "anim/armor_snakeskin.zip"),

	Asset("ATLAS", "images/inventoryimages/armor_snakeskin.xml"),
	Asset("IMAGE", "images/inventoryimages/armor_snakeskin.tex"),
}

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_body", "armor_snakeskin", "swap_body")
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

    inst.AnimState:SetBank("armor_snakeskin")
    inst.AnimState:SetBuild("armor_snakeskin")
    inst.AnimState:PlayAnimation("anim")
	
    --waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")

    inst.entity:SetPristine()	

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "armor_snakeskin"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/armor_snakeskin.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable.insulated = true
	
	inst:AddComponent("fueled")
	inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.RAINCOAT_PERISHTIME)
    inst.components.fueled:SetDepletedFn(inst.Remove)
	
    inst:AddComponent("waterproofer")

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)	
	
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/armor_snakeskin", fn, assets)
