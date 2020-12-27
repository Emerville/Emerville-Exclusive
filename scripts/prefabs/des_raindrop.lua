local assets =
{
	Asset("ANIM", "anim/raindrop.zip"),
}

local function fn()
	local inst = CreateEntity()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

	inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBuild("raindrop")
    inst.AnimState:SetBank("raindrop")
	inst.AnimState:PlayAnimation("anim")
	
	inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("des_raindrop", fn, assets)