local assets =
{
    Asset("ANIM", "anim/malamilantern.zip"),
    Asset("ANIM", "anim/swap_malamilantern_skin.zip"),
    Asset("ANIM", "anim/swap_malamilantern_skin_on.zip"),
    Asset("SOUND", "sound/wilson.fsb"),

    Asset("ATLAS", "images/inventoryimages/malamilantern_skin.xml"),
    Asset("IMAGE", "images/inventoryimages/malamilantern_skin.tex"),
    Asset("ATLAS", "images/inventoryimages/malamilantern_skin_lit.xml"),
    Asset("IMAGE", "images/inventoryimages/malamilantern_skin_lit.tex"),
}

local FIRST_FERTILIZE_COOLDOWN = 2  -- cooldown after fertilization starts
local FERTILIZE_COOLDOWN = 5        -- periodic cooldown between fertilization while remaining on
local FERTILIZE_DURATION = 6
local FERTILIZE_RADIUS = 10
local FERTILZE_SPEED_MULT = 3

local function StopGrowthBoost(inst)
    if inst._boostedfx ~= nil then
        inst._boostedfx:Kill()
        inst._boostedfx = nil
    end

    if inst._boostedtask ~= nil then
        inst._boostedtask:Cancel()
        inst._boostedtask = nil
    end

    if not inst.components.growable or inst.components.growable.targettime == nil
        or inst._boostedstage ~= inst.components.growable:GetStage() then
        return
    end

    local pausedremaining = inst.components.growable.pausedremaining
    if pausedremaining then
        inst.components.growable.pausedremaining = pausedremaining * FERTILZE_SPEED_MULT
        return
    end

    local remaining_time = inst.components.growable.targettime - GetTime()

    if remaining_time > 0 then

        -- Growable:StartGrowing() forces spring growth multiplier...
        if inst.components.growable.springgrowth and TheWorld.state.isspring then
            remaining_time = remaining_time / TUNING.SPRING_GROWTH_MODIFIER
        end

        inst.components.growable:StartGrowing(remaining_time * FERTILZE_SPEED_MULT)
    end
end

local function DoGrowthBoost(inst)
    if inst.components.fueled == nil or inst.components.fueled:IsEmpty() then
        return
    end

    local pt = inst:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, FERTILIZE_RADIUS, {"farm_plant"})
    for k, crop in ipairs(ents) do
        if crop:IsValid() and not crop.components.pickable and
            crop.components.growable and crop.components.growable:IsGrowing() then

            if crop._boostedfx == nil then
                crop._boostedfx = crop:SpawnChild("quagmire_wormwood_fx")
            end

            local remaining_time = crop.components.growable.targettime - GetTime()

            if crop._boostedtask == nil then
                remaining_time = remaining_time / FERTILZE_SPEED_MULT

                -- Growable:StartGrowing() forces spring growth multiplier...
                if crop.components.growable.springgrowth and TheWorld.state.isspring then
                    remaining_time = remaining_time / TUNING.SPRING_GROWTH_MODIFIER
                end

                crop.components.growable:StartGrowing(remaining_time)
                crop._boostedstage = crop.components.growable:GetStage()
            else
                crop._boostedtask:Cancel()
            end

            crop._boostedtask = crop:DoTaskInTime(math.min(FERTILIZE_DURATION, remaining_time), StopGrowthBoost)
        end
    end
end

local function onstartboostingfn(inst)
    if inst._task ~= nil then
        inst._task:Cancel()
    end

    inst._task = inst:DoTaskInTime(FIRST_FERTILIZE_COOLDOWN, function(inst)
        inst._task = inst:DoPeriodicTask(FERTILIZE_COOLDOWN, DoGrowthBoost)
        DoGrowthBoost(inst)
    end)
end

local function onstopboostingfn(inst)
    if inst._task ~= nil then
        inst._task:Cancel()
    end
    inst._task = nil

    -- one last boost so nearby crops get full duration
    DoGrowthBoost(inst)
end

local function fuelupdate(inst)
    if inst._light ~= nil then
        local fuelpercent = inst.components.fueled:GetPercent()
        inst._light.Light:SetIntensity(Lerp(0.4, 0.6, fuelpercent)) --0.75
        inst._light.Light:SetRadius(Lerp(7, 11, fuelpercent))
        inst._light.Light:SetFalloff(.9)
    end
end

local function turnon(inst)
    if inst.components.fueled ~= nil and not inst.components.fueled:IsEmpty() then
        inst.components.fueled:StartConsuming()

        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil

        if inst._light == nil or not inst._light:IsValid() then
            inst._light = SpawnPrefab("opulentlanternlight")
            fuelupdate(inst)
        end
        inst._light.entity:SetParent((owner or inst).entity)

        inst.AnimState:PlayAnimation("idle_skin_on")

        if owner ~= nil and inst.components.equippable:IsEquipped() then
            owner.AnimState:OverrideSymbol("swap_object", "swap_malamilantern_skin", "swap_malamilantern_skin")
            owner.AnimState:Show("LANTERN_OVERLAY")
        end

        inst.components.machine.ison = true

        inst.SoundEmitter:PlaySound("dontstarve/wilson/lantern_on")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/lantern_LP", "loop")

        inst.components.inventoryitem.atlasname = "images/inventoryimages/malamilantern_skin_lit.xml"
        inst.components.inventoryitem:ChangeImageName("malamilantern_skin_lit")

        inst:OnStartBoosting()
    end
end

local function turnoff(inst)
    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end

    if inst._light ~= nil then
        if inst._light:IsValid() then
            inst._light:Remove()
        end
        inst._light = nil
    end

    inst.AnimState:PlayAnimation("idle_skin_off")

    if inst.components.equippable:IsEquipped() then
        inst.components.inventoryitem.owner.AnimState:OverrideSymbol("swap_object", "swap_malamilantern_skin", "swap_malamilantern_skin")
        inst.components.inventoryitem.owner.AnimState:Hide("LANTERN_OVERLAY")
    end

    inst.components.machine.ison = false

    inst.SoundEmitter:KillSound("loop")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/lantern_off")

    inst.components.inventoryitem.atlasname = "images/inventoryimages/malamilantern_skin.xml"
    inst.components.inventoryitem:ChangeImageName("malamilantern_skin")

    inst:OnStopBoosting()
end

local function OnRemove(inst)
    if inst._light ~= nil and inst._light:IsValid() then
        inst._light:Remove()
    end
end

local function ondropped(inst)
    turnoff(inst)
    turnon(inst)
end

local function onequip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:OverrideSymbol("lantern_overlay", "swap_malamilantern_skin_on", "swap_malamilantern_skin_on")

    if inst.components.fueled:IsEmpty() then
        owner.AnimState:OverrideSymbol("swap_object", "swap_malamilantern_skin", "swap_malamilantern_skin")
        owner.AnimState:Hide("LANTERN_OVERLAY")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_malamilantern_skin", "swap_malamilantern_skin")
        owner.AnimState:Show("LANTERN_OVERLAY")
    end
    turnon(inst)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("lantern_overlay")
    owner.AnimState:Hide("LANTERN_OVERLAY")
end

local function nofuel(inst)
    local equippable = inst.components.equippable
    if equippable ~= nil and equippable:IsEquipped() then
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if owner ~= nil then
            local data =
            {
                prefab = inst.prefab,
                equipslot = equippable.equipslot,
            }
            turnoff(inst)
            owner:PushEvent("torchranout", data)
            return
        end
    end
    turnoff(inst)
end

local function takefuel(inst)
    if inst.components.equippable and inst.components.equippable:IsEquipped() then
        turnon(inst)
    end
end

local function lanternlightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetColour(215 / 255, 230 / 255, 250 / 255) --(.65, .65, .5)  --(125 / 255, 250 / 255, 80 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("malamilantern")
    inst.AnimState:SetBuild("malamilantern")
    inst.AnimState:PlayAnimation("idle_skin_off")

    inst:AddTag("light")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "malamilantern_skin"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/malamilantern_skin.xml"
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(turnoff)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
    inst.components.machine.cooldowntime = 0

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.BURNABLE
    inst.components.fueled.secondaryfueltype = FUELTYPE.CAVE
    inst.components.fueled:InitializeFuelLevel(TUNING.LANTERN_LIGHTTIME * 0.75)
    inst.components.fueled:SetDepletedFn(nofuel)
    inst.components.fueled:SetUpdateFn(fuelupdate)
    inst.components.fueled.ontakefuelfn = takefuel
    inst.components.fueled.accepting = true

    inst._light = nil
    inst._task = nil

    inst.OnStartBoosting = onstartboostingfn
    inst.OnStopBoosting = onstopboostingfn

    MakeHauntableLaunch(inst)

    inst.OnRemoveEntity = OnRemove

    return inst
end

return Prefab("common/inventory/opulentlantern", fn, assets),
       Prefab("common/inventory/opulentlanternlight", lanternlightfn)