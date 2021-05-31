require("prefabs/mushtree_spores")

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

local function IsLightOn(inst)
    return inst.Light:IsEnabled()
end

local light_str =
{
    {radius = 2.5, falloff = .85, intensity = 0.75},
    {radius = 3.25, falloff = .85, intensity = 0.75},
    {radius = 4.25, falloff = .85, intensity = 0.75},
    {radius = 5.5, falloff = .85, intensity = 0.75},
}
local fulllight_light_str =
{
    radius = 5.5, falloff = 0.85, intensity = 0.75
}

local colour_tint = { 0.4, 0.3, 0.25, 0.2, 0.1 }
local mult_tint = { 0.7, 0.6, 0.55, 0.5, 0.45 }

local sounds_2 =
{
    toggle = "dontstarve/common/together/mushroom_lamp/lantern_2_on",
    colour = "dontstarve/common/together/mushroom_lamp/change_colour",
    craft = "dontstarve/common/together/mushroom_lamp/craft_2",
}

local function ClearSoundQueue(inst)
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
        inst._soundtask = nil
    end
end

local function OnQueuedSound(inst, soundname)
    inst._soundtask = nil
    inst.SoundEmitter:PlaySound(soundname)
end

local function QueueSound(inst, delay, soundname)
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
    end
    inst._soundtask = inst:DoTaskInTime(delay, OnQueuedSound, soundname)
end

local COLOURED_LIGHTS =
{
    red =
    {
        [MUSHTREE_SPORE_RED] = true,
        ["winter_ornament_light1"] = true,
        ["winter_ornament_light5"] = true,
    },

    green =
    {
        [MUSHTREE_SPORE_GREEN] = true,
        ["winter_ornament_light2"] = true,
        ["winter_ornament_light6"] = true,
    },

    blue =
    {
        [MUSHTREE_SPORE_BLUE] = true,
        ["winter_ornament_light3"] = true,
        ["winter_ornament_light7"] = true,
    },
}

local function IsRedSpore(item)
    if COLOURED_LIGHTS.red[item.prefab] then
        return true
    elseif item.components.container ~= nil then
        return item.components.container:FindItem(IsRedSpore) ~= nil
    else
        return false
    end
end

local function IsGreenSpore(item)
    if COLOURED_LIGHTS.green[item.prefab] then
        return true
    elseif item.components.container ~= nil then
        return item.components.container:FindItem(IsGreenSpore) ~= nil
    else
        return false
    end
end

local function IsBlueSpore(item)
    if COLOURED_LIGHTS.blue[item.prefab] then
        return true
    elseif item.components.container ~= nil then
        return item.components.container:FindItem(IsBlueSpore) ~= nil
    else
        return false
    end
end

local function is_battery_type(item)
    return item:HasTag("lightbattery")
        or item:HasTag("spore")
        or item:HasTag("lightcontainer")
end

local function is_fulllighter(item)
    return item:HasTag("fulllighter")
end

local function UpdateLightState(inst)
    if not inst.components.fueled:IsEmpty() then

    ClearSoundQueue(inst)

    local sound = sounds_2
    local num_batteries = #inst.components.container:FindItems(is_battery_type)
		
    if num_batteries > 0 then
        local num_fulllights = #inst.components.container:FindItems(is_fulllighter)

        local new_perishrate = (num_fulllights > 0 and 0) or TUNING.PERISH_MUSHROOM_LIGHT_MULT
        inst.components.preserver:SetPerishRateMultiplier(new_perishrate)		

        if num_fulllights > 0 then
            inst.Light:SetRadius(fulllight_light_str.radius)
            inst.Light:SetFalloff(fulllight_light_str.falloff)
            inst.Light:SetIntensity(fulllight_light_str.intensity)
        else
            inst.Light:SetRadius(light_str[num_batteries].radius)
            inst.Light:SetFalloff(light_str[num_batteries].falloff)
            inst.Light:SetIntensity(light_str[num_batteries].intensity)
        end

            -- For the GlowCap, spores will tint the light colour to allow for a disco/rave in your base
            local r = #inst.components.container:FindItems(IsRedSpore)
            local g = #inst.components.container:FindItems(IsGreenSpore)
            local b = #inst.components.container:FindItems(IsBlueSpore)

            inst._light.Light:SetColour(colour_tint[g+b + 1] + r/11, colour_tint[r+b + 1] + g/11, colour_tint[r+g + 1] + b/11)
            inst.AnimState:SetMultColour(mult_tint[g+b + 1], mult_tint[r+b + 1], mult_tint[r+g + 1], 1)

            inst.SoundEmitter:PlaySound("dontstarve/common/together/mushroom_lamp/lantern_2_on") --I can't make it work, sad times.
 --           QueueSound(inst, 13 * FRAMES, sound.colour)
		end
    end
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
    if not inst.components.fueled:IsEmpty() then
        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end

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
    inst.AnimState:SetMultColour(.7, .7, .7, 1) 
	
    inst.Light:SetColour(.65, .65, .5)
    inst.Light:Enable(false)

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

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("opulentlantern")

    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(TUNING.PERISH_MUSHROOM_LIGHT_MULT)

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

    inst:ListenForEvent("itemget", UpdateLightState)
    inst:ListenForEvent("itemlose", UpdateLightState)

    inst._light = nil

    MakeHauntableLaunch(inst)

    inst.OnRemoveEntity = OnRemove

    return inst
end

return Prefab("common/inventory/opulentlantern", fn, assets),
       Prefab("common/inventory/opulentlanternlight", lanternlightfn)