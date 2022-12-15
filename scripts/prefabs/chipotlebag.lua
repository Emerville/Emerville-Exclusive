local easing = require("easing")

local assets =
{
    Asset("ANIM", "anim/chipotlebag.zip"),
	
    Asset("ATLAS", "images/inventoryimages/chipotlebag.xml"),
    Asset("IMAGE", "images/inventoryimages/chipotlebag.tex"),
}

local doll_prefabs =
{
	"dollluis",
	"guacamole",	
    "salsa",	
}

----------------------------------

local function onpickup(inst, picker)
	for _,prefabname in ipairs(doll_prefabs) do
		local prefab = SpawnPrefab(prefabname)
		inst.components.lootdropper:FlingItem(prefab)
	end
	--inst.AnimState:PlayAnimation("open")
	inst:Remove()
    return true --This makes the inventoryitem component not actually give the tumbleweed to the player
end

local function init()
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("chipotlebag")
    inst.AnimState:SetBuild("chipotlebag")
    inst.AnimState:PlayAnimation("idle")
	
    inst:AddTag("casino")

	inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "chipotlebag"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/chipotlebag.xml"
	inst.components.inventoryitem.canbepickedup = true
	
    inst:AddComponent("lootdropper")
	
--[[	inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_sticks"
    inst.components.pickable.onpickedfn = onpickup
    inst.components.pickable.canbepicked = true]]
	
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("backpack")
    inst.components.container.onopenfn = onpickup
		
	MakeHauntableLaunchAndPerish(inst)
	
    return inst
end

return Prefab("common/objects/chipotlebag", init, assets)