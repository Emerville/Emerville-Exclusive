require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/hat_merm.zip"),
    Asset("ANIM", "anim/hat_mermlight.zip"),
	Asset("ATLAS", "images/inventoryimages/mermhat.xml"),
    Asset("IMAGE", "images/inventoryimages/mermhat.tex"),
	Asset("ATLAS", "images/inventoryimages/mermlighthat.xml"),
    Asset("IMAGE", "images/inventoryimages/mermlighthat.tex"),
}

local function MakeHat(name)
    local fname = "hat_"..name
    local symname = name.."hat"
    local prefabname = symname

    --If you want to use generic_perish to do more, it's still
    --commented in all the relevant places below in this file.
    --[[local function generic_perish(inst)
        inst:Remove()
    end]]

    local function onequip(inst, owner, symbol_override)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, symbol_override or "swap_hat", inst.GUID, fname)
        else
            owner.AnimState:OverrideSymbol("swap_hat", fname, symbol_override or "swap_hat")
        end
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAIR_HAT")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAT")
        end
		
		owner:AddTag("merm")

        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end
    end

    local function onunequip(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("unequipskinneditem", inst:GetSkinName())
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
		
		owner:RemoveTag("merm")

        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

    local function opentop_onequip(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, "swap_hat", inst.GUID, fname)
        else
            owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
        end

        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")

        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end
    end

    local function simple(custom_init)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(symname)
        inst.AnimState:SetBuild(fname)
        inst.AnimState:PlayAnimation("anim")

        inst:AddTag("hat")

        if custom_init ~= nil then
            custom_init(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inventoryitem")
        inst:AddComponent("inspectable")

        inst:AddComponent("tradable")

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)

        MakeHauntableLaunch(inst)

        return inst
    end
	
	local function default()
        return simple()
    end
	
----MERM HAT
	local function merm_equip(inst, owner)
        onequip(inst, owner)
	end

    local function merm_unequip(inst, owner)
        onunequip(inst, owner)
	end
	
    local function merm_custom_init(inst)
        inst:AddTag("show_spoilage")
		inst:AddTag("waterproofer")
		end
    
    local function merm()
        local inst = simple(merm_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end
		
		inst.components.equippable:SetOnEquip(merm_equip)
        inst.components.equippable:SetOnUnequip(merm_unequip)

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY
		
		inst.components.inventoryitem.imagename = "mermhat"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/mermhat.xml"
		
		inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_MED)

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(inst.Remove)
		

        MakeHauntableLaunchAndPerish(inst)

        return inst
    end
----------MERM LIGHT HAT------------	
	 local function mermlight_turnon(inst)
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if not inst.components.fueled:IsEmpty() then
            if inst._light == nil or not inst._light:IsValid() then
                inst._light = SpawnPrefab("mermlighthatlight")
            end
            if owner ~= nil then
                onequip(inst, owner)
                inst._light.entity:SetParent(owner.entity)
            end
            inst.components.fueled:StartConsuming()
            local soundemitter = owner ~= nil and owner.SoundEmitter or inst.SoundEmitter
            soundemitter:PlaySound("dontstarve/common/minerhatAddFuel")
        elseif owner ~= nil then
            onequip(inst, owner, "swap_hat_off")
        end
    end

    local function mermlight_turnoff(inst)
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if owner ~= nil and inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
            onequip(inst, owner, "swap_hat_off")
        end
        inst.components.fueled:StopConsuming()
        if inst._light ~= nil then
            if inst._light:IsValid() then
                inst._light:Remove()
            end
            inst._light = nil
            local soundemitter = owner ~= nil and owner.SoundEmitter or inst.SoundEmitter
            soundemitter:PlaySound("dontstarve/common/minerhatOut")
        end
    end

    local function mermlight_unequip(inst, owner)
        onunequip(inst, owner)
        mermlight_turnoff(inst)
    end

    local function mermlight_perish(inst)
        local equippable = inst.components.equippable
        if equippable ~= nil and equippable:IsEquipped() then
            local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
            if owner ~= nil then
                local data =
                {
                    prefab = inst.prefab,
                    equipslot = equippable.equipslot,
                }
                mermlight_turnoff(inst)
                owner:PushEvent("torchranout", data)
                return
            end
        end
        mermlight_turnoff(inst)
    end

    local function mermlight_takefuel(inst)
        if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
            mermlight_turnon(inst)
        end
    end

    local function mermlight_custom_init(inst)
        inst.entity:AddSoundEmitter()
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function mermlight_onremove(inst)
        if inst._light ~= nil and inst._light:IsValid() then
            inst._light:Remove()
        end
    end

    local function mermlight()
        local inst = simple(mermlight_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem:SetOnDroppedFn(mermlight_turnoff)
        inst.components.equippable:SetOnEquip(mermlight_turnon)
        inst.components.equippable:SetOnUnequip(mermlight_unequip)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.CAVE
        inst.components.fueled:InitializeFuelLevel(TUNING.MINERHAT_LIGHTTIME)
        inst.components.fueled:SetDepletedFn(mermlight_perish)
        inst.components.fueled:SetTakeFuelFn(mermlight_takefuel)
        inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
        inst.components.fueled.accepting = true
		
		inst.components.inventoryitem.imagename = "mermlighthat"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/mermlighthat.xml"

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_LARGE)

        inst._light = nil
        inst.OnRemoveEntity = mermlight_onremove

        return inst
    end

    local fn = nil
    local assets = { Asset("ANIM", "anim/"..fname..".zip") }
    local prefabs = nil

   if name == "merm" then
        fn = merm
	elseif name == "mermlight" then
        fn = mermlight
        prefabs = { "mermlighthatlight" }
    end

    return Prefab(prefabname, fn or default, assets, prefabs)
end

local function mermlighthatlightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetFalloff(0.8)
    inst.Light:SetIntensity(.9)
    inst.Light:SetRadius(3)
    inst.Light:SetColour(0 / 255, 125 / 255, 255 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return  MakeHat("merm"),
MakeHat("mermlight"),
Prefab("mermlighthatlight",mermlighthatlightfn)