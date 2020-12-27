local assets =
{
	Asset("ANIM", "anim/hat_hound.zip"),
	
	Asset("ATLAS", "images/inventoryimages/hat_hound.xml"),
	Asset("IMAGE", "images/inventoryimages/hat_hound.tex"),	
}

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_hat", "hat_hound", "swap_hat")
	
	owner.AnimState:Show("HAT")
	owner.AnimState:Show("HAT_HAIR")
	owner.AnimState:Hide("HAIR_NOHAT")
	owner.AnimState:Hide("HAIR")
	
    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end		
	
	inst.components.fueled:StartConsuming()        
end

local function onunequip(inst, owner)

	owner.AnimState:Hide("HAT")
	owner.AnimState:Hide("HAT_HAIR")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")
	
    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end	
		
	inst.components.fueled:StopConsuming()      
end

local function hound_disable(inst)
    if inst.updatetask then
        inst.updatetask:Cancel()
        inst.updatetask = nil
    end
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner and owner.components.leader then
            
        if not owner:HasTag("spiderwhisperer") then --Webber has to stay a monster.
            owner:RemoveTag("monster")
			owner:RemoveTag("houndfriend")
            for k,v in pairs(owner.components.leader.followers) do
                if k:HasTag("hound") and k.components.combat then
                    k.components.combat:SuggestTarget(owner)
                end
            end
            owner.components.leader:RemoveFollowersByTag("hound")
        else
			owner:RemoveTag("houndfriend")		
            owner.components.leader:RemoveFollowersByTag("hound", function(follower)
                if follower and follower.components.follower then
                    if follower.components.follower:GetLoyaltyPercent() > 0 then
                        return false
                    else
                        return true
                    end
                end
            end)
        end

    end
end

local function hound_update(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner and owner.components.leader then
        owner.components.leader:RemoveFollowersByTag("pig")
        local x,y,z = owner.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, TUNING.SPIDERHAT_RANGE*2, {"hound"})
        for k,v in pairs(ents) do
            if v.components.follower and not v.components.follower.leader and not owner.components.leader:IsFollower(v) and owner.components.leader.numfollowers < 10 then
                    owner.components.leader:AddFollower(v)
            end
        end
    end
end

local function hound_enable(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner and owner.components.leader then
        owner.components.leader:RemoveFollowersByTag("pig")
        owner:AddTag("monster")
		owner:AddTag("houndfriend")
    end
	inst.updatetask = inst:DoPeriodicTask(0.5, hound_update, 1)
end

local function hound_equip(inst, owner)
    onequip(inst, owner)
    hound_enable(inst)
end

local function hound_unequip(inst, owner)
    onunequip(inst, owner)
    hound_disable(inst)
end

local function hound_perish(inst)
    hound_disable(inst)
    inst:Remove()
end

local function HatHoundCanAcceptFuelItem(self, item)
if item ~= nil and item.components.fuel ~= nil and (item.components.fuel.fueltype == FUELTYPE.HOUNDHAT or item.prefab == "spiderhat") then
return true
else
return false
end
end 
 
local function HatHoundTakeFuel(self, item) 
if self:CanAcceptFuelItem(item) then
	if item.prefab =="spiderhat" then
		self:DoDelta(TUNING.SPIDERHAT_PERISHTIME*3)
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

    inst.AnimState:SetBank("beehat")
    inst.AnimState:SetBuild("hat_hound")
    inst.AnimState:PlayAnimation("anim") 
	
    inst.foleysound = "dontstarve/movement/foley/fur"

    inst:AddTag("hat")	

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	
	
    inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetOnDroppedFn(hound_disable)
	inst.components.inventoryitem.imagename = "hat_hound"	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/hat_hound.xml"	

	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable.walkspeedmult = 1.10
	inst.components.equippable.dapperness = -TUNING.DAPPERNESS_SMALL
	inst.components.equippable:SetOnEquip(hound_equip)
	inst.components.equippable:SetOnUnequip(hound_unequip)	
	 
	inst:AddComponent("fueled")
	inst.components.fueled.accepting = true	
	inst.components.fueled.fueltype = FUELTYPE.HOUNDHAT	
	inst.components.fueled:InitializeFuelLevel(TUNING.SPIDERHAT_PERISHTIME*3)
	inst.components.fueled:SetDepletedFn(hound_perish)
	inst.components.fueled.CanAcceptFuelItem = HatHoundCanAcceptFuelItem
	inst.components.fueled.TakeFuelItem = HatHoundTakeFuel	
	
    return inst
end

return Prefab("common/inventory/hat_hound", fn, assets) 