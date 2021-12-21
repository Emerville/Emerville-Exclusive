name = "Emerville Exclusive"
version = "1.17.03" --Added three more decimals to specify the version number of the fork.
--version_compatible = "2.02" --didn't seem to work when I tried with local dedicated...
description = "This mod is so great, we made another one!"
author = "Luis95R, KoreanWaffles"
forumthread = ""

api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
all_clients_require_mod = true
client_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

id = "defaultitems" --this is for inter-mod stuff -M
server_filter_tags = {"Luis"}
priority = 252 --super early, supposedly to overcome problem with dedicated servers -M
			   --- not anymoar -D
			   
configuration_options =
{
--------------------------------------------------
--[LIGHT]
--------------------------------------------------
    { 
    name = "lightnecklacerecipe",
    label = "Bright Necklace",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },	
--------------------------------------------------
--[SURVIVAL]
--------------------------------------------------
    { 
    name = "wool_sackrecipe",
    label = "Wool Sack",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    }, 
--------
    { 
    name = "mechanicalfanrecipe",
    label = "Mechanical Fan",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = false,
    },	
--------------------------------------------------
--[FARM]
-------------------------------------------------- 
    { 
    name = "compost_boxrecipe",
    label = "Compost Box",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },  
      default = true,
    },	
--------
    { 
    name = "freezereyerecipe",
    label = "Freezer",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    }, 
--------------------------------------------------
--[SCIENCE]
--------------------------------------------------
    { 
    name = "trash_canrecipe",
    label = "Trash Can",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    }, 	
--------------------------------------------------
--[WAR]
--------------------------------------------------	
    { 
    name = "sword_rockrecipe",
    label = "Stone Sword",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    { 
    name = "fryingpanrecipe",
    label = "Frying Pan",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    { 
    name = "armor_rockrecipe",
    label = "Stone Armor",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    }, 
-------- 
    { 
    name = "hat_rockrecipe",
    label = "Stone Hat",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    }, 
--------  
    { 
    name = "hat_marblerecipe",
    label = "Marble Hat",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },  
--------		
    {
    name = "gear_gunrecipe",
    label = "Gear Gun",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = false,
    },		
--------------------------------------------------
--[STRUCTURES]
--------------------------------------------------	
    { 
    name = "crate_woodenrecipe",
    label = "Wooden Crate",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },  
      default = true,
    },
--------
    { 
    name = "mech_moonrock_itemrecipe",
    label = "Moonrock Wall Gate",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    --[[{ 
    name = "locked_mech_moonrock_itemrecipe",
    label = "Locked Moonrock Wall Gate",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },]]
-------- 	
    { 
    name = "flowerbushrecipe",
    label = "Flower Bush",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
--------
    { 
    name = "xmastreerecipe",
    label = "Christmas Tree",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = false,
    },
-------- 
    { 
    name = "christmastreerecipe",
    label = "Christmas Tree (Lighted)",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = false,
    },
-------- 
    { 
    name = "snowmanrecipe",
    label = "Snowman",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    { 
    name = "featherbrellarecipe",
    label = "Goosebrella",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
--------
    { 
    name = "crate_metalrecipe",
    label = "Metal Crate",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },  
      default = false,
    },  	
--------------------------------------------------
--[REFINE]
--------------------------------------------------
    { 
    name = "giftredrecipe",
    label = "Present",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
--------------------------------------------------
--[MAGIC]
--------------------------------------------------
    { 
    name = "darkaxerecipe",
    label = "Dark Axe",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    { 
    name = "darkpickaxerecipe",
    label = "Dark Pickaxe",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    { 
    name = "mace_stingrecipe",
    label = "Bee Sting Bat",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    }, 
--------  
    {
    name = "growstaffrecipe",
    label = "Growth Staff",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
--------------------------------------------------
--[DRESS]
-------------------------------------------------- 
    {
    name = "bandanarecipe",
    label = "Summer Bandana",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    { 
    name = "gear_wingsrecipe",
    label = "Gear Wings",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    { 
    name = "hat_houndrecipe",
    label = "HoundHat",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = false,
    },		
--------------------------------------------------
--[ANCIENT]
-------------------------------------------------- 
    { 
    name = "mech_ruins_itemrecipe",
    label = "Thulecite Wall Gate",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    --[[{ 
    name = "locked_mech_ruins_itemrecipe",
    label = "Locked Thulecite Wall Gate",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },]]
--------  
    { 
    name = "box_gearrecipe",
    label = "Gear Box",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    { 
    name = "gears_hat_gogglesrecipe",
    label = "Gear Goggles",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    }, 
-------- 
    { 
    name = "gears_staffrecipe",
    label = "Vacuum Bulb",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    { 
    name = "gears_macerecipe",
    label = "Randomatrix",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    { 
    name = "stampederecipe",
    label = "Stampede",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    { 
    name = "hornucopiarecipe",
    label = "Hornucopia",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
--------------------------------------------------
--[EXTRA]
--------------------------------------------------
	{
    name = "Wall Gates Recipe",
    options =
    {
     {description = "Gears", data = "gears"},
     {description = "Electrical Doodad", data = "transistor"},
	 {description = "Gold", data = "gold"},
    },
      default = "gears",
    },
-------- 
    { 
    name = "fuelsupplierrecipe",
    label = "Fuel Supplier",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    { 
    name = "lamppostrecipe",
    label = "Lamp Post",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
--------
    { 
    name = "lampshortrecipe",
    label = "Lamp Post Short",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
--------
    { 
    name = "postrecipe",
    label = "Post",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
--------
    { 
    name = "parkspikerecipe",
    label = "Iron Fence",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
--------  
    { 
    name = "parkspikeshortrecipe",
    label = "Iron Fence Short",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
--------
    { 
    name = "ivythingrecipe",
    label = "Ivy",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    { 
    name = "urnrecipe",
    label = "Urn",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    { 
    name = "miniyurtrecipe",
    label = "Mini Yurt",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },
-------- 
    { 
    name = "minitipirecipe",
    label = "Mini Tipi",
    options =
    {
     {description = "Craftable", data = true},
     {description = "Disabled", data = false},
    },
      default = true,
    },	
}