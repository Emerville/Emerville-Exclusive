local assets =
{
    Asset("ANIM", "anim/eyebrella.zip"),
	Asset("ANIM", "anim/swap_eyebrella.zip"),
	
	Asset("ATLAS", "images/inventoryimages/eyebrella.xml"),
	Asset("IMAGE", "images/inventoryimages/eyebrella.tex"),	
}
    
local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_eyebrella", "swap_object")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    
    owner.DynamicShadow:SetSize(2.2, 1.4)

    inst.components.fueled:StartConsuming()
end

local function onunequip(inst, owner) 
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

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()   
	
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("eyebrella")
    inst.AnimState:SetBuild("eyebrella")
    inst.AnimState:PlayAnimation("idle")  
	
    inst:AddTag("nopunch")
    inst:AddTag("umbrella")
	
    --waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")
	
    MakeInventoryFloatable(inst, "large")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_HUGE)	
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "eyebrella"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/eyebrella.xml"
	
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("insulator")
    inst.components.insulator:SetSummer()
    inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:SetDepletedFn(onperish)
    inst.components.fueled:InitializeFuelLevel(TUNING.UMBRELLA_PERISHTIME)  

    MakeHauntableLaunch(inst)	
	
    return inst
end

return Prefab("common/inventory/eyebrella", fn, assets)
