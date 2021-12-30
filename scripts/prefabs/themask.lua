local assets =
{
    Asset("ANIM", "anim/themask.zip"),

    Asset("ATLAS", "images/inventoryimages/themask.xml"),
    Asset("IMAGE", "images/inventoryimages/themask.tex"),
}

-----------------------------------------------------------
local firsttalk = 0.50
local secondtalk = 0.50
local WALK_SPEED_MULT = 1.05
local DUBLOON_SPAWN_RATE = 240 --480 Day/Regular --240 HalfDay/Event

local function SpawnDubloon(inst, owner)
    local dubloon = SpawnPrefab("taffy")
    dubloon.Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function OnActivate(inst)
    inst.dubloon_task = inst:DoPeriodicTask(DUBLOON_SPAWN_RATE, function()
        SpawnDubloon(inst, owner)
    end)

    inst.components.equippable.walkspeedmult = WALK_SPEED_MULT
    inst.components.fueled:StartConsuming()
end

local function onequip(inst, owner)
    if owner.components.talker then
        if math.random() < firsttalk then
            owner.components.talker:Say("S-s-s-s-s-s-mokin'!")
        elseif math.random() < secondtalk then
            owner.components.talker:Say("Did you miss me?")
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

    if inst.components.fueled ~= nil and not inst.components.fueled:IsEmpty() then
        if inst._fx ~= nil then
            inst._fx:kill_fx()
        end
        
        if inst.dubloon_task ~= nil then
            inst.dubloon_task:Cancel()
        end

        if inst.abilityready then
            inst._fx = SpawnPrefab("themasktornado")
            inst._fx.entity:SetParent(owner.entity)
            inst.components.fueled:DoDelta(-480)
        end
        
        OnActivate(inst)
    end
end

local function onunequip(inst, owner)
    if inst._fx ~= nil then
        inst._fx:kill_fx()
        inst._fx = nil
    end
    if inst.dubloon_task ~= nil then
        inst.dubloon_task:Cancel()
        inst.dubloon_task = nil
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
    
    inst.components.fueled:StopConsuming()
end

local function TheMaskCanAcceptFuelItem(self, item)
    return item ~= nil and item.prefab == "purplegem" and
        self.inst.components.fueled.currentfuel < self.inst.components.fueled.maxfuel
end

local function TheMaskTakeFuel(self, item)
    if self:CanAcceptFuelItem(item) then
        if self:IsEmpty() and self.inst.components.equippable:IsEquipped() then
            OnActivate(self.inst)
        end
    
        self:DoDelta(4800)
        self.inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_craft", "sound")
        self.inst.components.equippable.walkspeedmult = WALK_SPEED_MULT
        
        item:Remove()
        return true
    end
end

local function OnFuelDepleted(inst)
    inst.components.equippable.walkspeedmult = 1
    
    if inst.dubloon_task ~= nil then
        inst.dubloon_task:Cancel()
        inst.dubloon_task = nil
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
    inst.components.fueled:SetDepletedFn(OnFuelDepleted)

    inst:DoTaskInTime(0, function()
        if inst.components.fueled:IsEmpty() then
            inst.components.equippable.walkspeedmult = 1
        end
    end)
    
    -- Prevents tornado from spawning after a player joins
    inst.abilityready = false
    inst:DoTaskInTime(1, function()
        inst.abilityready = true
    end)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/themask", fn, assets )
