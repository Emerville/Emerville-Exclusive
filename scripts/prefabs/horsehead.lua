local assets =
{
	Asset("ANIM", "anim/aip_horse_head.zip"),
	
	Asset("ATLAS", "images/inventoryimages/aip_horse_head.xml"),
	Asset("IMAGE", "images/inventoryimages/aip_horse_head.tex"),
}

-----------------------------------------------------------
local firsttalk = 0.50
local secondtalk = 0.50

local function onequip(inst, owner)	
     if owner.components.talker then	
		if math.random() < firsttalk then
			owner.components.talker:Say("Neighhhhh!")
		else 
			if math.random() < secondtalk then
			owner.components.talker:Say("Weesnaw!")
		   end
	   end
    end	

	owner.AnimState:OverrideSymbol("swap_hat", "aip_horse_head", "swap_hat")
	owner.AnimState:Show("HAT")
	owner.AnimState:Show("HAIR_HAT")
	owner.AnimState:Hide("HAIR_NOHAT")
	owner.AnimState:Hide("HAIR")

	if owner:HasTag("player") then
		owner.AnimState:Hide("HEAD")
		-- owner.AnimState:Show("HEAD_HAT")
	end

	if inst.components.fueled ~= nil then
		inst.components.fueled:StartConsuming()
	end
end

local function onunequip(inst, owner)
	owner.AnimState:ClearOverrideSymbol("swap_hat")
	owner.AnimState:Hide("HAT")
	owner.AnimState:Hide("HAIR_HAT")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")

	if owner:HasTag("player") then
		owner.AnimState:Show("HEAD")
		-- owner.AnimState:Hide("HEAD_HAT")
	end

	if inst.components.fueled ~= nil then
		inst.components.fueled:StopConsuming()
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("aip_horse_head")
	inst.AnimState:SetBuild("aip_horse_head")
	inst.AnimState:PlayAnimation("anim")

	inst:AddTag("hat")
	inst:AddTag("waterproofer")
    inst:AddTag("casino")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "aip_horse_head"	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/aip_horse_head.xml"	

	inst:AddComponent("inspectable")

	inst:AddComponent("tradable")

	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.walkspeedmult = 1.10

	inst:AddComponent("fueled")
	inst.components.fueled.fueltype = FUELTYPE.USAGE
	inst.components.fueled:InitializeFuelLevel(960)
	inst.components.fueled:SetDepletedFn(inst.Remove)
	inst.components.fueled.accepting = true	
	
	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_LARGE)	

	MakeHauntableLaunch(inst)

	return inst
end

return Prefab("common/inventory/horsehead", fn, assets ) 