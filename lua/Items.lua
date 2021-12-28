local function lappend(l, st)
	local res = ""
	if #st > 0 then
		res = l .. st
	end
	return res
end

local function sappend(st1, s, st2)
	local res
	if #st2 > 0 then
		if #st1 > 0 then
			res = st1 .. s .. st2
		else
			res = st2
		end
	else
		res = st1
	end
	return res
end

local function cappend(st1, st2)
	return sappend(st1, ", ", st2)
end

function adjustWeaponDescription(wt)
	if wt.evade_adjust and wt.evade_adjust < 0 then
		wt.evade_description = string.format(", Evade Adjust: %d", wt.evade_adjust)
	end
	local st1, st2, st3 = "", "", ""
	if wt.class == "thunderstick" then
		st1 = "requires thunderstick tinker for upkeep and upgrade"
	end
	local sp = wml.get_child(wt, "special_type")
	if sp then
		if sp.throwable and sp.throwable == 1 then
			st1 = cappend(st1, "throwable")
		end
		if sp.firststrike and sp.firststrike == 1 then
			st1 = cappend(st1, "allows firststrike")
		end
		if sp.allow_poison and sp.allow_poison == 1 then
			st1 = cappend(st1, "allows poisoning")
		end
		if sp.marksman and sp.marksman == 1 then
			st1 = cappend(st1, "allows marksman")
		end
		if sp.backstab and sp.backstab == 1 then
			st1 = cappend(st1, "allows backstab")
		end
		if (sp.fire_shot_bow and sp.fire_shot_bow == 1) or (sp.fire_shot_xbow and sp.fire_shot_xbow == 1) then
			st1 = cappend(st1, "allows fire shot")
		end
		if sp.goliath_bane and sp.goliath_bane == 1 then
			st1 = cappend(st1, "allows goliath bane")
		end
		if (sp.remaining_ammo_thrown_heavy_blade and sp.remaining_ammo_thrown_heavy_blade == 1) or (sp.remaining_ammo_thrown_light_blade and sp.remaining_ammo_thrown_light_blade == 1) or (sp.remaining_ammo_javelin and sp.remaining_ammo_javelin == 1) or (sp.remaining_ammo_bow and sp.remaining_ammo_bow == 1) then
			st1 = cappend(st1, "allows remaining ammo")
		end
		if sp.readied_bolt and sp.readied_bolt == 1 then
			st1 = cappend(st1, "allows readied bolt")
		end
		if sp.ensnare and sp.ensnare == 1 then
			st1 = cappend(st1, "allows ensnare")
		end
		if sp.slashdash and sp.slashdash == 1 then
			st1 = cappend(st1, "allows slash+dash")
		end
		if sp.riposte and sp.riposte == 1 then
			st1 = cappend(st1, "allows riposte")
		end
		if sp.storm and sp.storm == 1 then
			st1 = cappend(st1, "allows storm")
		end
		if sp.cleave and sp.cleave == 1 then
			st1 = cappend(st1, "allows cleave")
		end
	end
	if wt.human_magic_adjust > 0 then
		st1 = cappend(st1, string.format("%d%% to human magic", wt.human_magic_adjust))
	end
	if wt.dark_magic_adjust > 0 then
		st1 = cappend(st1, string.format("%d%% to dark magic", wt.dark_magic_adjust))
	end
	if wt.faerie_magic_adjust > 0 then
		st1 = cappend(st1, string.format("%d%% to faerie magic", wt.faerie_magic_adjust))
	end
	if wt.runic_magic_adjust > 0 then
		st1 = cappend(st1, string.format("%d%% to runic magic", wt.runic_magic_adjust))
	end
	if wt.spirit_magic_adjust > 0 then
		st1 = cappend(st1, string.format("%d%% to spirit magic", wt.spirit_magic_adjust))
	end
	if wt.body_damage_rate and wt.body_damage_rate > 0 then
		st2 = string.format("%d%% body", wt.body_damage_rate)
	end
	if wt.deft_damage_rate and wt.deft_damage_rate > 0 then
		st2 = cappend(st2, string.format("%d%% deft", wt.deft_damage_rate))
	end
	if wt.mind_damage_rate and wt.mind_damage_rate > 0 then
		st2 = cappend(st2, string.format("%d%% mind", wt.mind_damage_rate))
	end
	st2 = lappend("Damage: ", st2)
	if wt.body_number_rate and wt.body_number_rate > 0 then
		st3 = string.format("%d%% body", wt.body_number_rate)
	end
	if wt.deft_number_rate and wt.deft_number_rate > 0 then
		st3 = cappend(st3, string.format("%d%% deft", wt.deft_number_rate))
	end
	if wt.mind_number_rate and wt.mind_number_rate > 0 then
		st3 = cappend(st3, string.format("%d%% mind", wt.mind_number_rate))
	end
	st3 = lappend("Strikes: ", st3)
	st2 = sappend(st2, "; ", st3)
	st1 = sappend(st1, "\n", st2)
	st2 = ""
	local pr = wml.get_child(wt, "prereq")
	if pr then
		if pr.body and pr.body > 0 then
			st2 = string.format("%d body", pr.body)
		end
		if pr.deft and pr.deft > 0 then
			st2 = cappend(st2, string.format("%d deft", pr.deft))
		end
		if pr.mind and pr.mind > 0 then
			st2 = cappend(st2, string.format("%d mind", pr.mind))
		end
	end
	st2 = lappend("Requires: ", st2)
	if wt.class == "polearm" then
		st1 = sappend(st1, "\n", st2)
	else
		st1 = sappend(st1, "; ", st2)
	end
	wt.special = st1
	return wt
end
function wesnoth.wml_actions.adjust_weapon_description(args)
	local var = string.match(args.variable, "[^%s]+") or H.wml_error("[adjust_weapon_description] requires a variable= key")
	wml.variables[var] = adjustWeaponDescription(wml.variables[var])
end

local function adjustArmorDescription(at)
	at.special = ""
	if at.block_wield then
		if at.block_wield == 1 then
			at.special = "disallows triple wield"
		elseif at.block_wield == 2 then
			at.special = "disallows dual wield"
		end
	end
	if at.block_ranged and at.block_ranged == 1 then
		at.special = cappend(at.special, "disallows ranged weapon")
	end
	local sp = wml.get_child(at, "special_type")
	if sp and sp.steadfast and sp.steadfast == 1 then
		at.special = cappend(at.special, "allows steadfast")
	end
	return at
end
function wesnoth.wml_actions.adjust_armor_description(args)
	local var = string.match(args.variable, "[^%s]+") or H.wml_error("[adjust_armor_description] requires a variable= key")
	wml.variables[var] = adjustArmorDescription(wml.variables[var])
end

local function createWeapon(wtype, rank, attr, var)
	if attr == "random" then
		W.set_variable { name = "r_temp", rand = "rusty,unbalanced,none,none,none,none,none,none,heavy,sharp,light,balanced" }
		attr = wml.variables['r_temp']
		W.clear_variable { name = "r_temp" }
	end

	local rank_frac = rank * 0.1 + 1
	rank = math.floor((rank * 5 + 6) / 12)

	local function adjustCoreStats(wt)
		if wt.range == "melee" then
			wt.category = "melee_weapon"
		end
		if wt.range == "ranged" then
			wt.category = "ranged_weapon"
		end
		wt.category = wt.category or "melee_weapon"
		if wt.category == "melee_weapon" then
			wt.range = wt.range or "melee"
			wt.evade_adjust = wt.evade_adjust or 0
		else
			wt.range = wt.range or "ranged"
		end

		wt.number = wt.number or 1
		if wt.number == 0 then
			wt.damage = wt.damage + 2 * rank
		elseif wt.number == 1 then
			wt.damage = wt.damage + rank
		else
			local n = math.floor(rank / 4)
			wt.number = wt.number + n
			wt.damage = wt.damage + rank - n
		end

		if attr == "rusty" then
			wt.damage = math.floor(wt.damage * 0.7 + 0.5)
		elseif attr == "unbalanced" then
			if wt.evade_adjust then
				wt.evade_adjust = wt.evade_adjust - 1
			end
			wt.damage = math.floor(wt.damage * 0.8 + 0.5)
			wt.number = math.max(1, wt.number - 1)
		elseif attr == "heavy" then
			if wt.evade_adjust then
				wt.evade_adjust = wt.evade_adjust - 1
			end
			wt.damage = math.floor(wt.damage * 1.7 + 0.5)
			wt.number = math.max(1, wt.number - 1)
		elseif attr == "light" then
			if wt.evade_adjust then
				wt.evade_adjust = math.min(0, wt.evade_adjust + 1)
			end
			wt.damage = math.floor(wt.damage * 0.5 + 0.5)
			wt.number = wt.number + 1
		elseif attr == "sharp" then
			wt.damage = math.floor(wt.damage * 1.3 + 0.5)
		elseif attr == "balanced" then
			if wt.evade_adjust then
				wt.evade_adjust = math.min(0, wt.evade_adjust + 1)
			end
			wt.damage = math.floor(wt.damage * 0.8 + 0.5)
			wt.number = wt.number + 1
		elseif attr ~= "none" then
			H.wml_error(string.format("invalid attribute= key in [create_weapon]: %s", attr))
		end

		wt.body_damage_rate = wt.body_damage_rate or 0
		wt.deft_damage_rate = wt.deft_damage_rate or 0
		wt.body_number_rate = wt.body_number_rate or 0
		wt.deft_number_rate = wt.deft_number_rate or 0
		if not (wt.class == "crossbow" or wt.class == "thunderstick") then
			if wt.number < 2 then
				if (wt.body_damage_rate + wt.deft_damage_rate) < 25 then
					wt.body_damage_rate = 2 * wt.body_damage_rate
					wt.deft_damage_rate = 2 * wt.deft_damage_rate
					wt.body_number_rate = math.floor(wt.body_number_rate / 2)
					wt.deft_number_rate = math.floor(wt.deft_number_rate / 2)
					if (wt.body_number_rate + wt.deft_number_rate) < 5 then
						wt.deft_number_rate = 5 - wt.body_number_rate
					end
				end
			elseif (wt.body_damage_rate + wt.deft_damage_rate) > 25 then
				wt.body_number_rate = 2 * wt.body_number_rate
				wt.deft_number_rate = 2 * wt.deft_number_rate
				wt.body_damage_rate = math.floor(wt.body_damage_rate / 2)
				wt.deft_damage_rate = math.floor(wt.deft_damage_rate / 2)
				if (wt.body_damage_rate + wt.deft_damage_rate) < 20 then
					wt.body_damage_rate = 20 - wt.deft_damage_rate
				end
			end
		end

		table.insert(wt, { "prereq", {} })
		if wt.class == "light_blade" or wt.class == "thrown_light_blade" or wt.class == "lash" then
			wt[#wt][2].deft = wt.damage
		elseif wt.class == "lob" or wt.class == "thrown_heavy_blade" then
			wt[#wt][2].body = math.floor(1.5 * wt.damage)
		elseif wt.class == "polearm" then
			wt[#wt][2].body = math.floor(0.7 * wt.damage)
			wt[#wt][2].deft = wt[#wt][2].body
		elseif not (wt.class == "crossbow" or wt.class == "thunderstick") then
			wt[#wt][2].body = wt.damage
		end

		return wt
	end

	local function adjustStats(wt)
		-- this is static
		wt.prob_name = wtype
		-- these will all be set later by other functions (see below)
		wt.human_magic_adjust = 0
		wt.dark_magic_adjust = 0
		wt.faerie_magic_adjust = 0
		wt.runic_magic_adjust = 0
		wt.spirit_magic_adjust = 0
		wt.absolute_value = 0

		return adjustCoreStats(wt)
	end

	local function adjustName(nm)
		local at, name
		if attr == "none" then
			name = tostring(nm)
		else
			if attr == "rusty" then
				if wtype == "club" or wtype == "magestaff" or wtype == "necrostaff" or wtype == "faerie_staff" or wtype == "spirit_staff" then
					at = _ "rotten "
				elseif wtype == "bow" or wtype == "crossbow" then
					at = _ "cracked "
				elseif wtype == "sling" then
					at = _ "worn "
				else
					at = _ "rusty "
				end
			elseif attr == "unbalanced" then
				if wtype == "bow" or wtype == "crossbow" then
					at = _ "rigid "
				elseif wtype == "sling" then
					at = _ "loose "
				else
					at = _ "unbalanced "
				end
			elseif attr == "heavy" then
				if wtype == "bow" then
					at = _ "long"
				elseif wtype == "sword" then
					at = _ "great"
				elseif wtype == "scimitar" then
					at = _ "great "
				else
					at = _ "heavy "
				end
			elseif attr == "light" then
				if wtype == "sword" or wtype == "saber"  then
					at = _ "short "
				elseif wtype == "bow" then
					at = _ "short"
				else
					at = _ "light "
				end
			elseif attr == "sharp" then
				if wtype == "club" then
					at = _ "crafted "
				elseif wtype == "bow" or wtype == "crossbow" then
					at = _ "recurve "
				elseif wtype == "sling" then
					at = _ "woven "
				elseif wtype == "magestaff" or wtype == "necrostaff" or wtype == "faerie_staff" or wtype == "spirit_staff" then
					at = _ "ebony "
				else
					at = _ "sharp "
				end
			elseif attr == "balanced" then
				if wtype == "bow" then
					at = _ "flexible "
				elseif wtype == "crossbow" then
					at = _ "geared "
				elseif wtype == "sling" then
					at = _ "knotted "
				else
					at = _ "balanced "
				end
			else
				H.wml_error(string.format("invalid attribute= key in [create_weapon]: %s", attr))
			end
			name = string.format("%s%s", tostring(at), tostring(nm))
		end
		return name
	end

	local function finalAdjust(wt)
		local bc = wt.damage * wt.number
		local cm = 0.78125
		if wt.class == "ranged" then
			cm = cm * 1.25
		end
		wt.absolute_value = math.max(2, math.floor(cm * bc * (bc + 1) + 3.75 * (wt.evade_adjust or 0) + wt.absolute_value + 0.5))

		wt.description = adjustName(wt.description)
		return adjustWeaponDescription(wt)
	end

	local function addMagicAdjust(school, amount, wt)
		local aa
		if attr == "rusty" then
			aa = math.floor(rank_frac * amount * 0.7 + 0.5)
		elseif attr == "sharp" then
			aa = math.floor(rank_frac * amount * 1.3 + 0.5)
		else
			aa = math.floor(rank_frac * amount + 0.5)
		end
		wt[school] = wt[school] + aa
		wt.absolute_value = wt.absolute_value + 2.5 * aa
		return wt
	end

	local weapon
	if wtype == "axe" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "axe",
			user_name = "axe",
			description = _ "axe",
			icon = "axe",
			ground_icon = "axe",
			type = "blade",
			class = "heavy_blade",
			class_description = "Heavy Blade",
			damage = 11,
			evade_adjust = -3,
			body_damage_rate = 30,
			deft_damage_rate = 10,
			body_number_rate = 5,
			material = "metal",
			{ "special_type", {
				cleave = 1
			} }
		}
	elseif wtype == "bow" then
		weapon = adjustStats {
			category = "ranged_weapon",
			range = "ranged",
			name = "bow",
			user_name = "bow",
			description = _ "bow",
			icon = "bow",
			ground_icon = "bow",
			type = "pierce",
			class = "bow",
			class_description = "Bow",
			damage = 4,
			number = 2,
			deft_damage_rate = 20,
			deft_number_rate = 10,
			material = "wood",
			{ "special_type", {
				marksman = 1,
				fire_shot_bow = 1,
				remaining_ammo_bow = 1
			} }
		}
	elseif wtype == "chakram" then
		weapon = adjustStats {
			category = "ranged_weapon",
			range = "ranged",
			name = "lob",
			user_name = "chakram",
			description = _ "chakram",
			icon = "chakram",
			ground_icon = "hatchet",
			type = "blade",
			class = "thrown_heavy_blade",
			class_description = "Thrown Heavy Blade",
			damage = 5,
			body_damage_rate = 20,
			deft_damage_rate = 20,
			body_number_rate = 5,
			material = "metal"
		}
	elseif wtype == "cleaver" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "axe",
			user_name = "cleaver",
			description = _ "cleaver",
			icon = "cleaver",
			ground_icon = "cleaver",
			type = "blade",
			class = "heavy_blade",
			class_description = "Heavy Blade",
			damage = 5,
			number = 2,
			evade_adjust = -3,
			body_damage_rate = 15,
			deft_damage_rate = 5,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "metal",
			{ "special_type", {
				cleave = 1
			} }
		}
	elseif wtype == "club" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "mace",
			user_name = "club",
			description = _ "club",
			icon = "club-small",
			ground_icon = "club",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 3,
			number = 2,
			evade_adjust = -2,
			body_damage_rate = 15,
			deft_damage_rate = 5,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "wood",
			{ "special_type", {
				storm = 1
			} }
		}
	elseif wtype == "crossbow" then
		weapon = adjustStats {
			category = "ranged_weapon",
			range = "ranged",
			name = "crossbow",
			user_name = "crossbow",
			description = _ "crossbow",
			icon = "crossbow-human",
			ground_icon = "crossbow",
			type = "pierce",
			class = "crossbow",
			class_description = "Crossbow",
			damage = 8,
			deft_damage_rate = 20,
			material = "wood",
			{ "special_type", {
				readied_bolt = 1,
				fire_shot_xbow = 1
			} }
		}
	elseif wtype == "dagger" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "dagger",
			user_name = "dagger",
			description = _ "dagger",
			icon = "dagger-human",
			ground_icon = "dagger",
			type = "blade",
			class = "light_blade",
			class_description = "Light Blade",
			damage = 4,
			number = 2,
			body_damage_rate = 5,
			deft_damage_rate = 15,
			deft_number_rate = 10,
			material = "metal",
			{ "special_type", {
				backstab = 1,
				soultrap = 1
			} }
		}
	elseif wtype == "dart" then
		weapon = adjustStats {
			category = "ranged_weapon",
			range = "ranged",
			name = "thrown-light-blade",
			user_name = "dagger-thrown",
			description = _ "dart",
			icon = "dagger-thrown-human",
			ground_icon = "dagger",
			type = "pierce",
			class = "thrown_light_blade",
			class_description = "Thrown Light Blade",
			damage = 2,
			number = 2,
			body_damage_rate = 5,
			deft_damage_rate = 15,
			deft_number_rate = 10,
			material = "metal",
			{ "special_type", {
				allow_poison = 1,
				remaining_ammo_thrown_light_blade = 1
			} }
		}
	elseif wtype == "epee" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "sword",
			user_name = "epee",
			description = _ "epee",
			icon = "saber-human",
			ground_icon = "saber",
			type = "pierce",
			class = "light_blade",
			class_description = "Light Blade",
			damage = 4,
			number = 2,
			body_damage_rate = 5,
			deft_damage_rate = 15,
			deft_number_rate = 10,
			material = "metal",
			{ "special_type", {
				riposte = 1,
				slashdash = 1
			} }
		}
	elseif wtype == "faerie_staff" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "magestaff",
			user_name = "magestaff",
			description = _ "faerie staff",
			icon = "staff-elven",
			ground_icon = "magestaff",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 7,
			evade_adjust = -2,
			body_damage_rate = 30,
			deft_damage_rate = 10,
			body_number_rate = 5,
			material = "wood",
			{ "special_type", {
				storm = 1
			} }
		}
		weapon = addMagicAdjust("faerie_magic_adjust", 10, weapon)
	elseif wtype == "glaive" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "spear",
			user_name = "glaive",
			description = _ "glaive",
			icon = "spear",
			ground_icon = "spear-fancy",
			type = "blade",
			class = "polearm",
			class_description = "Polearm",
			damage = 7,
			number = 2,
			evade_adjust = -2,
			body_damage_rate = 10,
			deft_damage_rate = 10,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "metal"
		}
	elseif wtype == "hammer" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "mace",
			user_name = "hammer",
			description = _ "hammer",
			icon = "hammer-dwarven",
			ground_icon = "hammer-runic",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 11,
			evade_adjust = -3,
			body_damage_rate = 25,
			deft_damage_rate = 15,
			body_number_rate = 5,
			material = "metal",
			{ "special_type", {
				storm = 1
			} }
		}
	elseif wtype == "hatchet" then
		weapon = adjustStats {
			category = "ranged_weapon",
			range = "ranged",
			name = "lob",
			user_name = "hatchet",
			description = _ "thrown hatchet",
			icon = "hatchet",
			ground_icon = "hatchet",
			type = "blade",
			class = "thrown_heavy_blade",
			class_description = "Thrown Heavy Blade",
			damage = 7,
			body_damage_rate = 20,
			deft_damage_rate = 20,
			body_number_rate = 5,
			material = "metal",
			{ "special_type", {
				remaining_ammo_thrown_heavy_blade = 1
			} }
		}
	elseif wtype == "javelin" then
		weapon = adjustStats {
			category = "ranged_weapon",
			range = "ranged",
			name = "javelin",
			user_name = "javelin",
			description = _ "javelin",
			icon = "javelin-human",
			ground_icon = "spear-fancy",
			type = "pierce",
			class = "javelin",
			class_description = "Javelin",
			damage = 7,
			body_damage_rate = 20,
			deft_damage_rate = 20,
			deft_number_rate = 5,
			material = "metal",
			{ "special_type", {
				remaining_ammo_javelin = 1
			} }
		}
	elseif wtype == "kusarigama" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "axe",
			user_name = "kusarigama",
			description = _ "kusarigama",
			icon = "scythe",
			ground_icon = "hatchet",
			type = "blade",
			class = "heavy_blade",
			class_description = "Heavy Blade",
			damage = 2,
			number = 3,
			evade_adjust = -3,
			body_damage_rate = 15,
			deft_damage_rate = 5,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "metal",
			{ "special_type", {
				throwable = 1
			} },
			{ "thrown", adjustCoreStats {
				category = "ranged_weapon",
				range = "ranged",
				name = "lob",
				user_name = "kusarigama",
				description = _ "kusarigama",
				icon = "scythe",
				type = "blade",
				class = "thrown_heavy_blade",
				class_description = "Thrown Heavy Blade",
				damage = 3,
				number = 1,
				body_damage_rate = 30,
				deft_damage_rate = 10,
				body_number_rate = 5,
				deft_number_rate = 0
			} }
		}
	elseif wtype == "mace" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "mace",
			user_name = "mace",
			description = _ "mace",
			icon = "mace",
			ground_icon = "mace",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 11,
			evade_adjust = -3,
			body_damage_rate = 40,
			body_number_rate = 5,
			material = "metal",
			{ "special_type", {
				storm = 1
			} }
		}
	elseif wtype == "magestaff" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "magestaff",
			user_name = "magestaff",
			description = _ "magestaff",
			icon = "staff-magic",
			ground_icon = "magestaff",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 7,
			evade_adjust = -2,
			body_damage_rate = 30,
			deft_damage_rate = 10,
			body_number_rate = 5,
			material = "wood",
			{ "special_type", {
				storm = 1
			} }
		}
		weapon = addMagicAdjust("human_magic_adjust", 20, weapon)
	elseif wtype == "necrostaff" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "magestaff",
			user_name = "necrostaff",
			description = _ "necromancer staff",
			icon = "staff-necromantic",
			ground_icon = "magestaff",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 7,
			evade_adjust = -2,
			body_damage_rate = 30,
			deft_damage_rate = 10,
			body_number_rate = 5,
			material = "wood",
			{ "special_type", {
				plague = 1,
				storm = 1
			} }
		}
		weapon = addMagicAdjust("dark_magic_adjust", 15, weapon)
	elseif wtype == "pike" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "spear",
			user_name = "pike",
			description = _ "pike",
			icon = "pike",
			ground_icon = "spear-fancy",
			type = "pierce",
			class = "polearm",
			class_description = "Polearm",
			damage = 9,
			number = 2,
			evade_adjust = -2,
			body_damage_rate = 10,
			deft_damage_rate = 10,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "metal",
			{ "special_type", {
				ensnare = 1,
				firststrike = 1,
				pointpike = 1
			} }
		}
	elseif wtype == "pitchfork" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "spear",
			user_name = "pitchfork",
			description = _ "pitchfork",
			icon = "pitchfork",
			ground_icon = "pitchfork",
			type = "pierce",
			class = "polearm",
			class_description = "Polearm",
			damage = 5,
			number = 2,
			evade_adjust = -1,
			body_damage_rate = 10,
			deft_damage_rate = 10,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "metal",
			{ "special_type", {
				throwable = 1,
				pointpike = 1
			} },
			{ "thrown", adjustCoreStats {
				category = "ranged_weapon",
				range = "ranged",
				name = "javelin",
				user_name = "javelin",
				description = _ "pitchfork",
				icon = "pitchfork",
				type = "pierce",
				class = "javelin",
				class_description = "Javelin",
				damage = 4,
				body_damage_rate = 20,
				deft_damage_rate = 20,
				body_number_rate = 5,
				{ "special_type", {
					remaining_ammo_javelin = 1
				} }
			} }
		}
	elseif wtype == "runic_hammer" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "magestaff",
			user_name = "hammer",
			description = _ "runic hammer",
			icon = "hammer-dwarven-runic",
			ground_icon = "hammer-runic",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 7,
			evade_adjust = -2,
			body_damage_rate = 30,
			deft_damage_rate = 10,
			body_number_rate = 5,
			material = "metal",
			{ "special_type", {
				storm = 1
			} }
		}
		weapon = addMagicAdjust("runic_magic_adjust", 20, weapon)
	elseif wtype == "saber" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "sword",
			user_name = "saber",
			description = _ "saber",
			icon = "saber-human",
			ground_icon = "saber",
			type = "blade",
			class = "light_blade",
			class_description = "Light Blade",
			damage = 6,
			number = 2,
			body_damage_rate = 5,
			deft_damage_rate = 15,
			deft_number_rate = 10,
			material = "metal",
			{ "special_type", {
				riposte = 1,
				slashdash = 1
			} }
		}
	elseif wtype == "scimitar" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "sword",
			user_name = "sword",
			description = _ "scimitar",
			icon = "sword-elven",
			ground_icon = "sword",
			type = "blade",
			class = "heavy_blade",
			class_description = "Heavy Blade",
			damage = 7,
			number = 2,
			evade_adjust = -2,
			body_damage_rate = 5,
			deft_damage_rate = 15,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "metal",
			{ "special_type", {
				cleave = 1
			} }
		}
	elseif wtype == "scythe" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "axe",
			user_name = "scythe",
			description = _ "scythe",
			icon = "scythe",
			ground_icon = "hatchet",
			type = "blade",
			class = "heavy_blade",
			class_description = "Heavy Blade",
			damage = 6,
			number = 2,
			evade_adjust = -3,
			body_damage_rate = 15,
			deft_damage_rate = 5,
			body_number_rate = 10,
			material = "metal",
			{ "special_type", {
				cleave = 1
			} }
		}
	elseif wtype == "sling" then
		weapon = adjustStats {
			category = "ranged_weapon",
			range = "ranged",
			name = "sling",
			user_name = "sling",
			description = _ "sling",
			icon = "sling",
			ground_icon = "sling",
			type = "impact",
			class = "lob",
			class_description = "Lob",
			damage = 3,
			body_damage_rate = 20,
			deft_damage_rate = 20,
			deft_number_rate = 5,
			material = "cloth",
			{ "special_type", {
				goliath_bane = 1
			} }
		}
	elseif wtype == "spear" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "spear",
			user_name = "spear",
			description = _ "spear",
			icon = "spear",
			ground_icon = "spear-fancy",
			type = "pierce",
			class = "polearm",
			class_description = "Polearm",
			damage = 7,
			number = 2,
			evade_adjust = -1,
			body_damage_rate = 10,
			deft_damage_rate = 10,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "metal",
			{ "special_type", {
				throwable = 1,
				firststrike = 1,
				pointpike = 1
			} },
			{ "thrown", adjustCoreStats {
				category = "ranged_weapon",
				range = "ranged",
				name = "javelin",
				user_name = "javelin",
				description = _ "thrown spear",
				icon = "javelin-human",
				type = "pierce",
				class = "javelin",
				class_description = "Javelin",
				damage = 5,
				body_damage_rate = 20,
				deft_damage_rate = 20,
				body_number_rate = 5,
				{ "special_type", {
					remaining_ammo_javelin = 1
				} }
			} }
		}
	elseif wtype == "spiked_gauntlet" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "spiked gauntlet",
			user_name = "spiked gauntlet",
			description = _ "spiked gauntlet",
			icon = "pike",
			ground_icon = "gauntlets",
			type = "pierce",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 5,
			number = 2,
			evade_adjust = -1,
			body_damage_rate = 15,
			deft_damage_rate = 5,
			body_number_rate = 8,
			deft_number_rate = 2,
			material = "metal"
		}
	elseif wtype == "spirit_staff" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "magestaff",
			user_name = "spirit_staff",
			description = _ "spirit staff",
			icon = "staff-magic",
			ground_icon = "magestaff",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 7,
			evade_adjust = -2,
			body_damage_rate = 30,
			deft_damage_rate = 10,
			body_number_rate = 5,
			material = "wood",
			{ "special_type", {
				storm = 1
			} }
		}
		weapon = addMagicAdjust("spirit_magic_adjust", 20, weapon)
	elseif wtype == "sword" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "sword",
			user_name = "sword",
			description = _ "sword",
			icon = "sword-human",
			ground_icon = "sword",
			type = "blade",
			class = "heavy_blade",
			class_description = "Heavy Blade",
			damage = 7,
			number = 2,
			evade_adjust = -2,
			body_damage_rate = 15,
			deft_damage_rate = 5,
			body_number_rate = 5,
			deft_number_rate = 5,
			material = "metal",
			{ "special_type", {
				cleave = 1
			} }
		}
	elseif wtype == "thrown_dagger" then
		weapon = adjustStats {
			category = "ranged_weapon",
			range = "ranged",
			name = "thrown-light-blade",
			user_name = "dagger_thrown",
			description = _ "thrown dagger",
			icon = "dagger-thrown-human",
			ground_icon = "dagger",
			type = "blade",
			class = "thrown_light_blade",
			class_description = "Thrown Light Blade",
			damage = 2,
			number = 2,
			body_damage_rate = 5,
			deft_damage_rate = 15,
			deft_number_rate = 10,
			material = "metal",
			{ "special_type", {
				allow_poison = 1,
				remaining_ammo_thrown_light_blade = 1
			} }
		}
	elseif wtype == "thunderstick" then
		weapon = adjustStats {
			category = "ranged_weapon",
			range = "ranged",
			name = "thunderstick",
			user_name = "thunderstick",
			description = _ "thunderstick",
			icon = "thunderstick",
			ground_icon = "thunderstick",
			type = "pierce",
			class = "thunderstick",
			class_description = "Thunderstick",
			damage = 22,
			max_damage = 22,
			level = 1,
			material = "composite"
		}
	elseif wtype == "whip" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			name = "whip",
			user_name = "whip",
			description = _ "whip",
			icon = "whip",
			ground_icon = "sling",
			type = "blade",
			class = "none",
			class_description = "Lash",
			damage = 4,
			number = 2,
			evade_adjust = -1,
			body_damage_rate = 5,
			deft_damage_rate = 5,
			deft_number_rate = 20,
			material = "cloth"
		}
	elseif wtype == "fist" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			undroppable = 1,
			name = "fist",
			user_name = "fist",
			description = _ "fist",
			icon = "fist-human",
			ground_icon = "fist",
			type = "impact",
			class = "bludgeon",
			class_description = "Bludgeon",
			damage = 1,
			number = 1,
			evade_adjust = 0,
			body_damage_rate = 20,
			deft_damage_rate = 10,
			body_number_rate = 0,
			deft_number_rate = 10,
			human_magic_adjust = 0,
			dark_magic_adjust = 0,
			faerie_magic_adjust = 0,
			runic_magic_adjust = 0,
			spirit_magic_adjust = 0,
			material = "cloth"
		}
	elseif wtype == "claws" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			undroppable = 1,
			name = "claws",
			user_name = "claws",
			description = _ "claws",
			icon = "claws",
			ground_icon = "claws",
			type = "blade",
			class = "light_blade",
			class_description = "Light Blade",
			damage = 2,
			number = 1,
			evade_adjust = 0,
			body_damage_rate = 10,
			deft_damage_rate = 15,
			body_number_rate = 0,
			deft_number_rate = 15,
			human_magic_adjust = 0,
			dark_magic_adjust = 0,
			faerie_magic_adjust = 0,
			runic_magic_adjust = 0,
			spirit_magic_adjust = 0,
			material = "cloth",
			{ "special_type", {
				backstab = 1
			} }
		}
	elseif wtype == "bite" then
		weapon = adjustStats {
			category = "melee_weapon",
			range = "melee",
			undroppable = 1,
			name = "bite",
			user_name = "bite",
			description = _ "bite",
			icon = "bite",
			ground_icon = "bite",
			type = "blade",
			class = "light_blade",
			class_description = "Light Blade",
			damage = 2,
			number = 1,
			evade_adjust = 0,
			body_damage_rate = 10,
			deft_damage_rate = 15,
			body_number_rate = 0,
			deft_number_rate = 15,
			human_magic_adjust = 0,
			dark_magic_adjust = 0,
			faerie_magic_adjust = 0,
			runic_magic_adjust = 0,
			spirit_magic_adjust = 0,
			material = "cloth",
			{ "special_type", {
				drains = 1
			} }
		}
	elseif wtype == "lob" then
		weapon = adjustStats {
			category = "ranged_weapon",
			range = "ranged",
			undroppable = 1,
			name = "lob",
			user_name = "lob",
			description = _ "thrown rock",
			icon = "rock_thrown",
			ground_icon = "rock_thrown",
			type = "impact",
			class = "lob",
			class_description = "Lob",
			damage = 1,
			number = 1,
			body_damage_rate = 20,
			body_number_rate = 0,
			deft_damage_rate = 10,
			deft_number_rate = 0,
			human_magic_adjust = 0,
			dark_magic_adjust = 0,
			faerie_magic_adjust = 0,
			runic_magic_adjust = 0,
			spirit_magic_adjust = 0,
			material = "cloth"
		}
	else
		H.wml_error(string.format("invalid type= key in [create_weapon] (%s)", wtype))
	end
	wml.variables[var] = finalAdjust(weapon)
end
function wesnoth.wml_actions.create_weapon(args)
	local wtype = string.match(args.type, "[^%s]+") or H.wml_error("[create_weapon] requires a type= key")
	local rank = args.rank or 0
	local attr = string.match(args.attribute or "none", "[^%s]+")
	local var = string.match(args.variable, "[^%s]+") or H.wml_error("[create_weapon] requires a variable= key")

	createWeapon(wtype, rank, attr, var)
end

local function createArmor(atype, rank, attr, var)
	if attr == "random" then
		W.set_variable { name = "r_temp", rand = "thick,light,polished,rusty,new,battered,none,none,none,none,none,none" }
		attr = wml.variables['r_temp']
		W.clear_variable { name = "r_temp" }
	end

	local rank_frac =  rank * 0.1 + 1

	local function adjustName(nm, mat)
		local at, name
		if attr == "none" then
			name = tostring(nm)
		else
			if attr == "light" then
				if mat == "cloth" then
					at = _ "thin "
				else
					at = _ "light "
				end
			elseif attr == "thick" then
				at = _ "thick "
			elseif attr == "polished" then
				if mat == "leather" then
					at = _ "oiled "
				elseif mat == "cloth" then
					at = _ "fine "
				else
					at = _ "polished "
				end
			elseif attr == "rusty" then
				if mat == "cloth" or mat == "leather"  then
					at = _ "stiff "
				else
					at = _ "rusty "
				end
			elseif attr == "new" then
				at = _ "new "
			elseif attr == "battered" then
				if mat == "leather" then
					at = _ "worn "
				elseif mat == "cloth" then
					at = _ "tattered "
				else
					at = _ "battered "
				end
			else
				H.wml_error("invalid attribute= key in [create_armor]")
			end
			name = string.format("%s%s", tostring(at), tostring(nm))
		end
		return name
	end

	local function adjustShield(at)
		local p_mult, r_mult = 1, 1
		if attr == "thick" then
			p_mult = 1.25
			r_mult = 1.25
		elseif attr == "light" then
			p_mult = 0.8
			r_mult = 0.8
		elseif attr == "polished" then
			p_mult = 0.8
		elseif attr == "rusty" then
			p_mult = 1.25
		elseif attr == "new" then
			r_mult = 1.25
		elseif attr == "battered" then
			r_mult = 0.8
		elseif not (attr == "none") then
			H.wml_error("invalid attribute= key in [create_armor]")
		end
		at.terrain_recoup = math.floor(at.terrain_recoup * rank_frac * r_mult + 0.5)
		at.ranged_adjust = math.ceil((at.ranged_adjust or 0) * p_mult - 0.5)
		at.magic_adjust = math.ceil((at.magic_adjust or 0) * p_mult - 0.5)
		at.evade_adjust = math.ceil((at.evade_adjust or 0) * p_mult - 0.5)

		at.category = "shield"
		at.block_wield = at.block_wield or 0
		at.block_ranged = at.block_ranged or 0
		return at
	end

	local function adjustArmor(at)
		local p_mult, d_mult, r_mult = 1, 1, 1
		if attr == "thick" then
			p_mult = 1.25
			d_mult = 1.2
			r_mult = 1.2
		elseif attr == "light" then
			p_mult = 0.75
			d_mult = 0.8
			r_mult = 0.8
		elseif attr == "polished" then
			p_mult = 0.6
			d_mult = 0.6
		elseif attr == "rusty" then
			p_mult = 1.5
			d_mult = 1.3
		elseif attr == "new" then
			r_mult = 1.2
		elseif attr == "battered" then
			r_mult = 0.8
		elseif not (attr == "none") then
			H.wml_error("invalid attribute= key in [create_armor]")
		end

		local function adjustResists(rt)
			W.set_variable { name = "r_temp", rand = "0..3" }
			if wml.variables['r_temp'] == 0 then
				W.set_variable { name = "r_temp", rand = "arcane,blade,cold,fire,impact,pierce" }
				rt[wml.variables['r_temp']] = (rt[wml.variables['r_temp']] or 0) + rank
			else
				r_mult = r_mult * rank_frac
			end
			W.clear_variable { name = "r_temp" }

			if not rt.arcane then
				rt.arcane = 0
			elseif rt.arcane > 0 then
				rt.arcane = math.floor(rt.arcane * r_mult + 0.5)
			end
			if not rt.blade then
				rt.blade = 0
			elseif rt.blade > 0 then
				rt.blade = math.floor(rt.blade * r_mult + 0.5)
			end
			if not rt.cold then
				rt.cold = 0
			elseif rt.cold > 0 then
				rt.cold = math.floor(rt.cold * r_mult + 0.5)
			end
			if not rt.fire then
				rt.fire = 0
			elseif rt.fire > 0 then
				rt.fire = math.floor(rt.fire * r_mult + 0.5)
			end
			if not rt.impact then
				rt.impact = 0
			elseif rt.impact > 0 then
				rt.impact = math.floor(rt.impact * r_mult + 0.5)
			end
			if not rt.pierce then
				rt.pierce = 0
			elseif rt.pierce > 0 then
				rt.pierce = math.floor(rt.pierce * r_mult + 0.5)
			end
			return rt
		end
		local function adjustMovetype(mt)
			local tt = {
				{ "castle", { defense = 0, movement = 0 } },
				{ "cave", { defense = 0, movement = 0 } },
				{ "deep_water", { defense = 0, movement = 0 } },
				{ "flat", { defense = 0, movement = 0 } },
				{ "forest", { defense = 0, movement = 0 } },
				{ "frozen", { defense = 0, movement = 0 } },
				{ "fungus", { defense = 0, movement = 0 } },
				{ "hills", { defense = 0, movement = 0 } },
				{ "impassable", { defense = 0, movement = 0 } },
				{ "mountains", { defense = 0, movement = 0 } },
				{ "reef", { defense = 0, movement = 0 } },
				{ "sand", { defense = 0, movement = 0 } },
				{ "shallow_water", { defense = 0, movement = 0 } },
				{ "swamp_water", { defense = 0, movement = 0 } },
				{ "unwalkable", { defense = 0, movement = 0 } },
				{ "village", { defense = 0, movement = 0 } }
			}
			local it = {
				castle = 1,
				cave = 2,
				deep_water = 3,
				flat = 4,
				forest = 5,
				frozen = 6,
				fungus = 7,
				hills = 8,
				impassable = 9,
				mountains = 10,
				reef = 11,
				sand = 12,
				shallow_water = 13,
				swamp_water = 14,
				unwalkable = 15,
				village = 16
			}
			for j = 1, #mt do
				local i = it[mt[j][1]]
				tt[i][2].defense = math.floor((mt[j][2].defense or 0) * d_mult + 0.5)
				tt[i][2].movement = mt[j][2].movement or 0
			end
			return tt
		end

		at.category = at.category or "torso_armor"

		at.magic_adjust = math.ceil((at.magic_adjust or 0) * p_mult - 0.5)
		at.evade_adjust = math.ceil((at.evade_adjust or 0) * p_mult - 0.5)
		if at.category == "head_armor" then
			at.ranged_adjust = math.ceil((at.ranged_adjust or 0) * p_mult - 0.5)
		end

		local r_flag, t_flag, b_flag = false, at.category == "head_armor", at.category ~= "torso_armor"
		for i = 1, #at do
			if at[i] and at[i][1] then
				if at[i][1] == "resistance" then
					at[i][2] = adjustResists(at[i][2])
					r_flag = true
				elseif at[i][1] == "terrain" then
					at[i][2] = adjustMovetype(at[i][2])
					t_flag = true
				elseif at[i][1] == "restricts" then
					at[i][2].head = at[i][2].head or 0
					at[i][2].arms = at[i][2].arms or 0
					at[i][2].legs = at[i][2].legs or 0
					at[i][2].shield = at[i][2].shield or 0
					b_flag = true
				end
				if r_flag and t_flag and b_flag then
					break
				end
			end
		end
		if not r_flag then
			table.insert(at, { "resistance", adjustResists({}) })
		end
		if not t_flag then
			table.insert(at, { "terrain", adjustMovetype({}) })
		end
		if not b_flag then
			table.insert(at, { "restricts", { head = 0, arms = 0, legs = 0, shield = 0 } })
		end

		return at
	end

	local function finalAdjust(at)
		if at.category == "shield" then
			at.absolute_value = math.max(2, math.floor(10 * at.terrain_recoup + 0.25 * (at.magic_adjust + at.ranged_adjust) + 3.75 * at.evade_adjust + 0.5))
		else
			local d_val, r_val, b_val = 0
			local r_flag, t_flag = false, at.category == "head_armor"
			for i = 1, #at do
				if at[i] and at[i][1] then
					if at[i][1] == "resistance" then
						r_val = at[i][2].blade + at[i][2].cold + at[i][2].fire + at[i][2].impact + at[i][2].pierce
						r_flag = true
					elseif at[i][1] == "terrain" then
						d_val = at[i][2][4][2].defense
						t_flag = true
					end
					if r_flag and t_flag then
						break
					end
				end
			end
			b_val = r_val + 0.2 * at.magic_adjust + 0.6 * at.evade_adjust - d_val
			at.absolute_value = math.max(2, math.floor(0.125 * b_val * (b_val + 1) + 0.5))
		end

		at.prob_name = atype
		at.description = adjustName(at.description, at.material)
		return adjustArmorDescription(at)
	end

	local armor
	if atype == "buckler" then
		armor = adjustShield {
			name = "buckler",
			description = _ "buckler",
			icon = "armor/buckler",
			ground_icon = "buckler",
			material = "metal",
			terrain_recoup = 4,
			evade_adjust = -2,
			magic_adjust = -30,
			ranged_adjust = -10
		}
	elseif atype == "iron_greaves" then
		armor = adjustArmor {
			category = "legs_armor",
			name = "iron_greaves",
			description = _ "iron greaves",
			icon = "icons/greaves",
			ground_icon = "greaves",
			material = "metal",
			evade_adjust = -5,
			magic_adjust = -10,
			{ "resistance", {
				blade = 27,
				cold = -5,
				fire = -5,
				impact = 8,
				pierce = 30
			} },
			{ "terrain", {
				{ "unwalkable", { defense = 7 } },
				{ "castle", { defense = 10 } },
				{ "village", { defense = 7 } },
				{ "shallow_water", { defense = 7 } },
				{ "deep_water", { defense = 7 } },
				{ "flat", { defense = 10 } },
				{ "forest", { defense = 7 } },
				{ "hills", { defense = 10 } },
				{ "mountains", { defense = 7 } },
				{ "swamp_water", { defense = 7 } },
				{ "fungus", { defense = 10 } }
			} }
		}
	elseif atype == "iron_helm" then
		armor = adjustArmor {
			category = "head_armor",
			name = "iron_helm",
			description = _ "iron helm",
			icon = "icons/helmet_corinthian",
			ground_icon = "helmet",
			material = "metal",
			evade_adjust = -3,
			ranged_adjust = -30,
			{ "resistance", {
				blade = 13,
				impact = 11
			} }
		}
	elseif atype == "iron_plate" then
		armor = adjustArmor {
			name = "iron_plate",
			description = _ "iron plate",
			icon = "icons/breastplate",
			ground_icon = "armor",
			material = "metal",
			evade_adjust = -10,
			magic_adjust = -40,
			{ "resistance", {
				blade = 40,
				fire = -5,
				cold = -5,
				impact = 11,
				pierce = 30
			} },
			{ "terrain", {
				{ "unwalkable", { defense = 7 } },
				{ "castle", { defense = 10 } },
				{ "village", { defense = 7 } },
				{ "shallow_water", { defense = 7 } },
				{ "deep_water", { defense = 7 } },
				{ "flat", { defense = 10 } },
				{ "forest", { defense = 7 } },
				{ "hills", { defense = 10 } },
				{ "mountains", { defense = 10 } },
				{ "swamp_water", { defense = 10 } },
				{ "fungus", { defense = 10 } }
			} }
		}
	elseif atype == "full_helm" then
		armor = adjustArmor {
			category = "head_armor",
			name = "full_helm",
			description = _ "full helm",
			icon = "icons/helmet_crested",
			ground_icon = "helmet",
			material = "metal",
			evade_adjust = -3,
			ranged_adjust = -10,
			{ "resistance", {
				blade = 7,
				impact = 15
			} }
		}
	elseif atype == "leather_cap" then
		armor = adjustArmor {
			category = "head_armor",
			name = "leather_cap",
			description = _ "leather cap",
			icon = "armor/leather-cap",
			ground_icon = "cap",
			material = "leather",
			evade_adjust = -1,
			{ "resistance", {
				blade = 5,
				impact = 7
			} }
		}
	elseif atype == "leather_leggings" then
		armor = adjustArmor {
			category = "legs_armor",
			name = "leather_leggings",
			description = _ "leather leggings",
			icon = "icons/boots_elven",
			ground_icon = "boots",
			material = "leather",
			evade_adjust = -2,
			{ "resistance", {
				blade = 10,
				impact = 5,
				pierce = 10
			} },
			{ "terrain", {
				{ "unwalkable", { defense = 2 } },
				{ "shallow_water", { defense = 2 } },
				{ "deep_water", { defense = 2 } },
				{ "flat", { defense = 2 } },
				{ "forest", { defense = 2 } },
				{ "hills", { defense = 2 } },
				{ "swamp_water", { defense = 2 } },
				{ "frozen", { defense = 2 } },
				{ "fungus", { defense = 2 } }
			} }
		}
	elseif atype == "mage_robe" then
		armor = adjustArmor {
			name = "mage_robe",
			description = _ "mage robe",
			icon = "icons/cloak_leather_brown",
			ground_icon = "robe",
			material = "cloth",
			evade_adjust = -14,
			{ "restricts", {
				head = 1,
				legs = 1
			} },
			{ "resistance", {
				blade = 25,
				impact = 17,
				pierce = 17
			} },
			{ "terrain", {
				{ "unwalkable", { defense = 10 } },
				{ "shallow_water", { defense = 10 } },
				{ "deep_water", { defense = 10 } },
				{ "flat", { defense = 10 } },
				{ "forest", { defense = 10 } },
				{ "hills", { defense = 10 } },
				{ "swamp_water", { defense = 10 } },
				{ "frozen", { defense = 10 } },
				{ "fungus", { defense = 10 } }
			} }
		}
	elseif atype == "mail_greaves" then
		armor = adjustArmor {
			category = "legs_armor",
			name = "mail_greaves",
			description = _ "mail greaves",
			icon = "icons/greaves",
			ground_icon = "greaves",
			material = "metal",
			evade_adjust = -4,
			magic_adjust = -10,
			{ "resistance", {
				blade = 18,
				impact = 10,
				pierce = 15
			} },
			{ "terrain", {
				{ "unwalkable", { defense = 5 } },
				{ "shallow_water", { defense = 5 } },
				{ "deep_water", { defense = 5 } },
				{ "flat", { defense = 5 } },
				{ "forest", { defense = 5 } },
				{ "hills", { defense = 5 } },
				{ "swamp_water", { defense = 5 } },
				{ "frozen", { defense = 5 } },
				{ "fungus", { defense = 5 } }
			} }
		}
	elseif atype == "round_shield" then
		armor = adjustShield {
			name = "shield_round",
			description = _ "round shield",
			icon = "icons/shield_wooden",
			ground_icon = "buckler",
			material = "metal",
			terrain_recoup = 8,
			evade_adjust = -5,
			magic_adjust = -60,
			ranged_adjust = -15,
			block_wield = 1
		}
	elseif atype == "scale_mail" then
		armor = adjustArmor {
			name = "scale_mail",
			description = _ "scale mail",
			icon = "icons/cuirass_muscled",
			ground_icon = "armor",
			material = "metal",
			evade_adjust = -6,
			magic_adjust = -25,
			{ "resistance", {
				blade = 25,
				impact = 15,
				pierce = 15
			} },
			{ "terrain", {
				{ "unwalkable", { defense = 5 } },
				{ "shallow_water", { defense = 5 } },
				{ "deep_water", { defense = 5 } },
				{ "flat", { defense = 5 } },
				{ "forest", { defense = 5 } },
				{ "hills", { defense = 5 } },
				{ "swamp_water", { defense = 5 } },
				{ "frozen", { defense = 5 } },
				{ "fungus", { defense = 5 } }
			} }
		}
	elseif atype == "studded_leather" then
		armor = adjustArmor {
			name = "studded_leather",
			description = _ "studded leather",
			icon = "icons/cuirass_leather_studded",
			ground_icon = "armor",
			material = "leather",
			evade_adjust = -4,
			magic_adjust = -20,
			{ "resistance", {
				blade = 15,
				impact = 8,
				pierce = 10
			} },
			{ "terrain", {
				{ "unwalkable", { defense = 3 } },
				{ "shallow_water", { defense = 3 } },
				{ "deep_water", { defense = 3 } },
				{ "flat", { defense = 3 } },
				{ "forest", { defense = 3 } },
				{ "hills", { defense = 3 } },
				{ "swamp_water", { defense = 3 } },
				{ "frozen", { defense = 3 } },
				{ "fungus", { defense = 3 } }
			} }
		}
	elseif atype == "tempered_plate" then
		armor = adjustArmor {
			name = "tempered_plate",
			description = _ "tempered plate",
			icon = "armor/plate-tempered",
			ground_icon = "armor",
			material = "metal",
			evade_adjust = -8,
			magic_adjust = -40,
			{ "resistance", {
				blade = 15,
				impact = 7,
				pierce = 45
			} },
			{ "terrain", {
				{ "unwalkable", { defense = 5 } },
				{ "shallow_water", { defense = 5 } },
				{ "deep_water", { defense = 5 } },
				{ "flat", { defense = 5 } },
				{ "forest", { defense = 5 } },
				{ "hills", { defense = 5 } },
				{ "swamp_water", { defense = 5 } },
				{ "frozen", { defense = 5 } },
				{ "fungus", { defense = 5 } }
			} }
		}
	elseif atype == "tower_shield" then
		armor = adjustShield {
			name = "shield_tower",
			description = _ "tower shield",
			icon = "icons/shield_tower",
			ground_icon = "buckler",
			material = "metal",
			terrain_recoup = 18,
			evade_adjust = -8,
			magic_adjust = -80,
			ranged_adjust = -20,
			block_wield = 2,
			block_ranged = 1,
			{ "special_type", {
				steadfast = 1
			} }
		}
	else
		H.wml_error(string.format("invalid type= key in [create_armor] (%s)", atype))
	end
	wml.variables[var] = finalAdjust(armor)
end

function wesnoth.wml_actions.create_armor(args)
	local atype = string.match(args.type, "[^%s]+") or H.wml_error("[create_armor] requires a type= key")
	local rank = args.rank or 0
	local attr = string.match(args.attribute or "none", "[^%s]+")
	local var = string.match(args.variable, "[^%s]+") or H.wml_error("[create_armor] requires a variable= key")

	createArmor(atype, rank, attr, var)
end

function wesnoth.wml_actions.drop_item(cfg)
	local x = cfg.x or H.wml_error("[drop_item] requires an x= key")
	local y = cfg.y or H.wml_error("[drop_item] requires a y= key")
	local var = cfg.from_variable
	local item_data
	if var then
		item_data = wml.variables[var]
	else
		item_data = wml.get_child(cfg, "item") or H.wml_error("[drop_item] requires either a from_variable= key or an [item] subtag")
		item_data = item_data.__shallow_parsed
	end

	if not item_data.undroppable or item_data.undroppable ~= 1 then
		local i = wml.variables[string.format("ground.x%d.y%d.items.length", x, y)]
		if item_data.category == "gold" then
		item_data.amount = tonumber(item_data.amount) or 0
		if item_data.amount > 0 then
			for j = 0, i - 1 do
				if wml.variables[string.format("ground.x%d.y%d.items[%d].category", x, y, j)] == "gold" then
					local old_image = wml.variables[string.format("ground.x%d.y%d.items[%d].ground_icon", x, y, j)]
					item_data.amount = item_data.amount + wml.variables[string.format("ground.x%d.y%d.items[%d].amount", x, y, j)]
					W.remove_item {
						x = x,
						y = y,
						image = string.format("items/%s.png", old_image)
					}
					wml.variables[string.format("ground.x%d.y%d.items[%d]", x, y, j)] = nil
					break
				end
			end
			if item_data.amount < 26 then
				item_data.ground_icon = "gold-coins-small"
				item_data.icon = "icons/gold-small"
			elseif item_data.amount < 76 then
				item_data.ground_icon = "gold-coins-medium"
				item_data.icon = "icons/gold-medium"
			else
				item_data.ground_icon = "gold-coins-large"
				item_data.icon = "icons/gold-large"
			end
			item_data.description = string.format("%d gold", item_data.amount)
		end
		end
		if item_data.ground_icon then
			W.item {
				x = x,
				y = y,
				image = string.format("items/%s.png", item_data.ground_icon),
				visible_in_fog = "no"
			}
			wml.variables[string.format("ground.x%d.y%d.items[%d]", x, y, i)] = item_data
		end
	end
end

function wesnoth.wml_actions.item_cleanup(cfg)
	local x = cfg.x or H.wml_error("[item_cleanup] requires an x= key")
	local y = cfg.y or H.wml_error("[item_cleanup] requires a y= key")
	local ix = cfg.index
	if type(ix) ~= "number" then
		ix = -1
	end
	if ix == -1 then
		wml.variables[string.format("ground.x%d.y%d.items", x, y)] = nil
	else
		wml.variables[string.format("ground.x%d.y%d.items[%d]", x, y, ix)] = nil
	end
	W.remove_item {
		x = x,
		y = y
	}
	local e = wml.variables[string.format("ground.x%d.y%d.exit.image", x, y)]
	if e then
		W.item {
			x = x,
			y = y,
			image = e,
			visible_in_fog = "yes"
		}
	end
	local g = wml.variables[string.format("ground.x%d.y%d", x, y)]
	if g and g[1] then
		for i = 1, #g do
			if g[i][1] == "items" and g[i][2].ground_icon then
				W.item {
					x = x,
					y = y,
					image = string.format("items/%s.png", g[i][2].ground_icon),
					visible_in_fog = "no"
				}
			end
		end
	else
		wml.variables[string.format("ground.x%d.y%d", x, y)] = nil
		g = wml.variables[string.format("ground.x%d", x)]
		if g and not g[1] then
			wml.variables[string.format("ground.x%d", x)] = nil
		end
	end
end
