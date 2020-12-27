chestfunctions = require("scenarios/chestfunctions")


local function OnCreate(inst, scenariorunner)

	local items = 
	{
		{
			--Body Items
			item = "bar",
			chance = 1.00,
		},
		{
			--Main Item
			item = "metal",
			chance = 0.66,
		},
		{
			--Secondary Items
			item = "box_gear",
			chance = 0.25,
		},
		{
			--Armor Items
			item = {"ruinshat", "armorruins"},
			chance = 0.75,
			initfn = function(item) item.components.armor:SetCondition(math.random(item.components.armor.maxcondition * 0.44, item.components.armor.maxcondition * 0.9))end
		},
		{
			--Armor Items
			item = {"ruinshat", "armorruins"},
			chance = 0.75,
			initfn = function(item) item.components.armor:SetCondition(math.random(item.components.armor.maxcondition * 0.44, item.components.armor.maxcondition * 0.9))end
		},		
		{
			--Weapon Item
			item = "ruins_bat",
			chance = 0.75,
			initfn = function(item) item.components.finiteuses:SetUses(math.random(item.components.finiteuses.total * 0.44, item.components.finiteuses.total * 0.9)) end
		},	
		{
			--Weapon Item
			item = "nightstick",
			chance = 0.75,
		},
		{
			item = "yellowgem",
			count = math.random(1, 4),
			chance = 0.60,
		},		
		{
			item = "trinket_6",
			count = math.random(5, 10),
			chance = 0.80,
		},
	}
	
	chestfunctions.AddChestItems(inst, items)
end

return
{
    OnCreate = OnCreate,
}
