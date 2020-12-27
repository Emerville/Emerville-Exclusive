local assets =
{
	Asset("ANIM", "anim/gear_hat.zip"),
	
	Asset("ATLAS", "images/inventoryimages/gear_hat.xml"),
	Asset("IMAGE", "images/inventoryimages/gear_hat.tex"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_hat", "gear_hat", "swap_hat")
				
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

local function onunequip(inst, owner) 
	
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
       
    inst.AnimState:SetBank("tophat")
    inst.AnimState:SetBuild("gear_hat")
    inst.AnimState:PlayAnimation("anim")
	
    inst:AddTag("hat")    

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("tradable")	

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "gear_hat"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/gear_hat.xml"
	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
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

return Prefab("common/inventory/gear_hat", fn, assets) 