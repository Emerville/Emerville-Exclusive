local assets =
{
    Asset("ANIM", "anim/purplecane.zip"),
    Asset("ANIM", "anim/swap_purplecane.zip"),

    Asset("ATLAS", "images/inventoryimages/purplecane.xml"),
    Asset("IMAGE", "images/inventoryimages/purplecane.tex"),
}

local prefabs =
{
    "lightning_barrier",
}

local CANE_SPEED_BUFFED = TUNING.CANE_SPEED_MULT + 0.35
local CANE_BUFF_DURATION = 5
local CANE_ARMOR_COOLDOWN = 240
local CANE_ARMOR_FIRST_COOLDOWN = 5 -- minimum cooldown after re-equipped
local SHIELD_DURATION = 10 * FRAMES
local SANITY_CHANGE_ON_BUFF = -15
local RESISTANCES = {
    "_combat"
}

local function OnBuff(inst)
    if inst._fx then
        inst._fx:kill_fx()
    end
    local owner = inst.components.inventoryitem:GetGrandOwner() or inst
    inst._fx = SpawnPrefab("lightning_barrier")
    inst._fx.Transform:SetPosition(0, 1.5, 0)
    inst._fx.entity:SetParent(owner.entity)

    inst.components.equippable.walkspeedmult = CANE_SPEED_BUFFED
    owner.components.sanity:DoDelta(SANITY_CHANGE_ON_BUFF)
end

local function OnBuffOver(inst, owner)
    if inst._fx then
        inst._fx:kill_fx()
        inst._fx = nil
    end

    local owner = inst.components.inventoryitem:GetGrandOwner() or inst
    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT

    inst.buff_task = nil
end

local function OnShieldOver(inst, OnResistDamage)
    for i, v in ipairs(RESISTANCES) do
        inst.components.resistance:RemoveResistance(v)
    end
    inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
    
    inst.shield_task = nil
end

local function OnResistDamage(inst)
    if inst.shield_task ~= nil then
        inst.shield_task:Cancel()
    end
    inst.shield_task = inst:DoTaskInTime(SHIELD_DURATION, OnShieldOver, OnResistDamage)
    inst.components.resistance:SetOnResistDamageFn(nil)
    
    if inst.buff_task ~= nil then
        inst.buff_task:Cancel()
    end
    inst.buff_task = inst:DoTaskInTime(CANE_BUFF_DURATION, OnBuffOver)
    OnBuff(inst)

    if inst.components.cooldown.onchargedfn ~= nil then
        inst.components.cooldown:StartCharging()
    end
end

local function ShouldResistFn(inst)
    if not inst.components.equippable:IsEquipped() then
        return false
    end
    local owner = inst.components.inventoryitem.owner
    return owner ~= nil and not (owner.components.inventory ~= nil and owner.components.inventory:EquipHasTag("forcefield"))
end

local function OnChargedFn(inst)
    if inst.shield_task ~= nil then
        inst.shield_task:Cancel()
        inst.shield_task = nil
        inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
    end

    for i, v in ipairs(RESISTANCES) do
        inst.components.resistance:AddResistance(v)
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_purplecane", "swap_purplecane")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    inst.components.cooldown.onchargedfn = OnChargedFn
    inst.components.cooldown:StartCharging(math.max(CANE_ARMOR_FIRST_COOLDOWN, inst.components.cooldown:GetTimeToCharged()))
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    
    if inst.shield_task ~= nil then
        inst.shield_task:Cancel()
        inst.shield_task = nil
        inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
    end

    if inst.buff_task ~= nil then
        inst.buff_task:Cancel()
        inst.buff_task = nil
        OnBuffOver(inst)
    end

    for i, v in ipairs(RESISTANCES) do
        inst.components.resistance:RemoveResistance(v)
    end

end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("purplecane")
    inst.AnimState:SetBuild("purplecane")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cane")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.CANE_DAMAGE)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "purplecane"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/purplecane.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY
    
    inst:AddComponent("resistance")
    inst.components.resistance:SetShouldResistFn(ShouldResistFn)
    inst.components.resistance:SetOnResistDamageFn(OnResistDamage)

    inst:AddComponent("cooldown")
    inst.components.cooldown.cooldown_duration = CANE_ARMOR_COOLDOWN

    MakeHauntableLaunch(inst)

    inst.shield_task = nil
    inst.buff_task = nil
    inst._fx = nil

    return inst
end

return Prefab("common/inventory/purplecane", fn, assets)