local assets =
{ 
    Asset("ANIM", "anim/spartahelmut1.zip"),
    Asset("ANIM", "anim/spartahelmut_swap2.zip"), 

    Asset("ATLAS", "images/inventoryimages/spartahelmut.xml"),
    Asset("IMAGE", "images/inventoryimages/spartahelmut.tex"),
}

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", "spartahelmut_swap2", "swap_hat")
	
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAT_HAIR")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
		owner.AnimState:Show("HEAD_HAT")
    end
	
	if owner and not owner:HasTag("spartan") then
		owner:AddTag("spartan")
	end
end

local function OnUnequip(inst, owner) 

    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAT_HAIR")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
		owner.AnimState:Hide("HEAD_HAT")
    end
	
	if owner and owner:HasTag("spartan") then
		owner:RemoveTag("spartan")
	end
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()	

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("spartahelmut")
    inst.AnimState:SetBuild("spartahelmut1")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("spartahat")
    inst:AddTag("casino")
    inst:AddTag("waterproofer")	
	
    inst.entity:SetPristine()	

    if not TheWorld.ismastersim then
        return inst
    end	
	
    inst:AddComponent("inspectable")
	
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 25		

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "spartahelmut"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/spartahelmut.xml"

	inst:AddComponent("armor")
	inst.components.armor:InitCondition(840, 0.90)
	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	
	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
	
    MakeHauntableLaunch(inst)	

    return inst
end

return Prefab("common/inventory/spartahelmut", fn, assets)