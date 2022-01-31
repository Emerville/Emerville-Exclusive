local assets =
{
	-- Animation files used for the item.
	Asset("ANIM", "anim/magicdolls.zip"),

	-- Inventory image and atlas file used for the item.
    Asset("ATLAS", "images/inventoryimages/magicdolls.xml"),
    Asset("IMAGE", "images/inventoryimages/magicdolls.tex"),
	Asset("ATLAS", "images/inventoryimages/magicdollstwo.xml"),
    Asset("IMAGE", "images/inventoryimages/magicdollstwo.tex"),
	Asset("ATLAS", "images/inventoryimages/magicdollsthree.xml"),
    Asset("IMAGE", "images/inventoryimages/magicdollsthree.tex"),
	Asset("ATLAS", "images/inventoryimages/magicdollsfour.xml"),
    Asset("IMAGE", "images/inventoryimages/magicdollsfour.tex"),
	Asset("ATLAS", "images/inventoryimages/magicdollsfive.xml"),
    Asset("IMAGE", "images/inventoryimages/magicdollsfive.tex"),
	Asset("ATLAS", "images/inventoryimages/magicdollssix.xml"),
    Asset("IMAGE", "images/inventoryimages/magicdollssix.tex"),

}

local names = {"magicdolls1","magicdolls2", "magicdolls3", "magicdolls4", "magicdolls5", "magicdolls6"}

local function inventoryicons(inst)
if inst.animname == "magicdolls1" then
	inst.components.inventoryitem.atlasname = "images/inventoryimages/magicdolls.xml"
	inst.components.inventoryitem.ChangeImageName = ("magicdolls")
elseif  inst.animname == "magicdolls2" then
	inst.components.inventoryitem.atlasname = "images/inventoryimages/magicdollstwo.xml"
    inst.components.inventoryitem:ChangeImageName("magicdollstwo")
elseif  inst.animname == "magicdolls3" then
	inst.components.inventoryitem.atlasname = "images/inventoryimages/magicdollsthree.xml"
    inst.components.inventoryitem:ChangeImageName("magicdollsthree")
elseif  inst.animname == "magicdolls4" then
	inst.components.inventoryitem.atlasname = "images/inventoryimages/magicdollsfour.xml"
    inst.components.inventoryitem:ChangeImageName("magicdollsfour")
elseif  inst.animname == "magicdolls5" then
	inst.components.inventoryitem.atlasname = "images/inventoryimages/magicdollsfive.xml"
    inst.components.inventoryitem:ChangeImageName("magicdollsfive")
elseif  inst.animname == "magicdolls6" then
	inst.components.inventoryitem.atlasname = "images/inventoryimages/magicdollssix.xml"
    inst.components.inventoryitem:ChangeImageName("magicdollssix")
else
	inst.components.inventoryitem.atlasname = "images/inventoryimages/magicdolls.xml"
	inst.components.inventoryitem.ChangeImageName = ("magicdolls")
	end
end
---

---
local function onsave(inst, data)
    data.anim = inst.animname
end

local function onload(inst, data)
    if data and data.anim then
        inst.animname = data.anim
        inst.AnimState:PlayAnimation(inst.animname, true)
    end
end

local function init()

	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("magicdolls")
    inst.AnimState:SetBuild("magicdolls")
	
    inst:AddTag("resurrector")
	inst:AddTag("molebait")
	inst:AddTag("cattoy")
    inst:AddTag("casino")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

    inst:AddComponent("inspectable")	

	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 25	
		
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetOnPutInInventoryFn(inventoryicons)
   
    inst.animname = names[math.random(#names)]
    inst.AnimState:PlayAnimation(inst.animname, true)
   
	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
	
	-- where inst is the hauntable item
	local old_onhaunt = inst.components.hauntable.onhaunt
	inst.components.hauntable:SetOnHauntFn(function(inst, doer)
	local fx = SpawnPrefab("small_puff")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx.Transform:SetScale(.5, .5, .5)
    inst:Remove()
    return old_onhaunt(inst, doer)
	end)
	
	inst:AddComponent("bait")
    
	    --------SaveLoad
    inst.OnSave = onsave 
    inst.OnLoad = onload 
	
    return inst
end

return Prefab("common/inventory/magicdolls", init, assets)