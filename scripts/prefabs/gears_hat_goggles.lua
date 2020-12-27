local assets =
{
	Asset("ANIM", "anim/gears_hat_goggles.zip"),
	
--	Asset("IMAGE", "images/colour_cubes/goggles_on_cc.tex"),
--	Asset("IMAGE", "images/colour_cubes/goggles_off_cc.tex"),
	Asset("ATLAS", "images/inventoryimages/gears_hat_goggles.xml"),
	Asset("IMAGE", "images/inventoryimages/gears_hat_goggles.tex"),
}

local function generic_perish(inst)
	local fin = SpawnPrefab("box_gear")
	      fin.Transform:SetPosition(inst.Transform:GetWorldPosition())	
    inst:Remove()
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_hat", "gears_hat_goggles", "swap_hat")
	
	owner.AnimState:Show("HAT")
	owner.AnimState:Show("HAT_HAIR")
--	owner.AnimState:Hide("HAIR_NOHAT")
--	owner.AnimState:Hide("HAIR")	
		
	inst.components.fueled:StartConsuming()        
end

local function onunequip(inst, owner)

	owner.AnimState:Hide("HAT")
	owner.AnimState:Hide("HAT_HAIR")
--	owner.AnimState:Show("HAIR_NOHAT")
--	owner.AnimState:Show("HAIR")	
	
    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end	
		
	inst.components.fueled:StopConsuming()      
end
	
local function goggles_onequip(inst, owner)
    onequip(inst, owner)
	owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_on")
end

local function goggles_onunequip(inst, owner)
    onunequip(inst, owner)
    owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_off")
end

local function goggles_perish(inst)
	local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
	if owner then
		owner:PushEvent("torchranout", {torch = inst})
	end
	generic_perish(inst)
end

local function fn(Sim)	
	local inst = CreateEntity()
		
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()	
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst) 

    inst.AnimState:SetBank("gears_hat_goggles")
    inst.AnimState:SetBuild("gears_hat_goggles")
    inst.AnimState:PlayAnimation("idle")
    
	inst:AddTag("nightvision")	
	inst:AddTag("hat")
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:AddComponent("inspectable")
	
    inst:AddComponent("tradable")	
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "gears_hat_goggles"		
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gears_hat_goggles.xml"
	
	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable:SetOnEquip(goggles_onequip)
	inst.components.equippable:SetOnUnequip(goggles_onunequip)
	
	inst:AddComponent("fueled")
	inst.components.fueled.fueltype = FUELTYPE.BURNABLE
	inst.components.fueled.secondaryfueltype = FUELTYPE.CAVE	
	inst.components.fueled:InitializeFuelLevel(TUNING.TOTAL_DAY_TIME*.75)
	inst.components.fueled:SetDepletedFn(goggles_perish)
	inst.components.fueled.accepting = true

	--[[
	inst:ListenForEvent("daytime", function(it)
	if GetWorld():IsCave() then return end
		if inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem:GetGrandOwner() == GetPlayer() and not GetWorld():IsCave() then
			GetWorld().components.colourcubemanager:SetOverrideColourCube(resolvefilepath("images/colour_cubes/goggles_off_cc.tex", 2))
		end
	end, GetWorld())
        inst:ListenForEvent("dusktime", function(it)
	if GetWorld():IsCave() then return end
		if inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem:GetGrandOwner() == GetPlayer() then
			if GetWorld() and GetWorld().components.colourcubemanager then
                GetWorld().components.colourcubemanager:SetOverrideColourCube(resolvefilepath("images/colour_cubes/goggles_on_cc.tex", 2))
			end
		end
	end, GetWorld())
        inst:ListenForEvent("nighttime", function(it)
	if GetWorld():IsCave() then return end
		if inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem:GetGrandOwner() == GetPlayer() then
			if GetWorld() and GetWorld().components.colourcubemanager then
                GetWorld().components.colourcubemanager:SetOverrideColourCube(resolvefilepath("images/colour_cubes/goggles_on_cc.tex", 2))
			end
		end
	end, GetWorld())
	]]
	
	MakeHauntableLaunch(inst)
	
    return inst
end

return Prefab("common/inventory/gears_hat_goggles", fn, assets ) 