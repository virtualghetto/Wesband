local min_x_0, max_x_0, min_x_1, max_x_1, min_y_0, max_y_0, min_y_1, max_y_1 = 1, current_dungeon_template.x, 1, current_dungeon_template.x, 1, current_dungeon_template.y, 1, current_dungeon_template.y

local function get_active_area(a_type, spacing)
	local s = spacing
	W.clear_variable { name = "dungeon_creation.temp.active_area" }
	while s > 0 and not dungeon_creation.temp.active_area do
		if a_type == "primary" then
			W.store_locations {
					x = string.format("%d-%d", min_x_0, max_x_0),
					y = string.format("%d-%d", min_y_0, max_y_0),
					find_in = "chamber_terrain",
					{ "not", { radius = s, { "filter", {} } } },
					variable = "dungeon_creation.temp.active_area"
				}
		elseif a_type == "secondary" then
			W.store_locations {
					x = string.format("%d-%d", min_x_1, max_x_1),
					y = string.format("%d-%d", min_y_1, max_y_1),
					find_in = "chamber_terrain",
					{ "not", { radius = s, { "filter", {} } } },
					variable = "dungeon_creation.temp.active_area"
				}
		elseif a_type == "water" then
			W.store_locations {
					terrain = "Ww,Ss",
					{ "not", { radius = s, { "filter", {} } } },
					variable = "dungeon_creation.temp.active_area"
				}
		else
			W.store_locations {
					find_in = "chamber_terrain",
					{ "not", { radius = s, { "filter", {} } } },
					variable = "dungeon_creation.temp.active_area"
				}
		end
		s = s - 1
	end
end

local function get_mob_loc()
	W.set_variable { name = "r_temp", rand = "0..$($dungeon_creation.temp.active_area.length-1)" }
	wesnoth.set_variable("dungeon_creation.temp.mob_x", dungeon_creation.temp.active_area[r_temp].x)
	wesnoth.set_variable("dungeon_creation.temp.mob_y", dungeon_creation.temp.active_area[r_temp].y)
end

W.set_variable { name = "r_temp", rand = "0..3" }
if r_temp == 0 then
	W.set_variable { name = "r_temp", rand = "0..10" }
	max_x_0, min_x_1 = current_dungeon_template.x / 2 + r_temp - 7, current_dungeon_template.x / 2 + r_temp - 2
elseif r_temp == 1 then
	W.set_variable { name = "r_temp", rand = "0..10" }
	max_x_1, min_x_0 = current_dungeon_template.x / 2 + r_temp - 7, current_dungeon_template.x / 2 + r_temp - 2
elseif r_temp == 2 then
	W.set_variable { name = "r_temp", rand = "0..10" }
	max_y_0, min_y_1 = current_dungeon_template.y / 2 + r_temp - 7, current_dungeon_template.y / 2 + r_temp - 2
else
	W.set_variable { name = "r_temp", rand = "0..10" }
	max_y_1, min_y_0 = current_dungeon_template.y / 2 + r_temp - 7, current_dungeon_template.y / 2 + r_temp - 2
end

local cluster_min, cluster_max = math.floor((dungeon_level.current + 1) * 0.4), math.floor((dungeon_level.current + 3) * 0.6)
local nominal_max, nominal_min = math.floor(cluster_max * 4 / 3), cluster_min
if nominal_max < cluster_max + 3 then
	nominal_min = nominal_min - 1
end
local function get_cluster_level()
	W.set_variable { name = "dungeon_creation.temp.cluster_level", rand = string.format("%d..%d", nominal_min, nominal_max)}
	if dungeon_creation.temp.cluster_level < cluster_min then
		wesnoth.set_variable("dungeon_creation.temp.cluster_level", cluster_min)
	elseif dungeon_creation.temp.cluster_level > cluster_max then
		wesnoth.set_variable("dungeon_creation.temp.cluster_level", cluster_max - 1)
	end
end

local boss_clusters, mini_clusters, loners, pool_loners
if const.active_players == 1 then
	W.set_variable { name = "r_temp", rand = "1,1,2" }
	boss_clusters = r_temp
	W.set_variable { name = "r_temp", rand = "1,2,2" }
	mini_clusters = r_temp
	W.set_variable { name = "r_temp", rand = "5..7" }
	loners = r_temp
	W.set_variable { name = "r_temp", rand = "0,1,1,1,2" }
	pool_loners = r_temp
elseif const.active_players == 2 then
	W.set_variable { name = "r_temp", rand = "1,2,2" }
	boss_clusters = r_temp
	W.set_variable { name = "r_temp", rand = "2,3,3" }
	mini_clusters = r_temp
	W.set_variable { name = "r_temp", rand = "6..9" }
	loners = r_temp
	W.set_variable { name = "r_temp", rand = "0,1,1,2,2" }
	pool_loners = r_temp
else
	W.set_variable { name = "r_temp", rand = "2,3" }
	boss_clusters = r_temp
	W.set_variable { name = "r_temp", rand = "3,3,4" }
	mini_clusters = r_temp
	W.set_variable { name = "r_temp", rand = "1..5" }
	loners = r_temp + 2 * const.active_players
	W.set_variable { name = "r_temp", rand = "0,1,2,2,3,3" }
	pool_loners = r_temp
end
wesnoth.set_variable("dungeon_creation.temp.cluster_id", 0)

if dungeon_creation.temp.water_theme_position > const.max_player_count then
	get_active_area("water", 2)
	while pool_loners > 0 and dungeon_creation.temp.active_area do
		wesnoth.set_variable("dungeon_creation.temp.mob_theme", "water")
		wesnoth.set_variable("dungeon_creation.temp.place_side", dungeon_creation.temp.water_theme_position)
		get_mob_loc()
		get_cluster_level()
		wesnoth.fire_event("create_mob_loner")
		wesnoth.set_variable("dungeon_creation.temp.cluster_id", dungeon_creation.temp.cluster_id + 1)
		pool_loners = pool_loners - 1
		get_active_area("water", 2)
	end
end
loners = loners + pool_loners

while boss_clusters > 0 do
	W.set_variable { name = "r_temp", rand = "0,0,1" }
	wesnoth.set_variable("dungeon_creation.temp.mob_theme", dungeon_creation.temp.creep_themes[r_temp].theme)
	wesnoth.set_variable("dungeon_creation.temp.place_side", r_temp + const.max_player_count + 1)
	if r_temp == 0 then
		get_active_area("primary", 4)
	else
		get_active_area("secondary", 4)
	end
	get_mob_loc()
	get_cluster_level()
	wesnoth.fire_event("create_mob_boss")
	W.set_variable { name = "r_temp", rand = "1..$const.active_players" }
	W.set_variable { name = "r_temp", rand = "1..$r_temp" }
	for i = 1, r_temp do
		wesnoth.fire_event("create_mob_tough")
	end
	W.set_variable { name = "r_temp", rand = "$const.active_players..$(2*$const.active_players)" }
	for i = 1, r_temp do
		wesnoth.fire_event("create_mob_mook")
	end
	wesnoth.set_variable("dungeon_creation.temp.cluster_id", dungeon_creation.temp.cluster_id + 1)
	boss_clusters = boss_clusters - 1
end

while mini_clusters > 0 do
	W.set_variable { name = "r_temp", rand = "0,1,1" }
	wesnoth.set_variable("dungeon_creation.temp.mob_theme", dungeon_creation.temp.creep_themes[r_temp].theme)
	wesnoth.set_variable("dungeon_creation.temp.place_side", r_temp + const.max_player_count + 1)
	if r_temp == 0 then
		get_active_area("primary", 3)
	else
		get_active_area("secondary", 3)
	end
	get_mob_loc()
	get_cluster_level()
	W.set_variable { name = "r_temp", rand = "1..$const.active_players" }
	W.set_variable { name = "r_temp", rand = "1..$r_temp" }
	for i = 1, r_temp do
		wesnoth.fire_event("create_mob_tough")
	end
	W.set_variable { name = "r_temp", rand = "$const.active_players..$(2*$const.active_players)" }
	W.set_variable { name = "r_temp", rand = "$const.active_players..$r_temp" }
	for i = 1, r_temp do
		wesnoth.fire_event("create_mob_mook")
	end
	wesnoth.set_variable("dungeon_creation.temp.cluster_id", dungeon_creation.temp.cluster_id + 1)
	mini_clusters = mini_clusters - 1
end

local side_counter
while loners > 0 do
	getProb({
		variable = "dungeon_creation.temp.mob_theme",
		name = "dungeon_creation.temp.loner_themes",
		op = "rand"
	})
	if dungeon_creation.temp.mob_theme == dungeon_creation.temp.creep_themes[0].theme then
		wesnoth.set_variable("dungeon_creation.temp.place_side", const.max_player_count + 1)
		get_active_area("primary", 2)
	elseif dungeon_creation.temp.mob_theme == dungeon_creation.temp.creep_themes[1].theme then
		wesnoth.set_variable("dungeon_creation.temp.place_side", const.max_player_count + 2)
		get_active_area("secondary", 2)
	else
		side_counter = 2
		while dungeon_creation.temp.mob_theme ~= dungeon_creation.temp.creep_themes[side_counter].theme do
			side_counter = side_counter + 1
		end
		wesnoth.set_variable("dungeon_creation.temp.place_side", side_counter + const.max_player_count + 1)
		get_active_area("loner", 2)
	end
	get_mob_loc()
	get_cluster_level()
	wesnoth.fire_event("create_mob_loner")
	wesnoth.set_variable("dungeon_creation.temp.cluster_id", dungeon_creation.temp.cluster_id + 1)
	loners = loners - 1
end