local assets =
{
    Asset("ANIM", "anim/purplecane.zip"),
    Asset("ANIM", "anim/swap_purplecane.zip"),
	
	Asset("ATLAS", "images/inventoryimages/purplecane.xml"),
    Asset("IMAGE", "images/inventoryimages/purplecane.tex"),
}

---------PURPLE STAFF---------

-- AddTag("nomagic") can be used to stop something being teleported
-- the component teleportedoverride can be used to control the location of a teleported item

local function getrandomposition(caster, teleportee, target_in_ocean)
	if target_in_ocean then
		local pt = TheWorld.Map:FindRandomPointInOcean(20)
		if pt ~= nil then
			return pt
		end
		local from_pt = teleportee:GetPosition()
		local offset = FindSwimmableOffset(from_pt, math.random() * 2 * PI, 90, 16)
						or FindSwimmableOffset(from_pt, math.random() * 2 * PI, 60, 16)
						or FindSwimmableOffset(from_pt, math.random() * 2 * PI, 30, 16)
						or FindSwimmableOffset(from_pt, math.random() * 2 * PI, 15, 16)
		if offset ~= nil then
			return from_pt + offset
		end
		return teleportee:GetPosition()
	else
		local centers = {}
		for i, node in ipairs(TheWorld.topology.nodes) do
			if TheWorld.Map:IsPassableAtPoint(node.x, 0, node.y) and node.type ~= NODE_TYPE.SeparatedRoom then
				table.insert(centers, {x = node.x, z = node.y})
			end
		end
		if #centers > 0 then
			local pos = centers[math.random(#centers)]
			return Point(pos.x, 0, pos.z)
		else
			return caster:GetPosition()
		end
	end
end

local function teleport_end(teleportee, locpos, loctarget)
    if loctarget ~= nil and loctarget:IsValid() and loctarget.onteleto ~= nil then
        loctarget:onteleto()
    end

    if teleportee.components.inventory ~= nil and teleportee.components.inventory:IsHeavyLifting() then
        teleportee.components.inventory:DropItem(
            teleportee.components.inventory:Unequip(EQUIPSLOTS.BODY),
            true,
            true
        )
    end

    --#v2c hacky way to prevent lightning from igniting us
    local preventburning = teleportee.components.burnable ~= nil and not teleportee.components.burnable.burning
    if preventburning then
        teleportee.components.burnable.burning = true
    end
--    TheWorld:PushEvent("ms_sendlightningstrike", locpos)
--    SpawnPrefab("shadow_puff_large_front").Transform:SetPosition(locpos)
    if preventburning then
        teleportee.components.burnable.burning = false
    end

    if teleportee:HasTag("player") then
        teleportee.sg.statemem.teleport_task = nil
        teleportee.sg:GoToState(teleportee:HasTag("playerghost") and "appear" or "wakeup")
        teleportee.SoundEmitter:PlaySound("dontstarve/common/staffteleport")
    else
        teleportee:Show()
        if teleportee.DynamicShadow ~= nil then
            teleportee.DynamicShadow:Enable(true)
        end
        if teleportee.components.health ~= nil then
            teleportee.components.health:SetInvincible(false)
        end
        teleportee:PushEvent("teleported")
    end
end

local function teleport_continue(teleportee, locpos, loctarget)
    if teleportee.Physics ~= nil then
        teleportee.Physics:Teleport(locpos.x, 0, locpos.z)
    else
        teleportee.Transform:SetPosition(locpos.x, 0, locpos.z)
    end

    if teleportee:HasTag("player") then
        teleportee:SnapCamera()
        teleportee:ScreenFade(true, 1)
        teleportee.sg.statemem.teleport_task = teleportee:DoTaskInTime(1, teleport_end, locpos, loctarget)
    else
        teleport_end(teleportee, locpos, loctarget)
    end
end

local function teleport_start(teleportee, staff, caster, loctarget, target_in_ocean)
    local ground = TheWorld

    --V2C: Gotta do this RIGHT AWAY in case anything happens to loctarget or caster
    local locpos = teleportee.components.teleportedoverride ~= nil and teleportee.components.teleportedoverride:GetDestPosition()
				or loctarget == nil and getrandomposition(caster, teleportee, target_in_ocean)
				or loctarget.teletopos ~= nil and loctarget:teletopos()
				or loctarget:GetPosition()

    if teleportee.components.locomotor ~= nil then
        teleportee.components.locomotor:StopMoving()
    end

--    staff.components.finiteuses:Use(1)

--[[    if ground:HasTag("cave") then
        -- There's a roof over your head, magic lightning can't strike!
        ground:PushEvent("ms_miniquake", { rad = 3, num = 5, duration = 1.5, target = teleportee })
        return
    end]]

    local isplayer = teleportee:HasTag("player")
    if isplayer then
        teleportee.sg:GoToState("forcetele")
    else
        if teleportee.components.health ~= nil then
            teleportee.components.health:SetInvincible(true)
        end
        if teleportee.DynamicShadow ~= nil then
            teleportee.DynamicShadow:Enable(false)
        end
        teleportee:Hide()
    end

    --#v2c hacky way to prevent lightning from igniting us
    local preventburning = teleportee.components.burnable ~= nil and not teleportee.components.burnable.burning
    if preventburning then
        teleportee.components.burnable.burning = true
    end
--    ground:PushEvent("ms_sendlightningstrike", teleportee:GetPosition())
    if preventburning then
        teleportee.components.burnable.burning = false
    end

--[[    if caster ~= nil and caster.components.sanity ~= nil then
        caster.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
    end]]

--    ground:PushEvent("ms_deltamoisture", TUNING.TELESTAFF_MOISTURE)

    if isplayer then
        teleportee.sg.statemem.teleport_task = teleportee:DoTaskInTime(3, teleport_continue, locpos, loctarget)
    else
        teleport_continue(teleportee, locpos, loctarget)
    end
end

local function teleport_targets_sort_fn(a, b)
    return a.distance < b.distance
end

local TELEPORT_MUST_TAGS = { "locomotor" }
local TELEPORT_CANT_TAGS = { "playerghost", "INLIMBO" }
local function teleport_func(inst, target)
    local caster = inst.components.inventoryitem.owner or target
    if target == nil then
        target = caster
    end

    local x, y, z = target.Transform:GetWorldPosition()
	local target_in_ocean = target.components.locomotor ~= nil and target.components.locomotor:IsAquatic()

	local loctarget = target.components.minigame_participator ~= nil and target.components.minigame_participator:GetMinigame()
						or target.components.teleportedoverride ~= nil and target.components.teleportedoverride:GetDestTarget()
                        or target.components.hitchable ~= nil and target:HasTag("hitched") and target.components.hitchable.hitched
						or nil

--[[	if loctarget == nil and not target_in_ocean then
		loctarget = FindNearestActiveTelebase(x, y, z, nil, 1)
	end]]
    teleport_start(target, inst, caster, loctarget, target_in_ocean)
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_purplecane", "swap_purplecane")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("purplecane")
    inst.AnimState:SetBuild("purplecane")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.CANE_DAMAGE)	
	
    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(teleport_func)
    inst.components.spellcaster.canuseontargets = false
    inst.components.spellcaster.canusefrominventory = true
    inst.components.spellcaster.canonlyuseonlocomotorspvp = false

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "purplecane"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/purplecane.xml"

    inst:AddComponent("equippable")

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY	
    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/purplecane", fn, assets)