require "prefabutil"
require "modutil"

local assets=
{
}

local prefabs = 
{
	"featherbrella",
}

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
	
	inst:DoTaskInTime(0, function(inst) 

	local pt = Vector3(inst.Transform:GetWorldPosition())
	local range = 5
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, range)
	
    for k, v in pairs(ents) do
		if v ~= nil then
		
		-- Here player gets his waterproofness (or lack thereof) back
        if v.components.moisture and v:HasTag("featherbrelled") then
			v:RemoveTag("featherbrelled")
			v.components.moisture:SetInherentWaterproofness(0)
		elseif v.components.moisture and v:HasTag("featherbrelled02") then
			v:RemoveTag("featherbrelled02")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_SMALL*0.5)
		elseif v.components.moisture and v:HasTag("featherbrelled035") then
			v:RemoveTag("featherbrelled035")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_SMALL)
		elseif v.components.moisture and v:HasTag("featherbrelled05") then
			v:RemoveTag("featherbrelled05")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_SMALLMED)
		elseif v.components.moisture and v:HasTag("featherbrelled07") then
			v:RemoveTag("featherbrelled07")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_MED)
		elseif v.components.moisture and v:HasTag("featherbrelled09") then
			v:RemoveTag("featherbrelled09")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_LARGE)
		elseif v.components.moisture and v:HasTag("featherbrelled1") then
			v:RemoveTag("featherbrelled1")
			v.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_HUGE)
		end
	    end
    end
	
	inst:Remove()
	
	end)
	
    return inst
end

return Prefab("common/objects/featherbrellahammerchecker", fn, assets, prefabs)