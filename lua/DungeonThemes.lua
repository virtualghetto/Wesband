W.set_variable { name = "dungeon_creation.temp.flow_type", rand = "1..25" }
dungeon_creation.temp.pool_flavor = "Ww"
W.set_variable { name = "r_temp", rand = "0..6" }
if r_temp < dungeon_level.current then
	W.set_variable { name = "r_temp", rand = "0..2" }
	if r_temp ~= 0 then
		dungeon_creation.temp.pool_flavor = "Ss"
	end
end
W.set_variable { name = "r_temp", rand = "6..14" }
if r_temp < dungeon_level.current then
	W.set_variable { name = "r_temp", rand = "0..2" }
	if r_temp == 1 then
		dungeon_creation.temp.pool_flavor = "Ql"
	elseif r_tmep == 2 then
		dungeon_creation.temp.pool_flavor = "Qlf"
	end
end
dungeon_creation.temp.flow_flavor = dungeon_creation.temp.pool_flavor
W.set_variable { name = "r_temp", rand = "4..9" }
if r_temp < dungeon_level.current then
	W.set_variable { name = "r_temp", rand = "0..2" }
	if r_temp == 0 then
		dungeon_creation.temp.flow_flavor = "Qxu"
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
if dungeon_creation.temp.terrain_variation == "Wwf" then
	if dungeon_creation.water_level_counter < 2 then
		dungeon_creation.water_level_counter = dungeon_creation.water_level_counter + 1
		dungeon_creation.temp.terrain_variation = "Ur"
	else
		dungeon_creation.temp.crawly_theme = "water"
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
		dungeon_creation.water_level_counter = 0
	end
elseif dungeon_creation.temp.terrain_variation == "Rd" or dungeon_creation.temp.terrain_variation == "Re" or dungeon_creation.temp.terrain_variation == "Ryc" then
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
	item = dungeon_creation.temp.creep_themes[0].theme,
	op = "clear"
})
if dungeon_creation.temp.creep_themes[0].theme ~= dungeon_creation.temp.crawly_theme then
	wesnoth.wml_actions.set_prob({
		name = "dungeon_creation.temp.prob_list",
		item = dungeon_creation.temp.crawly_theme,
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
	item = dungeon_creation.temp.creep_themes[0].theme,
	op = "clear"
})
wesnoth.wml_actions.set_prob({
	name = "dungeon_creation.temp.prob_list",
	item = dungeon_creation.temp.creep_themes[1].theme,
	op = "clear"
})
dungeon_creation.temp.water_theme_position = -1
if dungeon_creation.temp.creep_themes[0].theme == "water" then
	dungeon_creation.temp.water_theme_position = 0
elseif dungeon_creation.temp.creep_themes[1].theme == "water" then
	dungeon_creation.temp.water_theme_position = 1
else
	W.clear_variable { name = "terrain_match" }
	W.store_locations {
			terrain = "Ai",
			variable = "terrain_match"
		}
	if dungeon_creation.temp.terrain_variation == "Wwf" or (dungeon_creation.temp.flow_flavor == "" and dungeon_creation.temp.flow_type < 11) or terrain_match then
		W.set_variable { name = "dungeon_creation.temp.water_theme_position", rand = "2..$($const.max_enemy_count-1)" }
		wesnoth.wml_actions.set_prob({
			name = "dungeon_creation.temp.prob_list",
			item = "water",
			op = "clear"
		})
		W.clear_variable { name = "terrain_match" }
	end
end
for i = 2, const.max_enemy_count - 1 do
	if i == dungeon_creation.temp.water_theme_position then
		wesnoth.set_variable(string.format("dungeon_creation.temp.creep_themes[%i].theme", i), "water")
	elseif dungeon_creation.temp.prob_list.total_count == 0 then
		if i < dungeon_creation.temp.water_theme_position then
			wesnoth.set_variable(string.format("dungeon_creation.temp.creep_themes[%i].theme", i), "water")
			dungeon_creation.temp.water_theme_position = i
		else
			dungeon_creation.temp.creep_themes[i].theme = string.format("nullTheme%i", i)
		end
	else
		wesnoth.wml_actions.get_prob({
			variable = string.format("dungeon_creation.temp.creep_themes[%i].theme", i),
			name = "dungeon_creation.temp.prob_list",
			op = "rand"
		})
		wesnoth.wml_actions.set_prob({
			name = "dungeon_creation.temp.prob_list",
			item = dungeon_creation.temp.creep_themes[i].theme,
			op = "clear"
		})
	end
end
dungeon_creation.temp.water_theme_position = dungeon_creation.temp.water_theme_position + 1 + const.max_player_count
for i = 0, const.max_enemy_count - 1 do
	wesnoth.set_variable(string.format("dungeon_creation.active_themes[%i].theme", i), dungeon_creation.temp.creep_themes[i].theme)
	if dungeon_creation.temp.creep_themes[i].theme == "water" then
		W.modify_side {
				side = i + 1 + const.max_player_count,
				team_name = dungeon_creation.alliances.water,
				user_team_name = _ "Water Dwellers"
			}
	elseif dungeon_creation.temp.creep_themes[i].theme == "orcs" then
		W.modify_side {
				side = i + 1 + const.max_player_count,
				team_name = dungeon_creation.alliances.orcs,
				user_team_name = _ "Orcish Tribes"
			}
	elseif dungeon_creation.temp.creep_themes[i].theme == "outlaws" then
		W.modify_side {
				side = i + 1 + const.max_player_count,
				team_name = dungeon_creation.alliances.outlaws,
				user_team_name = _ "Outlaw Band"
			}
	elseif dungeon_creation.temp.creep_themes[i].theme == "undead" then
		W.modify_side {
				side = i + 1 + const.max_player_count,
				team_name = dungeon_creation.alliances.undead,
				user_team_name = _ "Undead Hordes"
			}
	elseif dungeon_creation.temp.creep_themes[i].theme == "planar" then
		W.modify_side {
				side = i + 1 + const.max_player_count,
				team_name = dungeon_creation.alliances.planar,
				user_team_name = _ "Planar Beings"
			}
	elseif dungeon_creation.temp.creep_themes[i].theme == "cave" then
		W.modify_side {
				side = i + 1 + const.max_player_count,
				team_name = dungeon_creation.alliances.cave,
				user_team_name = _ "Cavern Dwellers"
			}
	elseif dungeon_creation.temp.creep_themes[i].theme == "dark" then
		W.modify_side {
				side = i + 1 + const.max_player_count,
				team_name = dungeon_creation.alliances.dark,
				user_team_name = _ "Dwellers in Darkness"
			}
	elseif dungeon_creation.temp.creep_themes[i].theme == "slime" then
		W.modify_side {
				side = i + 1 + const.max_player_count,
				team_name = dungeon_creation.alliances.slime,
				user_team_name = _ "Creeping Ooze"
			}
	elseif dungeon_creation.temp.creep_themes[i].theme == "naga" then
		W.modify_side {
				side = i + 1 + const.max_player_count,
				team_name = dungeon_creation.alliances.naga,
				user_team_name = _ "Naga Warriors"
			}
	elseif dungeon_creation.temp.creep_themes[i].theme == "saurian" then
		W.modify_side {
				side = i + 1 + const.max_player_count,
				team_name = dungeon_creation.alliances.saurian,
				user_team_name = _ "Saurian Tribes"
			}
	else
		W.modify_side {
				side = i + 1 + const.max_player_count,
				user_team_name = _ "None"
			}
	end
end
if dungeon_creation.temp.loner_themes.total_weight > 0 and dungeon_creation.temp.prob_list.total_weight > 0 then
	wesnoth.wml_actions.set_prob({
		name = "dungeon_creation.temp.loner_themes",
		with_list = "dungeon_creation.temp.prob_list",
		op = "diff"
	})
end