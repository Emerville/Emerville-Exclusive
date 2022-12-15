--这里的内容主要是兼容性修改，优化性修改，mod内容里的通用修改部分(比如都要修改某个组件时，我就会把改动内容单独移到这里来，不再单独修改)
--local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

--------------------------------------------------------------------------
--[[ 弹吉他相关 ]]
--------------------------------------------------------------------------
local EventHandler = GLOBAL.EventHandler
local State = GLOBAL.State
local ACTIONS = GLOBAL.ACTIONS
local Action = GLOBAL.Action
local ActionHandler = GLOBAL.ActionHandler
local STRINGS = GLOBAL.STRINGS
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
--if TUNING.LEGION_FLASHANDCRUSH or TUNING.LEGION_DESERTSECRET then --米格尔吉他和白木吉他需要

    --------------------------------------------------------------------------
    --[[ 弹吉他sg与动作的触发 ]]
    --------------------------------------------------------------------------

    local function ResumeHands(inst)
        local hands = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if hands ~= nil and not hands:HasTag("book") then
            inst.AnimState:Show("ARM_carry")
            inst.AnimState:Hide("ARM_normal")
        end
    end

    local playguitar_pre = State{
        name = "playguitar_pre",
        tags = { "doing", "playguitar" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("soothingplay_pre", false)
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")

            local guitar = inst.bufferedaction ~= nil and (inst.bufferedaction.invobject or inst.bufferedaction.target) or nil
            inst.components.inventory:ReturnActiveActionItem(guitar)

            if guitar ~= nil and guitar.PlayStart ~= nil then --动作的执行处
                guitar:AddTag("busyguitar")
                inst.sg.statemem.instrument = guitar
                guitar.PlayStart(guitar, inst)
                inst:PerformBufferedAction()
            else
                inst:PushEvent("actionfailed", { action = inst.bufferedaction, reason = nil })
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
                return
            end

            inst.sg.statemem.playdoing = false
        end,

        events =
        {
            EventHandler("equip", function(inst)    --防止装备时改变手的显示状态
                inst.AnimState:Hide("ARM_carry")
                inst.AnimState:Show("ARM_normal")
            end),

            EventHandler("unequip", function(inst)  --防止卸下时改变手的显示状态
                inst.AnimState:Hide("ARM_carry")
                inst.AnimState:Show("ARM_normal")
            end),

            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.playdoing = true
                    inst.sg:GoToState("playguitar_loop", inst.sg.statemem.instrument)
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.playdoing then
                ResumeHands(inst)

                if inst.sg.statemem.instrument ~= nil then
                    inst.sg.statemem.instrument:RemoveTag("busyguitar")
                end
            end
        end,
    }

    local playguitar_loop = State{
        name = "playguitar_loop",
        tags = { "doing", "playguitar" },

        onenter = function(inst, instrument)
            inst.components.locomotor:Stop()
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")

            if instrument ~= nil and instrument.PlayDoing ~= nil then
                instrument.PlayDoing(instrument, inst)
            end

            inst.sg.statemem.instrument = instrument
            inst.sg.statemem.playdoing = false
        end,

        events =
        {
            EventHandler("equip", function(inst)    --防止装备时改变手的显示状态
                inst.AnimState:Hide("ARM_carry")
                inst.AnimState:Show("ARM_normal")
            end),

            EventHandler("unequip", function(inst)  --防止卸下时改变手的显示状态
                inst.AnimState:Hide("ARM_carry")
                inst.AnimState:Show("ARM_normal")
            end),

            EventHandler("playenough", function(inst)
                inst.sg.statemem.playdoing = true
                inst.sg:GoToState("playguitar_pst")
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.playdoing then
                ResumeHands(inst)
            end

            if inst.sg.statemem.instrument ~= nil then
                if inst.sg.statemem.instrument.PlayEnd ~= nil then
                    inst.sg.statemem.instrument.PlayEnd(inst.sg.statemem.instrument, inst)
                end
                inst.sg.statemem.instrument:RemoveTag("busyguitar")
            end
        end,
    }

    local playguitar_pst = State{
        name = "playguitar_pst",
        tags = { "doing", "playguitar" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("soothingplay_pst", false)
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
        end,

        events =
        {
            EventHandler("equip", function(inst)    --防止装备时改变手的显示状态
                inst.AnimState:Hide("ARM_carry")
                inst.AnimState:Show("ARM_normal")
            end),

            EventHandler("unequip", function(inst)  --防止卸下时改变手的显示状态
                inst.AnimState:Hide("ARM_carry")
                inst.AnimState:Show("ARM_normal")
            end),

            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            ResumeHands(inst)
        end,
    }

    local playguitar_client = State{
        name = "playguitar_client",
        tags = { "doing", "playguitar" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("soothingplay_pre", false)
            -- inst.AnimState:Hide("ARM_carry")
            -- inst.AnimState:Show("ARM_normal")

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(2)
        end,

        onupdate = function(inst)
            if inst:HasTag("doing") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    }

    AddStategraphState("wilson", playguitar_pre)
    --AddStategraphState("wilson_client", playguitar_pre)    --客户端与服务端的sg有区别，这里只需要服务端有就行了
    AddStategraphState("wilson", playguitar_loop)
    --AddStategraphState("wilson_client", playguitar_loop)
    AddStategraphState("wilson", playguitar_pst)
    AddStategraphState("wilson_client", playguitar_client) --客户端只需要一个就够了

    local PLAYGUITAR = Action({ priority = 5, mount_valid = false })
    PLAYGUITAR.id = "PLAYGUITAR"    --这个操作的id
    PLAYGUITAR.str = STRINGS.ACTIONS_LEGION.PLAYGUITAR    --这个操作的名字，比如法杖是castspell，蜗牛壳甲是use
    PLAYGUITAR.fn = function(act) --这个操作执行时进行的功能函数
        return true --我把具体操作加进sg中了，不再在动作这里执行
    end
    AddAction(PLAYGUITAR) --向游戏注册一个动作

    --往具有某组件的物品添加动作的检测函数，如果满足条件，就向人物的动作可执行表中加入某个动作。right表示是否是右键动作
    AddComponentAction("INVENTORY", "instrument", function(inst, doer, actions, right)
        if inst and inst:HasTag("guitar") and doer ~= nil and doer:HasTag("player") then
            table.insert(actions, ACTIONS.PLAYGUITAR) --这里为动作的id
        end
    end)

    --将一个动作与state绑定
    AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.PLAYGUITAR, function(inst, action)
        if
            (inst.sg and inst.sg:HasStateTag("busy"))
            or (action.invobject ~= nil and action.invobject:HasTag("busyguitar"))
            or (inst.components.rider ~= nil and inst.components.rider:IsRiding())
        then
            return
        end

        return "playguitar_pre"
    end))
    AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.PLAYGUITAR, function(inst, action)
        if
            (inst.sg and inst.sg:HasStateTag("busy"))
            or (action.invobject ~= nil and action.invobject:HasTag("busyguitar"))
            or (inst.replica.rider ~= nil and inst.replica.rider:IsRiding())
        then
            return
        end

        return "playguitar_client"
    end))
--end
