local assets =
{ 
    Asset("ANIM", "anim/hollowhat.zip"),
    Asset("ANIM", "anim/hollowhat_swap.zip"), 

    Asset("ATLAS", "images/inventoryimages/hollowhat.xml"),
    Asset("IMAGE", "images/inventoryimages/hollowhat.tex"),
}

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", "hollowhat_swap", "swap_hat")
	
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAT_HAIR")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
		owner.AnimState:Show("HEAD_HAT")				
    end
	
    inst.components.fueled:StartConsuming()	
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
	
	inst.components.fueled:StopConsuming()	
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("hollowhat")
    inst.AnimState:SetBuild("hollowhat")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hat")
	
    inst.entity:SetPristine()	

    if not TheWorld.ismastersim then
        return inst
    end
		
    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "hollowhat"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/hollowhat.xml"
	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable.walkspeedmult = 1.25	
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)	
	inst.components.equippable.dapperness = -TUNING.DAPPERNESS_LARGE	
    
	inst:AddComponent("fueled")
	inst.components.fueled.fueltype = FUELTYPE.USAGE
	inst.components.fueled:InitializeFuelLevel(800) --Originally 400
	inst.components.fueled:SetDepletedFn(inst.Remove)

	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
	
    MakeHauntableLaunch(inst)	

    return inst
end

return Prefab("common/inventory/hollowhat", fn, assets)