local assets =
{
	-- Animation files used for the item.
	Asset("ANIM", "anim/dark_pickaxe.zip"),
	Asset("ANIM", "anim/swap_dark_pickaxe.zip"),

	-- Inventory image and atlas file used for the item.
    Asset("ATLAS", "images/inventoryimages/dark_pickaxe.xml"),
    Asset("IMAGE", "images/inventoryimages/dark_pickaxe.tex"),
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_dark_pickaxe","swap_pickaxe")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
	inst.AnimState:SetMultColour(1, 1, 1, 0.8)
	owner:AddTag("shadowminer")
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
	inst.AnimState:SetMultColour(1, 1, 1, 0.7)
	owner:RemoveTag("shadowminer")
end

local function init()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("dark_pickaxe")
    inst.AnimState:SetBuild("dark_pickaxe")
    inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetMultColour(1, 1, 1, 0.7)

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
    inst.components.inventoryitem.imagename = "dark_pickaxe"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/dark_pickaxe.xml"	
	
	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL

	inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.MINE, 1.5)
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.PICKAXE_USES)
    inst.components.finiteuses:SetUses(TUNING.PICKAXE_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.MINE, 1)
	
    inst:AddComponent("inspectable")	
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.dapperness = TUNING.CRAZINESS_SMALL
	
	MakeHauntableLaunch(inst)	
    
    return inst
end

return Prefab("common/inventory/dark_pickaxe", init, assets)