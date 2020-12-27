local easing = require("easing")

local assets =
{
    Asset("ANIM", "anim/giftgamble.zip"),
	
    Asset("ATLAS", "images/inventoryimages/giftgamble.xml"),
    Asset("IMAGE", "images/inventoryimages/giftgamble.tex"),
}

local prefabs =
{
    "magicdolls",
	"magicbag",	
	"elegantlantern",
	"skeletalamulet",
	"horsehead",
}

local function MakeLoot(inst)
    local possible_loot =
    {
        {chance = 5,    item = "magicdolls"},	
        {chance = 5,    item = "magicdolls"},
		{chance = 5,    item = "magicdolls"},
		{chance = 5,    item = "magicdolls"},		
        {chance = 4,    item = "magicdolls"},
		{chance = 4,    item = "skeletalamulet"},
		{chance = 4,    item = "horsehead"},		
		{chance = 3,    item = "magicdolls"},		
        {chance = 3,    item = "elegantlantern"},
        {chance = 3,    item = "magicbag"},		
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
	
	MakeLoot(inst)
	
	inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_sticks"
    inst.components.pickable.onpickedfn = onpickup
    inst.components.pickable.canbepicked = true
		
	MakeHauntableLaunchAndPerish(inst)
	
    return inst
end

return Prefab("common/objects/giftgamble", init, assets)