local assets =
{
	Asset("ANIM", "anim/thorn_crown.zip"),
	
	Asset("ATLAS", "images/inventoryimages/thorn_crown.xml"),
	Asset("IMAGE", "images/inventoryimages/thorn_crown.tex"),
}

local chance_effect = 0.20

local function procfn(inst, data)
    if data.attacker ~= nil then
        if math.random() < chance_effect then
            if data.attacker and data.attacker.components.health and data.attacker.components.combat then
            data.attacker.components.combat:GetAttacked(inst, 100) -- Damage done to attacker
                SpawnPrefab("statue_transition_2").Transform:SetPosition(data.attacker:GetPosition():Get())
            end
        else if data.attacker and data.attacker.components.health and data.attacker.components.combat then	
            data.attacker.components.combat:GetAttacked(inst, 25) -- Damage done to attacker
        end
    end -- IT SHOULD WORK NOW.
end
--

local function OnEquip(inst, owner, data)
    owner.AnimState:OverrideSymbol("swap_hat", "thorn_crown", "swap_hat")
	
    owner.AnimState:Show("HAT")
    owner.AnimState:Hide("HAT_HAIR")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")
    owner.AnimState:Show("HEAD")
    owner.AnimState:Hide("HEAD_HAIR")
	
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
        owner.AnimState:Hide("HEAD_HAIR")
    end
	--
    owner:RemoveEventCallback("attacked", inst.tryproc)
    --
end

local function onfinishedfn(inst)
    local replacement = SpawnPrefab("goldcoin")
    local x, y, z = inst.Transform:GetWorldPosition()
    replacement.Transform:SetPosition(x, y, z)
    replacement.components.stackable:SetStackSize(6)

    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
    if holder ~= nil then
        local slot = holder:GetItemSlot(inst)
        holder:GiveItem(replacement, slot)
    end

    inst:Remove()
end

local function fn()
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()	
	
    MakeInventoryPhysics(inst)
       
    inst.AnimState:SetBank("flowerhat")
    inst.AnimState:SetBuild("thorn_crown")
    inst.AnimState:PlayAnimation("anim")  

    inst:AddTag("hat")
    inst:AddTag("casino")

    inst.entity:SetPristine()	
	
    if not TheWorld.ismastersim then
        return inst
    end	

    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "thorn_crown"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/thorn_crown.xml"	

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(1000, 0.9)
    inst.components.armor.onfinished = function() onfinishedfn(inst) end

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    
    MakeHauntableLaunch(inst)	

    return inst
end

return Prefab("common/inventory/thorn_crown", fn, assets)
