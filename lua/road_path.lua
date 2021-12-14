local helper = wesnoth.require "lua/helper.lua"
local LS = wesnoth.require "location_set"

local function on_board(x, y)
        if type(x) ~= "number" or type(y) ~= "number" then
                return false
        end
        local w, h = wesnoth.get_map_size()
        return x >= 1 and y >= 1 and x <= w and y <= h
end

local function insert_locs(x, y, locs_set)
	if locs_set:get(x,y) or not on_board(x, y) then
		return
	end
	locs_set:insert(x,y)
end

local function place_road(to_x, to_y, from_x, from_y, road_ops)
	if not on_board(to_x, to_y) then
		return
	end

	local tile_op = road_ops[wesnoth.get_terrain(to_x, to_y)]
	if tile_op then
		if tile_op.convert_to_bridge and from_x and from_y then
			local bridges = {}
			for elem in tile_op.convert_to_bridge:gmatch("[^%s,][^,]*") do
				table.insert(bridges, elem)
			end
			local dir = wesnoth.map.get_relative_dir(from_x, from_y, to_x, to_y)
			if dir == 'n' or dir == 's' then
				wesnoth.set_terrain(to_x, to_y, bridges[1], 'both', false)
			elseif dir == 'sw' or dir == 'ne' then
				wesnoth.set_terrain(to_x, to_y, bridges[2], 'both', false)
			elseif dir == 'se' or dir == 'nw' then
				wesnoth.set_terrain(to_x, to_y, bridges[3], 'both', false)
			end
		elseif tile_op.convert_to then
			local tile = helper.rand(tile_op.convert_to)
			wesnoth.set_terrain(to_x, to_y, tile, 'both', false)
		end
	end
end

function wesnoth.wml_actions.road_path(cfg)
	local from_x = tonumber(cfg.from_x) or helper.wml_error("[road_path] expects a from_x= attribute.")
	local from_y = tonumber(cfg.from_y) or helper.wml_error("[road_path] expects a from_y= attribute.")
	local to_x = tonumber(cfg.to_x) or helper.wml_error("[road_path] expects a to_x= attribute.")
	local to_y = tonumber(cfg.to_y) or helper.wml_error("[road_path] expects a to_y= attribute.")
	if not on_board(from_x, from_y) then
		return
	end

	if not on_board(to_x, to_y) then
		return
	end

	local windiness = tonumber(cfg.road_windiness) or 1

	local road_costs, road_ops = {}, {}
	for road in helper.child_range(cfg, "road_cost") do
		road_costs[road.terrain] = road.cost
		road_ops[road.terrain] = road
	end

	local path, cost

-- if wesnoth version >= 1.15.0
if wesnoth.compare_versions(wesnoth.game_config.version, ">=", "1.15.0") then


	path, cost = wesnoth.find_path(from_x, from_y, to_x, to_y, {
		viewing_side = 1, ignore_units = true, ignore_teleport = true, ignore_visibility = true,
		calculate = function(x, y, current_cost)
			local tile = wesnoth.get_terrain(x, y)
			local res = road_costs[tile] or 1.0
			if windiness > 1 then
				res = res * wesnoth.random(windiness)
			end
			return res
		end })


-- else wesnoth version < 1.15.0
else


	path, cost = wesnoth.find_path(from_x, from_y, to_x, to_y,
		function(x, y, current_cost)
			local tile = wesnoth.get_terrain(x, y)
			local res = road_costs[tile] or 1.0
			if windiness > 1 then
				res = res * wesnoth.random(windiness)
			end
			return res
		end )



end
-- end wesnoth version


	local prev_x, prev_y
	for i, loc in ipairs(path) do
		local locs_set = LS.create()
		insert_locs(loc[1], loc[2], locs_set)
		for x,y in locs_set:stable_iter() do
			place_road(x, y, prev_x, prev_y, road_ops)
			prev_x, prev_y = x, y
		end
	end
end
