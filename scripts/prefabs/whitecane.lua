local assets =
{
    Asset("ANIM", "anim/whitecane.zip"),
    Asset("ANIM", "anim/swap_whitecane.zip"),
	
	Asset("ATLAS", "images/inventoryimages/whitecane.xml"),
    Asset("IMAGE", "images/inventoryimages/whitecane.tex"),
}

local chance = 0.07 --Maybe revert to 5% if needed.

local function onattack(inst, owner, target)
	if math.random() < chance then
    if owner.components.health and not target:HasTag("wall") or target:HasTag("chester") then
        owner.components.sanity:DoDelta(-5) --Drains 5 sanity from user.
		SpawnPrefab("lightbulb").Transform:SetPosition(target:GetPosition():Get()) 
		SpawnPrefab("statue_transition").Transform:SetPosition(target:GetPosition():Get())
		end
	end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_whitecane", "swap_whitecane")
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

    inst.AnimState:SetBank("whitecane")
    inst.AnimState:SetBuild("whitecane")
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
	inst.components.inventoryitem.imagename = "whitecane"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/whitecane.xml"

    inst:AddComponent("equippable")

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY	
    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/whitecane", fn, assets)