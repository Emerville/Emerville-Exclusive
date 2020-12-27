local assets =
{
	Asset("ANIM", "anim/hat_marble.zip"),
--	Asset("ANIM", "anim/hat_marble_swap.zip"),
	
	Asset("ATLAS", "images/inventoryimages/hat_marble.xml"),	
	Asset("IMAGE", "images/inventoryimages/hat_marble.tex"),
}

local function onequip(inst, owner)
--	owner.AnimState:OverrideSymbol("swap_hat", "hat_marble_swap", "swap_hat")
	owner.AnimState:OverrideSymbol("swap_hat", "hat_marble", "swap_hat")
	
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

	inst.AnimState:SetBank("hat_marble")
    inst.AnimState:SetBuild("hat_marble")
	inst.AnimState:PlayAnimation("idle") 

    inst:AddTag("waterproofer")	
	inst:AddTag("marble")	
	inst:AddTag("hat")
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:AddComponent("inspectable")

	inst:AddComponent("tradable")	
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "hat_marble"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/hat_marble.xml"
	
	inst:AddComponent("armor")
	inst.components.armor:InitCondition(TUNING.ARMOR_SLURTLEHAT, TUNING.ARMORMARBLE_ABSORPTION)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable.walkspeedmult = 0.8	
	inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
	inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL*2)
	
	MakeHauntableLaunch(inst)
	
    return inst
end

return Prefab("common/inventory/hat_marble", fn, assets) 