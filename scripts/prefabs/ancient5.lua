local assets=
{
	Asset("ANIM", "anim/ancient5.zip"),
--	Asset("ATLAS", "images/inventoryimages/ancient5_map.xml"),
--    Asset("IMAGE", "images/inventoryimages/ancient5_map.tex"),
	Asset("SOUND", "sound/common.fsb"),

}

local prefabs = 

{
	"trinket_6",
	"metal",
	"gears",
	"thulecite", 
	"greengem",
	"yellowgem",
	"orangegem",
}

--[[SetSharedLootTable( 'ancientloot5',
{
    {'trinket_6',  0.5},
	{'metal',  0.4},
	{'gears',  0.2},
	{'thulecite',  0.1},
	{'greengem',  0.05},
	{'yellowgem',  0.05},
	{'orangegem',  0.05},
 
})

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("idle")
	--inst.AnimState:PushAnimation("idle")
end]]


local function fn(Sim)
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()	
	
--	local minimap = inst.entity:AddMiniMapEntity()
--	minimap:SetIcon( "ancient5_map.tex" )
    
    inst:AddTag("structure")
    MakeObstaclePhysics(inst, .5)
    
    inst.AnimState:SetBank("ancient5")
    inst.AnimState:SetBuild("ancient5")
	inst.AnimState:PlayAnimation("idle")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end		
		
    inst:AddComponent("inspectable")	
	
	--[[inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable('ancientloot5')
	
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)]]	
	
    return inst
end

return Prefab( "common/ancient5", fn, assets, prefabs)