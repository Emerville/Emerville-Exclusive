local assets = 
{
    Asset("ANIM", "anim/casinoamulets.zip"),
    Asset("ANIM", "anim/torso_casinoamulets.zip"),
    Asset("ANIM", "anim/wilton.zip"),
	
    Asset("ATLAS", "images/inventoryimages/reaperamulet.xml"),
    Asset("IMAGE", "images/inventoryimages/reaperamulet.tex"),
}

local function SpawnBone(inst, owner)
    local bone = SpawnPrefab("boneshard")
	bone.Transform:SetPosition(inst.Transform:GetWorldPosition())	
end

local function CheckEquiped(inst, owner)
    if owner and inst.components.equippable:IsEquipped() then
        owner.AnimState:SetBuild("wilton")

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

    owner.AnimState:SetBuild("wilton")
    owner.AnimState:OverrideSymbol("swap_body", "torso_casinoamulets", "torso_casinoamulets")
    inst.bone_task = inst:DoPeriodicTask(240, function() SpawnBone(inst, owner) end) --480 Day

    inst.equipped = true
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
	
    inst.bone_task:Cancel()
    inst.bone_task = nil

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

    inst.AnimState:SetBank("casinoamulets")
    inst.AnimState:SetBuild("casinoamulets")
    inst.AnimState:PlayAnimation("reaperamulet")

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
	inst.components.equippable.dapperness = -TUNING.DAPPERNESS_SMALL

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "reaperamulet"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/reaperamulet.xml"

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("common/inventory/reaperamulet2", init, assets)
