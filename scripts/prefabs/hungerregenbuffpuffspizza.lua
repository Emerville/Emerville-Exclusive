local function OnTick(inst, target)
    if target.components.hunger ~= nil and
--        not target.components.hunger:IsDead() and
        not target:HasTag("playerghost") then
        target.components.hunger:DoDelta(25, nil, "puffspizza") --(TUNING.JELLYBEAN_TICK_VALUE, nil, "puffspizza") --Hunger value
    else
        inst.components.debuff:Stop()
    end
end

local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) --in case of loading
    inst.task = inst:DoPeriodicTask(30, OnTick, nil, target) --(TUNING.JELLYBEAN_TICK_RATE, OnTick, nil, target) --How often
    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)
end

local function OnTimerDone(inst, data)
    if data.name == "regenover" then
        inst.components.debuff:Stop()
    end
end

local function OnExtended(inst, target)
    inst.components.timer:StopTimer("regenover")
    inst.components.timer:StartTimer("regenover", 7200) --Duration
    inst.task:Cancel()
    inst.task = inst:DoPeriodicTask(30, OnTick, nil, target) --(TUNING.JELLYBEAN_TICK_RATE, OnTick, nil, target)
end

local function fn()
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)

        return inst
    end

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    inst.entity:Hide()
    inst.persists = false

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(inst.Remove)
    inst.components.debuff:SetExtendedFn(OnExtended)
    inst.components.debuff.keepondespawn = true

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("regenover", 7200) --("regenover", TUNING.JELLYBEAN_DURATION) --Duration
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("hungerregenbuffpuffspizza", fn)