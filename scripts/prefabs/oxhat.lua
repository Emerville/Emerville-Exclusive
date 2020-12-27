local assets = 
{
	Asset("ANIM", "anim/hat_ox.zip"),

	Asset("ATLAS", "images/inventoryimages/hat_ox.xml"),
	Asset("IMAGE", "images/inventoryimages/hat_ox.tex"),
}
	
local function OnEquip(inst, owner)
    owner:AddTag("beefalo")
    owner.AnimState:OverrideSymbol("swap_hat", "hat_ox", "swap_hat")

	owner.AnimState:Show("HAT")
	owner.AnimState:Show("HAIR_HAT")
	owner.AnimState:Hide("HAIR_NOHAT")
	owner.AnimState:Hide("HAIR")
	
    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end	
	
	inst.components.fueled:StartConsuming()
end

local function OnUnequip(inst, owner)
    owner:RemoveTag("beefalo")
		
	owner.AnimState:Hide("HAT")
	owner.AnimState:Hide("HAIR_HAT")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")
	
    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end	
	
	inst.components.fueled:StopConsuming()	
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("oxhat")
    inst.AnimState:SetBuild("hat_ox")
	inst.AnimState:PlayAnimation("anim")

    inst:AddTag("hat")
    inst:AddTag("waterproofer")	

    inst.entity:SetPristine()	
	
    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("tradable")	
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "hat_ox"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/hat_ox.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)	

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
	
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.BEEFALOHAT_PERISHTIME)
    inst.components.fueled:SetDepletedFn(inst.Remove)
	
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/oxhat", fn, assets)
