local assets =
{
    Asset("ANIM", "anim/snowyball.zip"),
    Asset("ANIM", "anim/swap_snowyball.zip"),
  
    Asset("ATLAS", "images/inventoryimages/snowyball.xml"), 
    Asset("IMAGE", "images/inventoryimages/snowyball.tex"),
}

local function OnDropped(inst)
    inst.AnimState:PlayAnimation("idle")
end

local function OnCaught(inst, catcher)
    if catcher then
        if catcher.components.inventory then
            if inst.components.equippable and not catcher.components.inventory:GetEquippedItem(inst.components.equippable.equipslot) then
                catcher.components.inventory:Equip(inst)
            else
                catcher.components.inventory:GiveItem(inst)
            end
            catcher:PushEvent("catch")
        end
    end
end

local function OnThrown(inst, owner)
	inst.AnimState:PlayAnimation("idle")
end

--inst:Remove()

local function OnHit(inst, attacker, target)


    if not target:IsValid() then
        --target killed or removed in combat damage phase
        return
    end

    if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end

    if target.components.burnable ~= nil then
        if target.components.burnable:IsBurning() then
            target.components.burnable:Extinguish()
        elseif target.components.burnable:IsSmoldering() then
            target.components.burnable:SmotherSmolder()
        end
    end

    if target.components.combat ~= nil then
        target.components.combat:SuggestTarget(attacker)
    end

    if target.sg ~= nil and not target.sg:HasStateTag("frozen") then
        target:PushEvent("attacked", { attacker = attacker, damage = 0, weapon = inst })
    end

    if target.components.freezable ~= nil then
        target.components.freezable:AddColdness(1)
        target.components.freezable:SpawnShatterFX()
    end
	inst:Remove()
end


local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_snowyball", "swap_snowyball")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end


local function fn()
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()	
	
    MakeInventoryPhysics(inst)
 
    inst.AnimState:SetBank("snowyball")
    inst.AnimState:SetBuild("snowyball")
    inst.AnimState:PlayAnimation("idle")  
    
    -------        
	inst.entity:SetPristine()	
	
    if not TheWorld.ismastersim then
        return inst
    end	
	
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(24)
    inst.components.projectile:SetCanCatch(false)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnCaughtFn(OnCaught)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "snowyball"		
    inst.components.inventoryitem.atlasname = "images/inventoryimages/snowyball.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    return inst
end

return Prefab("common/inventory/snowyball", fn, assets) 
