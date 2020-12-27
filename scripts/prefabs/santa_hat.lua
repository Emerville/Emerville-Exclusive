local assets =
{ 
 --   Asset("ANIM", "anim/xmashat_default.zip"),
    Asset("ANIM", "anim/hat_santa_helper.zip"), 

    Asset("ATLAS", "images/inventoryimages/xmashat_default.xml"),
    Asset("IMAGE", "images/inventoryimages/xmashat_default.tex"),
}

local function SpawnDubloon(inst, owner)
SpawnPrefab("collapse_small")
--[[    local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,2,0)

    dubloon.Transform:SetPosition(pt:Get())
    local angle = owner.Transform:GetRotation()*(PI/180)
    local sp = (math.random()+1) * -1
    dubloon.Physics:SetVel(sp*math.cos(angle), math.random()*2+8, -sp*math.sin(angle))
    dubloon.components.inventoryitem:OnStartFalling()]]
end

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", "hat_santa_helper", "swap_hat")
	
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end

	if inst.components.fueled ~= nil then
        inst.components.fueled:StartConsuming()
        inst.dubloon_task = inst:DoPeriodicTask(1, function() SpawnDubloon(inst, owner) end)		
    end
end


local function OnUnequip(inst, owner) 

    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end

    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
		inst.dubloon_task:Cancel()
        inst.dubloon_task = nil
    end
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("santa_helper_hat")
    inst.AnimState:SetBuild("hat_santa_helper")
    inst.AnimState:PlayAnimation("anim")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "xmashat_default"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/xmashat_default.xml"
	
--[[    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("gift_red")
    inst.components.periodicspawner:SetRandomTimes(1, 120)
    inst.components.periodicspawner:SetDensityInRange(20, 4)]]
	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE
	
	inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
	
	inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.WALRUSHAT_PERISHTIME)
    inst.components.fueled:SetDepletedFn(inst.Remove)
	
    MakeHauntableLaunch(inst)	

    return inst
end

return Prefab("common/inventory/santa_hat", fn, assets)