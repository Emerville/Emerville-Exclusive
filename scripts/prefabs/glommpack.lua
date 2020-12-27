local assets =
{
	-- Animation files used for the item.
	Asset("ANIM", "anim/glommpack_ground.zip"),
	Asset("ANIM", "anim/swap_glommpack.zip"),
	Asset("ANIM", "anim/swap_glommpack2.zip"),
	Asset("ANIM", "anim/swap_glommpack3.zip"),
	
	Asset("ATLAS", "images/inventoryimages/glommpack.xml"),
	Asset("IMAGE", "images/inventoryimages/glommpack.tex"),
}

local function onequip(inst, owner) 
    --owner.AnimState:OverrideSymbol("swap_body", "swap_backpack", "backpack")
    owner.AnimState:OverrideSymbol("swap_body", "swap_glommpack", "swap_body")
    inst.components.container:Open(owner)
end

local function onunequip(inst, owner) 
    --owner.AnimState:ClearOverrideSymbol("backpack")
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst.components.container:Close(owner)
end

---------------------------------

local function fn(Sim)
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("glommpack_ground")
    inst.AnimState:SetBuild("glommpack_ground")
    inst.AnimState:PlayAnimation("anim")

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("glommpack.tex")
	
	inst.foleysound = "dontstarve_DLC001/creatures/glommer/flap"

    inst:AddTag("backpack")
	inst:AddTag("waterproofer")

	inst.entity:SetPristine()	
	
	if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "glommpack"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/glommpack.xml"
    inst.components.inventoryitem.cangoincontainer = false

    inst:AddComponent("equippable")
	if EQUIPSLOTS["BACK"] then
		inst.components.equippable.equipslot = EQUIPSLOTS.BACK
	else
		inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	end
    
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)	
	inst.components.equippable.walkspeedmult = 1.25
	
    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)	
    
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("backpack")
	
	inst.firstlight = 1
	inst.isnotmoving = 0
	
	inst:DoPeriodicTask(1/10, function() 
	local owner = inst.components.inventoryitem.owner
	if inst.components.equippable.isequipped == true and inst.firstlight == 1 and owner.components.locomotor and owner.components.locomotor.wantstomoveforward then
	owner.AnimState:OverrideSymbol("swap_body", -- Symbol to override.
    	"swap_glommpack2", -- Animation bank we will use to overwrite the symbol.
    	"swap_body") -- Symbol to overwrite it with.
	inst.firstlight = 2
	inst.isnotmoving = 0
	
	elseif inst.components.equippable.isequipped == true and inst.firstlight == 2 and owner.components.locomotor and owner.components.locomotor.wantstomoveforward then
	owner.AnimState:OverrideSymbol("swap_body", 
    	"swap_glommpack3", 
    	"swap_body") 
	inst.firstlight = 3
	
	elseif inst.components.equippable.isequipped == true and inst.firstlight == 3 and owner.components.locomotor and owner.components.locomotor.wantstomoveforward then
	owner.AnimState:OverrideSymbol("swap_body", 
    	"swap_glommpack2", 
    	"swap_body")
	inst.firstlight = 4
	
	elseif inst.components.equippable.isequipped == true and inst.firstlight == 4 and owner.components.locomotor and owner.components.locomotor.wantstomoveforward then
	owner.AnimState:OverrideSymbol("swap_body", 
    	"swap_glommpack", 
    	"swap_body") 
	inst.firstlight = 1
	
	elseif inst.components.equippable.isequipped == true and owner.components.locomotor and not owner.components.locomotor.wantstomoveforward and inst.isnotmoving == 0 then
	owner.AnimState:OverrideSymbol("swap_body", 
    	"swap_glommpack",
    	"swap_body") 
	inst.firstlight = 1
	inst.isnotmoving = 1
	end
	end)
	
    MakeHauntableLaunchAndDropFirstItem(inst)
	
    return inst
end

return Prefab("common/inventory/glommpack", fn, assets) 