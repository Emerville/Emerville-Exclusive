local assets =
{ 
    Asset("ANIM", "anim/xmashat_default.zip"),
    Asset("ANIM", "anim/xmashat_default_swap.zip"), 

    Asset("ATLAS", "images/inventoryimages/xmashat_default.xml"),
    Asset("IMAGE", "images/inventoryimages/xmashat_default.tex"),
}

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", "xmashat_default_swap", "swap_hat")
	
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end

	if inst.components.fueled ~= nil then
        inst.components.fueled:StartConsuming()
    end
end


local function OnUnequip(inst, owner) 

    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end

    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("xmashat_default")
    inst.AnimState:SetBuild("xmashat_default")
    inst.AnimState:PlayAnimation("idle")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "xmashat_default"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/xmashat_default.xml"
	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE
	
	inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
	
	inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.WALRUSHAT_PERISHTIME)
    inst.components.fueled:SetDepletedFn(inst.Remove)
	
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/santahat", fn, assets)