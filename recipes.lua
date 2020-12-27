local RECIPETABS = GLOBAL.RECIPETABS
local TECH = GLOBAL.TECH
local AllRecipes = GLOBAL.AllRecipes
local MakeRecipe = AddRecipe or function(name,ingr,tab,tech,placer,spacing,nounlock,num,_,atlas,image)
local rec = GLOBAL.Recipe(name,ingr,tab,tech,placer,spacing,nounlock,num,_)
rec.atlas = atlas
rec.image = image
end

local box_gear = Ingredient("box_gear", 1)
box_gear.atlas = "images/inventoryimages/box_gear.xml"

--------------------------------------------------------------------------
--[[ TOOLS ]]
--------------------------------------------------------------------------


--------------------------------------------------------------------------
--[[ LIGHT ]]
--------------------------------------------------------------------------
if GetModConfigData("lightnecklacerecipe") then
local lightnecklace = MakeRecipe("lightnecklace", 
{Ingredient("lightbulb", 6), Ingredient("rope", 1)}, 
RECIPETABS.LIGHT, 
TECH.NONE, 
nil, 
nil, 
nil, 
nil, 
nil, 
"images/inventoryimages/lightnecklace.xml",
"lightnecklace.tex")
lightnecklace.sortkey = AllRecipes["coldfirepit"]["sortkey"] + 0.1 
end

--------------------------------------------------------------------------
--[[ SURVIVAL ]]
--------------------------------------------------------------------------
local metal = Ingredient("metal", 1)
metal.atlas	= "images/inventoryimages/metal.xml"

if GetModConfigData("wool_sackrecipe") then
local wool_sack = MakeRecipe("wool_sack",
{Ingredient("steelwool", 2), Ingredient("silk", 6), Ingredient("rope", 2)},
RECIPETABS.SURVIVAL,
TECH.SCIENCE_TWO,
nil,
nil,
nil,
nil,
nil,
"images/inventoryimages/wool_sack.xml",
"wool_sack.tex")
wool_sack.sortkey = AllRecipes["piggyback"]["sortkey"] + 0.1
end

if GetModConfigData("mechanicalfanrecipe") then
MakeRecipe("mechanicalfan",
{metal, Ingredient("gears", 3), Ingredient("transistor", 5)},
RECIPETABS.SURVIVAL,
TECH.SCIENCE_TWO,
nil,
nil,
nil,
nil,
nil,
"images/inventoryimages/mechanicalfan_3.xml",
"mechanicalfan_3.tex")
end


--------------------------------------------------------------------------
--[[ FARM ]]
--------------------------------------------------------------------------
if GetModConfigData("compost_boxrecipe") then
local compost_box = MakeRecipe("compost_box", 
{Ingredient("spoiled_food", 8), Ingredient("boards", 3)}, 
RECIPETABS.FARM,
TECH.SCIENCE_TWO,
"compost_box_placer",
1.4,
nil,
nil,
nil,
"images/inventoryimages/compost_box.xml",
"compost_box.tex")
compost_box.sortkey = AllRecipes["fast_farmplot"]["sortkey"] + 0.1
end

if GetModConfigData("freezereyerecipe") then
local freezer = MakeRecipe("freezereye",
{Ingredient("deerclops_eyeball", 1), Ingredient("ice", 20), Ingredient("gears", 4)},
RECIPETABS.FARM,
TECH.SCIENCE_TWO,
"freezereye_placer",
1.4,
nil,
nil,
nil,
"images/inventoryimages/freezereye.xml",
"freezereye.tex")
freezer.sortkey = AllRecipes["icebox"]["sortkey"] + 0.2
end


--------------------------------------------------------------------------
--[[ SCIENCE ]]
--------------------------------------------------------------------------
if GetModConfigData("trash_canrecipe") then
local trash_can = MakeRecipe("trash_can", 
{Ingredient("cutstone", 3), Ingredient("transistor", 1)}, 
RECIPETABS.SCIENCE,
TECH.SCIENCE_TWO,
"trash_can_placer",
1.4,
nil,
nil,
nil,
"images/inventoryimages/trash_can.xml",
"trash_can.tex")
trash_can.sortkey = AllRecipes["researchlab2"]["sortkey"] + 0.1
end


--------------------------------------------------------------------------
--[[ WAR ]]
--------------------------------------------------------------------------
if GetModConfigData("sword_rockrecipe") then
local sword_rock = MakeRecipe("sword_rock",
{Ingredient("twigs", 3), Ingredient("rope", 1), Ingredient("rocks", 1)},  
RECIPETABS.WAR,
TECH.SCIENCE_TWO,
nil,
nil,
nil,
nil,
nil,
"images/inventoryimages/sword_rock.xml",
"sword_rock.tex")
sword_rock.sortkey = AllRecipes["spear"]["sortkey"] + 0.1
end

if GetModConfigData("mace_stingrecipe") then
local mace_sting = MakeRecipe("mace_sting",
{Ingredient("log", 1), Ingredient("rope", 1), Ingredient("stinger", 5)},  
RECIPETABS.WAR,
TECH.SCIENCE_TWO, 
nil, 
nil, 
nil, 
nil, 
nil, 
"images/inventoryimages/mace_sting.xml",
"mace_sting.tex") 
mace_sting.sortkey = AllRecipes["spear"]["sortkey"] + 0.2
end

if GetModConfigData("fryingpanrecipe") then
local fryingpan = MakeRecipe("fryingpan", 
{Ingredient("log", 1), Ingredient("charcoal", 3), Ingredient("steelwool", 2)},  
RECIPETABS.WAR, 
TECH.SCIENCE_ONE, 
nil, 
nil, 
nil, 
nil, 
nil, 
"images/inventoryimages/fryingpan.xml",
"fryingpan.tex")
fryingpan.sortkey = AllRecipes["hambat"]["sortkey"] + 0.1
end

if GetModConfigData("armor_rockrecipe") then
local armor_rock = MakeRecipe("armor_rock",
{Ingredient("rocks", 10), Ingredient("rope", 3)},  
RECIPETABS.WAR, 
TECH.SCIENCE_TWO,
nil,
nil,
nil,
nil,
nil,
"images/inventoryimages/armor_rock.xml",
"armor_rock.tex")
armor_rock.sortkey = AllRecipes["armorwood"]["sortkey"] + 0.1
end

if GetModConfigData("hat_rockrecipe") then
local hat_rock = MakeRecipe("hat_rock",
{Ingredient("pigskin", 1), Ingredient("rocks", 4), Ingredient("rope", 1)},  
RECIPETABS.WAR,
TECH.SCIENCE_TWO,
nil,
nil,
nil,
nil,
nil,
"images/inventoryimages/hat_rock.xml",
"hat_rock.tex")
hat_rock.sortkey = AllRecipes["footballhat"]["sortkey"] + 0.1
end

if GetModConfigData("hat_marblerecipe") then
local hat_marble = MakeRecipe("hat_marble",
{Ingredient("pigskin", 1), Ingredient("marble", 8), Ingredient("rope", 1)},   
RECIPETABS.WAR,
TECH.SCIENCE_TWO,
nil,
nil,
nil,
nil,
nil,
"images/inventoryimages/hat_marble.xml",
"hat_marble.tex")
hat_marble.sortkey = AllRecipes["footballhat"]["sortkey"] + 0.2
end

--------------------------------------------------------------------------
--[[ STRUCTURE ]]
--------------------------------------------------------------------------
if GetModConfigData("crate_woodenrecipe") then
local crate_wooden = MakeRecipe("crate_wooden", 
{Ingredient("boards", 20), Ingredient("rope", 3)}, 	
RECIPETABS.TOWN,
TECH.SCIENCE_TWO,
"crate_wooden_placer",
1.8,
nil,
nil,
nil,
"images/inventoryimages/crate_wooden.xml",
"crate_wooden.tex")
crate_wooden.sortkey = AllRecipes["treasurechest"]["sortkey"] + 0.1
crate_wooden.skinnable = true
end

AddRecipe("crate_wooden_gingerbread", 
{Ingredient("boards", 20), Ingredient("rope", 2)}, 	
nil,
TECH.LOST,
"crate_wooden_placer",
1.8,
nil,
nil,
nil,
"images/inventoryimages/crate_wooden_gingerbread.xml",
"crate_wooden_gingerbread.tex")

AddRecipe("crate_wooden_3d", 
{Ingredient("boards", 20), Ingredient("rope", 2)}, 	
nil,
TECH.LOST,
"crate_wooden_placer",
1.8,
nil,
nil,
nil,
"images/inventoryimages/crate_wooden.xml",
"crate_wooden.tex")

AddRecipe("crate_wooden_scary", 
{Ingredient("boards", 20), Ingredient("rope", 2)}, 	
nil,
TECH.LOST,
"crate_wooden_placer",
1.8,
nil,
nil,
nil,
"images/inventoryimages/crate_wooden.xml",
"crate_wooden.tex")

AddRecipe("crate_wooden_present", 
{Ingredient("boards", 20), Ingredient("rope", 2)}, 	
nil,
TECH.LOST,
"crate_wooden_placer",
1.8,
nil,
nil,
nil,
"images/inventoryimages/crate_wooden.xml",
"crate_wooden.tex")

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
local flowerrecipe = MakeRecipe("flowerbush",
{Ingredient("marble", 2), Ingredient("petals", 6)},
RECIPETABS.TOWN,
TECH.SCIENCE_TWO,
"flowerbush_placer",
1.4,
nil,
nil,
nil,
"images/inventoryimages/flowerbush.xml",
"flowerbush.tex")
flowerrecipe.sortkey = 39 + 0.05
end

if GetModConfigData("xmastreerecipe") then
local xmasrecipe = MakeRecipe("xmastree",
{Ingredient("log", 8), Ingredient("goldnugget", 12), Ingredient("petals", 8)},
RECIPETABS.TOWN,
TECH.SCIENCE_TWO,
"xmastree_placer",
1.4,
nil,
nil,
nil,
"images/inventoryimages/xmastree.xml",
"xmastree.tex")
xmasrecipe.sortkey = 39 + 0.10
end

if GetModConfigData("christmastreerecipe") then
local christmasrecipe = MakeRecipe("christmas_tree",
{Ingredient("log", 8), Ingredient("transistor", 3), Ingredient("petals", 8)}, 
RECIPETABS.TOWN,
TECH.SCIENCE_TWO, 
"christmas_tree_placer",
1.4,
nil,
nil,
nil,
"images/inventoryimages/christmas_tree.xml",
"christmas_tree.tex")
christmasrecipe.sortkey = 39 + 0.15
end

if GetModConfigData("snowmanrecipe") then
local snowrecipe = MakeRecipe("snowman",
{Ingredient("ice", 10), Ingredient("carrot", 1), Ingredient("twigs", 2)},
RECIPETABS.TOWN,
TECH.SCIENCE_TWO,
"snowman_placer",
1.4,
nil,
nil,
nil,
"images/inventoryimages/snowman.xml",
"snowman.tex")
snowrecipe.sortkey = 39 + 0.15
end

if GetModConfigData("featherbrellarecipe") then
local featherrecipe = MakeRecipe("featherbrella",
{Ingredient("goose_feather", 10), Ingredient("lightninggoathorn", 2), Ingredient("rope", 3)},
RECIPETABS.TOWN,
TECH.SCIENCE_TWO,
"featherbrella_placer",
1.4,
nil,
nil,
nil,
"images/inventoryimages/featherbrella.xml",
"featherbrella.tex")
featherrecipe.sortkey = AllRecipes["ruinsrelic_table"]["sortkey"] + 0.1  
end

if GetModConfigData("crate_metalrecipe") then
MakeRecipe("crate_metal",
{metal, Ingredient("dragon_scales", 1), Ingredient("cutstone", 8)}, 
RECIPETABS.TOWN,
TECH.SCIENCE_TWO, 
"crate_metal_placer",
1.6,
nil,
nil,
nil,
"images/inventoryimages/crate_metal.xml",
"crate_metal.tex")
end


--------------------------------------------------------------------------
--[[ REFINE ]]
--------------------------------------------------------------------------
if GetModConfigData("giftredrecipe") then
local redrecipe = MakeRecipe("gift_red",
{Ingredient("goldnugget", 3), Ingredient("papyrus", 1)},
RECIPETABS.REFINE,
TECH.SCIENCE_TWO,
nil,
nil,
nil,
nil,
nil,
"images/inventoryimages/tp_gift_red.xml",
"tp_gift_red.tex")
redrecipe.sortkey = 130 + 0.05
end


--------------------------------------------------------------------------
--[[ MAGIC ]]
--------------------------------------------------------------------------
if GetModConfigData("darkaxerecipe") then
local dark_axe = MakeRecipe("dark_axe", 
{Ingredient("nightmarefuel", 2), Ingredient("flint", 1)}, 
RECIPETABS.MAGIC, 
TECH.MAGIC_TWO, 
nil, 
nil, 
nil, 
nil, 
nil, 
"images/inventoryimages/dark_axe.xml",
"dark_axe.tex")
dark_axe.sortkey = AllRecipes["armor_sanity"]["sortkey"] + 0.1
end

if GetModConfigData("darkpickaxerecipe") then
local dark_pickaxe = MakeRecipe("dark_pickaxe",
{Ingredient("nightmarefuel", 2), Ingredient("flint", 2)}, 
RECIPETABS.MAGIC, 
TECH.MAGIC_TWO, 
nil, 
nil, 
nil, 
nil, 
nil, 
"images/inventoryimages/dark_pickaxe.xml",
"dark_pickaxe.tex") 
dark_pickaxe.sortkey = AllRecipes["armor_sanity"]["sortkey"] + 0.2
end

if GetModConfigData("growstaffrecipe") then
local growthstaff = MakeRecipe("growthstaff", 
{Ingredient("purplegem", 1), Ingredient("spear", 1), Ingredient("lureplantbulb", 1)}, 
RECIPETABS.MAGIC, 
TECH.MAGIC_THREE, 
nil, 
nil, 
nil, 
nil, 
nil, 
"images/inventoryimages/growthstaff.xml",
"growthstaff.tex")
growthstaff.sortkey = AllRecipes["telestaff"]["sortkey"] + 0.1
end



--------------------------------------------------------------------------
--[[ DRESS ]]
--------------------------------------------------------------------------

local pelt_hound = Ingredient("pelt_hound", 2)
pelt_hound.atlas  = "images/inventoryimages/pelt_hound.xml"

if GetModConfigData("bandanarecipe") then
local bandrecipe = MakeRecipe("summerbandana", 
{Ingredient("papyrus", 2)}, 
RECIPETABS.DRESS, 
TECH.SCIENCE_ONE, 
nil, 
nil, 
nil, 
nil, 
nil, 
"images/inventoryimages/summerbandana.xml",
"summerbandana.tex")
bandrecipe.sortkey = AllRecipes["deserthat"]["sortkey"] + 0.1
end

if GetModConfigData("gear_wingsrecipe") then
local wingsrecipe = MakeRecipe("gear_wings",
{Ingredient("gears", 2),Ingredient("silk", 6)},
RECIPETABS.DRESS,
TECH.SCIENCE_TWO,
nil,
nil,
nil,
nil,
nil,
"images/inventoryimages/gear_wings.xml",
"gear_wings.tex")
wingsrecipe.sortkey = AllRecipes["cane"]["sortkey"] + 0.1
end

if GetModConfigData("hat_houndrecipe") then
local hathoundrecipe = MakeRecipe("hat_hound",
{pelt_hound, Ingredient("houndstooth", 6), Ingredient("monstermeat", 1)},  
RECIPETABS.DRESS,
TECH.SCIENCE_TWO,
nil,
nil,
nil,
nil,
nil,
"images/inventoryimages/hat_hound.xml",
"hat_hound.tex")
hathoundrecipe.sortkey = AllRecipes["cane"]["sortkey"] + 0.2
end


--------------------------------------------------------------------------
--[[ ANCIENT ]]
--------------------------------------------------------------------------
if GetModConfigData("box_gearrecipe") then
MakeRecipe("box_gear",
{Ingredient("minotaurhorn", 1), Ingredient("gears", 12), Ingredient("yellowgem", 2)},  
RECIPETABS.ANCIENT,
TECH.ANCIENT_FOUR,
nil,
nil,
true,
nil,
nil,
"images/inventoryimages/box_gear.xml",
"box_gear.tex")
end

if GetModConfigData("gears_hat_gogglesrecipe") then
MakeRecipe("gears_hat_goggles",
{box_gear, Ingredient("thulecite", 5), Ingredient("yellowgem", 1)},  
RECIPETABS.ANCIENT, 
TECH.ANCIENT_FOUR,
nil,
nil,
true,
nil,
nil,
"images/inventoryimages/gears_hat_goggles.xml",
"gears_hat_goggles.tex")
end

if GetModConfigData("gears_staffrecipe") then
MakeRecipe("gears_staff",
{box_gear, Ingredient("thulecite", 10), Ingredient("yellowgem", 1)}, 
RECIPETABS.ANCIENT,
TECH.ANCIENT_FOUR,
nil,
nil,
true,
nil,
nil,
"images/inventoryimages/gears_staff.xml",
"gears_staff.tex")
end

if GetModConfigData("gears_macerecipe") then
MakeRecipe("gears_mace",
{box_gear, Ingredient("thulecite", 8), Ingredient("purplegem", 2)}, 
RECIPETABS.ANCIENT,
TECH.ANCIENT_FOUR,
nil,
nil,
true,
nil,
nil,
"images/inventoryimages/gears_mace.xml",
"gears_mace.tex")
end

if GetModConfigData("stampederecipe") then
MakeRecipe("stampede", 
{Ingredient("minotaurhorn", 1), Ingredient("bearger_fur", 1), Ingredient("purplegem", 3)}, 
RECIPETABS.ANCIENT,
TECH.ANCIENT_FOUR,
nil,
nil,
true,
nil,
nil,
"images/inventoryimages/stampede.xml",
"stampede.tex")
end

if GetModConfigData("hornucopiarecipe") then
MakeRecipe("hornucopia",
{Ingredient("minotaurhorn", 1),Ingredient("horn", 1),Ingredient("bonestew", 3)},  
RECIPETABS.ANCIENT,
TECH.ANCIENT_FOUR,
nil,
nil,
true,
nil,
nil,
"images/inventoryimages/hornucopia.xml",
"hornucopia.tex")
end


--------------------------------------------------------------------------
--[[ SLOT MACHINE ]]
--------------------------------------------------------------------------
AddRecipe("spartahelmut", 
{Ingredient("goldnugget", 4), Ingredient("cutstone", 1), Ingredient("feather_robin", 4) }, 
nil, 
TECH.LOST, 
nil, 
nil, 
nil, 
nil, 
nil, 
"images/inventoryimages/spartahelmut.xml",
"spartahelmut.tex") 

AddRecipe("baronsuit", 
{Ingredient("houndstooth", 2), Ingredient("silk", 12), Ingredient("goldnugget", 6)}, 
nil, 
TECH.LOST, 
nil, 
nil, 
nil, 
nil, 
nil, 
"images/inventoryimages/baronsuit.xml",
"baronsuit.tex") 

AddRecipe("hollowhat", 
{Ingredient("nightmarefuel", 1), Ingredient("boneshard", 1), Ingredient("houndstooth", 1)}, 
nil, 
TECH.LOST, 
nil, 
nil, 
nil, 
nil, 
nil, 
"images/inventoryimages/hollowhat.xml",
"hollowhat.tex") 

AddRecipe("magicdolls",
{Ingredient("beardhair", 2), Ingredient("nightmarefuel", 2), Ingredient("silk", 2)},
nil,
TECH.LOST,
nil,
nil,
nil,
nil,
nil,
"images/inventoryimages/magicdolls.xml",
"magicdolls.tex")

AddRecipe("ewecushat", 
{Ingredient("steelwool", 2), Ingredient("feather_crow", 2)}, 
nil, 
TECH.LOST, 
nil, 
nil, 
nil, 
nil, 
nil, 
"images/inventoryimages/ewecushat.xml",
"ewecushat.tex")


--------------------------------------------------------------------------
--[[ SLOT MACHINE STRUCTURES ]]
--------------------------------------------------------------------------
if GetModConfigData("lamppostrecipe") then
MakeRecipe("kynoox_lamp_post",
{Ingredient("lantern",1), Ingredient("cutstone", 2)},
RECIPETABS.REFINE,
TECH.LOST, 
"kynoox_lamp_post_placer",
1, 
nil, 
nil, 
nil, 
"images/inventoryimages/lamp_post.xml", 
"lamp_post.tex")
end

if GetModConfigData("lampshortrecipe") then
MakeRecipe("kynoox_lamp_short",
{Ingredient("lantern",1), Ingredient("cutstone", 2)},
RECIPETABS.REFINE,
TECH.LOST, 
"kynoox_lamp_short_placer",
1, 
nil, 
nil, 
nil, 
"images/inventoryimages/lamp_short.xml", 
"lamp_short.tex")
end 

if GetModConfigData("postrecipe") then
MakeRecipe("kynoox_post",
{Ingredient("cutstone",1)},
RECIPETABS.REFINE,
TECH.LOST, 
"kynoox_post_placer",
1, -- min_spacing
nil, -- nounlock
nil, -- numtogive
nil, -- builder_tag
"images/inventoryimages/bollard.xml", 
"bollard.tex")
end		
	
if GetModConfigData("parkspikerecipe") then
MakeRecipe("kynoox_parkspike",
{Ingredient("cutstone",2)},
RECIPETABS.REFINE,
TECH.LOST, 
"kynoox_parkspike_placer",
1, -- min_spacing
nil, -- nounlock
nil, -- numtogive
nil, -- builder_tag
"images/inventoryimages/fence.xml", 
"fence.tex")
end

if GetModConfigData("parkspikeshortrecipe") then
MakeRecipe("kynoox_parkspike_short",
{Ingredient("cutstone",2)},
RECIPETABS.REFINE,
TECH.LOST, 
"kynoox_parkspike_short_placer",
1, -- min_spacing
nil, -- nounlock
nil, -- numtogive
nil, -- builder_tag
"images/inventoryimages/fence2.xml", 
"fence2.tex")
end
		
if GetModConfigData("ivythingrecipe") then
MakeRecipe("kynoox_ivything",
{Ingredient("succulent_picked",1), Ingredient("cutstone",1)},
RECIPETABS.REFINE,
TECH.LOST, 
"kynoox_ivything_placer",
2, -- min_spacing
nil, -- nounlock
nil, -- numtogive
nil, -- builder_tag
"images/inventoryimages/ivy.xml", 
"ivy.tex")
end			

if GetModConfigData("urnrecipe") then
MakeRecipe("kynoox_urn",
{Ingredient("cutstone",2)},
RECIPETABS.REFINE,
TECH.LOST, 
"kynoox_urn_placer",
2, -- min_spacing
nil, -- nounlock
nil, -- numtogive
nil, -- builder_tag
"images/inventoryimages/urn.xml", 
"urn.tex")
end


if GetModConfigData("miniyurtrecipe") then
MakeRecipe("mini_yurt",
{Ingredient("silk",12), Ingredient("log",8), Ingredient("rope",6)}, 
RECIPETABS.REFINE,
TECH.LOST, 
"mini_yurt_placer",
2,
nil,
nil,
nil,
"images/inventoryimages/mini_yurt.xml", 
"mini_yurt.tex")
end

if GetModConfigData("minitipirecipe") then
MakeRecipe("mini_tipi",
{Ingredient("silk",8), Ingredient("log",10), Ingredient("rope",4)}, 
RECIPETABS.REFINE,
TECH.LOST, 
"mini_tipi_placer",
2, -- min_spacing
nil, -- nounlock
nil, -- numtogive
nil, -- builder_tag
"images/inventoryimages/mini_tipi.xml", 
"mini_tipi.tex")
end	

		
		
			
		