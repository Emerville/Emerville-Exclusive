local assets =
{
	Asset("ANIM", "anim/malamilantern.zip"),
	Asset("ANIM", "anim/swap_malamilantern.zip"),
	Asset("ANIM", "anim/swap_malamilantern_on.zip"),
    Asset("SOUND", "sound/wilson.fsb"),
	
	Asset("ATLAS", "images/inventoryimages/malamilantern.xml"),
    Asset("IMAGE", "images/inventoryimages/malamilantern.tex"),
	Asset("ATLAS", "images/inventoryimages/malamilantern_lit.xml"),
    Asset("IMAGE", "images/inventoryimages/malamilantern_lit.tex"),
}

local function fuelupdate(inst)
    if inst._light ~= nil then
        local fuelpercent = inst.components.fueled:GetPercent()
        inst._light.Light:SetIntensity(Lerp(0.4, 0.6, fuelpercent))
        inst._light.Light:SetRadius(Lerp(5, 8, fuelpercent))
        inst._light.Light:SetFalloff(.9)
    end
end

local function turnon(inst)
    if not inst.components.fueled:IsEmpty() then
        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end

        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil

        if inst._light == nil or not inst._light:IsValid() then
            inst._light = SpawnPrefab("elegantlanternlight")
            fuelupdate(inst)
        end
        inst._light.entity:SetParent((owner or inst).entity)

        inst.AnimState:PlayAnimation("idle_on")

        if owner ~= nil and inst.components.equippable:IsEquipped() then
            owner.AnimState:OverrideSymbol("swap_object", "swap_malamilantern", "swap_malamilantern")
            owner.AnimState:Show("LANTERN_OVERLAY")
        end

        inst.components.machine.ison = true

        inst.SoundEmitter:PlaySound("dontstarve/wilson/lantern_on")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/lantern_LP", "loop")

		inst.components.inventoryitem.atlasname = "images/inventoryimages/malamilantern_lit.xml"
        inst.components.inventoryitem:ChangeImageName("malamilantern_lit")
    end
end

local function turnoff(inst)
    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end

    if inst._light ~= nil then
        if inst._light:IsValid() then
            inst._light:Remove()
        end
        inst._light = nil
    end

    inst.AnimState:PlayAnimation("idle_off")

    if inst.components.equippable:IsEquipped() then
        inst.components.inventoryitem.owner.AnimState:OverrideSymbol("swap_object", "swap_malamilantern", "swap_malamilantern")
        inst.components.inventoryitem.owner.AnimState:Hide("LANTERN_OVERLAY")
    end

    inst.components.machine.ison = false

    inst.SoundEmitter:KillSound("loop")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/lantern_off")

	inst.components.inventoryitem.atlasname = "images/inventoryimages/malamilantern.xml"
    inst.components.inventoryitem:ChangeImageName("malamilantern")
end

local function OnRemove(inst)
    if inst._light ~= nil and inst._light:IsValid() then
        inst._light:Remove()
    end
end

local function ondropped(inst)
    turnoff(inst)
    turnon(inst)
end

--
local function onequip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:OverrideSymbol("lantern_overlay", "swap_malamilantern_on", "swap_malamilantern_on")
    
    if inst.components.fueled:IsEmpty() then
        owner.AnimState:OverrideSymbol("swap_object", "swap_malamilantern", "swap_malamilantern")
        owner.AnimState:Hide("LANTERN_OVERLAY") 
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_malamilantern", "swap_malamilantern")
        owner.AnimState:Show("LANTERN_OVERLAY") 
    end
    turnon(inst)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("lantern_overlay")
    owner.AnimState:Hide("LANTERN_OVERLAY")
end

local function nofuel(inst)
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
            owner:PushEvent("torchranout", data)
            return
        end
    end
    turnoff(inst)
end

local function takefuel(inst)
    if inst.components.equippable and inst.components.equippable:IsEquipped() then
        turnon(inst)
    end
end

---------------------------------

local function lanternlightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetColour(215 / 255, 230 / 255, 250 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)	

    inst.AnimState:SetBank("malamilantern")
    inst.AnimState:SetBuild("malamilantern")
    inst.AnimState:PlayAnimation("idle_off")
	
    inst:AddTag("light")	

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "malamilantern"	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/malamilantern.xml"	
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(turnoff)
	
    inst:AddComponent("equippable")	
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)	

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
    inst.components.machine.cooldowntime = 0

    inst:AddComponent("fueled")		
    inst.components.fueled.fueltype = FUELTYPE.BURNABLE
    inst.components.fueled:InitializeFuelLevel(TUNING.LANTERN_LIGHTTIME*0.75)
    inst.components.fueled:SetDepletedFn(nofuel)
    inst.components.fueled:SetUpdateFn(fuelupdate)
    inst.components.fueled.ontakefuelfn = takefuel
    inst.components.fueled.accepting = true

    inst._light = nil

    MakeHauntableLaunch(inst)

    inst.OnRemoveEntity = OnRemove

    return inst
end

return Prefab("common/inventory/elegantlantern", fn, assets),
       Prefab("common/inventory/elegantlanternlight", lanternlightfn)