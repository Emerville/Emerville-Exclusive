local assets =
{
    Asset("ANIM", "anim/des_fsp_grand_final_fix.zip"),

    Asset("ATLAS", "images/inventoryimages/des_statue_charlie.xml"),
    Asset("IMAGE", "images/inventoryimages/des_statue_charlie.tex"),

}

local PETALSPERDAY = 5
local MAXPETALS = 5

local function PlantFlower(inst)
    local minrad = 1.5
    local maxrad = 2.5

    --inst exists
    if not inst then return end
    local pt = inst:GetPosition()

    --not too many children
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, maxrad, {"flower"})
	if #ents >= MAXPETALS then return end

    -- Choose a flower to spawn
    local childtype
    local rand = math.random()
	if rand < 0.40 then
        childtype = "flower"
    elseif rand < 0.80 then
        childtype = "flower_evil"
    else
        childtype = "flower_rose"
    end

    --Find spot for new child and spawn
    local angle = math.random() * 2 * PI
    local radius = math.random() * (maxrad - minrad) + minrad
    local offset, check_angle, deflected = FindWalkableOffset(pt, angle, radius, 8, true, false)

    if(not check_angle) then return end
    pt.x = pt.x + radius * math.cos(check_angle)
    pt.z = pt.z - radius * math.sin(check_angle)

    SpawnPrefab(childtype).Transform:SetPosition(pt:Get())
end


local function Animation(inst)
    if inst.currentanim == "work" then
        if math.random() < 0.33 then
            inst.AnimState:PlayAnimation("fsp_cycle", true)
            inst.AnimState:SetTime((math.random() * 2) / 2)
        else
            inst.AnimState:PlayAnimation("fsp_idle", true)
        end
    else
        inst.AnimState:PlayAnimation("fsp_dry", true)
    end
end


local function Dry(inst)
    inst.currentanim = "fsp_dry"
    inst.state = "DRY"
    inst:AddTag("water_sourse_dry")
end

local function Fill(inst)
    inst.currentanim = "work"
    inst.state = "FULL"
    inst:RemoveTag("water_sourse_dry")
end

local function OnSave(inst, data)
    data.burnt = inst.state
    data.daysleft = inst.daysleft
end

local function OnLoad(inst, data)
    if data and data.state then
        inst.state = data.state
        inst.daysleft = data.daysleft or 2
        if inst.state == "FULL" then
            Fill(inst)
        else
            Dry(inst)
        end
    end
end

local function inspect_stat(inst)
    return (inst:HasTag("water_sourse_nolimit") and "FULL")
        or (inst:HasTag("water_sourse_dry") and "DRY")
        --#DISEASE or (inst:HasTag("diseased") and "DISEASED")
        or nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

   -- inst:AddTag("maxwell")
    --inst.entity:AddTag("statue")

    MakeObstaclePhysics(inst, 0.75)

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "des_statue_charlie.tex" )

    inst.AnimState:SetBank("des_fsp_grand_final_fix")
    inst.AnimState:SetBuild("des_fsp_grand_final_fix")
    inst.AnimState:PlayAnimation("fsp_cycle",true)

    inst:AddTag("antlion_sinkhole_blocker")

    inst.state = "FULL"
    inst:AddTag("water_sourse")
    inst:AddTag("water_sourse_nolimit")
    inst:AddTag("des_statue_charlie")
    inst:AddTag("structure")

    local scale = 1
    inst.Transform:SetScale(scale, scale, scale)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoPeriodicTask(18, function()
        Animation(inst)
    end)

    inst.daysleft = 5
    inst.currentanim = "work"
    ---------------Growing details
    local growth_stages = {
        {
            name = "Spawn Flower",
            time = function(inst) return TUNING.TOTAL_DAY_TIME/PETALSPERDAY end,
            fn = PlantFlower
        },
    }
    inst:AddComponent("growable")
    inst.components.growable.stages = growth_stages
    inst.components.growable:SetStage(1)
    inst.components.growable.loopstages = true
    inst.components.growable:StartGrowing()

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = inspect_stat


    local function OnStartDay(inst)
        inst.daysleft = inst.daysleft - 1
        if inst.daysleft < 1 and inst.state == "FULL" then
            Dry(inst)
            inst.daysleft = 2 + math.random(2,4)
        elseif inst.daysleft < 1 and inst.state == "DRY" then
            Fill(inst)
            inst.daysleft = 6 + math.random(1,3)
        end
    end

    inst:WatchWorldState("startday", OnStartDay)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("des_statue_charlie", fn, assets, prefabs)
