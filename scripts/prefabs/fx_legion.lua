--------------------------------------------------------------------------
--[[ 无需网络组建功能的特效创建通用函数 ]]
--------------------------------------------------------------------------

local prefs = {}

local function MakeFx(data)
	table.insert(prefs, Prefab(
		data.name,
		function()
			local inst = CreateEntity()

			inst.entity:AddTransform()
			inst.entity:AddNetwork()

			--Dedicated server does not need to spawn the local fx
			if not TheNet:IsDedicated() then
				--Delay one frame so that we are positioned properly before starting the effect
				--or in case we are about to be removed
				inst:DoTaskInTime(0, function(proxy)
					local inst2 = CreateEntity()

					--[[Non-networked entity]]

					inst2.entity:AddTransform()
					inst2.entity:AddAnimState()
					inst2.entity:SetCanSleep(false)
					inst2.persists = false

                    inst2:AddTag("FX")

					local parent = proxy.entity:GetParent()
					if parent ~= nil then
						inst2.entity:SetParent(parent.entity)
					end
					inst2.Transform:SetFromProxy(proxy.GUID)

					if data.fn_anim ~= nil then
						data.fn_anim(inst2)
					end

                    if data.fn_remove ~= nil then
						data.fn_remove(inst2)
                    else
                        inst2:ListenForEvent("animover", inst2.Remove)
					end
				end)
			end

            inst:AddTag("FX")

            if data.fn_common ~= nil then
				data.fn_common(inst)
			end

			inst.entity:SetPristine()
			if not TheWorld.ismastersim then
				return inst
			end

			inst.persists = false
			inst:DoTaskInTime(1, inst.Remove)

			return inst
		end,
		data.assets,
		data.prefabs
	))
end

    MakeFx({ --米格尔吉他：飘散的万寿菊花瓣
        name = "guitar_miguel_float_fx",
        assets = {
            Asset("ANIM", "anim/pine_needles.zip"), --官方砍树掉落松针特效
            Asset("ANIM", "anim/guitar_miguel_fx.zip"),
        },
        prefabs = nil,
        fn_common = nil,
        fn_anim = function(inst)
            inst.AnimState:SetBank("pine_needles")
            inst.AnimState:SetBuild("pine_needles")
            inst.AnimState:PlayAnimation(math.random() < 0.5 and "fall" or "chop")
            inst.AnimState:SetSortOrder(1)
            inst.Transform:SetScale(0.6, 0.6, 0.6)
            inst.AnimState:OverrideSymbol("needle", "guitar_miguel_fx", "needle")
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        end,
        fn_remove = nil,
    })

---------------
---------------

return unpack(prefs)
