H = wesnoth.require "lua/helper.lua"
W = H.set_wml_action_metatable {}
_ = wesnoth.textdomain "wesband"
unit = setmetatable({}, { __newindex = function(t, k, v) modu(k, v) end })
-- Define your global constants here.


H.set_wml_var_metatable(_G)

-- Define your global functions here.

-- chat tags,
-- have to override default [chat] tag to allow for no-speaker messages
-- can enter speaker="" for just a general statement, will not show <>
function wesnoth.wml_actions.chat(cfg)
	local side_list = wesnoth.get_sides(cfg)
	local message = tostring(cfg.message) or
		helper.wml_error "[chat] missing required message= attribute."

	local speaker = cfg.speaker
	if speaker then
		speaker = tostring(speaker)
	else
		speaker = ""
	end

	for index, side in ipairs(side_list) do
		if side.controller == "human" then
			wesnoth.message(speaker, message)
			break
		end
	end
end

-- command line alteration of units in the [variables] container
-- :lua unit.talentpoints=100
-- function modu(var, val)
--   local x, y = wesnoth.get_selected_tile()
--   H.modify_unit({ x = x, y = y }, { ["variables."..var] = val })
-- end

--! [store_shroud]
--! melinath

-- Given side= and variable=, stores that side's shroud data in that variable
-- Example:
-- [store_shroud]
--     side=1
--     variable=shroud_data
-- [/store_shroud]
function wesnoth.wml_actions.store_shroud(cfg)
	local team_num = cfg.side or H.wml_error("[store_shroud] expects a side= attribute.")
	local var = cfg.variable or H.wml_error("[store_shroud] expects a variable= attribute.")
	local team = wesnoth.get_side(team_num)
	local current_shroud = team.__cfg.shroud_data
	wesnoth.set_variable(var, current_shroud)
end

--! [set_shroud]
--! melinath

-- Given shroud data, removes the shroud in the marked places on the map.
-- Example:
-- [set_shroud]
--     side=1
--     shroud_data=$shroud_data # stored with store_shroud, for example!
-- [/set_shroud]
function wesnoth.wml_actions.set_shroud(cfg)
	local team_num = cfg.side or H.wml_error("[store_shroud] expects a side= attribute.")
	local shroud = cfg.shroud_data or H.wml_error("[store_shroud] expects a shroud_data= attribute.")
	if shroud == nil then
		H.wml_error("[set_shroud] was passed a nil shroud string")
	elseif string.sub(shroud,1,1)~="|" then
		H.wml_error("[set_shroud] was passed an invalid shroud string.")
	else
		local w,h,b=wesnoth.get_map_size()
		local shroud_x= (1-b)
		for r in string.gmatch(shroud,"|(%d*)") do
			local shroud_y=(1-b)
			for c in string.gmatch(r,"%d") do
				if c == "1" then
					W.remove_shroud { side = team_num, x = shroud_x, y = shroud_y }
				else
					W.place_shroud { side = team_num, x = shroud_x, y = shroud_y }
				end
				shroud_y=shroud_y+1
			end
			shroud_x=shroud_x+1
		end
	end
end

function wesnoth.wml_actions.get_distance(cfg)
	local x1 = cfg.x1 or H.wml_error("[get_distance] expects a x1= attribute")
	local y1 = cfg.y1 or H.wml_error("[get_distance] expects a y1= attribute")
	local x2 = cfg.x2 or H.wml_error("[get_distance] expects a x2= attribute")
	local y2 = cfg.y2 or H.wml_error("[get_distance] expects a y2= attribute")
	local var_name = cfg.variable or "distance"
	wesnoth.set_variable(var_name, H.distance_between(x1, y1, x2, y2))
end

function wesnoth.wml_actions.get_defense(cfg)
	local terrain = cfg.terrain or wesnoth.get_terrain(cfg.x, cfg.y) or H.wml_error("[get_defense] expects either a terrain= attribute or x= and y= attributes")
	local u
	if cfg.unit then
		local upath = wesnoth.get_variable(cfg.unit)
		u = wesnoth.get_units({ id = upath.id })[1]
	else
		u = (wesnoth.create_unit { type = cfg.type or H.wml_error("[get_defense] expects either a unit= attribute or a type= attribute") })
	end
	local var = cfg.variable or "defense"
	wesnoth.set_variable(var, wesnoth.unit_defense(u, terrain))
end

function wesnoth.wml_actions.get_move_cost(cfg)
	local terrain = cfg.terrain or wesnoth.get_terrain(cfg.x, cfg.y) or H.wml_error("[get_move_cost] expects either a terrain= attribute or x= and y= attributes")
	local u
	if cfg.unit then
		local upath = wesnoth.get_variable(cfg.unit)
		u = wesnoth.get_units({ id = upath.id })[1]
	else
		u = (wesnoth.create_unit { type = cfg.type }) or H.wml_error("[get_defense] expects either a unit= attribute or a type= attribute")
	end
	local var = cfg.variable or "movement_cost"
	wesnoth.set_variable(var, wesnoth.unit_movement_cost(u, terrain))
end

function wesnoth.wml_actions.generate_shop_details(cfg)
	local shop = cfg.shop or H.wml_error("[generate_shop_details]: no shop attribute given")

	local unit_type, shop_descriptors

	if shop == "weapon" or shop == "armor" then
		unit_type = H.rand("Master Bowman,Swordsman,Spearman,Sergeant,Pikeman,Longbowman,Javelineer,Heavy Infantryman,Bowman,Dwarvish Dragonguard,Dwarvish Fighter,Dwarvish Guardsman,Dwarvish Sentinel,Dwarvish Thunderer,Elvish Ranger,Elvish Marksman,Elvish Hero,Elvish Fighter,Elvish Captain,Elvish Archer")
		if shop == "weapon" then
			shop_descriptors = "Arms,Blades"
		else
			shop_descriptors = "Armor,Vestments,Shields"
		end
	elseif shop == "magic" then
		unit_type = H.rand("White Mage,Silver Mage,Red Mage,Mage of Light,Arch Mage,Elvish Shaman,Elvish Sorceress,Elvish Sylph,Dwarvish Runemaster")
		shop_descriptors = "Apothecary,Library,Magic Shoppe,Magical Supplies,Alchemy Store"
	elseif shop == "tavern" then
		unit_type = H.rand("Ruffian,Thug,Dwarvish Dragonguard,Dwarvish Fighter,Dwarvish Guardsman,Dwarvish Sentinel,Dwarvish Thunderer")
		shop_descriptors = "Tavern,Pub,Public House"
	else
		H.wml_error(string.format("[generate_name]: invalid shop attribute given: %s", shop))
	end

	local u = wesnoth.create_unit { type = unit_type, random_gender = "yes" }

	wesnoth.set_variable(string.format("shop_names.%s", shop), u.name)
	wesnoth.wml_actions.set_variable({ name = string.format("shop_names.%s2", shop), rand = shop_descriptors })
	wesnoth.set_variable(string.format("shop_names.%s3", shop), u.__cfg.profile)
end