local assets = 
{
	Asset("ANIM", "anim/hat_shark_teeth.zip"),

	Asset("ATLAS", "images/inventoryimages/donhatsharkteeth.xml"),
	Asset("IMAGE", "images/inventoryimages/donhatsharkteeth.tex"),
}

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_hat", "hat_shark_teeth", "swap_hat")
 
	owner.AnimState:Show("HAT")
	owner.AnimState:Hide("HAT_HAIR")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")
	
    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAIR")
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
        owner.AnimState:Hide("HEAD_HAIR")
    end	
	
	inst.components.fueled:StopConsuming()		
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("hat_shark_teeth")
	inst.AnimState:SetBuild("hat_shark_teeth")
	inst.AnimState:PlayAnimation("anim")

    inst:AddTag("hat")
	
    inst.entity:SetPristine()	

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "donhatsharkteeth"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/donhatsharkteeth.xml"

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

return Prefab("common/inventory/shark_teethhat", fn, assets)
