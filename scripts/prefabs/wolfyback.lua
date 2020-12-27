local assets =
{
	-- Animation files used for the item.
	Asset("ANIM", "anim/wolfyback.zip"),
	Asset("ANIM", "anim/swap_wolfyback.zip"),
	
	Asset("ATLAS", "images/inventoryimages/wolfyback.xml"),
	Asset("IMAGE", "images/inventoryimages/wolfyback.tex"),		
}

local function onequip(inst, owner) 
    --owner.AnimState:OverrideSymbol("swap_body", "swap_backpack", "backpack")
    owner.AnimState:OverrideSymbol("swap_body", "swap_wolfyback", "swap_body")
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

    inst.AnimState:SetBank("wolfyback")
    inst.AnimState:SetBuild("wolfyback")
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
	inst.components.inventoryitem.imagename = "wolfyback"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/wolfyback.xml"
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

return Prefab("common/inventory/wolfyback", fn, assets) 