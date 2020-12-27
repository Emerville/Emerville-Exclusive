local assets =
{
    Asset("ANIM", "anim/statueladygaga.zip"),
    Asset("ANIM", "anim/statue_small_harp_build.zip"),
    Asset("MINIMAP_IMAGE", "statue_small"),	
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.66)

    inst.entity:AddTag("statue")

    inst.AnimState:SetBank("statueladygaga")
    inst.AnimState:SetBuild("statueladygaga")
    inst.AnimState:OverrideSymbol("swap_statue", "statue_small_harp_build", "swap_statue")
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetIcon("statue_small.png")

    inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")	

    MakeHauntableWork(inst)

    return inst
end

return Prefab("statueladygaga", fn, assets)
