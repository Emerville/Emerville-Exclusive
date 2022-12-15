local assets =
{
    Asset("ANIM", "anim/gears_hat_goggles.zip"),
--  Asset("IMAGE", "images/colour_cubes/goggles_on_cc.tex"),
--  Asset("IMAGE", "images/colour_cubes/goggles_off_cc.tex"),
    Asset("ATLAS", "images/inventoryimages/gears_hat_goggles.xml"),
    Asset("IMAGE", "images/inventoryimages/gears_hat_goggles.tex"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_hat", "gears_hat_goggles", "swap_hat")

    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAT_HAIR")

    inst.components.fueled:StartConsuming()
    
    owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_on")
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_hat")
    
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAT_HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end

    inst.components.fueled:StopConsuming()

    owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_off")
end

local function ondepleted(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    if owner ~= nil then
        owner:PushEvent("torchranout", { torch = inst })
    end

    local replacement = SpawnPrefab("gearbox")
    local x, y, z = inst.Transform:GetWorldPosition()
    replacement.Transform:SetPosition(x, y, z)

    local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
    if holder ~= nil then
        local slot = holder:GetItemSlot(inst)
        holder:GiveItem(replacement, slot)
    end

    inst:Remove()
end

local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("gears_hat_goggles")
    inst.AnimState:SetBuild("gears_hat_goggles")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("nightvision")
    inst:AddTag("hat")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "gears_hat_goggles"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/gears_hat_goggles.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.BURNABLE
    inst.components.fueled.secondaryfueltype = FUELTYPE.CAVE
    inst.components.fueled:InitializeFuelLevel(TUNING.TOTAL_DAY_TIME * .75)
    inst.components.fueled:SetDepletedFn(ondepleted)
    inst.components.fueled.accepting = true

    --[[
    inst:ListenForEvent("daytime", function(it)
    if GetWorld():IsCave() then return end
        if inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem:GetGrandOwner() == GetPlayer() and not GetWorld():IsCave() then
            GetWorld().components.colourcubemanager:SetOverrideColourCube(resolvefilepath("images/colour_cubes/goggles_off_cc.tex", 2))
        end
    end, GetWorld())
        inst:ListenForEvent("dusktime", function(it)
    if GetWorld():IsCave() then return end
        if inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem:GetGrandOwner() == GetPlayer() then
            if GetWorld() and GetWorld().components.colourcubemanager then
                GetWorld().components.colourcubemanager:SetOverrideColourCube(resolvefilepath("images/colour_cubes/goggles_on_cc.tex", 2))
            end
        end
    end, GetWorld())
        inst:ListenForEvent("nighttime", function(it)
    if GetWorld():IsCave() then return end
        if inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem:GetGrandOwner() == GetPlayer() then
            if GetWorld() and GetWorld().components.colourcubemanager then
                GetWorld().components.colourcubemanager:SetOverrideColourCube(resolvefilepath("images/colour_cubes/goggles_on_cc.tex", 2))
            end
        end
    end, GetWorld())
    ]]

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/gears_hat_goggles", fn, assets )
