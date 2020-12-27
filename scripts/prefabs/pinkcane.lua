local assets =
{
    Asset("ANIM", "anim/pinkcane.zip"),
    Asset("ANIM", "anim/swap_pinkcane.zip"),
	
	Asset("ATLAS", "images/inventoryimages/pinkcane.xml"),
    Asset("IMAGE", "images/inventoryimages/pinkcane.tex"),
}

local prefabs = 
{
	"pinkfieldfx",
} 	

--[[local function pinkcane_fxanim(inst)
        inst._fx.AnimState:PlayAnimation("hit")
        inst._fx.AnimState:PushAnimation("idle_loop")
    end

    local function pinkcane_oncooldown(inst)
        inst._task = nil
    end

    local function pinkcane_unproc(inst)
        if inst:HasTag("forcefield") then
            inst:RemoveTag("forcefield")
            if inst._fx ~= nil then
                inst._fx:kill_fx()
                inst._fx = nil
            end
            inst:RemoveEventCallback("armordamaged", pinkcane_fxanim)

            inst.components.armor:SetAbsorption(TUNING.ARMOR_RUINSHAT_ABSORPTION)
            inst.components.armor.ontakedamage = nil

            if inst._task ~= nil then
                inst._task:Cancel()
            end
            inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_COOLDOWN, pinkcane_oncooldown)
        end
    end

local function pinkcane_proc(inst, owner)
        inst:AddTag("forcefield")
        if inst._fx ~= nil then
            inst._fx:kill_fx()
        end
        inst._fx = SpawnPrefab("pinkfieldfx")
        inst._fx.entity:SetParent(owner.entity)
        inst._fx.Transform:SetPosition(0, 0.2, 0)
        inst:ListenForEvent("armordamaged", pinkcane_fxanim)

        inst.components.armor:SetAbsorption(TUNING.FULL_ABSORPTION)
        inst.components.armor.ontakedamage = function(inst, damage_amount)
            if owner ~= nil and owner.components.sanity ~= nil then
                owner.components.sanity:DoDelta(-damage_amount * TUNING.ARMOR_RUINSHAT_DMG_AS_SANITY, false)
            end
        end

        if inst._task ~= nil then
            inst._task:Cancel()
        end
        inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_DURATION, pinkcane_unproc)
    end	]]
	
	
local function pinkcane_fxanim(inst)
        inst._fx.AnimState:PlayAnimation("hit")
        inst._fx.AnimState:PushAnimation("idle_loop")
    end

    local function pinkcane_oncooldown(inst)
        inst._task = nil
    end

    local function pinkcane_unproc(inst)
        if inst:HasTag("forcefield") then
            inst:RemoveTag("forcefield")
            if inst._fx ~= nil then
                inst._fx:kill_fx()
                inst._fx = nil
            end
 --           inst:RemoveEventCallback("armordamaged", pinkcane_fxanim)

--            inst.components.armor:SetAbsorption(TUNING.ARMOR_RUINSHAT_ABSORPTION)
--            inst.components.armor.ontakedamage = nil

            if inst._task ~= nil then
                inst._task:Cancel()
            end
            inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_COOLDOWN, pinkcane_oncooldown)
        end
    end	
	
	
local function pinkcane_proc(inst, owner)
	inst:AddTag("forcefield")
    if inst._fx ~= nil then
        inst._fx:kill_fx()
    end
    inst._fx = SpawnPrefab("pinkfieldfx")
    inst._fx.entity:SetParent(owner.entity)
    inst._fx.Transform:SetPosition(0, 0.2, 0)

--	local x, y, z = inst.Transform:GetWorldPosition()
--	local fx = SpawnPrefab("pinkfieldfx")
--	fx.Transform:SetPosition(x, y, z)
	
	local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 7)
    for i, v in ipairs(ents) do
        if not (v.components.freezable ~= nil and v.components.freezable:IsFrozen()) and
            not (v.components.pinnable ~= nil and v.components.pinnable:IsStuck()) then
			
			if v:HasTag("player") or v:HasTag("loyalcat") then
             v.components.health:DoDelta(5)
			  
            elseif v:HasTag("monster") then				 
			elseif v:HasTag("largecreature") then		 
			elseif v:HasTag("smallcreature") then		 
		    elseif v:HasTag("merm") then				 
			elseif v:HasTag("hostile") then		
            elseif v:HasTag("pauraoff") then
            end
		end	
	end

    if inst._task ~= nil then
        inst._task:Cancel()
    end
    inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_DURATION, pinkcane_unproc)
end
	
--[[local function tryproc(inst, owner)
    if inst._task == nil and math.random() < TUNING.ARMOR_RUINSHAT_PROC_CHANCE then
       pinkcane_proc(inst, owner)
    end
end]]

local chance = 0.09 --Maybe revert to 3% if needed.

local function onattack(inst, owner, target)
	if math.random() < chance then
		if owner.components.hunger and not target:HasTag("wall") or target:HasTag("chester") then
			owner.components.hunger:DoDelta(5) --Gives 5 hunger to user.
			pinkcane_proc(inst, owner)		
		end
	end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_pinkcane", "swap_pinkcane")
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

    inst.AnimState:SetBank("pinkcane")
    inst.AnimState:SetBuild("pinkcane")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.CANE_DAMAGE)
	inst.components.weapon:SetOnAttack(onattack)	

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "pinkcane"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/pinkcane.xml"

    inst:AddComponent("equippable")

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY	
    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/pinkcane", fn, assets)