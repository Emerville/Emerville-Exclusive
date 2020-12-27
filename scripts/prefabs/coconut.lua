require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/coconut.zip"),
    Asset("ATLAS", "images/inventoryimages/doncoconut.xml"),
    Asset("IMAGE", "images/inventoryimages/doncoconut.tex"),
    
    Asset("ATLAS", "images/inventoryimages/doncoconut_cooked.xml"),
    Asset("IMAGE", "images/inventoryimages/doncoconut_cooked.tex"),
}

local prefabs =
{
    "palmtree_short",
    "coconut_cooked",
}


local function stopgrowing(inst)
    if inst.growtask then
        inst.growtask:Cancel()
        inst.growtask = nil
    end
    inst.growtime = nil
end

local function restartgrowing(inst)
    if inst and not inst.growtask then
        local growtime = GetRandomWithVariance(TUNING.COCONUT_GROWTIME.base, TUNING.COCONUT_GROWTIME.random)
        inst.growtime = GetTime() + growtime
        inst.growtask = inst:DoTaskInTime(growtime, growtree)
    end
end


local function dig_up_stump(inst, chopper)
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SpawnLootPrefab("twigs")
    inst:Remove()
end


local function growtree(inst)
    inst.growtask = nil
    inst.growtime = nil
	inst.AnimState:PlayAnimation("planted")
    
    local sapling = SpawnPrefab("palmtree_short")
    if sapling then
    sapling.components.growable:StartGrowing()
    sapling.Transform:SetPosition(inst.Transform:GetWorldPosition())
    sapling.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
    inst:Remove()
    end
end

local function plant(inst, growtime)
    inst:RemoveComponent("inventoryitem")
    MakeHauntableIgnite(inst)
    RemovePhysicsColliders(inst)
    inst.AnimState:PlayAnimation("planted")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
    inst.growtime = GetTime() + growtime
    inst.growtask = inst:DoTaskInTime(growtime, growtree)
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up_stump)
    inst.components.workable:SetWorkLeft(1)
    
end


local function ondeploy(inst, pt, deployer)
    inst = inst.components.stackable:Get()
    inst.Physics:Teleport(pt:Get())
    local timeToGrow = GetRandomWithVariance(TUNING.PINECONE_GROWTIME.base, TUNING.PINECONE_GROWTIME.random)
    plant(inst, timeToGrow)

    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.LEIF_PINECONE_CHILL_RADIUS, { "leif" })

    local played_sound = false
    for i, v in ipairs(ents) do
        local chill_chance =
            v:GetDistanceSqToPoint(pt:Get()) < TUNING.LEIF_PINECONE_CHILL_CLOSE_RADIUS * TUNING.LEIF_PINECONE_CHILL_CLOSE_RADIUS and
            TUNING.LEIF_PINECONE_CHILL_CHANCE_CLOSE or
            TUNING.LEIF_PINECONE_CHILL_CHANCE_FAR

        if math.random() < chill_chance then
            if v.components.sleeper ~= nil then
                v.components.sleeper:GoToSleep(1000)
            end
        elseif not played_sound then
            v.SoundEmitter:PlaySound("dontstarve/creatures/leif/taunt_VO")
            played_sound = true
        end
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.growtime ~= nil then
        plant(inst, data.growtime)
    end
end


local function common(anim, iconnome, cookable)
    local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("coconut")
    inst.AnimState:SetBuild("coconut")
    inst.AnimState:PlayAnimation(anim)
    inst.AnimState:SetRayTestOnBB(true)

    if cookable then
        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = iconnome
    inst.components.inventoryitem.atlasname = "images/inventoryimages/"..iconnome..".xml"
	
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    if cookable then
        inst:AddComponent("cookable")
        inst.components.cookable.product = "coconut_cooked"
    end

    inst:AddComponent("tradable")
    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndPerish(inst)

	inst.OnLoad = OnLoad
	
    return inst
end

local function raw()
    local inst = common("idle", "coconut", true)

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("growable")
	
	inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
	
    return inst
end

local function cooked()
    local inst = common("cooked", "coconut_cooked")

    if not TheWorld.ismastersim then
        return inst
    end

	inst:RemoveComponent("growable")
	
	inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/2
	
	inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"
	
    return inst
end


STRINGS.COCONUT = "Coconut"
STRINGS.NAMES.COCONUT = "Coconut"
STRINGS.RECIPE_DESC.COCONUT = "That is a large nut"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.COCONUT = "That is a large nut"

STRINGS.COCONUT_COOKED = "Roasted Coconut"
STRINGS.NAMES.COCONUT_COOKED = "Roasted Coconut"
STRINGS.RECIPE_DESC.COCONUT_COOKED = "That is a large nut"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.COCONUT_COOKED = "That is a large nut"


return Prefab("coconut", raw, assets, prefabs),
    Prefab( "coconut_cooked", cooked, assets),
    MakePlacer("coconut_placer", "coconut", "coconut", "planted" ) 
