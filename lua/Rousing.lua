function checkSafety(x, y)
	if wesnoth.eval_conditional {
		{"have_unit", {
			side = const.enemy_sides,
			{ "filter_location", { x = x, y = y, radius = 12 } },
			{ "not", {
				{ "filter_wml", {
					{ "status", { guardian = "yes" } }
				} }
			} }
		} }
	} then
		return false
	elseif rouse_list then
		for i = 0, rouse_list.length - 1 do
			if wesnoth.eval_conditional {
				{"have_unit", {
					id = rouse_list[i].id,
					{ "filter_location", { x = x, y = y, radius = 12 } }
				} }
			} then
				return false
			end
		end
	end
	return true
end

function rouseUnits()
	local min_index = -1
	local hidden = false
	local rouse_enemies
	local u = wesnoth.get_units( {
			x = x1,
			y = y1
		} )[1]
	local v = H.get_child(u.__cfg, "variables")
	local a = H.get_child(v, "abilities")
	if a then
		if a.sneak == 1 and v.mobility == 2 and 2 * u.moves >= u.max_moves then
			hidden = true
		elseif v.mobility >= 1 then
			if a.ambush_forest == 1 then
				hidden = wesnoth.eval_conditional {
					{"have_location", {
						x = x1,
						y = y1,
						terrain = "*^F*"
					}}
				}
			end
			if a.ambush_mountain == 1 and not hidden then
				hidden = wesnoth.eval_conditional {
					{"have_location", {
						x = x1,
						y = y1,
						terrain = "M*,M*^*"
					}}
				}
			end
		end
		if not hidden and v.mobility >=0 and a.nightstalk == 1 then
			hidden = wesnoth.eval_conditional {
				{"have_location", {
					x = x1,
					y = y1,
					time_of_day = "chaotic"
				}}
			}
		end
		if hidden then
			local adj_enemies = wesnoth.get_units( {
				side = const.enemy_sides,
				{ "filter_location", { x = x1, y = y1, radius = 1 } },
			} )
			if adj_enemies[1] then
				hidden = false
			end
		end
	end
	if not hidden then
		rouse_enemies = wesnoth.get_units( {
				side = const.enemy_sides,
				{ "filter_location", { x = x1, y = y1, radius = 12 } },
				{ "filter_wml", {
					{ "status", { guardian = "yes" } }
				} }
			} )
		local dist = 14
		local min_dist = 13
		for i, u in ipairs(rouse_enemies) do
			local unflagged_id = true
			if rouse_list then
				for j = 0, rouse_list.length - 1 do
					if (rouse_list[j].id == u.id) then
						unflagged_id = false
						break
					end
				end
			end
			if unflagged_id then
				dist = H.distance_between(x1, y1, u.x, u.y)
				if dist <= (u.max_moves + 1) then
					local target_cost = u.max_moves + wesnoth.unit_movement_cost(u, wesnoth.get_terrain(x1, y1))
					local path, cost
					if target_cost > 99 then
						-- find_path gives unhelpful results if you're standing where the enemy can't be moved to
						-- so have to check each adjacent hex individually in that case
						target_cost = u.max_moves
						path, cost = wesnoth.find_path(u, x1, y1 + 1, { ignore_units = true, viewing_side = 0 })
						if cost > target_cost then
							path, cost = wesnoth.find_path(u, x1, y1 - 1, { ignore_units = true, viewing_side = 0 })
							if cost > target_cost then
								path, cost = wesnoth.find_path(u, x1 + 1, y1 - x1 % 2, { ignore_units = true, viewing_side = 0 })
								if cost > target_cost then
									path, cost = wesnoth.find_path(u, x1 - 1, y1 - x1 % 2, { ignore_units = true, viewing_side = 0 })
									if cost > target_cost then
										path, cost = wesnoth.find_path(u, x1 + 1, y1 + 1 - x1 % 2, { ignore_units = true, viewing_side = 0 })
										if cost > target_cost then
											path, cost = wesnoth.find_path(u, x1 - 1, y1 + 1 - x1 % 2, { ignore_units = true, viewing_side = 0 })
										end
									end
								end
							end
						end
					else
						path, cost = wesnoth.find_path(u, x1, y1, { ignore_units = true, viewing_side = 0 })
					end
					if cost <= target_cost then
						if just_roused then
							for j = 0, just_roused.length - 1 do
								if (just_roused[j].id == u.id) then
									unflagged_id = false
									break
								end
							end
						end
						if unflagged_id then
							W.set_variables {
									name = "just_roused",
									mode = "append",
									{ "value", { id = u.id } }
								}
						end
						local rouse_enemies_near = wesnoth.get_units( {
								side = u.side,
								{ "filter_location", {
										x = u.x, y = u.y, radius = u.max_moves
									} },
								{ "filter_wml", {
									{ "status", { guardian = "yes" } }
								} }
							} )
						for j, v in ipairs(rouse_enemies_near) do
							unflagged_id = true
							if rouse_list then
								for k = 0, rouse_list.length - 1 do
									if (rouse_list[k].id == v.id) then
										unflagged_id = false
										break
									end
								end
							end
							if just_roused then
								for k = 0, just_roused.length - 1 do
									if (just_roused[k].id == v.id) then
										unflagged_id = false
										break
									end
								end
							end
							if unflagged_id then
								W.set_variables {
										name = "just_roused",
										mode = "append",
										{ "value", { id = v.id } }
									}
							end
						end
						if dist < min_dist then
							min_dist = dist
							min_index = i
						end
					end
				end
			end
		end
	end
	if min_index > -1 then
		W.set_variables {
				name = "rouse_list",
				mode = "append",
				to_variable = "just_roused"
			}
		W.clear_variable { name = "just_roused" }
		local visible = wesnoth.get_units( {
				id = rouse_enemies[min_index].id,
				{ "filter_vision", { viewing_side = side_number } }
			} )
		if visible[1] then
			wesnoth.fire_event("spot", x1, y1, visible[1].x, visible[1].y)
		else
			wesnoth.fire_event("hear", x1, y1)
		end
	else
		if checkSafety(x1, y1) then
			wesnoth.fire_event("refresh moves", x1, y1)
		end
	end
end