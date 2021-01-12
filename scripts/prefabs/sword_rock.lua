local assets =
{
	Asset("ANIM", "anim/sword_rock.zip"),
	Asset("ANIM", "anim/swap_sword_rock.zip"),
	
	Asset("ATLAS", "images/inventoryimages/sword_rock.xml"),
    Asset("IMAGE", "images/inventoryimages/sword_rock.tex"),	
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_sword_rock", "swap_sword_rock")
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

    inst.AnimState:SetBank("sword_rock")
    inst.AnimState:SetBuild("sword_rock")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddTag("sharp")

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(38)
        
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(125)
    inst.components.finiteuses:SetUses(125)
	inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sword_rock"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sword_rock.xml"
	
	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
    MakeHauntableLaunch(inst)
    
    return inst
end

return Prefab("common/inventory/sword_rock", fn, assets) 