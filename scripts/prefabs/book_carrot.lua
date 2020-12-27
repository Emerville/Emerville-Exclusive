local assets =
{
	Asset("ANIM", "anim/book_carrot.zip"),
	
	Asset("ATLAS", "images/inventoryimages/book_carrot.xml"),
	Asset("IMAGE", "images/inventoryimages/book_carrot.tex"),
}

local prefabs =
{
    "book_fx",
	"carrot_planted",
	"ground_chunks_breaking",
}   

local function onread(inst, reader)
	
            local pt = reader:GetPosition()
            local numcarrots = 10

            reader.components.sanity:DoDelta(-TUNING.SANITY_HUGE)

            reader:StartThread(function()
                for k = 1, numcarrots do
                
                    local theta = math.random() * 2 * PI
                    local radius = math.random(3, 8)

                    -- we have to special case this one because birds can't land on creep
                    local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
                        local pos = pt + offset
                        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 1)
                        return next(ents) == nil
                    end)

                    if result_offset ~= nil then
                        local pos = pt + result_offset
                        local carrot = SpawnPrefab("carrot_planted")

                        carrot.Transform:SetPosition(pos:Get())

                        ShakeAllCameras(CAMERASHAKE.FULL, .2, .02, .25, reader, 40)

                        --need a better effect
                        SpawnPrefab("ground_chunks_breaking").Transform:SetPosition(pos:Get())
                        --PlayFX((pt + result_offset), "splash", "splash_ocean", "idle")
                    end
			        Sleep(.33)
                end
             end)
    return true
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()	
    inst.entity:AddNetwork()	

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("book_maxwell")
    inst.AnimState:SetBuild("book_carrot")
    inst.AnimState:PlayAnimation("idle")
	
    inst.entity:SetPristine()	
	
    if not TheWorld.ismastersim then
        return inst
    end		
    
    inst:AddComponent("inspectable")
	
    inst:AddComponent("book")
    inst.components.book.onread = onread	
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "book_carrot"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/book_carrot.xml"
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(5)
	inst.components.finiteuses:SetUses(5)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    
    return inst
end

return Prefab("common/inventory/book_carrot", fn, assets) 