local mask_table = {}
mask_table.ne_sw_hall = wesnoth.dofile("~add-ons/Wesband/masks/ne_sw_hall.lua")
mask_table.nw_se_hall = wesnoth.dofile("~add-ons/Wesband/masks/nw_se_hall.lua")

local function place_hall(x, y, dir)
	if dir == "SW" then
		W.terrain_mask {
			x = x - 11,
			y = y - 1 - x % 2,
			mask = mask_table.ne_sw_hall
		}
	elseif dir == "NE" then
		W.terrain_mask {
			x = x - 1,
			y = y - 6 - x % 2,
			mask = mask_table.ne_sw_hall
		}
	elseif dir == "SE" then
		W.terrain_mask {
			x = x - 1,
			y = y - 1 - x % 2,
			mask = mask_table.nw_se_hall
		}
	else
		W.terrain_mask {
			x = x - 11,
			y = y - 6 - x % 2,
			mask = mask_table.nw_se_hall
		}
	end
end

local function place_random_chamber(x, y)
	local mask_name
	W.set_variable { name = "r_temp", rand = "1..35" }
	if r_temp == 35 then
		W.set_variable { name = "r_temp", rand = "33..35" }
	end
	if r_temp == 1 then
		mask_name = "diamond_large_upper"
	elseif r_temp == 2 then
		mask_name = "diamond_large_lower"
	elseif r_temp == 3 then
		mask_name = "diamond_long_upper"
	elseif r_temp == 4 then
		mask_name = "diamond_long_lower"
	elseif r_temp == 5 then
		mask_name = "diamond_long2_upper"
	elseif r_temp == 6 then
		mask_name = "diamond_long2_lower"
	elseif r_temp == 7 then
		mask_name = "diamond_large_center"
	elseif r_temp == 8 then
		mask_name = "diamond_small_center"
	elseif r_temp == 9 then
		mask_name = "diamond_large2_center"
	elseif r_temp == 10 then
		mask_name = "diamond_columns"
	elseif r_temp == 11 then
		mask_name = "diamond_s"
	elseif r_temp == 12 then
		mask_name = "diamond_irreg"
	elseif r_temp == 13 then
		mask_name = "diamond_irreg2"
	elseif r_temp == 14 then
		mask_name = "diamond_irreg3"
	elseif r_temp == 15 then
		mask_name = "diamond_columns2"
	elseif r_temp == 16 then
		mask_name = "diamond_large_pool"
	elseif r_temp == 17 then
		mask_name = "diamond_star_pool"
	elseif r_temp == 18 then
		mask_name = "diamond_hex_pool"
	elseif r_temp == 19 then
		mask_name = "diamond_hex"
	elseif r_temp == 20 then
		mask_name = "diamond_star"
	elseif r_temp == 21 then
		mask_name = "diamond_star2"
	elseif r_temp == 22 then
		mask_name = "diamond_columns3"
	elseif r_temp == 23 then
		mask_name = "diamond_columns4"
	elseif r_temp == 24 then
		mask_name = "diamond_large3_center"
	elseif r_temp == 25 then
		mask_name = "diamond_large4_center"
	elseif r_temp == 26 then
		mask_name = "diamond_large5_center"
	elseif r_temp == 27 then
		mask_name = "diamond_large6_center"
	elseif r_temp == 28 then
		mask_name = "diamond_large7_center"
	elseif r_temp == 29 then
		mask_name = "diamond_large3_pool_center"
	elseif r_temp == 30 then
		mask_name = "diamond_large4_pool_center"
	elseif r_temp == 31 then
		mask_name = "diamond_large5_pool_center"
	elseif r_temp == 32 then
		mask_name = "diamond_large6_pool_center"
	elseif r_temp == 33 then
		mask_name = "diamond_large7_pool_center"
	elseif r_temp == 34 then
		mask_name = "diamond_large8_pool_center"
	else
		W.set_variable { name = "r_temp", rand = "0..2" }
		if r_temp == 0 then
			mask_name = "diamond_huge_columns"
		elseif r_temp == 1 then
			mask_name = "diamond_huge_columns2"
		else
			mask_name = "diamond_huge_maze"
		end
	end
	if not mask_table[mask_name] then
		mask_table[mask_name] = wesnoth.dofile(string.format("~add-ons/Wesband/masks/%s.lua", mask_name))
	end
	W.terrain_mask {
		x = x,
		y = y,
		mask = mask_table[mask_name]
	}
end

local function select_layout(edge_room_chance, extra_path_chance, stray_path_chance)
	-- setup for rooms/paths to select from
	local rooms, selected_rooms, candidate_paths, selected_paths = {}, {}, {}, {}
	local island_count = 0
	local w, h = wesnoth.get_map_size()
	local x_room_limit, y_room_limit = math.floor(w / 10 - 1) * 10 + 1, math.floor(h / 10 - 1) * 10 + 1
	local function process_room(x, y)
		local name = string.format("%d,%d", x, y)
		local accept_room
		if x == 1 or y == 1 or x == x_room_limit or y == y_room_limit then
			W.set_variable { name = "r_temp", rand = "0..99" }
			accept_room = wesnoth.get_variable("r_temp") < edge_room_chance
		else
			accept_room = true
		end
		if accept_room then
			rooms[name] = { parent = name, rank = 0 }
			table.insert(selected_rooms, { x = x, y = y })
			island_count = island_count + 1
		end
		if x % 20 == 11 then
			if x < x_room_limit then
				table.insert(candidate_paths, { name, string.format("%d,%d", x + 10, y - 5), x + 4, y + 4, "NE" })
				table.insert(candidate_paths, { name, string.format("%d,%d", x + 10, y + 5), x + 4, y + 4, "SE" })
			end
			table.insert(candidate_paths, { name, string.format("%d,%d", x - 10, y - 5), x + 4, y + 4, "NW" })
			table.insert(candidate_paths, { name, string.format("%d,%d", x - 10, y + 5), x + 4, y + 4, "SW" })
		end
	end
	for x = 1, x_room_limit, 10 do
		local a = math.max(1, x % 20 - 5)
		for y = a, y_room_limit, 10 do
			process_room(x, y)
		end
	end
	-- functions to select from paths
	local function find_root(a)
		local r
		if rooms[a].parent == a then
			r = a
		else
			r = find_root(rooms[a].parent)
			rooms[a].parent = r
		end
		return r
	end
	local function union(a, b)
		local r1, r2 = find_root(a), find_root(b)
		local new_join = r1 ~= r2
		if new_join then
			if rooms[r1].rank < rooms[r2].rank then
				rooms[r1].parent = r2
			elseif rooms[r1].rank > rooms[r2].rank then
				rooms[r2].parent = r1
			else
				rooms[r2].parent = r1
				rooms[r2].rank = rooms[r2].rank + 1
			end
		end
		return new_join
	end
	-- selection of paths
	local candidate_count, path_index, accept_path = #candidate_paths
	while island_count > 1 do
		W.set_variable { name = "r_temp", rand = string.format("1..%d", candidate_count) }
		path_index = wesnoth.get_variable("r_temp")
		if rooms[candidate_paths[path_index][1]] and rooms[candidate_paths[path_index][2]] then
			accept_path = union(candidate_paths[path_index][1], candidate_paths[path_index][2])
			if accept_path then
				island_count = island_count - 1
			else
				W.set_variable { name = "r_temp", rand = "0..99" }
				accept_path = wesnoth.get_variable("r_temp") < extra_path_chance
			end
		elseif rooms[candidate_paths[path_index][1]] or rooms[candidate_paths[path_index][2]] then
			W.set_variable { name = "r_temp", rand = "0..99" }
			accept_path = wesnoth.get_variable("r_temp") < stray_path_chance
		else
			accept_path = false
		end
		if accept_path then
			table.insert(selected_paths, { x = candidate_paths[path_index][3], y = candidate_paths[path_index][4], dir = candidate_paths[path_index][5] })
		end
		table.remove(candidate_paths, path_index)
		candidate_count = candidate_count - 1
	end
	for i = 1, candidate_count do
		W.set_variable { name = "r_temp", rand = "0..99" }
		if rooms[candidate_paths[i][1]] and rooms[candidate_paths[i][2]] then
			accept_path = wesnoth.get_variable("r_temp") < extra_path_chance
		elseif rooms[candidate_paths[i][1]] or rooms[candidate_paths[i][2]] then
			accept_path = wesnoth.get_variable("r_temp") < stray_path_chance
		else
			accept_path = false
		end
		if accept_path then
			table.insert(selected_paths, { x = candidate_paths[i][3], y = candidate_paths[i][4], dir = candidate_paths[i][5] })
		end
	end
	return selected_rooms, selected_paths
end

local rooms, halls = select_layout(75, 40, 25)
for i = 1, #halls do
	place_hall(halls[i].x, halls[i].y, halls[i].dir)
end
for i = 1, #rooms do
	place_random_chamber(rooms[i].x, rooms[i].y)
end

W.store_locations { terrain = "Re", variable = "chamber_terrain.hexes" }