local assets=
{ 
    Asset("ANIM", "anim/jajangmon_wes_bl.zip"),
    Asset("ANIM", "anim/swap_jajangmon_wes_bl.zip"), 

    Asset("ATLAS", "images/inventoryimages/jajangmon_wes_bl.xml"),
    Asset("IMAGE", "images/inventoryimages/jajangmon_wes_bl.tex"),
}

local prefabs = 
{ "balloons_empty",
}

local function OnEquip(inst, owner) 
        owner.AnimState:OverrideSymbol("swap_object", "swap_jajangmon_wes_bl", "jajangmon_wes_bl")
        owner.AnimState:Show("ARM_carry") 
        owner.AnimState:Hide("ARM_normal") 
end

local function OnUnequip(inst, owner) 
        owner.AnimState:Hide("ARM_carry") 
        owner.AnimState:Show("ARM_normal") 
end


local function OnDeath(inst)
    --UnregisterBalloon(inst)
    RemovePhysicsColliders(inst)
    --inst.AnimState:PlayAnimation("pop")
    inst.SoundEmitter:PlaySound("dontstarve/common/balloon_pop")
   -- inst.DynamicShadow:Enable(false)
    inst:AddTag("NOCLICK")
    inst.persists = false
   -- local attack_delay = .1 + math.random() * .2
  --  local remove_delay = math.max(attack_delay, inst.AnimState:GetCurrentAnimationLength()) + FRAMES
   -- inst:DoTaskInTime(attack_delay, DoAreaAttack)
   -- inst:DoTaskInTime(remove_delay, inst.Remove)
end


local function fn(colour)
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	
    --MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("jajangmon_wes_bl")
    inst.AnimState:SetBuild("jajangmon_wes_bl")
    inst.AnimState:PlayAnimation("idle", true)	
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	
	
    inst:AddComponent("inspectable")	

    --[[inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "jajangmon_wes_bl"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/jajangmon_wes_bl.xml"
    
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "balloons_empty"
	
    inst:AddTag("waterproofer")
	inst:AddTag("show_spoilage")
	
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(5)
    inst:ListenForEvent("death", OnDeath)

    inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(0)
	
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )]]
	

    return inst
end

return  Prefab("common/inventory/balloons_halloween", fn, assets, prefabs)