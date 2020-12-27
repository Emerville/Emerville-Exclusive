local assets =
{
	Asset("ANIM", "anim/weakpaw.zip"),
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
		inst.entity:AddSoundEmitter()
    
	

    if not TheWorld.ismastersim then
        return inst
    end

	inst.entity:SetPristine()
	
    anim:SetBank("weakpaw")
    anim:SetBuild("weakpaw")
    anim:PlayAnimation("crosshair")
    inst:AddTag("fx")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
    inst:DoTaskInTime(1.2, inst.Remove)
    return inst
end

return Prefab( "common/inventory/crosshair", fn, assets) 
