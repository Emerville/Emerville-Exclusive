local assets =
{
    Asset("ANIM", "anim/purplecane.zip"),
    Asset("ANIM", "anim/swap_purplecane.zip"),

    Asset("ATLAS", "images/inventoryimages/purplecane.xml"),
    Asset("IMAGE", "images/inventoryimages/purplecane.tex"),
}

local prefabs =
{
    "pinkfieldfx", -- to be changed to its own fx ...
}

local MIN_DAMAGE = 15
local SPEED_BUFF = 0.35
local BUFF_DURATION = 5
local BUFF_COOLDOWN = 30

local function OnBuff(inst, owner)
    if inst._fx then
        inst._fx:kill_fx()
    end
    inst._fx = SpawnPrefab("pinkfieldfx") -- to be changed to its own fx ...
    inst._fx.Transform:SetPosition(0, 0.2, 0) -- to be adjusted along new fx ...
    inst._fx.entity:SetParent(owner.entity)

    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT + SPEED_BUFF
end

local function OnBuffOver(inst, owner)
    if inst._fx then
        inst._fx:kill_fx()
    end

    if inst ~= nil and owner ~= nil then
        inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT
        inst.task = nil
    end
end

local function OnOwnerAttacked(inst, owner, data)
    if inst.components.cooldown and inst.components.cooldown:IsCharged()
        and data.damageresolved >= MIN_DAMAGE then
        if inst.task ~= nil then
            inst.task:Cancel()
        end
        inst.task = inst:DoTaskInTime(BUFF_DURATION, OnBuffOver, inst, owner)
        inst.components.cooldown:StartCharging(BUFF_COOLDOWN)

        OnBuff(inst, owner)
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_purplecane", "swap_purplecane")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    inst:ListenForEvent("attacked", inst.onownerattackedfn, owner)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    inst:RemoveEventCallback("attacked", inst.onownerattackedfn, owner)

    if inst.task ~= nil then
        inst.task:Cancel()
        OnBuffOver(inst, owner)
        inst.task = nil
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

    inst:AddTag("weapon")

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

    inst:AddComponent("cooldown")

    MakeHauntableLaunch(inst)

    inst.onownerattackedfn = function(owner, data) OnOwnerAttacked(inst, owner, data) end
    inst.task = nil

    return inst
end

return Prefab("common/inventory/purplecane", fn, assets)