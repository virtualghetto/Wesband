H = wesnoth.require "lua/helper.lua"
W = H.set_wml_action_metatable {}
_ = wesnoth.textdomain "wesband"
unit = setmetatable({}, { __newindex = function(t, k, v) modu(k, v) end })
-- Define your global constants here.


H.set_wml_var_metatable(_G)

-- Define your global functions here.

-- chat tags,
-- can enter speaker="" for just a general statement, will not show <>
wesnoth.register_wml_action("chat", function(args)
	local message = args.message or H.wml_error("[chat] expects a message= attribute.")
	if args.speaker then
		wesnoth.message(args.speaker, message)
	else
		wesnoth.message("", message)
	end
end)

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

wesnoth.register_wml_action("store_shroud", function(args)
	local team_num = args.side or H.wml_error("[store_shroud] expects a side= attribute.")
	local storage = args.variable or H.wml_error("[store_shroud] expects a variable= attribute.")
	local team = wesnoth.get_side(team_num)
	local current_shroud = team.__cfg.shroud_data
	wesnoth.set_variable(storage,current_shroud)
end)

--! [set_shroud]
--! melinath

-- Given shroud data, removes the shroud in the marked places on the map.
-- Example:
-- [set_shroud]
--     side=1
--     shroud_data=$shroud_data # stored with store_shroud, for example!
-- [/set_shroud]

wesnoth.register_wml_action("set_shroud", function(args)
	local team_num = args.side or H.wml_error("[store_shroud] expects a side= attribute.")
	local shroud = args.shroud_data or H.wml_error("[store_shroud] expects a shroud_data= attribute.")
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
end)

wesnoth.register_wml_action("get_distance", function(args)
	local x1 = args.x1 or H.wml_error("[get_distance] expects a x1= attribute")
	local y1 = args.y1 or H.wml_error("[get_distance] expects a y1= attribute")
	local x2 = args.x2 or H.wml_error("[get_distance] expects a x2= attribute")
	local y2 = args.y2 or H.wml_error("[get_distance] expects a y2= attribute")
	local var_name = args.variable or "distance"
	wesnoth.set_variable(var_name, H.distance_between(x1, y1, x2, y2))
end)

wesnoth.register_wml_action("get_defense", function(args)
	local terrain = args.terrain or wesnoth.get_terrain(args.x, args.y) or H.wml_error("[get_defense] expects either a terrain= attribute or x= and y= attributes")
	local u
	if args.unit then
		local upath = wesnoth.get_variable(args.unit)
		u = wesnoth.get_units({ id = upath.id })[1]
	else
		u = (wesnoth.create_unit { type = args.type }) or H.wml_error("[get_defense] expects either a unit= attribute or a type= attribute")
	end
	local var_name = args.variable or "defense"
	wesnoth.set_variable(var_name, wesnoth.unit_defense(u, terrain))
end)

wesnoth.register_wml_action("get_move_cost", function(args)
	local terrain = args.terrain or wesnoth.get_terrain(args.x, args.y) or H.wml_error("[get_move_cost] expects either a terrain= attribute or x= and y= attributes")
	local u
	if args.unit then
		local upath = wesnoth.get_variable(args.unit)
		u = wesnoth.get_units({ id = upath.id })[1]
	else
		u = (wesnoth.create_unit { type = args.type }) or H.wml_error("[get_defense] expects either a unit= attribute or a type= attribute")
	end
	local var_name = args.variable or "movement_cost"
	wesnoth.set_variable(var_name, wesnoth.unit_movement_cost(u, terrain))
end)

local old_unstore_handler
old_unstore_handler = wesnoth.register_wml_action("unstore_unit", function(args)
	local u = wesnoth.get_variable(args.variable)
	local a = args.__literal
	if u.type then
		old_unstore_handler(a)
	else
		W.wml_message { logger = "err", message = string.format("attempting to unstore unit with no type from variable %s (%s)", args.variable, a.variable) }
	end
end)