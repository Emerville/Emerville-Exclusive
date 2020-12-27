local assets =
{
	Asset("ANIM", "anim/armor_beefalo.zip"),
	
	Asset("ATLAS", "images/inventoryimages/armor_beefalo.xml"),
	Asset("IMAGE", "images/inventoryimages/armor_beefalo.tex"),	
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_beefalo", "swap_body")
    inst.components.fueled:StartConsuming()
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst.components.fueled:StopConsuming()
end

local function onperish(inst)
    inst:Remove()
end

local function fn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()	
	
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("armor_trunkvest_summer")
    inst.AnimState:SetBuild("armor_beefalo")
    inst.AnimState:PlayAnimation("anim")
	
    inst.foleysound = "dontstarve/movement/foley/trunksuit"	
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "armor_beefalo"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/armor_beefalo.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)	

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

    inst:AddComponent("fueled")
	inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.BEEFALOHAT_PERISHTIME)
    inst.components.fueled:SetDepletedFn(onperish)
	
    MakeHauntableLaunch(inst)	
    
    return inst
end

return Prefab("common/inventory/armor_beefalo", fn, assets) 