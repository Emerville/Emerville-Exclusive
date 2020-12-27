local assets =
{ 
    Asset("ANIM", "anim/broomstick.zip"),
    Asset("ANIM", "anim/swap_broomstick.zip"),
	
    Asset("IMAGE", "images/inventoryimages/broomstick.tex"),
    Asset("ATLAS", "images/inventoryimages/broomstick.xml"),
}

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
    inst.AnimState:PlayAnimation("idle")
	inst.Light:Enable(true)
end

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_broomstick", "swap_broomstick")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal")
    turnon(inst)
end
	
local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
    turnoff(inst)
end

local function onattack(inst, owner, target)
   SpawnPrefab("shadowstrike_slash2_fx").Transform:SetPosition(target:GetPosition():Get())
end
	
--[[local function onblink(staff, pos, caster) --Halloween
    if caster.components.sanity ~= nil then
       caster.components.sanity:DoDelta(-25) --Changed from 50 to 25
   end 
end]]

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

    inst.AnimState:SetBank("broomstick")
    inst.AnimState:SetBuild("broomstick")
    inst.AnimState:PlayAnimation("idle", true)
  	
    local light = inst.entity:AddLight()
    inst.Light:SetIntensity(0.65)
    inst.Light:SetRadius(1)
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
	
--    inst:AddComponent("blinkstaff") --Halloween
--    inst.components.blinkstaff.onblinkfn = onblink
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "broomstick"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/broomstick.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.walkspeedmult = 1.05 --TUNING.CANE_SPEED_MULT
	
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.NIGHTMARE	
    inst.components.fueled:InitializeFuelLevel(TUNING.TOTAL_DAY_TIME)
    inst.components.fueled:SetDepletedFn(nofuel)
    inst.components.fueled.ontakefuelfn = takefuel
	inst.components.fueled.accepting = true	
	
	MakeHauntableLaunch(inst)
	
    return inst
end

return  Prefab("common/inventory/broomstick", fn, assets)