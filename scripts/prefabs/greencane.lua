local assets =
{
    Asset("ANIM", "anim/greencane.zip"),
    Asset("ANIM", "anim/swap_greencane.zip"),
	
	Asset("ATLAS", "images/inventoryimages/green_cane.xml"),
    Asset("IMAGE", "images/inventoryimages/green_cane.tex"),
}

--[[local function onattack(inst, owner, target)
    if owner.components.health and not target:HasTag("wall") then
        owner.components.sanity:DoDelta(-TUNING.BATBAT_DRAIN * 0.125)
    end
end]]

local chance = 0.30 --33%

local function onattack(inst, owner, target)
	if math.random() < chance then
    if owner.components.health and not target:HasTag("wall") then
        owner.components.sanity:DoDelta(TUNING.BATBAT_DRAIN * 0.125)
		end
	end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_greencane", "swap_greencane")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("greencane")
    inst.AnimState:SetBuild("greencane")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.CANE_DAMAGE)
	inst.components.weapon:SetOnAttack(onattack)	

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "green_cane"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/green_cane.xml"

    inst:AddComponent("equippable")

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY	
    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/greencane", fn, assets)