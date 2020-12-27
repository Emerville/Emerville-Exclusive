local assets =
{
	Asset("ANIM", "anim/baronsuit.zip"),
	Asset("ANIM", "anim/baronsuit2.zip"),
	Asset("ANIM", "anim/torso_defitems.zip"),
	
	Asset("ATLAS", "images/inventoryimages/baronsuit.xml"),
	Asset("IMAGE", "images/inventoryimages/baronsuit.tex"),	
}
		
local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "baronsuit", "swap_body")
	inst.components.fueled:StartConsuming()
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
	inst.components.fueled:StopConsuming()
end

local function onperish(inst)
    inst:Remove()
end

local function suitbaron()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("torso_hawaiian")--"torso_defitems")--"baronsuit_bank")
    inst.AnimState:SetBuild("baronsuit2")
    inst.AnimState:PlayAnimation("anim")
	
    inst:AddTag("casino")
	
    inst.entity:SetPristine()	
	
    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("tradable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "baronsuit"	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/baronsuit.xml"
	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE*3
	inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)	

	inst:AddComponent("insulator")
	inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
	
	inst:AddComponent("fueled")
    inst.components.fueled:InitializeFuelLevel(TUNING.SWEATERVEST_PERISHTIME*2) --20 Days
	inst.components.fueled:SetDepletedFn(onperish)
		
	MakeHauntableLaunch(inst)	
    
    return inst
end
	
return Prefab("common/inventory/baronsuit", suitbaron, assets) 