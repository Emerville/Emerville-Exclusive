local assets =
{
	-- Animation files used for the item.
	Asset("ANIM", "anim/spartaswurd1.zip"),
	Asset("ANIM", "anim/swap_spartaswurd1.zip"),

	-- Inventory image and atlas file used for the item.
    Asset("ATLAS", "images/inventoryimages/spartaswurd.xml"),
    Asset("IMAGE", "images/inventoryimages/spartaswurd.tex"),
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", -- Symbol to override.
    	"swap_spartaswurd1", -- Animation bank we will use to overwrite the symbol.
    	"swap_spartaswurd") -- Symbol to overwrite it with.
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function init()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()	

    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("spartaswurd")
    inst.AnimState:SetBuild("spartaswurd1")
    inst.AnimState:PlayAnimation("swap")

    inst:AddTag("spartaswurd")
    inst:AddTag("casino")
	
    inst.entity:SetPristine()	

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(60)

	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(125)
    inst.components.finiteuses:SetUses(125)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "spartaswurd"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/spartaswurd.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
	MakeHauntableLaunch(inst)	
    
    return inst
end

return Prefab("common/inventory/spartaswurd", init, assets)