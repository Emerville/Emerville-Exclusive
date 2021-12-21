local assets =
{
    Asset("ANIM", "anim/orangecane.zip"),
    Asset("ANIM", "anim/swap_orangecane.zip"),

    Asset("ATLAS", "images/inventoryimages/orangecane.xml"),
    Asset("IMAGE", "images/inventoryimages/orangecane.tex"),
}

local prefabs =
{
	"sandspike_tallperk",
	"sanity_raise",
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_orangecane", "swap_orangecane")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function stomp(inst, caster)
    local caster = inst.components.inventoryitem.owner
    local pt = caster:GetPosition()
    local numtentacles = 10

    caster.components.sanity:DoDelta(-10)

    caster:StartThread(function()
        for k = 1, numtentacles do
            local theta = math.random() * 2 * PI
            local radius = math.random(3, 3)

            -- we have to special case this one because birds can't land on creep
            local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
                local pos = pt + offset
                --NOTE: The first search includes invisible entities
                return #TheSim:FindEntities(pos.x, 0, pos.z, 1, nil, { "INLIMBO", "FX" }) <= 0
                    and TheWorld.Map:IsDeployPointClear(pos, nil, 1)
            end)

            if result_offset ~= nil then
                local x, z = pt.x + result_offset.x, pt.z + result_offset.z
                local tentacle = SpawnPrefab("sandspike_tallperk")
                tentacle.Transform:SetPosition(x, 0, z)
                tentacle:DoTaskInTime(0, tentacle.TriggerFX)
                tentacle:DoTaskInTime(10, tentacle.KillFX)

                --need a better effect
                SpawnPrefab("sanity_raise").Transform:SetPosition(x, 0, z)
            end
        end
    end)
    return true
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
    inst.components.spellcaster:SetSpellFn(stomp)
    inst.components.spellcaster.canuseontargets = false
	inst.components.spellcaster.canusefrominventory = false
	inst.components.spellcaster.quickcast = true
	inst.components.spellcaster.canuseonpoint = true
	inst.components.spellcaster.castingstate = "castspell_tornado"	

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/orangecane", fn, assets)