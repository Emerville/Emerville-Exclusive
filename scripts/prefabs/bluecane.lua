local assets =
{
    Asset("ANIM", "anim/bluecane.zip"),
    Asset("ANIM", "anim/swap_bluecane.zip"),
	
	Asset("ATLAS", "images/inventoryimages/blue_cane.xml"),
    Asset("IMAGE", "images/inventoryimages/blue_cane.tex"),
}

local chance = 0.10 --Maybe change to 15% if needed.

local function onattack(inst, owner, target)
	if math.random() < chance then
		if target and target.components.freezable then
			target.components.freezable:AddColdness(3)
			target.components.freezable:SpawnShatterFX()
		end
	end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_bluecane", "swap_bluecane")
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

    inst.AnimState:SetBank("bluecane")
    inst.AnimState:SetBuild("bluecane")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cane")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.CANE_DAMAGE)
	inst.components.weapon:SetOnAttack(onattack)	

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "blue_cane"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/blue_cane.xml"

    inst:AddComponent("equippable")
	
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT
	
    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)
    inst.components.insulator:SetSummer()	

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/bluecane", fn, assets)