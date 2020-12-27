require "prefabutil"
require "recipe"
require "modutil"

local assets=
{
}

local attylaloot = { "smallmeat", "attylaskull" }

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.entity:SetPristine()
	
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot(attylaloot)
	
	inst:DoTaskInTime(0, function(inst) 
	
		inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
		inst:Remove()
		
	end)
	
    return inst
end

return Prefab( "common/objects/attylalootspawner", fn, assets, prefabs)