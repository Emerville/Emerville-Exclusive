local assets =
{
    Asset("ANIM", "anim/orangecane.zip"),
    Asset("ANIM", "anim/swap_orangecane.zip"),

    Asset("ATLAS", "images/inventoryimages/orangecane.xml"),
    Asset("IMAGE", "images/inventoryimages/orangecane.tex"),
}

local prefabs =
{
	"sandspike_tallcane",
	"sanity_raise",
    "crosshair",
    "swing_charge",
	"ground_chunks_breaking",
    "slingshotammo_marble_proj",
}

local SLEEPTARGETS_CANT_TAGS = { "hound_mutated", "statue"}
local SLEEPTARGETS_ONEOF_TAGS = { "hound", "warg" }

local function OnDamageAll(caster, pt)
    local range = 30
    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, range, nil, SLEEPTARGETS_CANT_TAGS, SLEEPTARGETS_ONEOF_TAGS)

    for k,v in pairs(ents) do
        if v.components.health and v.components.combat then
            local fx = SpawnPrefab("sandspike_tallcane")
            local tpos = Vector3(v.Transform:GetWorldPosition())
            fx.Transform:SetPosition(tpos.x, 0, tpos.z)

            v.components.health:DoDelta(-150)
            if v.sg and v.sg.sg.states.hit and not v.components.health:IsDead() then
                v.sg:GoToState("hit")
            end
        end
    end
end

local function Impale(inst, caster)
    local caster = inst.components.inventoryitem.owner
    local pt = Vector3(caster.Transform:GetWorldPosition())
    caster:DoTaskInTime(1, OnDamageAll, pt)
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_orangecane", "swap_orangecane")
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

    inst.AnimState:SetBank("orangecane")
    inst.AnimState:SetBuild("orangecane")
    inst.AnimState:PlayAnimation("idle")
	
    --Sneak these into pristine state for optimization
    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")
    inst:AddTag("rangedweapon")
    inst:AddTag("quickcast")
    inst:AddTag("cane")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.CANE_DAMAGE)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "orangecane"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/orangecane.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY
	
	inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(Impale)
    inst.components.spellcaster.canuseontargets = false
	inst.components.spellcaster.canusefrominventory = false
	inst.components.spellcaster.quickcast = true
	inst.components.spellcaster.canuseonpoint = true
	inst.components.spellcaster.castingstate = "castspell_tornado"	

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/orangecane", fn, assets)