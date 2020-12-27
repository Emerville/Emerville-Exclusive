local assets =
{ 
    Asset("ANIM", "anim/summerbandana.zip"),
    Asset("ANIM", "anim/summerbandana_swap.zip"), 

    Asset("ATLAS", "images/inventoryimages/summerbandana.xml"),
    Asset("IMAGE", "images/inventoryimages/summerbandana.tex"),
}

local function SummerBandana_OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", "summerbandana_swap", "swap_hat")
	
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

local function SummerBandana_OnUnequip(inst, owner) 

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

    inst.AnimState:SetBank("summerbandana")
    inst.AnimState:SetBuild("summerbandana")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hat")
	
    inst.entity:SetPristine()	

    if not TheWorld.ismastersim then
        return inst
    end		
	
    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "summerbandana"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/summerbandana.xml"

	inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(SummerBandana_OnEquip)
    inst.components.equippable:SetOnUnequip(SummerBandana_OnUnequip)
	
	inst:AddComponent("insulator")
	inst.components.insulator:SetInsulation(90)
	inst.components.insulator:SetSummer()	
	
	inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
	inst.components.fueled:InitializeFuelLevel(4800) --2500
	inst.components.fueled:SetDepletedFn(inst.Remove)
	
	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_LARGE_FUEL
	
	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
  	
	MakeHauntableLaunch(inst)	

    return inst
end

return Prefab("common/inventory/summerbandana", fn, assets)