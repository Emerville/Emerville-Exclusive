local assets = {
    Asset("ANIM", "anim/scythe.zip"),
    Asset("ANIM", "anim/swap_scythe.zip"),
    Asset("IMAGE", "images/inventoryimages/scythe.tex"),
    Asset("ATLAS", "images/inventoryimages/scythe.xml"),
}

local soul_drop_chance = 0.5

-- The scythe will emit a small light if it has fuel.
local function TurnOn(inst)
    if not inst.components.fueled:IsEmpty() then
        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
            inst.Light:Enable(true)
            inst:AddTag("light")
        end
    end
end

-- The scythe will stop emitting light.
local function TurnOff(inst)
    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
        inst.Light:Enable(false)
        inst:RemoveTag("light")
    end
end

-- When a mob is killed with the Scythe, it has a chance of reaping a soul.
local function OnKilled(inst, data)
    if math.random() < soul_drop_chance then
        local x, y, z = data.victim.Transform:GetWorldPosition()
        local px, py, pz = inst.Transform:GetWorldPosition()
        SpawnPrefab("reaper_soul").Transform:SetPosition(x, y, z)
        SpawnPrefab("wathgrithr_spirit").Transform:SetPosition(px, py, pz)
    end
end

-- Equips the Scythe and activates its light and reaping powers.
local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_scythe", "swap_scythe")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    inst:ListenForEvent("killed", OnKilled, owner)
    TurnOn(inst)
end

-- Unequips the Scythe and deactivates its light and reaping powers.
local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    inst:RemoveEventCallback("killed", OnKilled, owner)
    TurnOff(inst)
end

-- Plays a slash visual effect when the Scythe is swung.
local function OnAttack(inst, owner, target)
    SpawnPrefab("shadowstrike_slash2_fx").Transform:SetPosition(target:GetPosition():Get())
end

-- Turns off the Scythe's light when it runs of out fuel.
local function NoFuel(inst)
    SpawnPrefab("statue_transition").Transform:SetPosition(inst:GetPosition():Get())
    inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
    local equippable = inst.components.equippable
    if equippable ~= nil and equippable:IsEquipped() then
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if owner ~= nil then
            local data = {
                prefab = inst.prefab,
                equipslot = equippable.equipslot
            }
            TurnOff(inst)
            return
        end
    end
    TurnOff(inst)
end

-- Adds fuel to the Scythe (accepts nightmare fuel).
local function TakeFuel(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
    if inst.components.equippable and inst.components.equippable:IsEquipped() then
        TurnOn(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("scythe")
    inst.AnimState:SetBuild("scythe")
    inst.AnimState:PlayAnimation("idle")

    local light = inst.entity:AddLight()
    inst.Light:SetIntensity(0.65)
    inst.Light:SetRadius(1.5)
    inst.Light:SetFalloff(1)
    light:SetColour(180 / 255, 0 / 255, 255 / 255)
    inst.Light:Enable(false)

    inst:AddTag("sharp")
    inst:AddTag("scythe")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetOnAttack(OnAttack)
    inst.components.weapon:SetDamage(25)
    inst.components.weapon:SetRange(1.10)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "scythe"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/scythe.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.walkspeedmult = 1.10 -- TUNING.CANE_SPEED_MULT

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.NIGHTMARE
    inst.components.fueled:InitializeFuelLevel(TUNING.TOTAL_DAY_TIME)
    inst.components.fueled:SetDepletedFn(NoFuel)
    inst.components.fueled.ontakefuelfn = TakeFuel
    inst.components.fueled.accepting = true

    inst:ListenForEvent("killed", OnKilled)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/scythe", fn, assets)
