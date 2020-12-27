local assets =
{
    Asset("ANIM", "anim/swap_parasol.zip"),
    Asset("ANIM", "anim/swap_parasol_palmleaf.zip"),
    Asset("ANIM", "anim/parasol_palmleaf.zip"),
	
	Asset("ATLAS", "images/inventoryimages/dontropicalparasol.xml"),
	Asset("IMAGE", "images/inventoryimages/dontropicalparasol.tex"),
}

local function onequip_palm(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_parasol_palmleaf", "swap_parasol_palmleaf")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    owner.DynamicShadow:SetSize(1.7, 1)
	
	inst.components.fueled:StartConsuming()
end

local function onunequip_palm(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    owner.DynamicShadow:SetSize(1.3, 0.6)
	
	inst.components.fueled:StopConsuming()	
end

local function onperish(inst)
    local equippable = inst.components.equippable
    if equippable ~= nil and equippable:IsEquipped() then
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if owner ~= nil then
            local data =
            {
                prefab = inst.prefab,
                equipslot = equippable.equipslot,
            }
            inst:Remove()
            owner:PushEvent("umbrellaranout", data)
            return
        end
    end
    inst:Remove()
end

local function common_fn(name)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(name)
    inst.AnimState:SetBuild(name)
    inst.AnimState:PlayAnimation("idle")  

    inst:AddTag("nopunch")
    inst:AddTag("umbrella")

    --waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("waterproofer")
    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "dontropicalparasol"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/dontropicalparasol.xml"
	
    inst:AddComponent("equippable")

    inst:AddComponent("insulator")
    inst.components.insulator:SetSummer()

    MakeHauntableLaunch(inst)

    return inst
end

local function palm()
    local inst = common_fn("parasol_palmleaf", 3)

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:SetDepletedFn(onperish)
    inst.components.fueled:InitializeFuelLevel(TUNING.UMBRELLA_PERISHTIME)        

    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_HUGE)

    inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

    inst.components.equippable:SetOnEquip(onequip_palm)
    inst.components.equippable:SetOnUnequip(onunequip_palm)

    return inst
end

return Prefab("palmleaf_umbrella", palm, assets)
