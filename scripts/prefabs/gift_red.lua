local easing = require("easing")

local assets =
{
	Asset("ANIM", "anim/tp_gift_red.zip"),

	Asset("ATLAS", "images/inventoryimages/gift_red.xml"),
	Asset("IMAGE", "images/inventoryimages/gift_red.tex"),
}

local prefabs =
{
	"taffy",
	"winterhat",
	"trinket_18",
	"trinket_11",
	"trinket_5",
	"trinket_24",
	"gears",
	"mandrake",
	"purplegem",
	"tophat",
	"rabbit",
	"dragonpie",
	"flowerhat",
	"chocolatebar",	
	"waffles",
	"icecream",
--	"santa_helper_hat",
}

local function MakeLoot(inst)
    local possible_loot =
    {
        {chance = 6,    item = "taffy"},
        {chance = 3, 	item = "trinket_18"},
        {chance = 3, 	item = "trinket_11"},
        {chance = 3, 	item = "trinket_5"},
		{chance = 3, 	item = "trinket_24"},
        {chance = 1,    item = "winterhat"},
		{chance = 1,    item = "tophat"},
		{chance = 1,    item = "beefalohat"},	
		{chance = 0.1,  item = "waffles"},
		{chance = 0.1,  item = "icecream"},		
		{chance = 0.1,  item = "dragonpie"},
--		{chance = 0.1,  item = "santa_helper_hat"},		
		{chance = 0.05, item = "gears"},
	    {chance = 0.05, item = "purplegem"},		
		{chance = 0.05, item = "mandrake"},
	    {chance = 0.05, item = "chocolatebar"},			
    }
    local totalchance = 0
    for m, n in ipairs(possible_loot) do
        totalchance = totalchance + n.chance
    end
    inst.loot = {}
    inst.lootaggro = {}
    local next_loot = nil
    local next_aggro = nil
    local next_chance = nil
    local num_loots = 1
    while num_loots > 0 do
        next_chance = math.random()*totalchance
        next_loot = nil
        next_aggro = nil
        for m, n in ipairs(possible_loot) do
            next_chance = next_chance - n.chance
            if next_chance <= 0 then
                next_loot = n.item
                if n.aggro then next_aggro = true end
                break
            end
        end
        if next_loot ~= nil then
            table.insert(inst.loot, next_loot)
            if next_aggro then 
                table.insert(inst.lootaggro, true)
            else
                table.insert(inst.lootaggro, false)
            end
            num_loots = num_loots - 1
        end
    end
end

----------------------------------

local function onpickup(inst, picker)
    if inst.owner and inst.owner.components.childspawner then 
        inst:PushEvent("pickedup")
    end

    local item = nil
    for i, v in ipairs(inst.loot) do
        item = SpawnPrefab(v)
        item.Transform:SetPosition(inst.Transform:GetWorldPosition())
        if item.components.inventoryitem and item.components.inventoryitem.ondropfn then
            item.components.inventoryitem.ondropfn(item)
        end
        if inst.lootaggro[i] and item.components.combat and picker ~= nil then
            if not (item:HasTag("spider") and (picker:HasTag("spiderwhisperer") or picker:HasTag("monsdter"))) then
                item.components.combat:SuggestTarget(picker)
            end
        end
    end
	if picker and picker.components.sanity then
        picker.components.sanity:DoDelta(TUNING.SANITY_TINY)
	end
	inst.AnimState:PlayAnimation("open")
	inst:ListenForEvent("animover", function(inst) inst:Remove() end)
    return true --This makes the inventoryitem component not actually give the tumbleweed to the player
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst) 

    inst.AnimState:SetBuild("tp_gift_red")
    inst.AnimState:SetBank("giftgamble")
    inst.AnimState:PlayAnimation("idle")
	
	inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end	

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "gift_red"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gift_red.xml"
	inst.components.inventoryitem.canbepickedup = false
	
	MakeLoot(inst)
	
	inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_sticks"
    inst.components.pickable.onpickedfn = onpickup
    inst.components.pickable.canbepicked = true
	
	MakeHauntableLaunchAndPerish(inst)	
   
    return inst
end

return Prefab( "common/inventory/gift_red", fn, assets) 