local assets =
{
    Asset("ANIM", "anim/maxwell_torch.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "maxwelllight_flame",
}

local function extinguish(inst)
    if inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
end

local function changelevels(inst, order)
    for i=1, #order do
        inst.components.burnable:SetFXLevel(order[i])
        Sleep(0.05)
    end
end

local function light(inst)    
    inst.task = inst:StartThread(function() changelevels(inst, inst.lightorder) end)    
end

local function onupdatefueledraining(inst)
    inst.components.fueled.rate = 1 + TUNING.PIGTORCH_RAIN_RATE * TheWorld.state.precipitationrate
end

local function onisraining(inst, israining)
    if inst.components.fueled ~= nil then
        if israining then
            inst.components.fueled:SetUpdateFn(onupdatefueledraining)
        else
            inst.components.fueled:SetUpdateFn()
            inst.components.fueled.rate = 1
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("maxwell_torch")
    inst.AnimState:SetBuild("maxwell_torch")
    inst.AnimState:PlayAnimation("idle", false)

    inst:AddTag("wildfireprotected")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

	inst:AddComponent("burnable")    
    inst.components.burnable.canlight = false
    inst.components.burnable:AddBurnFX("maxwelllight_flame", Vector3(0, 0, 0), "fire_marker")
	inst.components.burnable:SetOnIgniteFn(light)
	
	inst.lightorder = {5,6,7,8,7}
	inst.components.burnable:Ignite()
    inst:AddComponent("playerprox")
	inst.components.playerprox:SetDist(17, 27 )
    inst.components.playerprox:SetOnPlayerNear(function() if not inst.components.burnable:IsBurning() then inst.components.burnable:Ignite() end end)
    inst.components.playerprox:SetOnPlayerFar(extinguish)

    return inst
end

local function arealight()
    local inst = fn()
    inst.lightorder = {5,6,7,8,7}
	inst:AddComponent("burnable")
	inst.components.burnable:Ignite()
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(17, 27 )
    inst.components.playerprox:SetOnPlayerNear(function() if not inst.components.burnable:IsBurning() then inst.components.burnable:Ignite() end end)
    inst.components.playerprox:SetOnPlayerFar(extinguish)
    --inst:AddComponent("named")
    --inst.components.named:SetName(STRINGS.NAMES["MAXWELLLIGHT"])
    --inst.components.inspectable.nameoverride = "maxwelllight"

    return inst
end

return Prefab("maxwelllight", fn, assets, prefabs),
       MakePlacer("maxwelllight_placer", "maxwell_torch", "maxwell_torch", "idle")