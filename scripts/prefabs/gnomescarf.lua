local assets = 
{
    Asset("ANIM", "anim/casinoamulets.zip"),
    Asset("ANIM", "anim/torso_gnomescarf.zip"),
	
    Asset("ATLAS", "images/inventoryimages/reaperamulet.xml"),
    Asset("IMAGE", "images/inventoryimages/reaperamulet.tex"),
}

local function SpawnBone(inst, owner)
    local bone = SpawnPrefab("boneshard")
	bone.Transform:SetPosition(inst.Transform:GetWorldPosition())	
end

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_gnomescarf", "torso_gnomescarf")
    inst.bone_task = inst:DoPeriodicTask(240, function() SpawnBone(inst, owner) end) --480 Day
end

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
	
    inst.bone_task:Cancel()
    inst.bone_task = nil
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


    return inst
end

return Prefab("common/inventory/gnomescarf", init, assets)
