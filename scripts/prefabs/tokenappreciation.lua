local assets =
{
    Asset("ANIM", "anim/tokenappreciation.zip"),
	
    Asset("ATLAS", "images/inventoryimages/tokenappreciation.xml"),
    Asset("IMAGE", "images/inventoryimages/tokenappreciation.tex"),
}

local prefabs =
{
    "tokenappreciation_coin_fx",
}

local names = {"tokenappreciation1","tokenappreciation2", "tokenappreciation3"}

local function inventoryicons(inst, item)
if item.prefab == "tokenappreciation1" then
	inst.components.inventoryitem.atlasname = "images/inventoryimages/tokenappreciation.xml"
	inst.components.inventoryitem.ChangeImageName = ("tokenappreciation1")
elseif  item.prefab == "tokenappreciation2" then
	inst.components.inventoryitem.atlasname = "images/inventoryimages/tokenappreciation.xml"
    inst.components.inventoryitem:ChangeImageName("tokenappreciation2")
elseif  item.prefab == "tokenappreciation3" then
	inst.components.inventoryitem.atlasname = "images/inventoryimages/tokenappreciation.xml"
    inst.components.inventoryitem:ChangeImageName("tokenappreciation3")
else
	inst.components.inventoryitem.atlasname = "images/inventoryimages/tokenappreciation.xml"
	inst.components.inventoryitem.ChangeImageName = ("tokenappreciation1")
	end
end

local function MakeCoin(id, hasfx)
  local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("tokenappreciation")
    inst.AnimState:SetBuild("tokenappreciation")
    inst.AnimState:PlayAnimation("idle")
    if id > 1 then
        inst.AnimState:OverrideSymbol("coin01", "tokenappreciation", "coin0"..tostring(id))
        inst.AnimState:OverrideSymbol("coin_shad1", "tokenappreciation", "coin_shad"..tostring(id))
    end
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem:SetOnPutInInventoryFn(inventoryicons)   

	inst:AddComponent("waterproofer")
	inst.components.waterproofer.effectiveness = 0	
    
    return inst
end


    return Prefab("tokenappreciation"..id, fn, assets, hasfx and prefabs or nil)
end


local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("tokenappreciation")
    inst.AnimState:SetBuild("tokenappreciation")
    inst.AnimState:PlayAnimation("opal_loop", true)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    if not TheWorld.ismastersim then
        return inst
    end

    --event_server_data("quagmire", "prefabs/quagmire_coins").master_postinit_fx(inst)

    return inst
end
	
----------------------------------------------------------------------------------------------------
-- return prefabs
----------------------------------------------------------------------------------------------------
return MakeCoin(1),
    MakeCoin(2),
    MakeCoin(3, true),
    Prefab("tokenappreciation_coin_fx", fxfn, assets)
