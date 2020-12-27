local assets =
{
    Asset("ANIM", "anim/mechanicalfan.zip"),
	
	Asset("ATLAS", "images/inventoryimages/mechanicalfan_0.xml"),
    Asset("IMAGE", "images/inventoryimages/mechanicalfan_0.tex"),
    Asset("ATLAS", "images/inventoryimages/mechanicalfan_1.xml"),
    Asset("IMAGE", "images/inventoryimages/mechanicalfan_1.tex"),
	Asset("ATLAS", "images/inventoryimages/mechanicalfan_2.xml"),
    Asset("IMAGE", "images/inventoryimages/mechanicalfan_2.tex"),
	Asset("ATLAS", "images/inventoryimages/mechanicalfan_3.xml"),
    Asset("IMAGE", "images/inventoryimages/mechanicalfan_3.tex"),
	
	Asset("SOUND", "sound/common.fsb"),
}

local function OnFuelSectionChange(new, old, inst)
    if inst.components.machine.ison == false then
    if inst.components.fueled.currentfuel >= 80 then
		inst.AnimState:PlayAnimation("idle_3")
	elseif inst.components.fueled.currentfuel < 80 and inst.components.fueled.currentfuel > 40 then
		inst.AnimState:PlayAnimation("idle_2")
	elseif inst.components.fueled.currentfuel <= 40 and inst.components.fueled.currentfuel > 0 then
		inst.AnimState:PlayAnimation("idle_1") 
	elseif inst.components.fueled.currentfuel == 0 then
		inst.AnimState:PlayAnimation("idle_0")
	end
elseif inst.components.machine.ison == true then
	if inst.components.fueled.currentfuel >= 80 then
		inst.AnimState:PushAnimation("working_3", true)
	elseif inst.components.fueled.currentfuel < 80 and inst.components.fueled.currentfuel > 40 then
		inst.AnimState:PushAnimation("working_2", true)
	elseif inst.components.fueled.currentfuel <= 40 and inst.components.fueled.currentfuel > 0 then
		inst.AnimState:PushAnimation("working_1", true)
	elseif inst.components.fueled.currentfuel == 0 then
		inst.AnimState:PushAnimation("working_0", true)
	end
end
end

local function CanInteract(inst)
    return not inst.components.fueled:IsEmpty()
end

local function takefuel(inst)
if inst.components.machine.ison == false then
    if inst.components.fueled.currentfuel >= 80 then
		inst.AnimState:PlayAnimation("idle_3")
	elseif inst.components.fueled.currentfuel < 80 and inst.components.fueled.currentfuel > 40 then
		inst.AnimState:PlayAnimation("idle_2")
	elseif inst.components.fueled.currentfuel <= 40 and inst.components.fueled.currentfuel > 0 then
		inst.AnimState:PlayAnimation("idle_1") 
	elseif inst.components.fueled.currentfuel == 0 then
		inst.AnimState:PlayAnimation("idle_0")
	end
elseif inst.components.machine.ison == true then
	if inst.components.fueled.currentfuel >= 80 then
		inst.AnimState:PlayAnimation("working_3", true)
	elseif inst.components.fueled.currentfuel < 80 and inst.components.fueled.currentfuel > 40 then
		inst.AnimState:PlayAnimation("working_2", true)
	elseif inst.components.fueled.currentfuel <= 40 and inst.components.fueled.currentfuel > 0 then
		inst.AnimState:PlayAnimation("working_1", true)
	elseif inst.components.fueled.currentfuel == 0 then
		inst.AnimState:PlayAnimation("working_0", true)
	end
end
end

local function turnon(inst)
    if not inst.components.fueled:IsEmpty() then
        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end

        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil

	if inst.components.fueled.currentfuel >= 80 then
		inst.AnimState:PlayAnimation("working_3", true)
	elseif inst.components.fueled.currentfuel < 80 and inst.components.fueled.currentfuel > 40 then
		inst.AnimState:PlayAnimation("working_2", true)
	elseif inst.components.fueled.currentfuel <= 40 and inst.components.fueled.currentfuel > 0 then
		inst.AnimState:PlayAnimation("working_1", true)
	elseif inst.components.fueled.currentfuel == 0 then
		inst.AnimState:PlayAnimation("working_0", true)
	end

        inst.components.machine.ison = true

		inst.components.heater:SetThermics(false, true)
		
        inst.SoundEmitter:PlaySound("dontstarve/common/fan_twirl_LP", "loop")
    end
end

local function turnoff(inst)
    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end

	if inst.components.fueled.currentfuel >= 80 then
		inst.AnimState:PlayAnimation("idle_3")
		inst.components.inventoryitem.atlasname = "images/inventoryimages/mechanicalfan_3.xml"
		inst.components.inventoryitem:ChangeImageName("mechanicalfan_3")
		
	elseif inst.components.fueled.currentfuel < 80 and inst.components.fueled.currentfuel > 40 then
		inst.AnimState:PlayAnimation("idle_2")
		inst.components.inventoryitem.atlasname = "images/inventoryimages/mechanicalfan_2.xml"
		inst.components.inventoryitem:ChangeImageName("mechanicalfan_2")
		
	elseif inst.components.fueled.currentfuel <= 40 and inst.components.fueled.currentfuel > 0 then
		inst.AnimState:PlayAnimation("idle_1") 
		inst.components.inventoryitem.atlasname = "images/inventoryimages/mechanicalfan_1.xml"
		inst.components.inventoryitem:ChangeImageName("mechanicalfan_1")
		
	elseif inst.components.fueled.currentfuel == 0 then
		inst.AnimState:PlayAnimation("idle_0")
		inst.components.inventoryitem.atlasname = "images/inventoryimages/mechanicalfan_0.xml"
		inst.components.inventoryitem:ChangeImageName("mechanicalfan_0")
	end

    inst.components.machine.ison = false
	
	inst.components.heater:SetThermics(false, false)

    inst.SoundEmitter:KillSound("loop")
end

local function ondropped(inst)
    turnoff(inst)
    turnon(inst)
end

local function nofuel(inst)
    turnoff(inst)
end

local function GetHeatFn(inst)
    return -20
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)

	MakeSmallPropagator(inst)
	
    inst.AnimState:SetBank("mechanicalfan")
    inst.AnimState:SetBuild("mechanicalfan")
    inst.AnimState:PlayAnimation("idle_3")

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
	inst:AddComponent("heater")
	inst.components.heater.heatfn = GetHeatFn
	
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "mechanicalfan_3"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/mechanicalfan_3.xml"

    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(turnoff)

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
    inst.components.machine.cooldowntime = 0
	inst.components.machine.caninteractfn = CanInteract
	
	inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.BURNABLE
	inst.components.fueled.ontakefuelfn = takefuel
	inst.components.fueled.accepting = true 
    inst.components.fueled:InitializeFuelLevel(120)
	inst.components.fueled.maxfuel = 120
    inst.components.fueled:SetDepletedFn(nofuel)
	inst.components.fueled:SetSections(3)
	inst.components.fueled:SetSectionCallback(OnFuelSectionChange)
	
	MakeHauntableLaunch(inst)
	    AddHauntableCustomReaction(inst, function(inst, haunter)
        if math.random() <= TUNING.HAUNT_CHANCE_OFTEN then
            if inst.components.fueled and not inst.components.fueled:IsEmpty() then
                inst.components.fueled:MakeEmpty()
                inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
                return true
            end
        end
        return false
    end, true, false, true)
	
    return inst
end

return Prefab("common/objects/mechanicalfan", fn, assets)