local assets =
{ 
    Asset("ANIM", "anim/birchnuthat.zip"),
    Asset("ANIM", "anim/birchnuthat_swap.zip"), 

    Asset("ATLAS", "images/inventoryimages/birchnuthat.xml"),
    Asset("IMAGE", "images/inventoryimages/birchnuthat.tex"),
}

local function procfn(inst, data)
	if data.attacker ~= nil then
		local dtatk = data.attacker
		if  not dtatk:HasTag("player") and dtatk and dtatk.components.health and dtatk.components.combat then
			dtatk.components.health:DoDelta(-6) -- Damage done to attacker
			else			
		end
	end -- IT SHOULD WORK NOW.
end

local function OnEquip(inst, owner, data) 
    owner.AnimState:OverrideSymbol("swap_hat", "birchnuthat_swap", "swap_hat")
	
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAT_HAIR")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
	    owner.AnimState:Show("HEAD_HAT")
	end
	--
	inst.tryproc = function(inst, data) procfn(inst,data) end 
    owner:ListenForEvent("attacked", inst.tryproc)	
	--
end

local function OnUnequip(inst, owner, data) 

    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAT_HAIR")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
		owner.AnimState:Hide("HEAD_HAT")
    end
	--
	owner:RemoveEventCallback("attacked", inst.tryproc)
	--
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("birchnuthat")
    inst.AnimState:SetBuild("birchnuthat")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hat")
    inst:AddTag("waterproofer")	
	
    inst.entity:SetPristine()	

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	
	inst:AddComponent("tradable")	

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "birchnuthat"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/birchnuthat.xml"	
	
	inst:AddComponent("armor")
	inst.components.armor:InitCondition(225, 0.5)
   	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	
	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
	
	MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/birchnuthat", fn, assets)