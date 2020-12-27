local assets =
{
	-- Animation files used for the item.
	Asset("ANIM", "anim/bunnyback.zip"),
	Asset("ANIM", "anim/swap_bunnyback.zip"),
	
	Asset("ATLAS", "images/inventoryimages/bunnyback.xml"),
	Asset("IMAGE", "images/inventoryimages/bunnyback.tex"),		
}

local function onequip(inst, owner) 
    --owner.AnimState:OverrideSymbol("swap_body", "swap_backpack", "backpack")
    owner.AnimState:OverrideSymbol("swap_body", "swap_bunnyback", "swap_body")
    inst.components.container:Open(owner)
end

local function onunequip(inst, owner) 
    --owner.AnimState:ClearOverrideSymbol("backpack")
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst.components.container:Close(owner)
end

---------------------------------

local function fn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()	
	
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bunnyback")
    inst.AnimState:SetBuild("bunnyback")
    inst.AnimState:PlayAnimation("anim")
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("wool_sack.tex")	
	
    inst.foleysound = "dontstarve/movement/foley/backpack"

    inst:AddTag("backpack")
	inst:AddTag("waterproofer")	

	inst.entity:SetPristine()	
	
	if not TheWorld.ismastersim then
        return inst
    end	
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "bunnyback"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/bunnyback.xml"
    inst.components.inventoryitem.cangoincontainer = false

    inst:AddComponent("equippable")
	if EQUIPSLOTS["BACK"] then
		inst.components.equippable.equipslot = EQUIPSLOTS.BACK
	else
		inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	end
    
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)	

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("piggyback")
	
    MakeHauntableLaunchAndDropFirstItem(inst)	
		
    return inst
end	

return Prefab("common/inventory/bunnyback", fn, assets) 