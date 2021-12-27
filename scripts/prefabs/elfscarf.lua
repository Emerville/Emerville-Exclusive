local assets = 
{
    Asset("ANIM", "anim/elfscarf.zip"),
    Asset("ANIM", "anim/torso_elfscarf.zip"),
	
    Asset("ATLAS", "images/inventoryimages/elfscarf.xml"),
    Asset("IMAGE", "images/inventoryimages/elfscarf.tex"),
}


local function MakeLoot(inst)
    local possible_loot =
    {
        {chance = 3, 	item = "winter_food1"}, --Gingerbread Cookie
		{chance = 3, 	item = "winter_food2"}, --Sugar Cookie
        {chance = 3, 	item = "winter_food5"}, --Chocolate Log Cake
        {chance = 1, 	item = "winter_food8"}, --Hot Cocoa
		{chance = 0.1,  item = "chocolatebar"}, 
        {chance = 0.1,  item = "coffee"},		
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

local function SpawnFood(inst)
	MakeLoot(inst)
    local item = nil
    for i, v in ipairs(inst.loot) do
        item = SpawnPrefab(v)
        item.Transform:SetPosition(inst.Transform:GetWorldPosition())
        if item.components.inventoryitem and item.components.inventoryitem.ondropfn then
            item.components.inventoryitem.ondropfn(item)
        end
    end
end

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_elfscarf", "torso_elfscarf")
    
	if inst.components.fueled ~= nil then
        inst.components.fueled:StartConsuming()
        inst.food_task = inst:DoPeriodicTask(240, function() SpawnFood(inst, owner) end) --480 Day	
    end
end

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
	
    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
		inst.food_task:Cancel()
		inst.food_task = nil
    end
end

local function init()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("elfscarf")
    inst.AnimState:SetBuild("elfscarf")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "elfscarf"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/elfscarf.xml"
	
	inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)
	
	inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.TOPHAT_PERISHTIME)
    inst.components.fueled:SetDepletedFn(inst.Remove)

    return inst
end

return Prefab("common/inventory/elfscarf", init, assets)
