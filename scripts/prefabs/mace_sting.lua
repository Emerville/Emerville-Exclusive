local assets =
{
	Asset("ANIM", "anim/mace_sting.zip"),
	Asset("ANIM", "anim/swap_mace_sting.zip"),
	
	Asset("ATLAS", "images/inventoryimages/mace_sting.xml"),
    Asset("IMAGE", "images/inventoryimages/mace_sting.tex"),	
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_mace_sting", "swap_nightmaresword")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()	
	
    MakeInventoryPhysics(inst)	
	
    inst.AnimState:SetBank("nightmaresword")
    inst.AnimState:SetBuild("mace_sting")
    inst.AnimState:PlayAnimation("idle")
	
    inst:AddTag("sharp")	
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end		
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(45)
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(100)
    inst.components.finiteuses:SetUses(100)   
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "mace_sting"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mace_sting.xml"
	
	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    
    return inst
end

return Prefab("common/inventory/mace_sting", fn, assets) 