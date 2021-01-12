------------------------------------------------------------------------
--- Custom modded reskin by Platypus

-- Just add a list of supported reskins for a structure prefab to PREFAB_SKINS
-- and the reskin tool will change both bank and build of that structure.
-- Also takes care of adding necessary recipes

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

local SpawnPrefab = GLOBAL.SpawnPrefab

for prefab, skins in pairs(PREFAB_SKINS) do
    GLOBAL.PREFAB_SKINS[prefab] = {}
	GLOBAL.PREFAB_SKINS_IDS[prefab] = {}
	for k,v in pairs(skins) do
        GLOBAL.PREFAB_SKINS[prefab][k] = v
		GLOBAL.PREFAB_SKINS_IDS[prefab][v] = k
	end
end

for k,_ in pairs(PREFAB_SKINS) do
    AddPrefabPostInit(k, function(inst)
        inst:AddComponent("reskinnable")
    end)
end

local function ReskinToolPostInit(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return inst
    end

    local _spellfn = inst.components.spellcaster.spell
    local _cancastfn = inst.components.spellcaster.can_cast_fn
    
    local spellfn = function(inst, target, pos)
        if not target.components.reskinnable then
            return _spellfn(inst, target, pos)
        end

        target = target or inst.components.inventoryitem.owner

        local fx = SpawnPrefab("explode_reskin")
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
    
    local cancastfn = function(doer, target, pos)
        return PREFAB_SKINS[target.prefab] ~= nil or _cancastfn(doer, target, pos)
    end
    
    inst.components.spellcaster:SetSpellFn(spellfn)
    inst.components.spellcaster:SetCanCastFn(cancastfn)
end
AddPrefabPostInit("reskin_tool", ReskinToolPostInit)

local function GetName(var)
    return GLOBAL.STRINGS.SKIN_NAMES[var]
end

local function RecipePopupPostConstruct(widget)
    local _GetSkinsList = widget.GetSkinsList
    local _GetSkinOptions = widget.GetSkinOptions
    
    local GetSkinsList = function(self)
        if not self.recipe or not self.recipe.reskinnable then
            return _GetSkinsList(self)
        end
        
        self.skins_list = {}
        for _,item_type in pairs(PREFAB_SKINS[self.recipe.name]) do
            table.insert(self.skins_list, {
                type = type,
                item = item_type,
                timestamp = nil,
            })
        end

        return self.skins_list
    end
    
    local GetSkinOptions = function(self)
        if not self.recipe or not self.recipe.reskinnable then
            return _GetSkinOptions(self)
        end
        
        local skin_options =
        {
            {
                text = GLOBAL.STRINGS.UI.CRAFTING.DEFAULT,
                data = nil, 
                colour = GLOBAL.SKIN_RARITY_COLORS["Common"],
                new_indicator = false,
                image = {self.recipe.atlas or "images/inventoryimages.xml", self.recipe.image or self.recipe.name .. ".tex", "default.tex"},
            }
        }
		
        local recipe_timestamp = GLOBAL.Profile:GetRecipeTimestamp(self.recipe.name)
        
        if self.skins_list and GLOBAL.TheNet:IsOnlineMode() then 
            for which = 1, #self.skins_list do 
                local image_name = self.skins_list[which].item 

                local rarity = GLOBAL.GetRarityForItem("item", image_name)
                local colour = rarity and GLOBAL.SKIN_RARITY_COLORS[rarity] or GLOBAL.SKIN_RARITY_COLORS["Common"]
                local text_name = GetName(image_name) or GLOBAL.SKIN_STRINGS.SKIN_NAMES["missing"]
                local new_indicator = not self.skins_list[which].timestamp or (self.skins_list[which].timestamp > recipe_timestamp)

                if image_name ~= "" then
                    image_name = string.gsub(image_name, "_none", "")
                else
                    image_name = "default"
                end

                table.insert(skin_options,  
                {
                    text = text_name, 
                    data = nil,
                    colour = colour,
                    new_indicator = new_indicator,
                    image = {self.recipe.atlas or image_name .. ".xml" or "images/inventoryimages.xml", image_name..".tex" or "default.tex", "default.tex"},
                })
            end
	    else 
    		self.spinner_empty = true
	    end

	    return skin_options
    end
    
    widget.GetSkinsList = GetSkinsList
    widget.GetSkinOptions = GetSkinOptions
end

AddClassPostConstruct("widgets/recipepopup", RecipePopupPostConstruct)

local function BuilderPostInit(builder)
    local _MakeRecipeFromMenu = builder.MakeRecipeFromMenu
    local _DoBuild = builder.DoBuild
    local _MakeRecipeAtPoint = builder.MakeRecipeAtPoint
    
    local MakeRecipeFromMenu = function(self, recipe, skin)
        if not recipe.reskinnable then
            return _MakeRecipeFromMenu(self, recipe, skin)
		end
        
        if not recipe.placer then
            if self:KnowsRecipe(recipe.name) then
                if self:IsBuildBuffered(recipe.name) or self:CanBuild(recipe.name) then
                    self:MakeRecipe(recipe, nil, nil, skin)
                end
            elseif GLOBAL.CanPrototypeRecipe(recipe.level, self.accessible_tech_trees) and
                    self:CanLearn(recipe.name) and self:CanBuild(recipe.name) then
                self:MakeRecipe(recipe, nil, nil, skin, function()
                    self:ActivateCurrentResearchMachine()
                    self:UnlockRecipe(recipe.name)
                end)
            end
		end
    end
    
    local OnBuild = function(inst, data)
        if data.item.components.reskinnable then
            data.item.components.reskinnable:SetReskin(data.skin)
        end
    end
    
    local DoBuild = function(self, recname, pt, rotation, skin)
        local canbuild = false
        
        builder.inst:ListenForEvent("buildstructure", OnBuild)
        canbuild = _DoBuild(self, recname, pt, rotation, skin)
        builder.inst:RemoveEventCallback("buildstructure", OnBuild)
        
        return canbuild
    end
    
    local MakeRecipeAtPoint = function(self, recipe, pt, rot, skin)
        print("Received skin to build: ".. (skin or "nil"))
        _MakeRecipeAtPoint(self, recipe, pt, rot, skin)
    end
    
    builder.MakeRecipeFromMenu = MakeRecipeFromMenu
    builder.DoBuild = DoBuild
    builder.MakeRecipeAtPoint = MakeRecipeAtPoint
end

AddComponentPostInit("builder", BuilderPostInit)

local function PlayerControllerPostInit(playercontroller)
    local _StartBuildPlacementMode = playercontroller.StartBuildPlacementMode
    
    local StartBuildPlacementMode = function(self, recipe, skin)
		if not recipe or not recipe.reskinnable or not skin or not table.contains(PREFAB_SKINS[recipe.name], skin) then
            return _StartBuildPlacementMode(self, recipe, skin)
        end
        
        self.placer_cached = nil
        self.placer_recipe = recipe
        self.placer_recipe_skin = skin

        if self.placer ~= nil then
            self.placer:Remove()
        end
        
        self.placer = SpawnPrefab(recipe.placer, skin)
        
        local linked_entities = self.placer.components.placer.linked
        for _,ent in ipairs(linked_entities) do
            if ent.AnimState:GetBuild() == recipe.name then
                ent:AddComponent("reskinnable")
                ent.components.reskinnable:SetReskin(skin)
            end
        end
        
        self.placer.components.placer:SetBuilder(self.inst, recipe)
        self.placer.components.placer.testfn = function(pt, rot)
            local builder = self.inst.replica.builder
            return builder ~= nil and builder:CanBuildAtPoint(pt, recipe, rot)
        end
	end
    
    playercontroller.StartBuildPlacementMode = StartBuildPlacementMode
end

AddComponentPostInit("playercontroller", PlayerControllerPostInit)
