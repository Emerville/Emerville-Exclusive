local assets =
{
    Asset("ANIM", "anim/wigfriddoll.zip"),
    Asset("ANIM", "anim/swap_wigfriddoll.zip"),
  
    Asset("ATLAS", "images/inventoryimages/wigfriddoll.xml"),
    Asset("IMAGE", "images/inventoryimages/wigfriddoll.tex"),
}

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_wigfriddoll", "swap_wigfriddoll")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
	
	inst.components.fueled:StartConsuming()		
end
  
local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
	
    inst.components.fueled:StopConsuming()	
end

local function onattack(inst, owner, target)
    if owner.components.health and target.components.hauntable and not target:HasTag("shadow") then
		inst.components.weapon:SetDamage(20)		
        target.components.hauntable:Panic(3)  		
	else
		inst.components.weapon:SetDamage(20)		
	end
	if owner.components.health and target:HasTag("shadow") then
		inst.components.weapon:SetDamage(80)
		SpawnPrefab("statue_transition").Transform:SetPosition(target:GetPosition():Get())
	end
end

local function DstDollAcceptFuelItem(self, item)
if item ~= nil and item.components.fuel ~= nil and (item.components.fuel.fueltype == FUELTYPE.DSTDOLL or item.prefab == "magicdolls") then
		return true
	else
		return false
    end
end
 
local function DstDollTakeFuel(self, item) 
if self:CanAcceptFuelItem(item) then
	if item.prefab == "magicdolls" then
		self:DoDelta(2400)
	 end
        item:Remove()
        return true
    end
end
 
local function fn() 
    local inst = CreateEntity()
 
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	inst.entity:AddMiniMapEntity()
     
    MakeInventoryPhysics(inst)   
      
    inst.AnimState:SetBank("wigfriddoll")
    inst.AnimState:SetBuild("wigfriddoll")
    inst.AnimState:PlayAnimation("idle")
	
    inst.MiniMapEntity:SetIcon("wigfriddoll.tex")
 
    inst:AddTag("sharp")
 
    if not TheWorld.ismastersim then
        return inst
    end
 
    inst.entity:SetPristine()
     
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(20)
	inst.components.weapon.onattack = onattack	
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)	
	
    inst:AddComponent("fueled")
	inst.components.fueled.accepting = true	
	inst.components.fueled.fueltype = FUELTYPE.DSTDOLL
	inst.components.fueled.CanAcceptFuelItem = DstDollAcceptFuelItem
	inst.components.fueled.TakeFuelItem = DstDollTakeFuel
    inst.components.fueled:InitializeFuelLevel(4800)
    inst.components.fueled:SetDepletedFn(inst.Remove)	
      
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wigfriddoll"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wigfriddoll.xml"
	      
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY*2
	
	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)	

	local old_onhaunt = inst.components.hauntable.onhaunt
	
	inst.components.hauntable:SetOnHauntFn(function(inst, doer)		
    SpawnPrefab("lavaarena_player_revive_from_corpse_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.components.fueled:DoDelta(-1600)	
    return old_onhaunt(inst, doer)
	end)
     
    return inst
end

return  Prefab("common/inventory/dst_wigfriddoll", fn, assets) 