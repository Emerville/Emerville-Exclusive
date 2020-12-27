local assets =
{
    Asset("ANIM", "anim/ladygaga.zip"),
    Asset("ANIM", "anim/statue_small_harp_build.zip"),
    Asset("MINIMAP_IMAGE", "statue_small"),	
}

local prefabs =
{
    "marble",
    "rock_break_fx",
}

SetSharedLootTable( 'statue_harp',
{
    {'marble',  1.0},
    {'marble',  1.0},
    {'marble',  0.3},
})

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.66)

    inst.entity:AddTag("statue")

    inst.AnimState:SetBank("ladygaga")
    inst.AnimState:SetBuild("ladygaga")
    inst.AnimState:OverrideSymbol("swap_statue", "statue_small_harp_build", "swap_statue")
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetIcon("statue_small.png")

    inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end
		

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('statue_harp')

    inst:AddComponent("inspectable")	

    MakeHauntableWork(inst)

    return inst
end

return Prefab("ladygaga", fn, assets, prefabs)
