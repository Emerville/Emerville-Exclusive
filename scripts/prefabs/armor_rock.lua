local assets =
{
	Asset("ANIM", "anim/armor_rock.zip"),
	
	Asset("ATLAS", "images/inventoryimages/armor_rock.xml"),
    Asset("IMAGE", "images/inventoryimages/armor_rock.tex"),	
}

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_rock", "swap_body")
    inst:ListenForEvent("blocked", OnBlocked, owner)
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
	inst:RemoveEventCallback("blocked", OnBlocked, owner)
end

local function fn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()	
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("armor_rock")
    inst.AnimState:SetBuild("armor_rock")
    inst.AnimState:PlayAnimation("idle")
    	
	inst.foleysound = "dontstarve/movement/foley/metalarmour"
    
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "armor_rock"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/armor_rock.xml"
	
	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(480, 0.85)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	inst.components.equippable.walkspeedmult = 0.85
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)
    inst.components.insulator:SetSummer()
    
	MakeHauntableLaunch(inst)
	
    return inst
end

return Prefab("common/inventory/armor_rock", fn, assets) 