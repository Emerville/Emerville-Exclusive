local assets =
{
	Asset("ANIM", "anim/themask.zip"),
	
	Asset("ATLAS", "images/inventoryimages/themask.xml"),
	Asset("IMAGE", "images/inventoryimages/themask.tex"),
}

-----------------------------------------------------------
local function SpawnDubloon(inst, owner)
    local dubloon = SpawnPrefab("taffy")
	dubloon.Transform:SetPosition(inst.Transform:GetWorldPosition())	
end

local firsttalk = 0.50
local secondtalk = 0.50

local function onequip(inst, owner)	
    if inst._fx ~= nil then
        inst._fx:kill_fx()
    end
    inst._fx = SpawnPrefab("themasktornado")
    inst._fx.entity:SetParent(owner.entity)
 
    if owner.components.talker then	
		if math.random() < firsttalk then
			owner.components.talker:Say("S-s-s-s-s-s-mokin'!") 
		else 
			if math.random() < secondtalk then
			owner.components.talker:Say("Did you miss me?")
		   end
	   end
    end	

	owner.AnimState:OverrideSymbol("swap_hat", "themask", "swap_hat")
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
		inst.components.fueled:DoDelta(-480)
        inst.dubloon_task = inst:DoPeriodicTask(240, function() SpawnDubloon(inst, owner) end) --480 Day/Regular --240 HalfDay/Event
	end
end

local function onunequip(inst, owner)
    if inst._fx ~= nil then
        inst._fx:kill_fx()
        inst._fx = nil
    end

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

local function TheMaskCanAcceptFuelItem(self, item)
if item ~= nil and item.components.fuel ~= nil and (item.components.fuel.fueltype == FUELTYPE.PURPLEGEM or item.prefab == "purplegem") then
		return true
	else
		return false
	end
end 
 
local function TheMaskTakeFuel(self, item) 
if self:CanAcceptFuelItem(item) then
	if item.prefab =="purplegem" then
		self:DoDelta(4800)
		self.inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_craft", "sound")
	end
        item:Remove()
        return true
    end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("themask")
	inst.AnimState:SetBuild("themask")
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("hat")
	inst:AddTag("waterproofer")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "themask"	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/themask.xml"	

	inst:AddComponent("inspectable")

	inst:AddComponent("tradable")

	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.walkspeedmult = 1.05
	
	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_LARGE)
	
	inst:AddComponent("fueled")
	inst.components.fueled.accepting = true --false 
	inst.components.fueled.fueltype = FUELTYPE.PURPLEGEM	
	inst.components.fueled:InitializeFuelLevel(4800)
	inst.components.fueled.CanAcceptFuelItem = TheMaskCanAcceptFuelItem
	inst.components.fueled.TakeFuelItem = TheMaskTakeFuel	

	inst:DoPeriodicTask(1/10, function() 
	-- Don't take fuel if magazine is full!
	if inst.components.fueled.maxfuel == inst.components.fueled.currentfuel and inst.components.fueled.accepting == true then
	inst.components.fueled.accepting = false
	end
	-- Take fuel if magazine size is bigger than bullet count!
	if inst.components.fueled.maxfuel > inst.components.fueled.currentfuel and inst.components.fueled.accepting == false then
	inst.components.fueled.accepting = true
	end

	-- If snowglobe was emptied and refueled, restore its abilities!
	if not inst.components.fueled:IsEmpty() and inst:HasTag("emptythemask") then
	inst:AddComponent("equippable")	
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.walkspeedmult = 1.05	
	inst:RemoveTag("emptythemask")
	end
	
	-- Empty? No shooting
	if inst.components.fueled:IsEmpty() then
	
	if not inst:HasTag("emptythemask") then
	inst:RemoveComponent("equippable")
	inst:AddTag("emptythemask")
	end
	
	end
	end)	
		
    MakeHauntableLaunch(inst)	

	return inst
end

return Prefab("common/inventory/themask", fn, assets ) 