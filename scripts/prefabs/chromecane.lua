local assets =
{
    Asset("ANIM", "anim/chromecane.zip"),
    Asset("ANIM", "anim/swap_chromecane.zip"),
	
	Asset("ATLAS", "images/inventoryimages/chromecane.xml"),
    Asset("IMAGE", "images/inventoryimages/chromecane.tex"),
}


--8% chance on hit to spawn electricity fx + do x2 damage (34 damage)
--Drains user health by 1.


local chance = 0.08 --Maybe revert to 10% if needed.
local electric = false

local function onattack(inst, owner, target)
    --Check if the attack is electric. If it is, then the weapon should already be charged, so uncharge it.
    if electric then
        electric = false
        SpawnPrefab("electrichitsparks").Transform:SetPosition(target:GetPosition():Get())
        inst.components.weapon:SetDamage(17) --Cane Damage
    end
    --This will charge the next attack.
    if math.random() < chance and not target:HasTag("wall") and not target:HasTag("chester") then
        electric = true
        inst.components.weapon:SetDamage(17*3) --Triple Damage
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_chromecane", "swap_chromecane")
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

    inst.AnimState:SetBank("chromecane")
    inst.AnimState:SetBuild("chromecane")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cane")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(17) --Cane Damage
	inst.components.weapon:SetOnAttack(onattack)	

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "chromecane"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/chromecane.xml"

    inst:AddComponent("equippable")

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY	
    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/chromecane", fn, assets)