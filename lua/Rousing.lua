function checkSafety(x, y)
	local rouse_list = wesnoth.get_variable("rouse_list")
	local safety
	if rouse_list then
		safety = not wesnoth.eval_conditional {
			{ "have_unit", {
				side = const.enemy_sides,
				{ "filter_location", { x = x, y = y, radius = 12 } },
				{ "and", {
					{ "not", {
						{ "filter_wml", {
							{ "status", { guardian = "yes" } }
						} }
					} },
					{ "or", {
						id = rouse_list
					} }
				} }
			} }
		}
	else
		safety = not wesnoth.eval_conditional {
			{ "have_unit", {
				side = const.enemy_sides,
				{ "filter_location", { x = x, y = y, radius = 12 } },
				{ "not", {
					{ "filter_wml", {
						{ "status", { guardian = "yes" } }
					} }
				} }
			} }
		}
	end
	return safety
end

function wesnoth.wml_actions.rouse_units(cfg)
	local x, y = cfg.x or H.wml_error("[rouse_units] expects an x= attribute"), cfg.y or H.wml_error("[rouse_units] expects a y= attribute")
	local min_index = -1
	local hidden = false
	local rouse_enemies
	local u = wesnoth.get_unit(x, y)
	if u then
		local v = u.variables.__cfg
		local a = H.get_child(v, "abilities")
		if a then
			if a.sneak == 1 and v.mobility == 2 and 2 * u.moves >= u.max_moves then
				hidden = true
			elseif v.mobility >= 1 then
				if a.ambush_forest == 1 then
					hidden = wesnoth.eval_conditional {
						{ "have_location", {
							x = x,
							y = y,
							terrain = "*^F*"
						} }
					}
				end
				if a.ambush_mountain == 1 and not hidden then
					hidden = wesnoth.eval_conditional {
						{ "have_location", {
							x = x,
							y = y,
							terrain = "M*,M*^*"
						} }
					}
				end
			end
			if not hidden and v.mobility >= 0 and a.nightstalk == 1 then
				hidden = wesnoth.eval_conditional {
					{ "have_location", {
						x = x,
						y = y,
						time_of_day = "chaotic"
					} }
				}
			end
			if hidden then
				hidden = not wesnoth.eval_conditional {
					{ "have_unit", {
						side = wesnoth.get_variable("const.enemy_sides"),
						{ "filter_adjacent", {
							x = x,
							y = y
						} }
					} }
				}
			end
		end
	end
	local rouse_list = wesnoth.get_variable("rouse_list")
	if not hidden then
		wesnoth.wml_actions.store_locations {
			variable = "rouse_temp_locs",
			x = x,
			y = y,
			radius = 12,
			{ "filter", {} }
		}
		if rouse_list then
			rouse_enemies = wesnoth.get_units( {
					side = const.enemy_sides,
					{ "filter_location", { find_in = "rouse_temp_locs" } },
					{ "filter_wml", {
						{ "status", { guardian = "yes" } }
					} },
					{ "not", {
						id = rouse_list
					} }
				} )
		else
			rouse_enemies = wesnoth.get_units( {
					side = const.enemy_sides,
					{ "filter_location", { find_in = "rouse_temp_locs" } },
					{ "filter_wml", {
						{ "status", { guardian = "yes" } }
					} }
				} )
		end
		local dist = 14
		local min_dist = 13
		for i, u in ipairs(rouse_enemies) do
			dist = H.distance_between(x, y, u.x, u.y)
			if dist <= (u.max_moves + 1) then
				local target_cost = u.max_moves + wesnoth.unit_movement_cost(u, wesnoth.get_terrain(x, y))
				local path, cost
				if target_cost > 99 then
					-- find_path gives unhelpful results if you're standing where the enemy can't be moved to
					-- so have to check each adjacent hex individually in that case
					target_cost = u.max_moves
					path, cost = wesnoth.find_path(u, x, y + 1, { ignore_units = true, viewing_side = 0 })
					if cost > target_cost then
						path, cost = wesnoth.find_path(u, x, y - 1, { ignore_units = true, viewing_side = 0 })
						if cost > target_cost then
							path, cost = wesnoth.find_path(u, x + 1, y - x % 2, { ignore_units = true, viewing_side = 0 })
							if cost > target_cost then
								path, cost = wesnoth.find_path(u, x - 1, y - x % 2, { ignore_units = true, viewing_side = 0 })
								if cost > target_cost then
									path, cost = wesnoth.find_path(u, x + 1, y + 1 - x % 2, { ignore_units = true, viewing_side = 0 })
									if cost > target_cost then
										path, cost = wesnoth.find_path(u, x - 1, y + 1 - x % 2, { ignore_units = true, viewing_side = 0 })
									end
								end
							end
						end
					end
				else
					path, cost = wesnoth.find_path(u, x, y, { ignore_units = true, viewing_side = 0 })
				end
				if cost <= target_cost then
					if rouse_list then
						rouse_list = string.format("%s,%s", rouse_list, u.id)
					else
						rouse_list = u.id
					end
					wesnoth.wml_actions.store_locations {
						variable = "rouse_temp_locs",
						x = u.x,
						y = u.y,
						radius = u.max_moves,
						{ "filter", {} }
					}
					local rouse_enemies_near = wesnoth.get_units( {
							side = u.side,
							{ "filter_location", { find_in = "rouse_temp_locs" } },
							{ "filter_wml", {
								{ "status", { guardian = "yes" } }
							} },
							{ "not", {
								id = rouse_list
							} }
						} )
					for j, v in ipairs(rouse_enemies_near) do
						rouse_list = string.format("%s,%s", rouse_list, v.id)
					end
					if dist < min_dist then
						min_dist = dist
						min_index = i
					end
				end
			end
		end
	end
	if min_index > -1 then
		wesnoth.set_variable("rouse_list", rouse_list)
		local visible = wesnoth.get_units( {
				id = rouse_enemies[min_index].id,
				{ "filter_vision", { viewing_side = side_number } }
			} )
		if visible[1] then
			wesnoth.fire_event("spot", x, y, visible[1].x, visible[1].y)
		else
			wesnoth.fire_event("hear", x, y)
		end
	elseif cfg.refresh and u and checkSafety(x, y) and u.side == wesnoth.current.side and u.attacks_left > 0 and u.variables.simple_action and u.variables.simple_action > 0 then
		u.moves = u.max_moves
	end
	wesnoth.set_variable("rouse_temp_locs")
end