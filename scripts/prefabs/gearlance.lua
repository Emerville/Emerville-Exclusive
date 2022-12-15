local assets =
{
    Asset("ANIM", "anim/gears_mace.zip"),
    Asset("ANIM", "anim/swap_gears_mace.zip"),
    Asset("ATLAS", "images/inventoryimages/gearlance.xml"),
    Asset("IMAGE", "images/inventoryimages/gearlance.tex"),
}

local function onfinished(inst)
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

--OLD EFFECT
--[[local chance = 0.33
local chance_effect = 0.50

local function onattack(inst, owner, target)
    if math.random() < chance then
        if math.random() < chance_effect then
            if target and target.components.burnable then
                target.components.burnable:Ignite(true)
            end
        else
            if target and target.components.freezable then
            target.components.freezable:AddColdness(1)
            target.components.freezable:SpawnShatterFX()
            end
        end
    end
end]]

local summonchance = 0.25
local secondtalk = 0.10

local function stab(staff, target, pos)
    local caster = staff.components.inventoryitem.owner

    if target:HasTag("player") then
        caster.components.talker:Say("I will not do that.")
    else
        caster.components.sanity:DoDelta(-10)

        local pos = target:GetPosition()
        caster.Transform:SetPosition(pos.x, pos.y, pos.z)
        target.components.combat:GetAttacked(caster, 200, nil)
        target.components.combat:SuggestTarget(caster)
        caster.components.locomotor:Stop()
        SpawnPrefab("statue_transition_2").Transform:SetPosition(target.Transform:GetWorldPosition())
        SpawnPrefab("shadow_despawn").Transform:SetPosition(target.Transform:GetWorldPosition())
        caster.SoundEmitter:PlaySound("dontstarve/sanity/creature2/appear")
        staff.components.finiteuses:Use(10)

     if math.random() < summonchance then
        caster.components.talker:Say("You can run but you can't hide!")
        else
            if math.random() < secondtalk then
                caster.components.talker:Say("Feel the power of the shadows!")
            else
         end
      end
   end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_gears_mace", "swap_nightmaresword")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(stab)
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canonlyuseoncombat = true
    inst.components.spellcaster.quickcast = true
    inst.components.spellcaster.castingstate = "castspell_tornado"
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end


local function onattack(inst, attacker, target)
    local explode = SpawnPrefab("impact")
    local pos = target:GetPosition()
    explode.Transform:SetPosition(pos.x, pos.y, pos.z)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("nightmaresword")
    inst.AnimState:SetBuild("gears_mace")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.BATBAT_DAMAGE)
    inst.components.weapon:SetOnAttack(onattack)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(150)
    inst.components.finiteuses:SetUses(150)
    inst.components.finiteuses:SetOnFinished(onfinished)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "gearlance"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/gearlance.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.dapperness = TUNING.CRAZINESS_SMALL
    inst.components.equippable.walkspeedmult = 1.1

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/gearlance", fn, assets)