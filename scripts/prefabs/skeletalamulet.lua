local assets = {
    Asset("ANIM", "anim/skeletalamulet.zip"),
    Asset("ANIM", "anim/torso_skeletalamulet.zip"),
    Asset("ATLAS", "images/inventoryimages/skeletalamulet.xml"),
    Asset("IMAGE", "images/inventoryimages/skeletalamulet.tex"),
    Asset("ANIM", "anim/reaper.zip")
}

local function CheckEquiped(inst, owner)
    if owner and inst.components.equippable:IsEquipped() then
        owner.AnimState:SetBuild("reaper")

        if inst.taskskel ~= nil then
            inst.taskskel:Cancel()
            inst.taskskel = nil
        end
    end
end

local function OnEquip(inst, owner)
    if inst.skins == nil and owner.components.skinner then
        inst.skins = owner.components.skinner:GetClothing()
        owner.components.skinner:ClearAllClothing()
    end

    owner.AnimState:SetBuild("reaper")
    owner.AnimState:OverrideSymbol("swap_body", "torso_skeletalamulet", "torso_skeletalamulet")

    inst.equipped = true

    if owner.components.sanity then
        owner.components.sanity:DoDelta(-25)
    end
end

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:SetBuild(owner.prefab)

    if owner.components.skinner then
        owner.components.skinner:SetClothing(inst.skins.body)
        owner.components.skinner:SetClothing(inst.skins.hand)
        owner.components.skinner:SetClothing(inst.skins.legs)
        owner.components.skinner:SetClothing(inst.skins.feet)
        inst.skins = nil
    end

    inst.equipped = false

    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end

    if inst.taskskel ~= nil then
        inst.taskskel:Cancel()
        inst.taskskel = nil
    end
end

local function OnSave(inst, data)
    data.skins = inst.skins
end

local function OnLoad(inst, data)
    if data and data.skins then
        inst.skins = data.skins
    end
end

local function init()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("skeletalamulet")
    inst.AnimState:SetBuild("skeletalamulet")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("casino")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "skeletalamulet"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skeletalamulet.xml"

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("common/inventory/skeletalamulet", init, assets)
