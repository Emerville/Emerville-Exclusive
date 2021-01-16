require "prefabutil"
require "scheduler"
require "simutil"
require "behaviours/doaction"

local assets =
{
    Asset("ANIM", "anim/VacuumChest.zip"),
    Asset("ATLAS", "images/inventoryimages/vacuum_chest.xml"),
    Asset("IMAGE", "images/inventoryimages/vacuum_chest.tex"),
}

local prefabs =
{
    "collapse_small",
}

local function onopen(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("open")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("close")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end
end

--[[local function onhammered(inst, worker)
    if not inst:HasTag("fire") and inst.components.burnable then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    if inst.components.container then
        inst.components.container:DropEverything()
    end
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end]]

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("closed", false)
        if inst.components.container then
            inst.components.container:DropEverything()
            inst.components.container:Close()
        end
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/chest_craft")
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function cansuckit(inst, ent)
    return ent.components.inventoryitem and ent.components.inventoryitem.canbepickedup
        and (ent.prefab ~= "bernie_inactive" or ent.components.fueled:IsEmpty())
        and ent.components.inventoryitem.cangoincontainer
        and ent ~= inst and ent.entity:IsVisible()
end

local function suckit(inst, item)
    inst.AnimState:PlayAnimation("hit")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    inst.components.container:GiveItem(item)
end

local function vacuum(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local unfilledstacks = {}
    local ents = TheSim:FindEntities(x, y, z, inst.searchradius, nil, inst.ignoretags)

    for _,ent in ipairs(ents) do
        if cansuckit(inst, ent) then
            if not inst.components.container:IsFull() then
                return suckit(inst, ent)
            elseif ent.components.stackable then
                if unfilledstacks[ent.prefab] then
                    return suckit(inst, ent)
                end

                for _,v in pairs(inst.components.container.slots) do
                    if v.components.stackable and not v.components.stackable:IsFull() then
                        if v.prefab == ent.prefab then
                            return suckit(inst, ent)
                        else
                            unfilledstacks[v.prefab] = true
                        end
                    end
                end
            end
        end
    end
end

local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("vacuum_chest.tex")

    inst:AddTag("structure")
    inst.AnimState:SetBank("chest")
    inst.AnimState:SetBuild("VacuumChest")
    inst.AnimState:PlayAnimation("closed")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container:WidgetSetup("vacuum_chest")
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true

    inst:AddComponent("lootdropper")

--[[    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)]]

    inst:ListenForEvent("onbuilt", onbuilt)

    MakeSnowCovered(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst.searchradius = 6
    inst.ignoretags = { "casino", "irreplaceable", "resurrector", "companion" }

    inst:DoPeriodicTask(0.5, vacuum)

    return inst
end

return Prefab("common/vacuum_chest", fn, assets),
       MakePlacer("common/vacuum_chest_placer", "chest", "VacuumChest", "closed")
