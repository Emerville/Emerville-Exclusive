--CONTAINERS:
local containers = GLOBAL.require("containers")
local oldwidgetsetup = containers.widgetsetup
_G=GLOBAL

mods=_G.rawget(_G,"mods")or(function()local m={}_G.rawset(_G,"mods",m)return m end)()
mods.old_widgetsetup = mods.old_widgetsetup or containers.smartercrockpot_old_widgetsetup or oldwidgetsetup
containers.widgetsetup = function(container, prefab, ...)
    if not prefab and container.inst.prefab == "glommpack" then
        prefab = "backpack"
    end
    return oldwidgetsetup(container, prefab, ...)
end

local oldwidgetsetup3 = containers.widgetsetup
containers.widgetsetup = function(container, prefab, ...)
    if not prefab and container.inst.prefab == "schest"  then
        prefab = "treasurechest"
    end
    return oldwidgetsetup3(container, prefab, ...)
end

local oldwidgetsetup4 = containers.widgetsetup
containers.widgetsetup = function(container, prefab, ...)
    if not prefab and container.inst.prefab == "wool_sack"  then
        prefab = "piggyback"
    end
    return oldwidgetsetup4(container, prefab, ...)
end

local oldwidgetsetup5 = containers.widgetsetup
containers.widgetsetup = function(container, prefab, ...)
    if not prefab and container.inst.prefab == "wolfyback"  then
        prefab = "piggyback"
    end
    return oldwidgetsetup5(container, prefab, ...)
end

local oldwidgetsetup6 = containers.widgetsetup
containers.widgetsetup = function(container, prefab, ...)
    if not prefab and container.inst.prefab == "bunnyback"  then
        prefab = "piggyback"
    end
    return oldwidgetsetup6(container, prefab, ...)
end

local oldwidgetsetup7 = containers.widgetsetup
containers.widgetsetup = function(container, prefab, ...)
    if not prefab and container.inst.prefab == "equip_pack"  then
        prefab = "piggyback"
    end
    return oldwidgetsetup7(container, prefab, ...)
end

local oldwidgetsetup8 = containers.widgetsetup
containers.widgetsetup = function(container, prefab, ...)
    if not prefab and container.inst.prefab == "freezer"  then
        prefab = "treasurechest"
    end
    return oldwidgetsetup8(container, prefab, ...)
end

local oldwidgetsetup9 = containers.widgetsetup
containers.widgetsetup = function(container, prefab, ...)
    if not prefab and container.inst.prefab == "christmaswoodie"  then
        prefab = "sacred_chest"
    end
    return oldwidgetsetup9(container, prefab, ...)
end
