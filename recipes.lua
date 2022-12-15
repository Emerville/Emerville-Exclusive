local RECIPETABS = GLOBAL.RECIPETABS
local TECH = GLOBAL.TECH
local AllRecipes = GLOBAL.AllRecipes
local MakeRecipe = AddRecipe or function(name,ingr,tab,tech,placer,spacing,nounlock,num,_,atlas,image)
local rec = GLOBAL.Recipe(name,ingr,tab,tech,placer,spacing,nounlock,num,_)
rec.atlas = atlas
rec.image = image
end

local gearbox = Ingredient("gearbox", 1)
gearbox.atlas = "images/inventoryimages/gearbox.xml"

--------------------------------------------------------------------------
--[[ TOOLS ]]
--------------------------------------------------------------------------


--------------------------------------------------------------------------
--[[ LIGHT ]]
--------------------------------------------------------------------------
if GetModConfigData("lightnecklacerecipe") then
AddRecipe2("lightnecklace", 
{Ingredient("lightbulb", 6), Ingredient("rope", 1)}, 
TECH.NONE, 
{atlas = "images/inventoryimages/lightnecklace.xml"},
{"LIGHT"})
end

--------------------------------------------------------------------------
--[[ SURVIVAL ]]
--------------------------------------------------------------------------
local metal = Ingredient("metal", 1)
metal.atlas	= "images/inventoryimages/metal.xml"

if GetModConfigData("wool_sackrecipe") then
AddRecipe2("wool_sack",
{Ingredient("steelwool", 2), Ingredient("silk", 6), Ingredient("rope", 2)},
TECH.SCIENCE_TWO,
{atlas = "images/inventoryimages/wool_sack.xml"},
{"CONTAINERS"})
end

if GetModConfigData("mechanicalfanrecipe") then
AddRecipe2("mechanicalfan",
{metal, Ingredient("gears", 3), Ingredient("transistor", 5)},
TECH.SCIENCE_TWO,
{atlas = "images/inventoryimages/mechanicalfan_3.xml"},
{"TOOLS", "SUMMER"})
end

--------------------------------------------------------------------------
--[[ FARM ]]
--------------------------------------------------------------------------
if GetModConfigData("compost_boxrecipe") then
AddRecipe2("compost_box", 
{Ingredient("spoiled_food", 8), Ingredient("boards", 3)}, 
TECH.SCIENCE_TWO,
{placer = "compost_box_placer", min_spacing = 1.4, atlas = "images/inventoryimages/compost_box.xml"},
{"STRUCTURES", "CONTAINERS"})
end

if GetModConfigData("freezereyerecipe") then
AddRecipe2("freezereye",
{Ingredient("deerclops_eyeball", 1), Ingredient("ice", 20), Ingredient("gears", 4)},
TECH.SCIENCE_TWO,
{placer = "freezereye_placer", min_spacing = 1.4, atlas = "images/inventoryimages/freezereye.xml"},
{"COOKING", "STRUCTURES", "CONTAINERS"})
end


--------------------------------------------------------------------------
--[[ SCIENCE ]]
--------------------------------------------------------------------------
if GetModConfigData("trash_canrecipe") then
AddRecipe2("trash_can", 
{Ingredient("cutstone", 3), Ingredient("transistor", 1)}, 
TECH.SCIENCE_TWO,
{placer = "trash_can_placer", min_spacing = 1.4, atlas = "images/inventoryimages/trash_can.xml"},
{"STRUCTURES", "CONTAINERS"})
end


--------------------------------------------------------------------------
--[[ WAR ]]
--------------------------------------------------------------------------
if GetModConfigData("sword_rockrecipe") then
AddRecipe2("sword_rock",
{Ingredient("twigs", 3), Ingredient("rope", 1), Ingredient("rocks", 1)},  
TECH.SCIENCE_ONE,
{atlas = "images/inventoryimages/sword_rock.xml"},
{"WEAPONS"})
end

if GetModConfigData("mace_stingrecipe") then
AddRecipe2("mace_sting",
{Ingredient("log", 1), Ingredient("rope", 1), Ingredient("stinger", 5)},  
TECH.SCIENCE_TWO, 
{atlas = "images/inventoryimages/mace_sting.xml"},
{"WEAPONS"})
end

if GetModConfigData("fryingpanrecipe") then
AddRecipe2("fryingpan", 
{Ingredient("log", 1), Ingredient("charcoal", 3), Ingredient("steelwool", 2)},  
TECH.SCIENCE_ONE, 
{atlas = "images/inventoryimages/fryingpan.xml"},
{"WEAPONS"})
end

if GetModConfigData("armor_rockrecipe") then
AddRecipe2("armor_rock",
{Ingredient("rocks", 10), Ingredient("rope", 3)},   
TECH.SCIENCE_TWO,
{atlas = "images/inventoryimages/armor_rock.xml"},
{"ARMOUR"})
end

if GetModConfigData("hat_rockrecipe") then
AddRecipe2("hat_rock",
{Ingredient("pigskin", 1), Ingredient("rocks", 4), Ingredient("rope", 1)},  
TECH.SCIENCE_TWO,
{atlas = "images/inventoryimages/hat_rock.xml"},
{"ARMOUR"})
end

if GetModConfigData("hat_marblerecipe") then
AddRecipe2("hat_marble",
{Ingredient("pigskin", 1), Ingredient("marble", 8), Ingredient("rope", 1)},   
TECH.SCIENCE_TWO,
{atlas = "images/inventoryimages/hat_marble.xml"},
{"ARMOUR"})
end

--------------------------------------------------------------------------
--[[ STRUCTURE ]]
--------------------------------------------------------------------------
if GetModConfigData("crate_woodenrecipe") then
AddRecipe2("crate_wooden", 
{Ingredient("boards", 20), Ingredient("rope", 3)}, 	
TECH.SCIENCE_TWO,
{placer = "crate_wooden_placer", min_spacing = 1.8, atlas = "images/inventoryimages/crate_wooden.xml"},
{"STRUCTURES", "CONTAINERS"})
end

AddRecipe2("crate_wooden_gingerbread", 
{Ingredient("boards", 20), Ingredient("rope", 2)}, 	
TECH.LOST,
{placer = "crate_wooden_placer_gingerbread", min_spacing = 1.8, atlas = "images/inventoryimages/crate_wooden_gingerbread.xml"},
{"STRUCTURES", "CONTAINERS"})

AddRecipe2("crate_wooden_3d", 
{Ingredient("boards", 20), Ingredient("rope", 2)}, 	
TECH.LOST,
{placer = "crate_wooden_placer_3d", min_spacing = 1.8, atlas = "images/inventoryimages/crate_wooden.xml"},
{"STRUCTURES", "CONTAINERS"})

AddRecipe2("crate_wooden_scary", 
{Ingredient("boards", 20), Ingredient("rope", 2)}, 	
TECH.LOST,
{placer = "crate_wooden_placer_scary", min_spacing = 1.8, atlas = "images/inventoryimages/crate_wooden.xml"},
{"STRUCTURES", "CONTAINERS"})

AddRecipe2("crate_wooden_present", 
{Ingredient("boards", 20), Ingredient("rope", 2)}, 	
TECH.LOST,
{placer = "crate_wooden_placer_present", min_spacing = 1.8, atlas = "images/inventoryimages/crate_wooden.xml"},
{"STRUCTURES", "CONTAINERS"})

--if GetModConfigData("mech_hay_itemrecipe") then
--local mechhayrecipe = MakeRecipe("mech_hay_item",
--{Ingredient("wall_hay_item", 1), Ingredient("goldnugget", 2),Ingredient("gears", 1)},
--RECIPETABS.TOWN,
--TECH.SCIENCE_TWO,
--nil,
--nil,
--nil,
--nil,
--nil,
--"images/inventoryimages/mech_hay_item.xml",
--"mech_hay_item.tex")
--mechhayrecipe.sortkey = 14 + 0.05
--end

--if GetModConfigData("mech_wood_itemrecipe") then
--local mechwoodrecipe = MakeRecipe("mech_wood_item",
--{Ingredient("wall_wood_item", 1), Ingredient("goldnugget", 2),Ingredient("gears", 1)},
--RECIPETABS.TOWN,
--TECH.SCIENCE_TWO,
--nil,
--nil,
--nil,
--nil,
--nil,
--"images/inventoryimages/mech_wood_item.xml",
--"mech_wood_item.tex")
--mechwoodrecipe.sortkey = 15 + 0.05
--end

--if GetModConfigData("mech_stone_itemrecipe") then
--local mechstonerecipe = MakeRecipe("mech_stone_item",
--{Ingredient("wall_stone_item", 1), Ingredient("goldnugget", 2),Ingredient("gears", 1)},
--RECIPETABS.TOWN,
--TECH.SCIENCE_TWO,
--nil,
--nil,
--nil,
--nil,
--nil,
--"images/inventoryimages/mech_stone_item.xml",
--"mech_stone_item.tex")
--mechstonerecipe.sortkey = 16 + 0.05
--end

--if GetModConfigData("locked_mech__stone_itemrecipe") then	
--local lockedmechstonerecipe = MakeRecipe("locked_mech_stone_item",
--{Ingredient("wall_stone_item", 1), Ingredient("goldnugget", 2),Ingredient("gears", 1)},
--RECIPETABS.TOWN,
--TECH.SCIENCE_TWO,
--nil,
--nil,
--nil,
--nil,
--nil,
--"images/inventoryimages/locked_mech_stone_item.xml",
--"locked_mech_stone_item.tex")
--lockedmechstonerecipe.sortkey = 16 + 0.10
--end

--[[if GetModConfigData("mech_moonrock_itemrecipe") then
local mechmoonrockrecipe = MakeRecipe("mech_moonrock_item",
{Ingredient("wall_moonrock_item", 1), Ingredient("goldnugget", 2),Ingredient("gears", 1)},
RECIPETABS.TOWN,
TECH.SCIENCE_TWO,
nil,
nil,
nil,
nil,
nil,
"images/inventoryimages/mech_moonrock_item.xml",
"mech_moonrock_item.tex")
mechmoonrockrecipe.sortkey = 23 + 0.05
end]]

--if GetModConfigData("locked_mech_moonrock_itemrecipe") then
--local lockedmechmoonrockrecipe = MakeRecipe("locked_mech_moonrock_item",
--{Ingredient("wall_moonrock_item", 1), Ingredient("goldnugget", 2),Ingredient("gears", 1)},
--RECIPETABS.TOWN,
--TECH.SCIENCE_TWO,
--nil,
--nil,
--nil,
--nil,
--nil,
--"images/inventoryimages/locked_mech_moonrock_item.xml",
--"locked_mech_moonrock_item.tex")
--lockedmechmoonrockrecipe.sortkey = 17 + 0.10
--end 

if GetModConfigData("flowerbushrecipe") then
AddRecipe2("flowerbush",
{Ingredient("marble", 2), Ingredient("petals", 6)},
TECH.SCIENCE_TWO,
{placer = "flowerbush_placer", min_spacing = 1.4, atlas = "images/inventoryimages/flowerbush.xml"},
{"STRUCTURES", "DECOR"})
end

if GetModConfigData("xmastreerecipe") then
AddRecipe2("xmastree",
{Ingredient("log", 8), Ingredient("goldnugget", 12), Ingredient("petals", 8)},
TECH.SCIENCE_TWO,
{placer = "xmastree_placer", min_spacing = 1.4, atlas = "images/inventoryimages/xmastree.xml"},
{"STRUCTURES", "DECOR", "WINTER"})
end

if GetModConfigData("christmastreerecipe") then
AddRecipe2("christmas_tree",
{Ingredient("livinglog", 3), Ingredient("transistor", 3), Ingredient("petals", 8)}, 
TECH.SCIENCE_TWO, 
{placer = "christmas_tree_placer", min_spacing = 1.4, atlas = "images/inventoryimages/christmas_tree.xml"},
{"STRUCTURES", "DECOR", "WINTER"})
end

if GetModConfigData("snowmanrecipe") then
AddRecipe2("snowman",
{Ingredient("ice", 10), Ingredient("carrot", 1), Ingredient("twigs", 2)},
TECH.SCIENCE_TWO,
{placer = "snowman_placer", min_spacing = 1.4, atlas = "images/inventoryimages/snowman.xml"},
{"STRUCTURES", "DECOR", "WINTER"})
end

if GetModConfigData("featherbrellarecipe") then
AddRecipe2("featherbrella",
{Ingredient("goose_feather", 10), Ingredient("lightninggoathorn", 2), Ingredient("rope", 3)},
TECH.SCIENCE_TWO,
{placer = "featherbrella_placer", min_spacing = 1.4, atlas = "images/inventoryimages/featherbrella.xml"},
{"STRUCTURES", "DECOR", "SUMMER"})
end

if GetModConfigData("crate_metalrecipe") then
AddRecipe2("crate_metal",
{metal, Ingredient("dragon_scales", 1), Ingredient("cutstone", 8)}, 
TECH.SCIENCE_TWO, 
{placer = "crate_metal_placer", min_spacing = 1.6, atlas = "images/inventoryimages/crate_metal.xml"},
{"STRUCTURES", "CONTAINERS"})
end


--------------------------------------------------------------------------
--[[ REFINE ]]
--------------------------------------------------------------------------
if GetModConfigData("giftredrecipe") then
AddRecipe2("gift_red",
{Ingredient("goldnugget", 3), Ingredient("papyrus", 1)},
TECH.SCIENCE_TWO,
{atlas = "images/inventoryimages/gift_red.xml"},
{"REFINE"})
end


--------------------------------------------------------------------------
--[[ MAGIC ]]
--------------------------------------------------------------------------
if GetModConfigData("darkaxerecipe") then
AddRecipe2("dark_axe", 
{Ingredient("nightmarefuel", 2), Ingredient("flint", 1)}, 
TECH.MAGIC_TWO, 
{atlas = "images/inventoryimages/dark_axe.xml"},
{"MAGIC", "TOOLS"})
end

if GetModConfigData("darkpickaxerecipe") then
AddRecipe2("dark_pickaxe",
{Ingredient("nightmarefuel", 2), Ingredient("flint", 2)},  
TECH.MAGIC_TWO, 
{atlas = "images/inventoryimages/dark_pickaxe.xml"},
{"MAGIC", "TOOLS"})
end

if GetModConfigData("growstaffrecipe") then
AddRecipe2("growthstaff", 
{Ingredient("purplegem", 1), Ingredient("spear", 1), Ingredient("lureplantbulb", 1)},  
TECH.MAGIC_THREE, 
{atlas = "images/inventoryimages/growthstaff.xml"},
{"MAGIC", "TOOLS"})
end


--------------------------------------------------------------------------
--[[ DRESS ]]
--------------------------------------------------------------------------
local pelt_hound = Ingredient("pelt_hound", 2)
pelt_hound.atlas  = "images/inventoryimages/pelt_hound.xml"

if GetModConfigData("bandanarecipe") then
AddRecipe2("summerbandana", 
{Ingredient("papyrus", 2)}, 
TECH.SCIENCE_ONE,  
{atlas = "images/inventoryimages/summerbandana.xml"},
{"CLOTHING", "SUMMER"})
end

if GetModConfigData("gear_wingsrecipe") then
AddRecipe2("gear_wings",
{Ingredient("gears", 2),Ingredient("silk", 6)},
TECH.SCIENCE_TWO,
{atlas = "images/inventoryimages/gear_wings.xml"},
{"CLOTHING"})
end

if GetModConfigData("hat_houndrecipe") then
AddRecipe2("hat_hound",
{pelt_hound, Ingredient("houndstooth", 6), Ingredient("monstermeat", 1)},  
TECH.SCIENCE_TWO,
{atlas = "images/inventoryimages/hat_hound.xml"},
{"CLOTHING"})
end


--------------------------------------------------------------------------
--[[ ANCIENT ]]
--------------------------------------------------------------------------
if GetModConfigData("gearboxrecipe") then
AddRecipe2("gearbox",
{Ingredient("minotaurhorn", 1), Ingredient("gears", 12), Ingredient("yellowgem", 2)},  
TECH.ANCIENT_FOUR,
{nounlock = true, atlas = "images/inventoryimages/gearbox.xml"},
{"CRAFTING_STATION"})
end

if GetModConfigData("geargogglesrecipe") then
AddRecipe2("geargoggles",
{gearbox, Ingredient("thulecite", 5), Ingredient("yellowgem", 1)},   
TECH.ANCIENT_FOUR,
{nounlock = true, atlas = "images/inventoryimages/geargoggles.xml"},
{"CRAFTING_STATION"})
end

if GetModConfigData("gearlancerecipe") then
AddRecipe2("gearlance",
{gearbox, Ingredient("thulecite", 8), Ingredient("purplegem", 2)}, 
TECH.ANCIENT_FOUR,
{nounlock = true, atlas = "images/inventoryimages/gearlance.xml"},
{"CRAFTING_STATION"})
end

if GetModConfigData("gearstaffrecipe") then
AddRecipe2("gearstaff",
{gearbox, Ingredient("thulecite", 10), Ingredient("yellowgem", 1)}, 
TECH.ANCIENT_FOUR,
{nounlock = true, atlas = "images/inventoryimages/gearstaff.xml"},
{"CRAFTING_STATION"})
end

if GetModConfigData("stampederecipe") then
AddRecipe2("stampede", 
{Ingredient("minotaurhorn", 1), Ingredient("bearger_fur", 1), Ingredient("purplegem", 3)}, 
TECH.ANCIENT_FOUR,
{nounlock = true, atlas = "images/inventoryimages/stampede.xml"},
{"CRAFTING_STATION"})
end

if GetModConfigData("hornucopiarecipe") then
AddRecipe2("hornucopia",
{Ingredient("minotaurhorn", 1),Ingredient("horn", 1),Ingredient("bonestew", 3)},  
TECH.ANCIENT_FOUR,
{nounlock = true, atlas = "images/inventoryimages/hornucopia.xml"},
{"CRAFTING_STATION"})
end


--------------------------------------------------------------------------
--[[ SLOT MACHINE ]]
--------------------------------------------------------------------------
AddRecipe2("spartahelmut", 
{Ingredient("goldnugget", 4), Ingredient("cutstone", 1), Ingredient("feather_robin", 4) }, 
TECH.LOST, 
{atlas = "images/inventoryimages/spartahelmut.xml"},
{"ARMOUR"})

AddRecipe2("ewecushat", 
{Ingredient("steelwool", 2), Ingredient("feather_crow", 2)},  
TECH.LOST, 
{atlas = "images/inventoryimages/ewecushat.xml"},
{"ARMOUR"})

AddRecipe2("baronsuit", 
{Ingredient("houndstooth", 2), Ingredient("silk", 12), Ingredient("goldnugget", 6)},  
TECH.LOST, 
{atlas = "images/inventoryimages/baronsuit.xml"},
{"CLOTHING"})

AddRecipe2("hollowhat", 
{Ingredient("nightmarefuel", 1), Ingredient("boneshard", 1), Ingredient("houndstooth", 1)}, 
TECH.LOST, 
{atlas = "images/inventoryimages/hollowhat.xml"},
{"CLOTHING", "MAGIC"})

AddRecipe2("magicdolls",
{Ingredient("beardhair", 2), Ingredient("nightmarefuel", 2), Ingredient("silk", 2)},
TECH.LOST,
{atlas = "images/inventoryimages/magicdolls.xml"},
{"REFINE"})

AddRecipe2("beargerkit", 
{Ingredient("gunpowder", 5), Ingredient("red_cap", 10)}, 
TECH.LOST, 
{atlas = "images/inventoryimages/beargerkit.xml"},
{"REFINE"})


--------------------------------------------------------------------------
--[[ SLOT MACHINE STRUCTURES ]]
--------------------------------------------------------------------------
if GetModConfigData("fuelsupplierrecipe") then
AddRecipe2("fuelsupplier",
{Ingredient("dragon_scales", 1),Ingredient("redgem", 1)},
TECH.LOST,
{placer = "fuelsupplier_placer", min_spacing = 1, atlas = "images/inventoryimages/fuelsupplier.xml"},
{"STRUCTURE", "DECOR"})
end

if GetModConfigData("lamppostrecipe") then
AddRecipe2("lamp_post",
{Ingredient("lantern",1), Ingredient("cutstone", 2)},
TECH.LOST, 
{placer = "lamp_post_placer", min_spacing = 1, image = "lamp_post.tex", atlas = "images/inventoryimages/lamp_post.xml"},
{"LIGHT", "STRUCTURE", "DECOR"})
end

if GetModConfigData("lampshortrecipe") then
AddRecipe2("lamp_short",
{Ingredient("lantern",1), Ingredient("cutstone", 2)},
TECH.LOST, 
{placer = "lamp_short_placer", min_spacing = 1, image = "lamp_short.tex", atlas = "images/inventoryimages/lamp_short.xml"},
{"LIGHT", "STRUCTURE", "DECOR"})
end 

if GetModConfigData("postrecipe") then
AddRecipe2("post",
{Ingredient("cutstone",1)},
TECH.LOST, 
{placer = "post_placer_placer", min_spacing = 1, image = "bollard.tex", atlas = "images/inventoryimages/bollard.xml"},
{"DECOR"})
end		
	
if GetModConfigData("parkspikerecipe") then
AddRecipe2("parkspike",
{Ingredient("cutstone",2)},
TECH.LOST, 
{placer = "parkspike_placer", min_spacing = 1, image = "fence.tex", atlas = "images/inventoryimages/fence.xml"},
{"DECOR"})
end

if GetModConfigData("parkspikeshortrecipe") then
AddRecipe2("parkspike_short",
{Ingredient("cutstone",2)},
TECH.LOST, 
{placer = "parkspike_short_placer", min_spacing = 1, image = "fence.tex", atlas = "images/inventoryimages/fence.xml"},
{"DECOR"})
end
		
if GetModConfigData("ivythingrecipe") then
AddRecipe2("ivything",
{Ingredient("succulent_picked",1), Ingredient("cutstone",1)},
TECH.LOST, 
{placer = "ivything_placer", min_spacing = 2, image = "ivy.tex", atlas = "images/inventoryimages/ivy.xml"},
{"DECOR"})
end			

if GetModConfigData("urnrecipe") then
AddRecipe2("urn",
{Ingredient("cutstone",2)},
TECH.LOST, 
{placer = "urn_placer", min_spacing = 2, atlas = "images/inventoryimages/urn.xml"},
{"DECOR"})
end

if GetModConfigData("statue_charlierecipe") then
AddRecipe2("statue_charlie",
{Ingredient("cutstone",8), Ingredient("marble",10), Ingredient("petals",5)}, 
TECH.LOST, 
{placer = "statue_charlie_placer", min_spacing = 3, atlas = "images/inventoryimages/statue_charlie.xml"},
{"DECOR"}) 
end	

if GetModConfigData("miniyurtrecipe") then
AddRecipe2("mini_yurt",
{Ingredient("silk",12), Ingredient("log",8), Ingredient("rope",6)}, 
TECH.LOST, 
{placer = "mini_yurt_placer", min_spacing = 2, atlas = "images/inventoryimages/mini_yurt.xml"},
{"DECOR"}) 
end

if GetModConfigData("minitipirecipe") then
AddRecipe2("mini_tipi",
{Ingredient("silk",8), Ingredient("log",10), Ingredient("rope",4)}, 
TECH.LOST, 
{placer = "mini_tipi_placer", min_spacing = 2, atlas = "images/inventoryimages/mini_tipi.xml"},
{"DECOR"}) 
end	

		
		
			
		