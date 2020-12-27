local assets =
{
	-- Animation files used for the item.
	Asset("ANIM", "anim/cactusmace.zip"),
	Asset("ANIM", "anim/swap_cactusmace.zip"),

	-- Inventory image and atlas file used for the item.
    Asset("ATLAS", "images/inventoryimages/cactusmace.xml"),
    Asset("IMAGE", "images/inventoryimages/cactusmace.tex"),
}

local function UpdateDamage(inst, target)
	local owner = inst.components.inventoryitem.owner
    if owner and inst.components.perishable and inst.components.weapon then
        local dmg = 68.5 * inst.components.perishable:GetPercent()
        dmg = Remap(dmg, 0, 68.5, 0.5*68.5, 68.5) --Damage will change based on spoilage ~ 7 per day
        inst.components.weapon:SetDamage(dmg)
		owner.components.health:DoDelta(-1) --Damages the player for 1 HP
    end
end

local function OnLoad(inst, data)
    UpdateDamage(inst)
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_cactusmace","swap_cactusmace")
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
		
    inst.AnimState:SetBank("cactusmace")
    inst.AnimState:SetBuild("cactusmace")
    inst.AnimState:PlayAnimation("cactusmace")
	
	inst:AddTag("show_spoilage")
    inst:AddTag("icebox_valid")	
	
    inst.entity:SetPristine()	
	
    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST) -- Lasts 6 days
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"	
		
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(68.5)
	inst.components.weapon:SetOnAttack(UpdateDamage)

    inst:AddComponent("inspectable")
    	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "cactusmace"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/cactusmace.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
	inst.OnLoad = OnLoad
	
    MakeHauntableLaunchAndPerish(inst)	
    
    return inst
end

return Prefab("common/inventory/cactusmace", init, assets)