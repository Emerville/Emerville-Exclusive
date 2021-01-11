------------------------------------------------------------------------
--- Custom modded reskin by Platypus

-- Just add a list of supported reskins for a certain prefab to PREFAB_SKINS
-- and the reskin tool will change both bank and build of that prefab.

-- Ideally all reskins should be in the same bank, but they currently are not.
-- Doesn't support ownership yet, should it?
-- Also doesn't support reskins on items with klei skins, should it??

------------------------------------------------------------------------

local PREFAB_SKINS = {
    crate_wooden =
    {
        "crate_wooden_gingerbread",
        "crate_wooden_3d",
        "crate_wooden_scary",
        "crate_wooden_present",
    },
}

local RESKIN_FX_INFO =
{
    crate_wooden =      { offset = 0,   scale = 1.4 },
}

GLOBAL.MODDED_PREFAB_SKINS = MODDED_PREFAB_SKINS
GLOBAL.MODDED_RESKIN_FX_INFO = RESKIN_FX_INFO

function ReskinToolSpellFn(inst, target, pos)
    if not target.components.reskinnable then
        return inst._spellfn(inst, target, pos)
    end

    target = target or inst.components.inventoryitem.owner

    local fx = GLOBAL.SpawnPrefab("explode_reskin")
    local fx_info = RESKIN_FX_INFO[target.prefab] or {}
    local scale_override = fx_info.scale or 1
    local offset = fx_info.offset or 0
    local fx_pos_x, fx_pos_y, fx_pos_z = target.Transform:GetWorldPosition()

    fx.Transform:SetScale(scale_override, scale_override, scale_override)
    fx.Transform:SetPosition(fx_pos_x, fx_pos_y + offset, fx_pos_z)

    inst:DoTaskInTime(0, function()
        if not target:IsValid() or not inst:IsValid() or
                not target.components.reskinnable then
            return nil
        end

        local prefab_to_skin = target.prefab
        local curr_skin = target.components.reskinnable:GetReskin()

        if curr_skin == inst._cached_reskinname[prefab_to_skin] then
            local new_reskinname = nil
            local search_for_skin = inst._cached_reskinname[prefab_to_skin] ~= nil

            for _,item_type in pairs(PREFAB_SKINS[prefab_to_skin]) do
                if search_for_skin then
                    if inst._cached_reskinname[prefab_to_skin] == item_type then
                        search_for_skin = false
                    end
                else
                    new_reskinname = item_type
                    break
                end
            end
            inst._cached_reskinname[prefab_to_skin] = new_reskinname
        end

        target.components.reskinnable:SetReskin(inst._cached_reskinname[prefab_to_skin])
    end)
end

local function ReskinToolPostInit(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return inst
    end

    inst._spellfn = inst.components.spellcaster.spell
    _cancastfn = inst.components.spellcaster.can_cast_fn

    inst.components.spellcaster:SetSpellFn(ReskinToolSpellFn)
    inst.components.spellcaster:SetCanCastFn(function(doer, target, pos)
        return PREFAB_SKINS[target.prefab] ~= nil or _cancastfn(doer, target, pos)
    end)
end

AddPrefabPostInit("reskin_tool", ReskinToolPostInit)

for k,_ in pairs(PREFAB_SKINS) do
    AddPrefabPostInit(k, function(inst)
        inst:AddComponent("reskinnable")
    end)
end
