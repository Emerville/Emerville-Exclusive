local assets =
{
    Asset("ANIM", "anim/gears_staff.zip"),
    Asset("ANIM", "anim/swap_gears_staff.zip"),
    Asset("ATLAS", "images/inventoryimages/gearstaff.xml"),
    Asset("IMAGE", "images/inventoryimages/gearstaff.tex"),
}

local function onpocket(inst)
    inst.components.burnable:Extinguish()
end

local function ondropped(inst)
   inst.Light:Enable(false)
end

local function onequip(inst, owner)
    inst.components.burnable:Ignite()
    owner.AnimState:OverrideSymbol("swap_object", "swap_gears_staff", "swap_nightmaresword")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/morningstar", "torch")
    inst.Light:Enable(true)

    inst:DoTaskInTime(0, function()
        if inst.components.fueled.currentfuel < inst.components.fueled.maxfuel then
            inst.components.fueled:DoDelta(-inst.components.fueled.maxfuel * .01)
        end
    end)
end

local function onunequip(inst, owner)
    inst.components.burnable:Extinguish()
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    inst.SoundEmitter:KillSound("torch")
    inst.Light:Enable(false)
end

local function onattack(inst, owner, target)
    if owner.components.health and not target:HasTag("shadow") and not target:HasTag("shadowchesspiece") then
        owner.components.sanity:DoDelta(2.5, false, "gears_staff")
        inst.components.weapon:SetDamage(TUNING.SPEAR_DAMAGE)
    else
        owner.components.sanity:DoDelta(5, false, "gears_staff")
        inst.components.weapon:SetDamage(TUNING.SPEAR_DAMAGE * 2)
        SpawnPrefab("statue_transition").Transform:SetPosition(target:GetPosition():Get())
    end
end

local function ondepleted(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")

    local replacement = SpawnPrefab("gearbox")
    local x, y, z = inst.Transform:GetWorldPosition()
    replacement.Transform:SetPosition(x, y, z)

    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
    if holder ~= nil then
        local slot = holder:GetItemSlot(inst)
        holder:GiveItem(replacement, slot)
    end

    inst:Remove()
end

local function ontakefuel(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("nightmaresword")
    inst.AnimState:SetBuild("gears_staff")
    inst.AnimState:PlayAnimation("idle")

    inst.Light:SetRadius(1.5)
    inst.Light:SetFalloff(0.4)
    inst.Light:SetIntensity(0.75)
    inst.Light:SetColour(255/255, 255/255, 155/255)
    inst.Light:Enable(false)

    inst:AddTag("light")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SPEAR_DAMAGE)
    inst.components.weapon.onattack = onattack

    -------
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "gearstaff"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/gearstaff.xml"

    inst.components.inventoryitem:SetOnDroppedFn(ondropped)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnPocket(onpocket)
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.dapperness = TUNING.CRAZINESS_SMALL

    inst:AddComponent("burnable")
    inst.components.burnable.canlight = false
    inst.components.burnable.fxprefab = nil

    inst:AddComponent("fueled")
    inst.components.fueled:InitializeFuelLevel(TUNING.TOTAL_DAY_TIME * .75)
    inst.components.fueled.accepting = true
    inst.components.fueled.fueltype = FUELTYPE.NIGHTMARE
    inst.components.fueled.ontakefuelfn = ontakefuel
    inst.components.fueled:SetDepletedFn(ondepleted)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/gearstaff", fn, assets)