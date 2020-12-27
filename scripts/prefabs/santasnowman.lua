require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/snowman.zip"),
	
    Asset("ATLAS", "images/inventoryimages/snowman.xml"),
    Asset("IMAGE", "images/inventoryimages/snowman.tex"),
}

local prefabs = 
{
	"collapse_small",
}
--------------------------------

local function onbuilt(inst)
        inst.AnimState:PlayAnimation("building")
        inst.AnimState:PushAnimation("idle")             
end

local function onperish(inst)
    inst:Remove()
end

---------------------------------

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("snowman")
    inst.AnimState:SetBuild("snowman")
    inst.AnimState:PlayAnimation("idle")

	inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
	
	inst:ListenForEvent("onbuilt", onbuilt)
	
	inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(14)
    inst.components.perishable:StartPerishing()
    inst.components.perishable:SetOnPerishFn(onperish)
	
    return inst
end

return Prefab("common/objects/santasnowman", fn, assets, prefabs),
       MakePlacer("common/snowman_placer", "snowman", "snowman", "idle") 