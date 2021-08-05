local Assets =
{
	Asset("ANIM", "anim/starterinventory.zip"),
    Asset("ATLAS", "images/inventoryimages/fuelsupplier.xml"),
    Asset("IMAGE", "images/inventoryimages/fuelsupplier.tex"),
}


local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
    inst:Remove()
end


local function onhit(inst, worker)
end


local function isFirepit(inst)
--[[
    return inst.components.fueled and
           (inst.components.fueled.fueltype == FUELTYPE.BURNABLE or
            inst.components.fueled.fueltype == FUELTYPE.CAVE or
            inst.components.fueled.fueltype == FUELTYPE.CHEMICAL or
            inst.components.fueled.fueltype == FUELTYPE.MAGIC or
            inst.components.fueled.fueltype == FUELTYPE.NIGHTMARE)
]]           
	if inst:HasTag("yamche") then return false end
    return inst.components.fueled or inst.prefab == "pumpkin_lantern" or inst.prefab == "esentry" or inst.prefab == "aqvarium"
end


local function giveFuel(inst)
--    print("---- Fuel Supplier giveFuel()")
    local firepit = FindEntity(inst, 10, isFirepit)
    if not firepit then return end
    
    -- Aquarium Plus
    if firepit.prefab == "aqvarium" then
--	    print("\tAquarium Plus")
    	local c_max_seeds = 10
        local c_max_meat = 3
       	firepit.data.seeds = c_max_seeds
        firepit.data.meat = c_max_meat

    -- Sentry Gun of the Engineer
    elseif firepit.prefab == "esentry" then
    	if firepit.upgradelevel >= 70 then
			firepit.ammo = 300
            firepit.components.named:SetName("Sentry Gun lvl 3".."\n"..firepit.ammo.." Rounds Remaining".."\n"..firepit.components.health.currenthealth.." Health " )
		elseif firepit.upgradelevel >= 30 then
			firepit.ammo = 200
            firepit.components.named:SetName("Sentry Gun lvl 2".."\n"..firepit.ammo.." Rounds Remaining".."\n"..firepit.components.health.currenthealth.." Health " )
		else
			firepit.ammo = 100
            firepit.components.named:SetName("Sentry Gun lvl 1".."\n"..firepit.ammo.." Rounds Remaining".."\n"..firepit.components.health.currenthealth.." Health "  )
		end

    elseif firepit and firepit.components.fueled then
        if firepit.components.perishable then
            -- Pumpkin Lantern
            firepit.components.perishable:SetPercent(1.0)
        elseif firepit.components.machine then
            -- A kind of Lantern
            firepit.components.fueled:SetPercent(1.0)
        elseif firepit.components.inventoryitem then
            -- A kind of Amulet?
            firepit.components.fueled:SetPercent(1.0)
        else
            -- A kind of Fire Pit
            if firepit.components.fueled:GetPercent() < 0.7 then
                firepit.components.fueled:SetPercent(1.0)
            end
        end
    end
end


local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("starterinventory")
    inst.AnimState:SetBuild("starterinventory")
    inst.AnimState:PlayAnimation("idle")
	
    inst.entity:SetPristine() 

    if not TheWorld.ismastersim then   
      return inst  
    end   

    inst:AddComponent("lootdropper")
    --[[inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit) ]]   

    inst:DoTaskInTime(0.5, giveFuel)
    inst:DoPeriodicTask(60, giveFuel)

    return inst
end

STRINGS.NAMES.FUELSUPPLIER = "Fuel Supplier"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.FUELSUPPLIER = "Add fuel to fire pit permanently."
    return Prefab("common/inventory/fuelsupplier", fn, Assets),
    MakePlacer("common/fuelsupplier_placer", "starterinventory", "starterinventory", "idle") 
