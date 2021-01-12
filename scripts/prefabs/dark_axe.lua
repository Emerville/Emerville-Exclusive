local assets =
{
	-- Animation files used for the item.
	Asset("ANIM", "anim/dark_axe.zip"),
	Asset("ANIM", "anim/swap_dark_axe.zip"),

	-- Inventory image and atlas file used for the item.
    Asset("ATLAS", "images/inventoryimages/dark_axe.xml"),
    Asset("IMAGE", "images/inventoryimages/dark_axe.tex"),
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_dark_axe","swap_axe")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
	owner:AddTag("shadowchopper")
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
	owner:RemoveTag("shadowchopper")
end

local function init()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("dark_axe")
    inst.AnimState:SetBuild("dark_axe")
    inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetMultColour(1, 1, 1, 0.8)

	inst:AddTag("sharp")
	inst:AddTag("shadow")
	
	inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end	
		
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SPEAR_DAMAGE)
	inst.components.weapon.attackwear = 2
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "dark_axe"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/dark_axe.xml"	
	
	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL

	inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP, 1.5)
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.AXE_USES)
    inst.components.finiteuses:SetUses(TUNING.AXE_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)	
	
    inst:AddComponent("inspectable")
   
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.dapperness = TUNING.CRAZINESS_SMALL
	
	MakeHauntableLaunch(inst)
    
    return inst
end

return Prefab("common/inventory/dark_axe", init, assets)