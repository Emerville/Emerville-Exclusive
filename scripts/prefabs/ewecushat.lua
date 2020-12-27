local assets =
{ 
    Asset("ANIM", "anim/ewecushat.zip"),
    Asset("ANIM", "anim/ewecushat_swap.zip"), 

    Asset("ATLAS", "images/inventoryimages/ewecushat.xml"),
    Asset("IMAGE", "images/inventoryimages/ewecushat.tex"),
}

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", "ewecushat_swap", "swap_hat")
	
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAT_HAIR")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
		owner.AnimState:Show("HEAD_HAT")
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
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("ewecushat")
    inst.AnimState:SetBuild("ewecushat")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hat")
    inst:AddTag("waterproofer")	
    inst:AddTag("casino")
	
    inst.entity:SetPristine()	

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "ewecushat"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/ewecushat.xml"
    
	inst:AddComponent("armor")
	inst.components.armor:InitCondition(785, 0.9)	
	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	
	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
	
    MakeHauntableLaunch(inst)	
	
    return inst
end

return Prefab("common/inventory/ewecushat", fn, assets)