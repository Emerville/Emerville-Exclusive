local assets =
{
	Asset("ANIM", "anim/hat_rock.zip"),
--	Asset("ANIM", "anim/hat_rock_swap.zip"),
	
	Asset("ATLAS", "images/inventoryimages/hat_rock.xml"),	
	Asset("IMAGE", "images/inventoryimages/hat_rock.tex"),
}

local function onequip(inst, owner)
--	owner.AnimState:OverrideSymbol("swap_hat", "hat_rock_swap", "swap_hat")
	owner.AnimState:OverrideSymbol("swap_hat", "hat_rock", "swap_hat")
	
	owner.AnimState:Show("HAT")
	owner.AnimState:Show("HAIR_HAT")
	owner.AnimState:Hide("HAIR_NOHAT")
	owner.AnimState:Hide("HAIR")	
	
	if owner:HasTag("player") then
		owner.AnimState:Hide("HEAD")
		owner.AnimState:Show("HEAD_HAT")
	end
end

local function onunequip(inst, owner)

	owner.AnimState:Hide("HAT")
	owner.AnimState:Hide("HAIR_HAT")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")
	
    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end
end

local function fn()	
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("hat_rock")
    inst.AnimState:SetBuild("hat_rock")
	inst.AnimState:PlayAnimation("idle") 

    inst:AddTag("waterproofer")		
	inst:AddTag("hat")
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		return inst
	end 
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("tradable")	
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "hat_rock"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/hat_rock.xml"
	
	inst:AddComponent("armor")
	inst.components.armor:InitCondition(360, .85)
	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable.walkspeedmult = 0.9	
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
	inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL*2)

	MakeHauntableLaunch(inst)
	
    return inst
end

return Prefab("common/inventory/hat_rock", fn, assets) 