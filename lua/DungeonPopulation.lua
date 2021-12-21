local min_x_0, max_x_0, min_y_0, max_y_0 = 1, wml.variables["current_dungeon_template.x"], 1, wml.variables["current_dungeon_template.y"]
local min_x_1, max_x_1, min_y_1, max_y_1 = 1, max_x_0, 1, max_y_0
local spacings = {
	primary = 4,
	secondary = 4,
	water = 2,
	loner = 2
}
local function get_active_area(a_type)
	local s = spacings[a_type]
	wml.variables["dungeon_creation.temp.active_area"] = nil
	local function get_locations()
		local loc_table
		if a_type == "primary" then
			loc_table = {
					x = string.format("%d-%d", min_x_0, max_x_0),
					y = string.format("%d-%d", min_y_0, max_y_0),
					find_in = "chamber_terrain.hexes",
					variable = "dungeon_creation.temp.active_area"
				}
		elseif a_type == "secondary" then
			loc_table =  {
					x = string.format("%d-%d", min_x_1, max_x_1),
					y = string.format("%d-%d", min_y_1, max_y_1),
					find_in = "chamber_terrain.hexes",
					variable = "dungeon_creation.temp.active_area"
				}
		elseif a_type == "water" then
			loc_table =  {
					terrain = "Ww,Ss",
					variable = "dungeon_creation.temp.active_area"
				}
		else
			loc_table =  {
					find_in = "chamber_terrain.hexes",
					variable = "dungeon_creation.temp.active_area"
				}
		end
		if s > 0 then
			table.insert(loc_table, { "not", { radius = s, { "filter", {} } } })
		else
			table.insert(loc_table, { "not", { { "filter", {} } } })
		end
		W.store_locations(loc_table)
		local filled = false
		if wml.variables["dungeon_creation.temp.active_area"] then
			filled = true
		end
		return filled
	end
	local done = get_locations()
	while s > 0 and not done do
		s = s - 1
		done = get_locations()
	end
	spacings[a_type] = s
end

local function get_mob_loc()
	local dcaal = tonumber(wml.variables["dungeon_creation.temp.active_area.length"]) or 0
	--local ix = H.rand("0..$($dungeon_creation.temp.active_area.length-1)")
	local ix = tonumber(H.rand(string.format("0..%i", dcaal - 1)))
	local loc = wml.variables[string.format("dungeon_creation.temp.active_area[%d]", ix)]
	wml.variables["dungeon_creation.temp.mob_x"] = loc.x
	wml.variables["dungeon_creation.temp.mob_y"] = loc.y
end

local rnd_1 = H.rand("0..3")
local rnd_2 = H.rand("0..10")
if rnd_1 == 0 then
	max_x_0, min_x_1 = max_x_1 / 2 + rnd_2 - 7, max_x_1 / 2 + rnd_2 - 2
elseif rnd_1 == 1 then
	max_x_1, min_x_0 = max_x_0 / 2 + rnd_2 - 7, max_x_0 / 2 + rnd_2 - 2
elseif rnd_1 == 2 then
	max_y_0, min_y_1 = max_y_1 / 2 + rnd_2 - 7, max_y_1 / 2 + rnd_2 - 2
else
	max_y_1, min_y_0 = max_y_0 / 2 + rnd_2 - 7, max_y_0 / 2 + rnd_2 - 2
end

local current_level = wml.variables["dungeon_level.current"]
local cluster_min, cluster_max = math.floor((current_level + 1) * 0.4), math.floor((current_level + 3) * 0.6)
local nominal_max, nominal_min = math.floor(cluster_max * 4 / 3), cluster_min
if nominal_max < cluster_max + 3 then
	nominal_min = nominal_min - 1
end
local function get_cluster_level()
	local rnd = H.rand(string.format("%d..%d", nominal_min, nominal_max))
	if rnd < cluster_min then
		rnd = cluster_min
	elseif rnd > cluster_max then
		rnd = cluster_max - 1
	end
	wml.variables["dungeon_creation.temp.cluster_level"] = rnd
end

local boss_clusters, mini_clusters, loners, pool_loners
local player_count = tonumber(wml.variables["const.active_players"]) or 0
if player_count == 1 then
	boss_clusters = tonumber(H.rand("1,1,2"))
	mini_clusters = tonumber(H.rand("1,2,2"))
	loners = H.rand("5..7")
	pool_loners = tonumber(H.rand("0,1,1,1,2"))
elseif player_count == 2 then
	boss_clusters = tonumber(H.rand("1,2,2"))
	mini_clusters = tonumber(H.rand("2,3,3"))
	loners = H.rand("6..9")
	pool_loners = tonumber(H.rand("0,1,1,2,2"))
else
	boss_clusters = tonumber(H.rand("2,3"))
	mini_clusters = tonumber(H.rand("3,3,4"))
	loners = H.rand("1..5") + 2 * player_count
	pool_loners = tonumber(H.rand("0,1,2,2,3,3"))
end
wml.variables["dungeon_creation.temp.cluster_id"] = 0
local function advance_cluster()
	wml.variables["dungeon_creation.temp.cluster_id"] = wml.variables["dungeon_creation.temp.cluster_id"] + 1
end

local first_enemy_position = wml.variables["const.max_player_count"]
if wml.variables['dungeon_creation.temp.water_theme_position'] > first_enemy_position then
	get_active_area("water")
	while pool_loners > 0 and wml.variables["dungeon_creation.temp.active_area"] do
		wml.variables["dungeon_creation.temp.mob_theme"] = "water"
		wml.variables["dungeon_creation.temp.place_side"] = wml.variables['dungeon_creation.temp.water_theme_position']
		get_mob_loc()
		get_cluster_level()
		wesnoth.fire_event("create_mob_loner")
		advance_cluster()
		pool_loners = pool_loners - 1
		get_active_area("water")
	end
end
loners = loners + pool_loners

while boss_clusters > 0 do
	local theme_index = tonumber(H.rand("0,0,1"))
	wml.variables["dungeon_creation.temp.mob_theme"] = wml.variables[("dungeon_creation.temp.creep_themes[%d].theme"):format(theme_index)]
	wml.variables["dungeon_creation.temp.place_side"] = theme_index + first_enemy_position + 1
	if theme_index == 0 then
		get_active_area("primary")
	else
		get_active_area("secondary")
	end
	get_mob_loc()
	get_cluster_level()
	wesnoth.fire_event("create_mob_boss")
	local ap = tonumber(wml.variables["const.active_players"]) or 0
	--local tough_count = H.rand(string.format("1..%d", H.rand("1..$const.active_players")))
	local tough_count = tonumber(H.rand(string.format("1..%i", ap)))
	for i = 1, tough_count do
		wesnoth.fire_event("create_mob_tough")
	end
	local ap2 = ap * 2
	local mook_count = tonumber(H.rand(string.format("%i..%i", ap, ap2)))
	--local mook_count = H.rand("$const.active_players..$(2*$const.active_players)")
	for i = 1, mook_count do
		wesnoth.fire_event("create_mob_mook")
	end
	advance_cluster()
	boss_clusters = boss_clusters - 1
end
spacings.primary = math.min(spacings.primary, 3)
spacings.secondary = math.min(spacings.secondary, 3)

while mini_clusters > 0 do
	local theme_index = tonumber(H.rand("0,1,1"))
	wml.variables["dungeon_creation.temp.mob_theme"] = wml.variables[("dungeon_creation.temp.creep_themes[%d].theme"):format(theme_index)]
	wml.variables["dungeon_creation.temp.place_side"] = theme_index + first_enemy_position + 1
	if theme_index == 0 then
		get_active_area("primary")
	else
		get_active_area("secondary")
	end
	get_mob_loc()
	get_cluster_level()
	local ap = tonumber(wml.variables["const.active_players"]) or 0
	--local tough_count = H.rand(string.format("1..%d", H.rand("1..$const.active_players")))
	local tough_count = tonumber(H.rand(string.format("1..%i", ap)))
	for i = 1, tough_count do
		wesnoth.fire_event("create_mob_tough")
	end
	local ap2 = ap * 2
	--local mook_count = H.rand(string.format("$const.active_players..%d", H.rand("$const.active_players..$(2*$const.active_players)")))
	local mook_count = tonumber(H.rand(string.format("%i..%i", ap, ap2)))
	for i = 1, mook_count do
		wesnoth.fire_event("create_mob_mook")
	end
	advance_cluster()
	mini_clusters = mini_clusters - 1
end
spacings.primary = math.min(spacings.primary, 2)
spacings.secondary = math.min(spacings.secondary, 2)

local side_counter
while loners > 0 do
	wesnoth.wml_actions.get_prob({
		variable = "dungeon_creation.temp.mob_theme",
		name = "dungeon_creation.temp.loner_themes",
		op = "rand"
	})
	if wml.variables['dungeon_creation.temp.mob_theme'] == wml.variables['dungeon_creation.temp.creep_themes[0].theme'] then
		wml.variables["dungeon_creation.temp.place_side"] = first_enemy_position + 1
		get_active_area("primary")
	elseif wml.variables['dungeon_creation.temp.mob_theme'] == wml.variables['dungeon_creation.temp.creep_themes[1].theme'] then
		wml.variables["dungeon_creation.temp.place_side"] = first_enemy_position + 2
		get_active_area("secondary")
	else
		side_counter = 2
		while wml.variables['dungeon_creation.temp.mob_theme'] ~= wml.variables[("dungeon_creation.temp.creep_themes[%d].theme"):format(side_counter)] do
			side_counter = side_counter + 1
		end
		wml.variables["dungeon_creation.temp.place_side"] = side_counter + first_enemy_position + 1
		get_active_area("loner")
	end
	get_mob_loc()
	get_cluster_level()
	wesnoth.fire_event("create_mob_loner")
	advance_cluster()
	loners = loners - 1
end
