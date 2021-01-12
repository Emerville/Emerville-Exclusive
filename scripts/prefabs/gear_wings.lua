local assets =
{
	Asset("ANIM", "anim/gear_wings.zip"),
	Asset("ANIM", "anim/gear_wings_ground.zip"),
	
	Asset("ATLAS", "images/inventoryimages/gear_wings.xml"),
	Asset("IMAGE", "images/inventoryimages/gear_wings.tex"),
}

local function onperish (inst, owner)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner then
        owner.SoundEmitter:PlaySound("dontstarve/wilson/use_break")
	    owner.SoundEmitter:PlaySound("dontstarve/creatures/knight/hurt")
        local brokentool = SpawnPrefab("brokentool")
        brokentool.Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
	end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "gear_wings", "swap_body")
	owner.SoundEmitter:PlaySound("dontstarve/creatures/knight/idle")
	
	inst.components.fueled:StartConsuming()
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
	
	inst.components.fueled:StopConsuming()
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)
       
    inst.AnimState:SetBank("bank")
    inst.AnimState:SetBuild("gear_wings_ground")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "gear_wings"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/gear_wings.xml"
	
	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
    
	inst:AddComponent("fueled")
    inst.components.fueled:InitializeFuelLevel(960) --- 8 days * 1.5
    inst.components.fueled:SetDepletedFn(onperish)
		
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.walkspeedmult = 1.20    
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    return inst
end

return Prefab( "common/inventory/gear_wings", fn, assets) 