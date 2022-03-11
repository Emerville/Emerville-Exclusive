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
    if owner.components.hunger ~= nil then
        owner.components.hunger.burnratemodifiers:SetModifier(inst, TUNING.ARMORBEARGER_SLOW_HUNGER)
    end
	inst.components.fueled:StartConsuming()
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if owner.components.hunger ~= nil then
        owner.components.hunger.burnratemodifiers:RemoveModifier(inst)
    end
	inst.components.fueled:StopConsuming()
end

local function ondepleted(inst, owner)
    local replacement = SpawnPrefab("goldcoin")
    local x, y, z = inst.Transform:GetWorldPosition()
    replacement.Transform:SetPosition(x, y, z)
	replacement.components.stackable:SetStackSize(10)

    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
    if holder ~= nil then
        local slot = holder:GetItemSlot(inst)
        holder:GiveItem(replacement, slot)
    end

    inst:Remove()
end

local function fn()
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
    inst.components.fueled:SetDepletedFn(ondepleted)
		
	MakeHauntableLaunch(inst)	
    
    return inst
end
	
return Prefab("common/inventory/baronsuit", fn, assets) 