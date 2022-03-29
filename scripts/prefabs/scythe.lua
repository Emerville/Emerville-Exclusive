local assets =
{ 
    Asset("ANIM", "anim/scythe.zip"),
    Asset("ANIM", "anim/swap_scythe.zip"),
	
    Asset("IMAGE", "images/inventoryimages/scythe.tex"),
    Asset("ATLAS", "images/inventoryimages/scythe.xml"),
}

local prefabs =
{
    "efc",
}

local function spawnspirit(inst)
    local dubloon = SpawnPrefab("efc")
    dubloon.Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function IsValidVictim(victim)
    return victim ~= nil
        and not ((victim:HasTag("prey") and not victim:HasTag("hostile")) or
                victim:HasTag("veggie") or
                victim:HasTag("structure") or
                victim:HasTag("wall") or
                victim:HasTag("balloon") or
                victim:HasTag("groundspike") or
                victim:HasTag("smashable") or
                victim:HasTag("companion"))
        and victim.components.health ~= nil
        and victim.components.combat ~= nil
end

local function onkilled(inst, data)
    local victim = data.victim
    if IsValidVictim(victim) then
        if not victim.components.health.nofadeout and (victim:HasTag("epic") or math.random() < 0.1) then
            local time = victim.components.health.destroytime or 2
            local x, y, z = victim.Transform:GetWorldPosition()
            inst:DoTaskInTime(time, spawnspirit, x, y, z)
        end
    end
end

local function turnon(inst)
    if not inst.components.fueled:IsEmpty() then
        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
			inst.Light:Enable(true)
			inst:AddTag("light")
        end
    end
end

local function turnoff(inst)
    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
		inst.Light:Enable(false)
	    inst:RemoveTag("light")
    end
end

local function ondropped(inst)
	inst.Light:Enable(true)
end

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_scythe", "swap_scythe")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal")
    turnon(inst)
end
	
local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
    turnoff(inst)
end

local slashchance = 0.92
--local soulsiphonchance = 0.08
local function onattack(inst, owner, target)
	SpawnPrefab("shadowstrike_slash2_fx").Transform:SetPosition(target:GetPosition():Get())
    if math.random() < slashchance then
	
    else
		SpawnPrefab("reaper_soul").Transform:SetPosition(target:GetPosition():Get())
        owner.components.talker:Say("Your time has come!")
    end
end

local function nofuel(inst)
	SpawnPrefab("statue_transition").Transform:SetPosition(inst:GetPosition():Get())
    inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")	
    local equippable = inst.components.equippable
    if equippable ~= nil and equippable:IsEquipped() then
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if owner ~= nil then
            local data =
            {
                prefab = inst.prefab,
                equipslot = equippable.equipslot,
            }
            turnoff(inst)
            return
        end
    end
    turnoff(inst)
end

local function takefuel(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
    if inst.components.equippable and inst.components.equippable:IsEquipped() then
        turnon(inst)
    end
end	

local function fn()
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddLight()
    inst.entity:AddNetwork()	
	
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("scythe")
    inst.AnimState:SetBuild("scythe")
    inst.AnimState:PlayAnimation("idle")
  	
    local light = inst.entity:AddLight()
    inst.Light:SetIntensity(0.65)
    inst.Light:SetRadius(1.5)
    inst.Light:SetFalloff(1)
    light:SetColour(180/255, 0/255, 255/255)
    inst.Light:Enable(false)
	
    inst:AddTag("sharp")	
    inst:AddTag("scythe")	
	
	inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
		return inst
	end	

    inst:AddComponent("weapon")
    inst.components.weapon:SetOnAttack(onattack)
    inst.components.weapon:SetDamage(25)
    inst.components.weapon:SetRange(1.10)
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "scythe"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/scythe.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.walkspeedmult = 1.10 --TUNING.CANE_SPEED_MULT
	
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.NIGHTMARE	
    inst.components.fueled:InitializeFuelLevel(TUNING.TOTAL_DAY_TIME)
    inst.components.fueled:SetDepletedFn(nofuel)
    inst.components.fueled.ontakefuelfn = takefuel
	inst.components.fueled.accepting = true
	
    inst:ListenForEvent("killed", onkilled)
	
	MakeHauntableLaunch(inst)
	
    return inst
end

return  Prefab("common/inventory/scythe", fn, assets)