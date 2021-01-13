local assets =
{ 
    Asset("ANIM", "anim/hat_bush.zip"),
    Asset("ATLAS", "images/inventoryimages/bushhatex.xml"),
    Asset("IMAGE", "images/inventoryimages/bushhatex.tex"),
}

local prefabs = 
{
}

local fname = "hat_bush"
local symname = "bushhat"
local prefabname = symname


local function removeBerryBush(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 10, {"bushhatex_temp"})
    for i, v in ipairs(ents) do
    	v:Remove()
    end
end


local function stopusingbush(inst, data)
    local hat = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
    if hat ~= nil and data.statename ~= "hide" then
        hat.components.useableitem:StopUsingItem()
    end
end


local function keeptargetfn()
    return false
end


local function makeBerryBush(inst)
    local bush = SpawnPrefab("berrybush")
    if bush then
    	bush:AddTag("bushhatex_temp")
	    bush:AddTag("animal")
    	bush:AddTag("prey")
--    	bush:AddTag("rabbit")
    	bush:AddTag("smallcreature")
--    	bush:AddTag("canbetrapped")
--    	bush:AddTag("cattoy")
--    	bush:AddTag("catfood")

        bush:AddComponent("combat")
        bush.components.combat:SetKeepTargetFunction(keeptargetfn)
        bush:AddComponent("health")
		bush.components.health:SetMaxHealth(100)

        local pos = Vector3(inst.Transform:GetWorldPosition() )
        local dist = 3 + 7*math.random()
        local angle = math.random()*2*PI
        pos.x = pos.x + dist*math.cos(angle)
        pos.z = pos.z + dist*math.sin(angle)
        bush.Physics:Teleport(pos:Get())
		
		SpawnPrefab("small_puff").Transform:SetPosition(pos:Get())
    end
end


local function bush_onuse(inst)
--	print("---- Bush Hat Ex bush_onuse()")
    local owner = inst.components.inventoryitem.owner
    if owner then
        owner.sg:GoToState("hide")
    end

    -- cancel enemy's attention
    local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 60, {"_combat"})
    for i, v in ipairs(ents) do
    	if v.components.combat and v.components.combat.target == owner then
			v.components.combat:SetTarget(nil)
    	end
    end

    -- spred berry bushes
    local c = 0.6
    for i=1,6 do
        inst:DoTaskInTime(c, makeBerryBush)
        c = c + 0.1
    end

	inst.doHiding = true
end


local function bush_onstopuse(inst)
    if not inst.doHiding then return end
--	print("---- Bush Hat Ex bush_onstopuse()")

    -- remove sprayied berry bushes
	removeBerryBush(inst)

	inst.doHiding = false
end


local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end

    inst:ListenForEvent("newstate", stopusingbush, owner)
end


local function OnUnequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_hat")

    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end

    inst:RemoveEventCallback("newstate", stopusingbush, owner)

    -- remove sprayied berry bushes
	removeBerryBush(inst)
end


local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(symname)
    inst.AnimState:SetBuild(fname)
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("hat")
    inst:AddTag("hide")
	
    inst.foleysound = "dontstarve/movement/foley/bushhat"
	
    inst.entity:SetPristine() 

    if not TheWorld.ismastersim then   
      return inst  
    end   
    
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bushhatex"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bushhatex.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst.doHiding = false
    inst:AddComponent("useableitem")
    inst.components.useableitem:SetOnUseFn(bush_onuse)
    inst.components.useableitem:SetOnStopUseFn(bush_onstopuse)

    MakeHauntableLaunch(inst)
	
    return inst
end

return  Prefab("common/inventory/bushhatex", fn, assets, prefabs)