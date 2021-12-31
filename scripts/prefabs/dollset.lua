local easing = require("easing")

local assets =
{
    Asset("ANIM", "anim/giftgamble.zip"),
	
    Asset("ATLAS", "images/inventoryimages/giftgamble.xml"),
    Asset("IMAGE", "images/inventoryimages/giftgamble.tex"),
}

local doll_prefabs =
{
	"dollwolfgang",
	"dollwilson",	
    "dollwigfrid",
    "dollwillow",
	"dollwendy",
    "dollwx",
	"dollwicker",
    "dollwes",
	"dollmaxwell",
	"dollwoodie",
	"dollwebber",
	"dollwinona",
	"dollwormwood",
	"dollwortox_uncorrupted",	
	"dollwurt_abyssal",
	"dollwarly",
	"dollwalter",
	"dollmystery",	
}

----------------------------------

local function onpickup(inst, picker)
	for _,prefabname in ipairs(doll_prefabs) do
		local prefab = SpawnPrefab(prefabname)
		inst.components.lootdropper:FlingItem(prefab)
	end
	inst.AnimState:PlayAnimation("open")
	inst:ListenForEvent("animover", function(inst) inst:Remove() end)
    return true --This makes the inventoryitem component not actually give the tumbleweed to the player
end

local function init()
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("giftgamble")
    inst.AnimState:SetBuild("giftgamble")
    inst.AnimState:PlayAnimation("idle")
	
    inst:AddTag("casino")

	inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end
	
	--inst:AddComponent("lootdropper")
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "giftgamble"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/giftgamble.xml"
	inst.components.inventoryitem.canbepickedup = false
	
    inst:AddComponent("lootdropper")
	
	inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_sticks"
    inst.components.pickable.onpickedfn = onpickup
    inst.components.pickable.canbepicked = true
		
	MakeHauntableLaunchAndPerish(inst)
	
    return inst
end

return Prefab("common/objects/dollset", init, assets)