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
    inst.SoundEmitter:PlaySound("musicbox/sound/playmelody", "musicbox_melody")
end

local function turnoff(inst)
    inst.components.fueled:StopConsuming()
    inst.Light:Enable(false)
    inst:RemoveTag("light")
    inst.SoundEmitter:KillSound("musicbox_melody")
end

local function ondropped(inst)
    turnoff(inst)
    turnon(inst)
end

local function nofuel(inst)
    SpawnPrefab("sparks").Transform:SetPosition(inst:GetPosition():Get())
    turnoff(inst)
end

local function takefuel(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_craft")
end

local function CanAcceptFuelItem(self, item)
    return self.accepting and item and item.components.fuel and (item.components.fuel.fueltype == self.fueltype or item.components.fuel.fueltype == self.secondaryfueltype)
end

local function TakeFuelItem(self, item, doer)
    if self:CanAcceptFuelItem(item) then
        local fuelvalue = 480
        self:DoDelta(fuelvalue, doer)

        if item.components.fuel ~= nil then
            item.components.fuel:Taken(self.inst)
        end
        item:Remove()

        if self.ontakefuelfn ~= nil then
            self.ontakefuelfn(self.inst)
        end
        self.inst:PushEvent("takefuel", { fuelvalue = fuelvalue })

        return true
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
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(turnoff)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.BLUEGEM
    inst.components.fueled:InitializeFuelLevel(480)
    inst.components.fueled:SetDepletedFn(nofuel)
    inst.components.fueled:SetTakeFuelFn(takefuel)
    inst.components.fueled.CanAcceptFuelItem = CanAcceptFuelItem
    inst.components.fueled.TakeFuelItem = TakeFuelItem
    inst.components.fueled.accepting = true

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/musicbox", fn, assets)
