local assets =
{
    Asset("ANIM", "anim/musicbox.zip"),
    Asset("ATLAS", "images/inventoryimages/musicbox.xml"),
    Asset("IMAGE", "images/inventoryimages/musicbox.tex"),
}

local function turnon(inst)
    if inst.components.fueled:IsEmpty() then
        return
    end
    inst.components.fueled:StartConsuming()
    inst.Light:Enable(true)
    inst:AddTag("light")
    inst.SoundEmitter:PlaySound("musicbox/sound/playmelody", "christmas")
end

local function turnoff(inst)
    inst.components.fueled:StopConsuming()
    inst.Light:Enable(false)
    inst:RemoveTag("light")
    inst.SoundEmitter:KillSound("musicbox/sound/playmelody", "christmas")
end

local function OnDropped(inst)
    turnoff(inst)
    turnon(inst)
end

local function MusicBoxCanAcceptFuelItem(self, item)
    return item ~= nil and item.components.fuel ~= nil
        and (item.components.fuel.fueltype == FUELTYPE.BLUEGEM or item.prefab == "bluegem")
end

local function nofuel(inst)
    SpawnPrefab("sparks").Transform:SetPosition(inst:GetPosition():Get())
    inst.SoundEmitter:KillSound("musicbox/sound/playmelody", "christmas")
    inst.Light:Enable(false)
    turnoff(inst)
end

local function MusicBoxTakeFuel(self, item)
    if self:CanAcceptFuelItem(item) then
        self:DoDelta(480)
        self.inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_craft", "sound")
        return true
    end
    OnDropped(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("musicbox")
    inst.AnimState:SetBuild("musicbox")
    inst.AnimState:PlayAnimation("idle", true)

    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(1)
    inst.Light:SetColour(237/255, 237/255, 209/255)
    inst.Light:Enable(false)

    inst:AddTag("musicbox")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "musicbox"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/musicbox.xml"
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(turnoff)

    inst:AddComponent("fueled")
    inst.components.fueled.accepting = true
    inst.components.fueled.fueltype = FUELTYPE.BLUEGEM
    inst.components.fueled:InitializeFuelLevel(480)
    inst.components.fueled:SetDepletedFn(nofuel)
    inst.components.fueled.CanAcceptFuelItem = MusicBoxCanAcceptFuelItem
    inst.components.fueled.TakeFuelItem = MusicBoxTakeFuel

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/musicbox", fn, assets)
