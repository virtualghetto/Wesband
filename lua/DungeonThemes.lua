local _ = wesnoth.textdomain "wesnoth-Wesband"

W.set_variable { name = "dungeon_creation.temp.flow_type", rand = "1..25" }
wml.variables['dungeon_creation.temp.pool_flavor'] = "Ww"
W.set_variable { name = "r_temp", rand = "0..6" }
if wml.variables['r_temp'] < wml.variables['dungeon_level.current'] then
	W.set_variable { name = "r_temp", rand = "0..2" }
	if wml.variables['r_temp'] ~= 0 then
		wml.variables['dungeon_creation.temp.pool_flavor'] = "Ss"
	end
end
W.set_variable { name = "r_temp", rand = "6..14" }
if wml.variables['r_temp'] < wml.variables['dungeon_level.current'] then
	W.set_variable { name = "r_temp", rand = "0..2" }
	if wml.variables['r_temp'] == 1 then
		wml.variables['dungeon_creation.temp.pool_flavor'] = "Ql"
	elseif wml.variables['r_temp'] == 2 then
		wml.variables['dungeon_creation.temp.pool_flavor'] = "Qlf"
	end
end
wml.variables['dungeon_creation.temp.flow_flavor'] = wml.variables['dungeon_creation.temp.pool_flavor']
W.set_variable { name = "r_temp", rand = "4..9" }
if wml.variables['r_temp'] < wml.variables['dungeon_level.current'] then
	W.set_variable { name = "r_temp", rand = "0..2" }
	if wml.variables['r_temp'] == 0 then
		wml.variables['dungeon_creation.temp.flow_flavor'] = "Qxu"
	end
end
W.set_variable { name = "dungeon_creation.temp.wall_flavor", rand = "Xu,Xu,Xos" }
wesnoth.wml_actions.get_prob({
	variable = "dungeon_creation.temp.terrain_variation",
	name = "dungeon_creation.terrains",
	op = "rand"
})
W.set_variables {
		name = "dungeon_creation.temp.prob_list",
		to_variable = "dungeon_creation.cluster_themes"
	}
W.set_variables {
		name = "dungeon_creation.temp.loner_themes",
		to_variable = "dungeon_creation.loner_themes"
	}
W.set_variable { name = "dungeon_creation.temp.crawly_theme", rand = "cave,slime" }
if wml.variables['dungeon_creation.temp.terrain_variation'] == "Wwf" then
	if wml.variables['dungeon_creation.water_level_counter'] < 2 then
		wml.variables['dungeon_creation.water_level_counter'] = wml.variables['dungeon_creation.water_level_counter'] + 1
		wml.variables['dungeon_creation.temp.terrain_variation'] = "Ur"
	else
		wml.variables['dungeon_creation.temp.crawly_theme'] = "water"
		wesnoth.wml_actions.set_prob({
			name = "dungeon_creation.temp.loner_themes",
			item = "water",
			weight = 200,
			op = "set"
		})
		wesnoth.wml_actions.set_prob({
			name = "dungeon_creation.temp.loner_themes",
			item = "naga",
			weight = 200,
			op = "set"
		})
		wesnoth.wml_actions.set_prob({
			name = "dungeon_creation.temp.loner_themes",
			item = "saurian",
			weight = 200,
			op = "set"
		})
		wesnoth.wml_actions.set_prob({
			name = "dungeon_creation.temp.prob_list",
			item = "water",
			weight = 400,
			op = "set"
		})
		wesnoth.wml_actions.set_prob({
			name = "dungeon_creation.temp.prob_list",
			item = "saurian",
			weight = 800,
			op = "set"
		})
		wml.variables['dungeon_creation.water_level_counter'] = 0
	end
elseif wml.variables['dungeon_creation.temp.terrain_variation'] == "Rd" or wml.variables['dungeon_creation.temp.terrain_variation'] == "Re" or wml.variables['dungeon_creation.temp.terrain_variation'] == "Ryc" then
	wesnoth.wml_actions.set_prob({
		name = "dungeon_creation.temp.prob_list",
		item = "outlaws",
		weight = 100,
		op = "add"
	})
end
wesnoth.wml_actions.get_prob({
	variable = "dungeon_creation.temp.creep_themes[0].theme",
	name = "dungeon_creation.temp.prob_list",
	op = "rand"
})
wesnoth.wml_actions.set_prob({
	name = "dungeon_creation.temp.prob_list",
	item = wml.variables['dungeon_creation.temp.creep_themes[0].theme'],
	op = "clear"
})
if wml.variables['dungeon_creation.temp.creep_themes[0].theme'] ~= wml.variables['dungeon_creation.temp.crawly_theme'] then
	wesnoth.wml_actions.set_prob({
		name = "dungeon_creation.temp.prob_list",
		item = wml.variables['dungeon_creation.temp.crawly_theme'],
		weight = 300,
		op = "scale"
	})
end
wesnoth.wml_actions.get_prob({
	variable = "dungeon_creation.temp.creep_themes[1].theme",
	name = "dungeon_creation.temp.prob_list",
	op = "rand"
})
W.set_variables {
		name="dungeon_creation.temp.prob_list",
		mode="replace",
		to_variable="dungeon_creation.loner_themes"
	}
wesnoth.wml_actions.set_prob({
	name = "dungeon_creation.temp.prob_list",
	item = wml.variables['dungeon_creation.temp.creep_themes[0].theme'],
	op = "clear"
})
wesnoth.wml_actions.set_prob({
	name = "dungeon_creation.temp.prob_list",
	item = wml.variables['dungeon_creation.temp.creep_themes[1].theme'],
	op = "clear"
})
wml.variables['dungeon_creation.temp.water_theme_position'] = -1
if wml.variables['dungeon_creation.temp.creep_themes[0].theme'] == "water" then
	wml.variables['dungeon_creation.temp.water_theme_position'] = 0
elseif wml.variables['dungeon_creation.temp.creep_themes[1].theme'] == "water" then
	wml.variables['dungeon_creation.temp.water_theme_position'] = 1
else
	W.clear_variable { name = "terrain_match" }
	W.store_locations {
			terrain = "Ai",
			variable = "terrain_match"
		}
	if wml.variables['dungeon_creation.temp.terrain_variation'] == "Wwf" or (wml.variables['dungeon_creation.temp.flow_flavor'] == "" and wml.variables['dungeon_creation.temp.flow_type'] < 11) or wml.variables['terrain_match'] then
		--W.set_variable { name = "dungeon_creation.temp.water_theme_position", rand = "2..$($const.max_enemy_count-1)" }
		W.set_variable { name = "dungeon_creation.temp.water_theme_position", rand = string.format("2..%d", wml.variables['const.max_enemy_count'] -1) }
		wesnoth.wml_actions.set_prob({
			name = "dungeon_creation.temp.prob_list",
			item = "water",
			op = "clear"
		})
		W.clear_variable { name = "terrain_match" }
	end
end
for i = 2, wml.variables['const.max_enemy_count'] - 1 do
	if i == wml.variables['dungeon_creation.temp.water_theme_position'] then
		wml.variables[string.format("dungeon_creation.temp.creep_themes[%i].theme", i)] = "water"
	elseif wml.variables['dungeon_creation.temp.prob_list.total_count'] == 0 then
		if i < wml.variables['dungeon_creation.temp.water_theme_position'] then
			wml.variables[string.format("dungeon_creation.temp.creep_themes[%i].theme", i)] = "water"
			wml.variables['dungeon_creation.temp.water_theme_position'] = i
		else
			wml.variables[("dungeon_creation.temp.creep_themes[%d].theme"):format(i)] = string.format("nullTheme%i", i)
		end
	else
		wesnoth.wml_actions.get_prob({
			variable = string.format("dungeon_creation.temp.creep_themes[%i].theme", i),
			name = "dungeon_creation.temp.prob_list",
			op = "rand"
		})
		wesnoth.wml_actions.set_prob({
			name = "dungeon_creation.temp.prob_list",
			item = wml.variables[("dungeon_creation.temp.creep_themes[%d].theme"):format(i)],
			op = "clear"
		})
	end
end
 wml.variables['dungeon_creation.temp.water_theme_position'] =  wml.variables['dungeon_creation.temp.water_theme_position'] + 1 +  wml.variables['const.max_player_count']
for i = 0,  wml.variables['const.max_enemy_count'] - 1 do
	wml.variables[string.format("dungeon_creation.active_themes[%i].theme", i)] = wml.variables[("dungeon_creation.temp.creep_themes[%d].theme"):format(i)]
	if  wml.variables[("dungeon_creation.temp.creep_themes[%d].theme"):format(i)] == "water" then
		W.modify_side {
				side = i + 1 +  wml.variables['const.max_player_count'],
				team_name =  wml.variables['dungeon_creation.alliances.water'],
				user_team_name = _ "Water Dwellers"
			}
	elseif  wml.variables[("dungeon_creation.temp.creep_themes[%d].theme"):format(i)] == "orcs" then
		W.modify_side {
				side = i + 1 +  wml.variables['const.max_player_count'],
				team_name =  wml.variables['dungeon_creation.alliances.orcs'],
				user_team_name = _ "Orcish Tribes"
			}
	elseif  wml.variables[("dungeon_creation.temp.creep_themes[%d].theme"):format(i)] == "outlaws" then
		W.modify_side {
				side = i + 1 + wml.variables['const.max_player_count'],
				team_name = wml.variables['dungeon_creation.alliances.outlaws'],
				user_team_name = _ "Outlaw Band"
			}
	elseif wml.variables[("dungeon_creation.temp.creep_themes[%d].theme"):format(i)] == "undead" then
		W.modify_side {
				side = i + 1 + wml.variables['const.max_player_count'],
				team_name = wml.variables['dungeon_creation.alliances.undead'],
				user_team_name = _ "Undead Hordes"
			}
	elseif wml.variables[("dungeon_creation.temp.creep_themes[%d].theme"):format(i)] == "planar" then
		W.modify_side {
				side = i + 1 + wml.variables['const.max_player_count'],
				team_name = wml.variables['dungeon_creation.alliances.planar'],
				user_team_name = _ "Planar Beings"
			}
	elseif wml.variables[("dungeon_creation.temp.creep_themes[%d].theme"):format(i)] == "cave" then
		W.modify_side {
				side = i + 1 + wml.variables['const.max_player_count'],
				team_name = wml.variables['dungeon_creation.alliances.cave'],
				user_team_name = _ "Cavern Dwellers"
			}
	elseif wml.variables[("dungeon_creation.temp.creep_themes[%d].theme"):format(i)] == "dark" then
		W.modify_side {
				side = i + 1 + wml.variables['const.max_player_count'],
				team_name = wml.variables['dungeon_creation.alliances.dark'],
				user_team_name = _ "Dwellers in Darkness"
			}
	elseif wml.variables[("dungeon_creation.temp.creep_themes[%d].theme"):format(i)] == "slime" then
		W.modify_side {
				side = i + 1 + wml.variables['const.max_player_count'],
				team_name = wml.variables['dungeon_creation.alliances.slime'],
				user_team_name = _ "Creeping Ooze"
			}
	elseif wml.variables[("dungeon_creation.temp.creep_themes[%d].theme"):format(i)] == "naga" then
		W.modify_side {
				side = i + 1 + wml.variables['const.max_player_count'],
				team_name = wml.variables['dungeon_creation.alliances.naga'],
				user_team_name = _ "Naga Warriors"
			}
	elseif wml.variables[("dungeon_creation.temp.creep_themes[%d].theme"):format(i)] == "saurian" then
		W.modify_side {
				side = i + 1 + wml.variables['const.max_player_count'],
				team_name = wml.variables['dungeon_creation.alliances.saurian'],
				user_team_name = _ "Saurian Tribes"
			}
	else
		W.modify_side {
				side = i + 1 + wml.variables['const.max_player_count'],
				user_team_name = _ "None"
			}
	end
end
if wml.variables['dungeon_creation.temp.loner_themes.total_weight'] > 0 and wml.variables['dungeon_creation.temp.prob_list.total_weight'] > 0 then
	wesnoth.wml_actions.set_prob({
		name = "dungeon_creation.temp.loner_themes",
		with_list = "dungeon_creation.temp.prob_list",
		op = "diff"
	})
end
