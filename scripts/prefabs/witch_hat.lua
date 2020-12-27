local assets =
{
    Asset("ANIM", "anim/witch_hat.zip"),
	
    Asset("ATLAS", "images/inventoryimages/witch_hat.xml"),
	Asset("IMAGE", "images/inventoryimages/witch_hat.tex"),
}

local prefabs = 
{
	"forcefieldfx",
	"froglegs",
} 	

local function SpawnDubloon(inst, owner)
    local dubloon = SpawnPrefab("froglegs")
	dubloon.Transform:SetPosition(inst.Transform:GetWorldPosition())	
end


--[[    local function ruinshat_fxanim(inst)
        inst._fx.AnimState:PlayAnimation("hit")
        inst._fx.AnimState:PushAnimation("idle_loop")
    end

    local function ruinshat_oncooldown(inst)
        inst._task = nil
    end

    local function ruinshat_unproc(inst)
        if inst:HasTag("forcefield") then
            inst:RemoveTag("forcefield")
            if inst._fx ~= nil then
                inst._fx:kill_fx()
                inst._fx = nil
            end
            inst:RemoveEventCallback("armordamaged", ruinshat_fxanim)

            inst.components.armor:SetAbsorption(0)
            inst.components.armor.ontakedamage = nil

            if inst._task ~= nil then
                inst._task:Cancel()
            end
            inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_COOLDOWN, ruinshat_oncooldown)
        end
    end

    local function ruinshat_proc(inst, owner)
        inst:AddTag("forcefield")
        if inst._fx ~= nil then
            inst._fx:kill_fx()
        end
        inst._fx = SpawnPrefab("forcefieldfx")
        inst._fx.entity:SetParent(owner.entity)
        inst._fx.Transform:SetPosition(0, 0.2, 0)
        inst:ListenForEvent("armordamaged", ruinshat_fxanim)

        inst.components.armor:SetAbsorption(TUNING.FULL_ABSORPTION)
        inst.components.armor.ontakedamage = function(inst, damage_amount)
            if owner ~= nil and owner.components.sanity ~= nil then
                owner.components.sanity:DoDelta(-damage_amount * TUNING.ARMOR_RUINSHAT_DMG_AS_SANITY, false)
            end
        end

        if inst._task ~= nil then
            inst._task:Cancel()
        end
        inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_DURATION, ruinshat_unproc)
    end

    local function tryproc(inst, owner, data)
        if inst._task == nil and
            not data.redirected and
            math.random() < TUNING.ARMOR_RUINSHAT_PROC_CHANCE then
            ruinshat_proc(inst, owner)
        end
    end

    local function ruins_onremove(inst)
        if inst._fx ~= nil then
            inst._fx:kill_fx()
            inst._fx = nil
        end
    end]]
	
local function onequip(inst, owner)
--    inst.onattach(owner)

    owner.AnimState:OverrideSymbol("swap_hat", "witch_hat", "swap_hat")
	
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")
	owner:AddTag("bat")	
	
    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end	
	
	if inst.components.fueled ~= nil then
        inst.components.fueled:StartConsuming()
        inst.dubloon_task = inst:DoPeriodicTask(480, function() SpawnDubloon(inst, owner) end) --480 Day/Regular --240 HalfDay/Event	
    end
	
end
 
local function onunequip(inst, owner)
--    inst.ondetach()

    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")
	owner:RemoveTag("bat")
	
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
 
local function fn(Sim)
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddNetwork()

    inst.AnimState:SetBank("tophat")
    inst.AnimState:SetBuild("witch_hat")
    inst.AnimState:PlayAnimation("anim")   
         
    inst:AddTag("hat")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	

    inst:AddComponent("inspectable")
	
	inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "witch_hat"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/witch_hat.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD  
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = 1.05
	
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.TOPHAT_PERISHTIME)
    inst.components.fueled:SetDepletedFn(inst.Remove)
	
--[[    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMOR_RUINSHAT, 0)	

        inst.OnRemoveEntity = ruins_onremove

        inst._fx = nil
        inst._task = nil
        inst._owner = nil
        inst.procfn = function(owner, data) tryproc(inst, owner, data) end
        inst.onattach = function(owner)
            if inst._owner ~= nil then
                inst:RemoveEventCallback("attacked", inst.procfn, inst._owner)
                inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
            end
            inst:ListenForEvent("attacked", inst.procfn, owner)
            inst:ListenForEvent("onremove", inst.ondetach, owner)
            inst._owner = owner
            inst._fx = nil
        end
        inst.ondetach = function()
            ruinshat_unproc(inst)
            if inst._owner ~= nil then
                inst:RemoveEventCallback("attacked", inst.procfn, inst._owner)
                inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
                inst._owner = nil
                inst._fx = nil
            end
        end]]	
	
	MakeHauntableLaunch(inst)	

    return inst
end
 
return Prefab("common/inventory/witch_hat", fn, assets) --add back ,prefabs