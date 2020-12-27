local assets =
{
	-- Animation files used for the item.
	Asset("ANIM", "anim/growthstaff.zip"),
	Asset("ANIM", "anim/swap_growthstaff.zip"),

	-- Inventory image and atlas file used for the item.
    Asset("ATLAS", "images/inventoryimages/growthstaff.xml"),
    Asset("IMAGE", "images/inventoryimages/growthstaff.tex"),
}

local function onfinished(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
    inst:Remove()
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", -- Symbol to override.
    	"swap_growthstaff", -- Animation bank we will use to overwrite the symbol.
    	"swap_growthstaff") -- Symbol to overwrite it with.
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function growstaff(staff)
	local caster = staff.components.inventoryitem.owner
	local pt = Vector3(caster.Transform:GetWorldPosition())
	
	staff.components.finiteuses:Use(1) 
	
	for k, v in pairs(TheSim:FindEntities(pt.x, pt.y, pt.z, 30)) do
		if v.components.pickable then
			v.components.pickable:FinishGrowing()
		end
		
		if v.components.crop then
			v.components.crop:DoGrow(TUNING.TOTAL_DAY_TIME * 3)
		end
		
		if v.components.growable and v:HasTag("tree") and not v:HasTag("stump") then
			v.components.growable:DoGrowth()
		end
	end
	return true
end

local function init()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()	

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("growthstaff")
    inst.AnimState:SetBuild("growthstaff")
    inst.AnimState:PlayAnimation("growthstaff")

    inst:AddTag("staff")
	inst:AddTag("nopunch")

	inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
		return inst
	end

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "growthstaff"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/growthstaff.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(growstaff)
    inst.components.spellcaster.canuseontargets = false
	inst.components.spellcaster.canusefrominventory = true
	inst.components.spellcaster.canuseonpoint = true
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(5)
    inst.components.finiteuses:SetUses(5)
    inst.components.finiteuses:SetOnFinished(onfinished)
	
    MakeHauntableLaunch(inst)	
    
    return inst
end

return Prefab("common/inventory/growthstaff", init, assets)