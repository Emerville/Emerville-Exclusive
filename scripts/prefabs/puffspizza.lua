local assets =
{
    Asset("ANIM", "anim/puffspizza.zip"),
    Asset("ATLAS", "images/inventoryimages/puffspizza.xml"),
    Asset("IMAGE", "images/inventoryimages/puffspizza.tex"),
}

-- Rewrote the function to prevent the Pizza from spawning on the Lunar Islands.
-- Needs some more testing to make sure it's fool proof. How about a public test? That always goes well :) --KW
local function GetRandomPosition(inst)
    local locations = {}
    for i, node in ipairs(TheWorld.topology.nodes) do
        if not table.contains(node.tags, "not_mainland") and TheWorld.Map:IsPassableAtPoint(node.x, 0, node.y) then
            table.insert(locations, {x = node.x, z = node.y})
        end
    end
    if #locations > 0 then
        local pos = locations[math.random(#locations)]
        return Point(pos.x, 0, pos.z)
    else
        return inst:GetPosition()
    end
end

local function OnPizzaTeleported(inst)
    local pos = GetRandomPosition(inst)
    inst.Transform:SetPosition(pos.x, 0, pos.z)
    SpawnPrefab("pandorachest_reset").Transform:SetPosition(pos.x, 0, pos.z)
end

local function OnPizzaExpired(inst)
    local owner = inst.components.inventoryitem.owner
    local teleportDelay = owner and .4 or 0

    if owner ~= nil and owner.components.inventory ~= nil then
        owner.components.inventory:DropItem(inst)
    elseif owner ~= nil and owner.components.container ~= nil then
        owner.components.container:DropItem(inst)
    end

    local pizzashatter = SpawnPrefab("round_puff_fx_sm")
    pizzashatter.Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst:DoTaskInTime(teleportDelay, function()
        inst:RandomTeleport()
        inst.pizzashatter_task = nil
    end)
end

--Start 10 Minute Timer when the Pizza is picked up. When 10 minutes pass, remove item from inventory & spawn the pizza at a random place in the world (TeleportPizza)
local function OnPickup(inst, owner)
    if inst.pizzashatter_task == nil then
        inst.pizzashatter_task = inst:DoTaskInTime(600, function() OnPizzaExpired(inst) end) --600 = 10 minutes. Put 2 while testing for 2 seconds.
    end
    -- Added a pickup announcement so players know when a Pizza has been found. Kinda odd that Show Me displays
    -- the timer while it's in your inventory. --KW
    if inst.announcement and owner.name then
        TheNet:Announce(owner.name.." is on a pizza delivery!")
        inst.announcement = false
        inst.components.timer:StartTimer("announcement", 300) -- 5 minutes
    end
end

local function OnTimerDone(inst, data)
    if data.name == "announcement" then
        inst.announcement = true
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("puffspizza")
    inst.AnimState:SetBuild("puffspizza")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("irreplaceable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 10	

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "puffspizza"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/puffspizza.xml"
    inst.components.inventoryitem:SetOnPickupFn(OnPickup)

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", OnTimerDone)

    inst.RandomTeleport = OnPizzaTeleported
    inst.announcement = true

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/puffspizza", fn, assets)