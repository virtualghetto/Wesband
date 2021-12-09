local function parse_container(wml)
	local parsed
	if not (type(wml) == "table") then
		parsed = wml
	else
		parsed = { k = {}, c = {} }
		for k,v in pairs(wml) do
			if not (type(v) == "table") then
				parsed.k[k] = v
			end
		end
		for i = 1, #wml do
			if parsed.c[wml[i][1]] then
				table.insert(parsed.c[wml[i][1]], parse_container(wml[i][2]))
			else
				parsed.c[wml[i][1]] = { parse_container(wml[i][2]) }
			end
		end
	end
	return parsed
end
local function unparse_container(parsed)
	local wml = {}
	for k,v in pairs(parsed.k) do
		wml[k] = v
	end
	for k,v in pairs(parsed.c) do
		for i = 1, #v do
			table.insert(wml, { k, unparse_container(v[i]) })
		end
	end
	return wml
end
local function dcp(parsed, aflag)
	local clone
	if aflag then
		clone = {}
		for i = 1, #parsed do
			table.insert(clone, dcp(parsed[i]))
		end
	else
		clone = { k = {}, c = {} }
		for k,v in pairs(parsed.k) do
			clone.k[k] = v
		end
		for k,a in pairs(parsed.c) do
			clone.c[k] = {}
			for i = 1, #a do
				table.insert(clone.c[k], a[i])
			end
		end
	end
	return clone
end
local function get_p(parsed, relative)
	local aflag, t, v = false, parsed
	if type(relative) ~= "nil" then
		for pn in string.gmatch(relative, "[^%.]+") do
			v = nil
			if aflag then
				t = t[1]
				aflag = false
			end
			if not t then break end
			local p, n = string.match(pn, "^([%a%d_]+)%[(%d+)%]$")
			if not p then
				p = string.match(pn, "^([%a%d_]+)$")
			end
			if n then
				local i = tonumber(n) + 1
				if t.c[p] and t.c[p][i] then
					t = t.c[p][i]
				else
					t = nil
				end
			elseif p then
				if type(t.k[p]) ~= "nil" then
					v = t.k[p]
				elseif t.c[p] then
					t = t.c[p]
					aflag = true
				else
					t = nil
				end
			else
				H.wml_error(string.format("malformed path segment: %s", pn))
			end
		end
	end
	if t and not v then
		t = dcp(t, aflag)
	end
	return v or t
end
local function clear_p(parsed, relative)
	if type(relative) ~= "nil" then
		local p, n, np = string.match(relative, "^([%a%d_]+)%[(%d+)%]%.([%a%d%[%]%._]+)$")
		if p then
			local i = tonumber(n) + 1
			if parsed.c[p] and parsed.c[p][i] then
				clear_p(parsed.c[p][i], np)
			end
		else
			p, np = string.match(relative, "^([%a%d_]+)%.([%a%d%[%]%._]+)$")
			if p then
				if parsed.c[p] and parsed.c[p][1] then
					clear_p(parsed.c[p][1], np)
				end
			else
				p, n = string.match(relative, "^([%a%d_]+)%[(%d+)%]$")
				if p then
					local i = tonumber(n) + 1
					if parsed.c[p] and parsed.c[p][i] then
						table.remove(parsed.c[p], i)
					end
				else
					p = string.match(relative, "^([%a%d_]+)$")
					if p then
						if type(parsed.k[p]) ~= "nil" then
							parsed.k[p] = nil
						elseif parsed.c[p] then
							parsed.c[p] = nil
						end
					else
						H.wml_error(string.format("malformed path segment: %s", relative))
					end
				end
			end
		end
	else
		parsed = nil
	end
	return parsed
end
local function set_p(parsed, relative, value, pflag)
	if type(value) == "nil" then
		clear_p(parsed, relative)
	elseif type(relative) ~= "nil" then
		local p, n, np = string.match(relative, "^([%a%d_]+)%[(%d+)%]%.([%a%d%[%]%._]+)$")
		if p then
			local i = tonumber(n) + 1
			if not parsed.c[p] then
				parsed.c[p] = { { k = {}, c = {} } }
			end
			for j = #parsed.c[p] + 1, i do
				table.insert(parsed.c[p], { k = {}, c = {} })
			end
			set_p(parsed.c[p][i], np, value, pflag)
		else
			p, np = string.match(relative, "^([%a%d_]+)%.([%a%d%[%]%._]+)$")
			if p then
				if not (parsed.c[p] and parsed.c[p][1]) then
					parsed.c[p] = { { k = {}, c = {} } }
				end
				set_p(parsed.c[p][1], np, value, pflag)
			else
				p, n = string.match(relative, "^([%a%d_]+)%[(%d+)%]$")
				if p then
					local i = tonumber(n) + 1
					if type(value) == "table" then
						if not parsed.c[p] then
							parsed.c[p] = {}
						end
						if #parsed.c[p] < i then
							for j = #parsed.c[p] + 1, i - 1 do
								table.insert(parsed.c[p], { k = {}, c = {} })
							end
						else
							table.remove(parsed.c[p], i)
						end
						if pflag then
							table.insert(parsed.c[p], i, dcp(value))
						else
							table.insert(parsed.c[p], i, parse_container(value))
						end
					else
						H.wml_error(string.format("attempt to assign scalar value to array element: %s", relative))
					end
				else
					p = string.match(relative, "^([%a%d_]+)$")
					if p then
						if type(value) == "table" then
							parsed.c[p] = {}
							if pflag then
								table.insert(parsed.c[p], dcp(value))
							else
								table.insert(parsed.c[p], parse_container(value))
							end
						else
							parsed.k[p] = value
						end
					else
						H.wml_error(string.format("malformed path segment: %s", relative))
					end
				end
			end
		end
	elseif pflag then
		parsed = dcp(value)
	else
		parsed = parse_container(value)
	end
	return parsed
end

local function get_unit_equipment(unit)
	local equipment = {}
	equipment.head_armor = get_p(unit, string.format("variables.inventory.armor.head[%d]", get_p(unit, "variables.equipment_slots.head_armor")))
	equipment.torso_armor = get_p(unit, string.format("variables.inventory.armor.torso[%d]", get_p(unit, "variables.equipment_slots.torso_armor")))
	equipment.leg_armor = get_p(unit, string.format("variables.inventory.armor.legs[%d]", get_p(unit, "variables.equipment_slots.leg_armor")))
	equipment.shield = get_p(unit, string.format("variables.inventory.armor.shield[%d]", get_p(unit, "variables.equipment_slots.shield")))
	equipment.melee_1 = get_p(unit, string.format("variables.inventory.weapons.melee[%d]", get_p(unit, "variables.equipment_slots.melee_1")))
	local wield_skill, block_wield = get_p(unit, "variables.abilities.wield"), get_p(equipment.shield, "block_wield")
	if wield_skill and wield_skill > 0 and block_wield < 2 then
		equipment.melee_2 = get_p(unit, string.format("variables.inventory.weapons.melee[%d]", get_p(unit, "variables.equipment_slots.melee_2")))
		if wield_skill == 2 and block_wield == 0 then
			equipment.melee_3 = get_p(unit, string.format("variables.inventory.weapons.melee[%d]", get_p(unit, "variables.equipment_slots.melee_3")))
		end
	end
	equipment.thrown = get_p(equipment.melee_1, "thrown[0]")
	if get_p(equipment.shield, "block_ranged") == 0 and (get_p(unit, "variables.no_ranged") or 0) == 0 then
		equipment.ranged = get_p(unit, string.format("variables.inventory.weapons.ranged[%d]", math.max(0, get_p(unit, "variables.equipment_slots.ranged"))))
	end
	return equipment
end

local function get_attack_basics(unit, equipment, weapon)
	local attack = {
		description = get_p(weapon, "description"),
		name = get_p(weapon, "name"),
		user_name = get_p(weapon, "user_name"),
		type = get_p(weapon, "type"),
		icon = string.format("attacks/%s.png", get_p(weapon, "icon")),
		range = get_p(weapon, "range"),
		material = get_p(weapon, "material")
	}
	local percent_mult, skill_dam, skill_num = 1.0, 1, 0
	local weapon_class = get_p(weapon, "class")
	if weapon_class == "magical" or weapon_class == "spell" then
		skill_dam = (get_p(unit, "variables.abilities.magic_casting.power") or 0) * (get_p(weapon, "spell_power") or 1)
		skill_num = (get_p(unit, "variables.abilities.magic_casting.speed") or 0)
	else
		if get_p(weapon, "number") < 2 then
			skill_dam = 2
		end
		skill_dam = skill_dam * (get_p(unit, string.format("variables.weapon_skills.%s.damage", weapon_class)) or 0)
		skill_num = get_p(unit, string.format("variables.weapon_skills.%s.attack", weapon_class)) or 0
	end
	local function add_stat_adjusts(stat)
		local stat_level = get_p(unit, "variables." .. stat)
		skill_dam = skill_dam + (get_p(weapon, stat .. "_damage_rate") or 0) * stat_level * 0.01
		skill_num = skill_num + (get_p(weapon, stat .. "_number_rate") or 0) * stat_level * 0.01
		local prereq = get_p(weapon, "prereq." .. stat) or 0
		if prereq > stat_level then
			percent_mult = percent_mult * stat_level / prereq
		end
	end
	add_stat_adjusts("body")
	add_stat_adjusts("deft")
	add_stat_adjusts("mind")
	if weapon_class == "spell" then
		local spell_bonus_type = get_p(weapon, "bonus_type")
		local armor_penalty = get_p(equipment.shield, "magic_adjust") + get_p(equipment.head_armor, "magic_adjust") + get_p(equipment.torso_armor, "magic_adjust") + get_p(equipment.leg_armor, "magic_adjust")
		if spell_bonus_type == "runic_magic_adjust" then
			armor_penalty = armor_penalty * 0.5
			if get_p(equipment.melee_1, "user_name") == "hammer" then
				armor_penalty = math.min(0, armor_penalty + 3 * (get_p(unit, "variables.abilities.magic_casting.focus") or 0))
			end
		elseif get_p(weapon, "name") == "faerie fire" then
			if get_p(equipment.melee_1, "name") == "sword" then
				armor_penalty = math.min(0, armor_penalty + 3 * (get_p(unit, "variables.abilities.magic_casting.focus") or 0))
			end
		end
		percent_mult = percent_mult * math.max(0, 100 + (get_p(equipment.melee_1, spell_bonus_type) or 0) + armor_penalty) * 0.01
	elseif attack.range == "ranged" then
		percent_mult = percent_mult * math.max(0, 100 + get_p(equipment.head_armor, "ranged_adjust") + get_p(equipment.shield, "ranged_adjust")) * 0.01
	end
	local unit_race = get_p(unit, "race")
	if unit_race == "elf" then
		if weapon_class == "bow" then
			skill_num = skill_num + 1
		end
	elseif unit_race == "dwarf" then
		local weapon_type = get_p(weapon, "user_name")
		if weapon_type == "axe" then
			skill_num = skill_num + 1
			percent_mult = percent_mult * 0.8
		elseif weapon_type == "hammer" then
			percent_mult = percent_mult * 1.2
		end
	elseif unit_race == "troll" then
		if weapon_class ~= "bludgeon" and weapon_class ~= "lob" then
			percent_mult = percent_mult * 0.75
		end
	elseif unit_race == "lizard" then
		if weapon_class == "polearm" or weapon_class == "javelin" then
			skill_num = skill_num + 1
			percent_mult = percent_mult * 0.8
		end
	end
	attack.damage = math.max(1, math.floor(percent_mult * (get_p(weapon, "damage") + skill_dam)))
	attack.number = math.floor(get_p(weapon, "number") + skill_num)
	local target_level = get_p(unit, "variables.abilities.target") or 0
	if target_level > 0 and (get_p(weapon, "special_type.backstab") or 0) > 0 then
		attack.damage = math.ceil(attack.damage * 0.5 * (3 + target_level))
		attack.number = math.ceil(attack.number * 0.5)
	end
	if (get_p(unit, "variables.abilities.witch_magic") or 0) == 4 then
		attack.damage = math.floor(attack.damage * 1.5 + 0.5)
	end
	if weapon_class == "light_blade" and (get_p(unit, "variables.abilities.witchcraft") or 0) == 1 and (get_p(unit, "variables.abilities.magic_casting.power") or 0) > 0 then
		attack.number = math.ceil(attack.number * 0.5)
	end
	if attack.user_name == "hammer" and (get_p(unit, "variables.abilities.devling_spiker") or 0) > 0 then
		attack.description = "nail 'em"
		attack.damage = math.floor(attack.damage * attack.number + 0.5)
		attack.number = 1
	end
	if attack.user_name == "spike 'em" then
		attack.damage = math.floor(attack.damage * attack.number * 1.25 + 0.5)
		attack.number = 1
	end
	return attack, weapon_class
end
wesnoth.register_wml_action("calculate_weapon_display", function(args)
	local unit_var = args.unit_variable or H.wml_error("[calculate_weapon_display] requires a unit_variable= key")
	local weapon_var = args.weapon_variable or H.wml_error("[calculate_weapon_display] requires a unit_variable= key")
	local unit = parse_container(wesnoth.get_variable(unit_var))
	local equipment = get_unit_equipment(unit)
	local weapon = parse_container(wesnoth.get_variable(weapon_var))
	local attack = get_attack_basics(unit, equipment, weapon)
	wesnoth.set_variable("display_damage", attack.damage)
	wesnoth.set_variable("display_number", attack.number)
end)

local function find_npc_value(unit, params)
	params = params or {}
	local modifiers = { -- any of these values can be overridden by the passed in parameters
		arcane = params.arcane_mod or 1.5,
		impact = params.impact_mod or 1.15,
		fire = params.fire_mod or 1.35,
		cold = params.cold_mod or 1.3,
		pierce = params.pierce_mod or 1.1,
		blade = params.blade_mod or 1,
		ranged = params.ranged_mod or 1.1,
		magical = params.magical_mod or 1.7,
		marksman = params.marksman_mod or 1.4,
		poison = params.poison_mod or 6,
		charge = params.charge_mod or 1.1,
		plague = params.plague_mod or 1.1,
		soultrap = params.soultrap_mod or 1.2,
		drain = params.drain_mod or 2.5,
		slow = params.slow_mod or 1.5,
		rage = params.rage_mod or 1.8,
		berserk = params.berserk_mod or 2.2,
		slashdash = params.slashdash_mod or 1.5,
		accuracy = params.accuracy_mod or 1.2,
		evasion = params.evasion_mod or 1.4,	
		goliath = params.goliath_mod or 1.6,	
		ensnare = params.ensnare_mod or 1.2,
		pointpike = params.pointpike_mod or 1.2,
		storm = params.storm_mod or 1.2,
		brutal = params.brutal_mod or 1.3,
		dread = params.dread_mod or 1.6,
		firststrike = params.firststrike_mod or 1.2,
		cleave = params.cleave_mod or 1.8,
		riposte = params.riposte_mod or 1.3,
		ammo = params.ammo_mod or 1.8,
		bloodlust = params.bloodlust_mod or 1.5,
		grace = params.grace_mod or 1.4,
		steadfast = params.steadfast_mod or 0.006,
		feeding = params.feeding_mod or 1.05,
		dash = params.dash_mod or 1.1,
		illuminates = params.illuminates_mod or 1.1,
		submerge = params.submerge_mod or 1.01,
		tutor = params.tutor_mod or 1.1,
		loner = params.loner_mod or 1.1,
		cold_aura = params.cold_aura_mod or 1.2,
		dark_aura = params.dark_aura_mod or 2,
		deadzone = params.deadzone_mod or 4,
		ambush_forest = params.ambush_forest_mod or 1.1,
		ambush_mountains = params.ambush_mountains_mod or 1.1,
		sneak = params.sneak_mod or 1.5,
		nightstalk = params.nightstalk_mod or 1.1,
		healthy = params.healthy_mod or 3,
		undead = params.undead_mod or 1.1,
		fearless = params.fearless_mod or 1.05,
		skirmisher = params.skirmisher_mod or 1.2
	}
	local function move_cost_modifer(terrain_type, base, multiplier, offset)
		return 1 + (offset or 0) + (multiplier or 0.7) * ((base or 2) - math.min(get_p(unit, "movement_costs." .. terrain_type), 5))
	end
	local function resist_value(damage_type, base)
		return math.max(0, (200 - base - get_p(unit, "resistance." .. damage_type)) / modifiers[damage_type])
	end
	local function defense_value(terrain_type, base, divisor)
		return (100 - base - get_p(unit, "defense." .. terrain_type)) / divisor
	end
	local values = { -- get basic values
		hp = get_p(unit, "max_hitpoints") * 1.1,
		moves = (get_p(unit, "max_moves") * 0.04 + 0.6) * move_cost_modifer("swamp_water", 3) * move_cost_modifer("shallow_water", 3) * move_cost_modifer("forest") * move_cost_modifer("frozen", 3, 0.04, -0.01) * move_cost_modifer("hills", 2, 0.1) * move_cost_modifer("mountains", 3, 0.05) * move_cost_modifer("cave", 2, 0.1, 0.05) * move_cost_modifer("fungus") * move_cost_modifer("sand"),
		resists = 1.35 * (resist_value("arcane", 50) + resist_value("blade", 50) + resist_value("cold", 50) + resist_value("fire", 50) + resist_value("impact", 50) + resist_value("pierce", 50)) / (1 / modifiers.arcane + 1 / modifiers.blade + 1 / modifiers.cold + 1 / modifiers.fire + 1 / modifiers.impact + 1 / modifiers.pierce) - 17.5, -- no idea the rationale behind this formula, but it seems to be what the WML version converts to
		defense = 50 + defense_value("flat", 50, 3) + defense_value("swamp_water", 20, 8) + defense_value("forest", 50, 4) + defense_value("hills", 50, 2) + defense_value("frozen", 20, 10) + defense_value("mountains", 60, 5) + defense_value("cave", 40, 3) + defense_value("sand", 30, 4),
		attacks = 0,
		melee = {},
		ranged = {}
	}
	-- apply ability modifiers
	if (get_p(unit, "abilities.skirmisher.id") or "none") == "skirmisher" then
		values.moves = values.moves * modifiers.skirmisher
	end
	local ability_array = get_p(unit, "abilities.resistance")
	if type(ability_array) == "table" then
		for i = 1, #ability_array do
			local ability_id = get_p(ability_array[i], "id") or "none"
			if ability_id == "steadfast" then
				if values.resists > 75 then
					values.resists = math.max(1, 100 - values.resists)
				else
					values.resists = math.max(1, values.resists - 50)
				end
			elseif ability_id == "deadzone" then
				values.defense = values.defense * modifiers.deadzone
			elseif ability_id == "coldaura" then
				values.defense = values.defense * modifiers.cold_aura
			end
		end
	end
	ability_array = get_p(unit, "abilities.regenerate")
	if type(ability_array) == "table" then
		for i = 1, #ability_array do
			local ability_id = get_p(ability_array[i], "id") or "none"
			if ability_id == "regenerates" then
				values.hp = values.hp + get_p(ability_array[i], "value")
			end
		end
	end
	ability_array = get_p(unit, "abilities.heals")
	if type(ability_array) == "table" then
		for i = 1, #ability_array do
			local ability_id = get_p(ability_array[i], "id") or "none"
			if ability_id == "healing" then
				values.defense = values.defense + 2 * get_p(ability_array[i], "value")
			end
		end
	end
	ability_array = get_p(unit, "abilities.leadership")
	if type(ability_array) == "table" then
		for i = 1, #ability_array do
			local ability_id = get_p(ability_array[i], "id") or "none"
			if ability_id == "leadership" then
				values.defense = values.defense + 5
			elseif ability_id == "loner" then
				values.defense = values.defense * modifiers.loner
			elseif ability_id == "darkaura" then
				values.defense = values.defense * modifiers.dark_aura
			end
		end
	end
	ability_array = get_p(unit, "abilities.dummy")
	if type(ability_array) == "table" then
		for i = 1, #ability_array do
			local ability_id = get_p(ability_array[i], "id") or "none"
			if ability_id == "wbd_feeding" then
				values.hp = values.hp * modifiers.feeding
			elseif ability_id == "dash" then
				values.defense = values.defense * modifiers.dash
			elseif ability_id == "battletutor" then
				values.defense = values.defense * modifiers.tutor
			end
		end
	end
	ability_array = get_p(unit, "abilities.illuminates")
	if type(ability_array) == "table" then
		for i = 1, #ability_array do
			local ability_id = get_p(ability_array[i], "id") or "none"
			if ability_id == "illumination" then
				values.defense = values.defense * modifiers.illuminates
			end
		end
	end
	ability_array = get_p(unit, "abilities.hides")
	if type(ability_array) == "table" then
		for i = 1, #ability_array do
			local ability_id = get_p(ability_array[i], "id") or "none"
			if ability_id == "submerge" then
				values.defense = values.defense * modifiers.submerge
			elseif ability_id == "ambush_forest" then
				values.defense = values.defense * modifiers.ambush_forest
			elseif ability_id == "ambush_mountains" then
				values.defense = values.defense * modifiers.ambush_mountains
			elseif ability_id == "sneak" then
				values.defense = values.defense * modifiers.sneak
			elseif ability_id == "nightstalk" then
				values.defense = values.defense * modifiers.nightstalk
			end
		end
	end
	ability_array = get_p(unit, "modifications.trait")
	if type(ability_array) == "table" then
		for i = 1, #ability_array do
			local ability_id = get_p(ability_array[i], "id") or "none"
			if ability_id == "healthy" then
				values.hp = values.hp + modifiers.healthy
			elseif ability_id == "undead" then
				values.defense = values.defense * modifiers.undead
			elseif ability_id == "fearless" then
				values.defense = values.defense * modifiers.fearless
			end
		end
	end
	-- evaluate attacks
	local attack_array = get_p(unit, "attack")
	local function process_attack_set(attack_set)
		local result = 0
		if #attack_set > 0 then
			table.sort(attack_set, function(a, b) return a.value > b.value end)
			result = attack_set[1].value
			for i = 2, #attack_set do
				if attack_set[i].specials and attack_set[1].type ~= attack_set[i].type then
					result = result * (1.05 + math.max(0, attack_set[i].value - 0.9 * attack_set[1].value))
				else
					result = result * 0.999
				end
			end
		end
		return result
	end
	if type(attack_array) == "table" then
		for i = 1, #attack_array do
			local attack_eval = {
				type = get_p(attack_array[i], "type"),
				specials = false
			}
			attack_eval.value = get_p(attack_array[i], "damage") * get_p(attack_array[i], "number") * modifiers[attack_eval.type]
			ability_array = get_p(attack_array[i], "specials.backstab")
			if type(ability_array) == "table" then
				for i = 1, #ability_array do
					local ability_id = get_p(ability_array[i], "id") or "none"
					if ability_id == "backstab" then
						attack_eval.value = attack_eval.value * math.max(1.05, values.moves)
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.charge")
			if type(ability_array) == "table" then
				for i = 1, #ability_array do
					local ability_id = get_p(ability_array[i], "id") or "none"
					if ability_id == "charge" then
						attack_eval.value = attack_eval.value * modifiers.charge
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.plague")
			if type(ability_array) == "table" then
				for i = 1, #ability_array do
					local ability_id = get_p(ability_array[i], "id") or "none"
					if ability_id == "plague" then
						attack_eval.value = attack_eval.value * modifiers.plague
						attack_eval.specials = true
					elseif ability_id == "soultrap" then
						attack_eval.value = attack_eval.value * modifiers.soultrap
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.drain")
			if type(ability_array) == "table" then
				for i = 1, #ability_array do
					local ability_id = get_p(ability_array[i], "id") or "none"
					if ability_id == "drain" then
						attack_eval.value = attack_eval.value * modifiers.drain
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.slow")
			if type(ability_array) == "table" then
				for i = 1, #ability_array do
					local ability_id = get_p(ability_array[i], "id") or "none"
					if ability_id == "slow" then
						attack_eval.value = attack_eval.value * modifiers.slow
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.berserk")
			if type(ability_array) == "table" then
				for i = 1, #ability_array do
					local ability_id = get_p(ability_array[i], "id") or "none"
					if ability_id == "rage" then
						attack_eval.value = attack_eval.value * modifiers.rage
						attack_eval.specials = true
					elseif ability_id == "berserk" then
						attack_eval.value = attack_eval.value * modifiers.berserk
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.damage")
			if type(ability_array) == "table" then
				for i = 1, #ability_array do
					local ability_id = get_p(ability_array[i], "id") or "none"
					if ability_id == "evasion" then
						attack_eval.value = attack_eval.value * modifiers.evasion
						attack_eval.specials = true
					elseif ability_id == "goliath_bane" then
						attack_eval.value = attack_eval.value * modifiers.goliath
						attack_eval.specials = true
					elseif ability_id == "dread" then
						attack_eval.value = attack_eval.value * modifiers.dread
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.attacks")
			if type(ability_array) == "table" then
				for i = 1, #ability_array do
					local ability_id = get_p(ability_array[i], "id") or "none"
					if ability_id == "storm" then
						attack_eval.value = attack_eval.value * modifiers.storm
						attack_eval.specials = true
					elseif ability_id == "brutal" then
						attack_eval.value = attack_eval.value * modifiers.brutal
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.firststrike")
			if type(ability_array) == "table" then
				for i = 1, #ability_array do
					local ability_id = get_p(ability_array[i], "id") or "none"
					if ability_id == "firststrike" then
						attack_eval.value = attack_eval.value * modifiers.firststrike
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.dummy")
			if type(ability_array) == "table" then
				for i = 1, #ability_array do
					local ability_id = get_p(ability_array[i], "id") or "none"
					if ability_id == "slashdash" then
						attack_eval.value = attack_eval.value * modifiers.slashdash
						attack_eval.specials = true
					elseif ability_id == "cleave" then
						attack_eval.value = attack_eval.value * modifiers.cleave
						attack_eval.specials = true
					elseif ability_id == "remaining_ammo" then
						attack_eval.value = attack_eval.value * modifiers.ammo
						attack_eval.specials = true
					elseif ability_id == "bloodlust" then
						attack_eval.value = attack_eval.value * modifiers.bloodlust
						attack_eval.specials = true
					elseif ability_id == "grace" then
						attack_eval.value = attack_eval.value * modifiers.grace
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.poison")
			if type(ability_array) == "table" then
				for i = 1, #ability_array do
					local ability_id = get_p(ability_array[i], "id") or "none"
					if ability_id == "poison" then
						attack_eval.value = attack_eval.value + modifiers.poison + get_p(attack_array[i], "number")
						attack_eval.specials = true
					end
				end
			end
			ability_array = get_p(attack_array[i], "specials.chance_to_hit")
			if type(ability_array) == "table" then
				for i = 1, #ability_array do
					local ability_id = get_p(ability_array[i], "id") or "none"
					if ability_id == "magical" then
						attack_eval.value = attack_eval.value * modifiers.magical
						attack_eval.specials = true
					elseif ability_id == "marksman" then
						attack_eval.value = attack_eval.value * modifiers.marksman
						attack_eval.specials = true
					elseif ability_id == "riposte" then
						attack_eval.value = attack_eval.value * modifiers.riposte
						attack_eval.specials = true
					elseif ability_id == "pointpike" then
						attack_eval.value = attack_eval.value * modifiers.pointpike
						attack_eval.specials = true
					elseif ability_id == "ensnare" then
						attack_eval.value = attack_eval.value * modifiers.ensnare
						attack_eval.specials = true
					elseif ability_id == "accuracy" then
						attack_eval.value = attack_eval.value * modifiers.accuracy
						attack_eval.specials = true
					end
				end
			end
			table.insert(values[get_p(attack_array[i], "range")], attack_eval)
		end
		local melee_val, ranged_val = process_attack_set(values.melee), process_attack_set(values.ranged)
		if melee_val > ranged_val then
			values.attacks = melee_val + ranged_val * 0.5
		else
			values.attacks = ranged_val + melee_val * 0.5
		end
	end
	return values.hp * (values.defense + values.resists) * values.moves * values.attacks / 3005.6
end

local function find_equipment_value(unit)
	local function total_type_value(equipment_type)
		local equipment_array, value = get_p(unit, "variables.inventory." .. equipment_type), 0
		if type(equipment_array) == "table" then
			for i = 1, #equipment_array do
				value = value + math.floor((get_p(equipment_array[i], "absolute_value") or 0) * 0.2 + 0.5)
			end
		end
		return value
	end
	return total_type_value("weapons.melee") + total_type_value("weapons.ranged") + total_type_value("armor.head") + total_type_value("armor.torso") + total_type_value("armor.legs") + total_type_value("armor.shield")
end

function construct_unit(var, unstore)
	local unit = parse_container(wesnoth.get_variable(var))
	local player = get_p(unit, "side") <= wesnoth.get_variable("const.max_player_count") and get_p(unit, "canrecruit")

	if (get_p(unit, "variables.abilities.faerie_touch") or 0) > 0 and get_p(unit, "variables.inventory.weapons.melee[0].description") ~= "faerie touch" then
		local faerie_touch = get_p(unit, "variables.inventory.weapons.melee[0]")
		set_p(faerie_touch, "special_type", { magical_to_hit = 1 })
		faerie_touch = unparse_container(faerie_touch)
		faerie_touch.icon = "touch-faerie"
		faerie_touch.user_name = "faerie touch"
		faerie_touch.description = "faerie touch"
		faerie_touch.class = "magical"
		faerie_touch.class_description = "Magical"
		if get_p(unit, "variables.abilities.faerie_touch") == 2 then
			faerie_touch.type = "arcane"
		end
		faerie_touch.body_damage_rate = 0
		faerie_touch.deft_damage_rate = 5
		faerie_touch.mind_damage_rate = 10
		faerie_touch.deft_number_rate = 5
		faerie_touch.mind_number_rate = 5
		set_p(unit, "variables.inventory.weapons.melee[0]", adjustWeaponDescription(faerie_touch))
	elseif (get_p(unit, "variables.abilities.lich_touch") or 0) == 1 and get_p(unit, "variables.inventory.weapons.melee[0].description") ~= "lich touch" then
		local lich_touch = get_p(unit, "variables.inventory.weapons.melee[0]")
		set_p(lich_touch, "special_type", { spell_drains = 1 })
		lich_touch = unparse_container(lich_touch)
		lich_touch.icon = "touch-faerie"
		lich_touch.user_name = "lich touch"
		lich_touch.description = "lich touch"
		lich_touch.class = "magical"
		lich_touch.class_description = "Magical"
		lich_touch.type = "arcane"
		lich_touch.body_damage_rate = 0
		lich_touch.deft_damage_rate = 5
		lich_touch.mind_damage_rate = 10
		lich_touch.deft_number_rate = 5
		lich_touch.mind_number_rate = 5
		set_p(unit, "variables.inventory.weapons.melee[0]", adjustWeaponDescription(lich_touch))
	end
	clear_p(unit, "variables.inventory.type")
	local weapon_list = get_p(unit, "variables.inventory.weapons.melee") or {}
	for i = 1, #weapon_list do
		local weapon_class_path = "variables.inventory.type." .. get_p(weapon_list[i], "class")
		set_p(unit, weapon_class_path, 1 + (get_p(unit, weapon_class_path) or 0))
		local thrown = get_p(weapon_list[i], "thrown")
		if thrown then
			weapon_class_path = "variables.inventory.type." .. get_p(weapon_list[i], "thrown.class")
			set_p(unit, weapon_class_path, 1 + (get_p(unit, weapon_class_path) or 0))
		end
	end
	weapon_list = get_p(unit, "variables.inventory.weapons.ranged") or {}
	for i = 1, #weapon_list do
		local weapon_class_path = "variables.inventory.type." .. get_p(weapon_list[i], "class")
		set_p(unit, weapon_class_path, 1 + (get_p(unit, weapon_class_path) or 0))
		if weapon_class_path == "thunderstick" then
			local max_damage = get_p(weapon_list[i], "max_damage")
			if max_damage > get_p(weapon_list[i], "damage") and get_p(weapon_list[i], "level") <= (get_p(unit, "variables.abilities.thunderstick_tinker") or 0) then
				set_p(unit, string.format("variables.inventory.weapons.ranged[%d].damage", i - 1), max_damage)
			end
		end
	end

	local equipment = get_unit_equipment(unit)
	local evade = 3 * (get_p(unit, "variables.evade_level") or 0) + (get_p(equipment.head_armor, "evade_adjust") or 0) + (get_p(equipment.torso_armor, "evade_adjust") or 0) + (get_p(equipment.leg_armor, "evade_adjust") or 0) + (get_p(equipment.shield, "evade_adjust") or 0) + (get_p(equipment.melee_1, "evade_adjust") or 0)
	if equipment.melee_2 then
		evade = evade + (get_p(equipment.melee_2, "evade_adjust") or 0)
		if equipment.melee_3 then
			evade = evade + (get_p(equipment.melee_3, "evade_adjust") or 0)
		end
	end
	set_p(unit, "variables.mobility", math.max(0, math.min(2, math.floor(evade / 4))))
	set_p(unit, "variables.abstract_moves", get_p(unit, "variables.max_moves"))
	if (not player) and (get_p(unit, "variables.abilities.minotaur_magic") or 0) == 2 then
		set_p(unit, "max_moves", 8)
	else
		set_p(unit, "max_moves", math.floor(get_p(unit, "variables.max_moves") * math.min(1, 1 + evade * 0.01)))
	end
	set_p(unit, "moves", math.min(get_p(unit, "moves"), get_p(unit, "max_moves")))
	local function set_resist(resist)
		set_p(unit, "resistance." .. resist, math.max(0, get_p(unit, "variables.resistance." .. resist)) - get_p(equipment.head_armor, "resistance." .. resist) - get_p(equipment.torso_armor, "resistance." .. resist) - get_p(equipment.leg_armor, "resistance." .. resist))
	end
	set_resist("arcane")
	set_resist("blade")
	set_resist("cold")
	set_resist("fire")
	set_resist("impact")
	set_resist("pierce")

	if (not player) and (get_p(unit, "variables.abilities.minotaur_magic") or 0) > 0 then
		set_p(unit, "resistance.fire", math.max(0, get_p(unit, "resistance.fire") - 20))
	end

	local shield_recoup = get_p(equipment.shield, "terrain_recoup") or 0
	local function set_movetype(terrain)
		local function check_num(data)
			if type(data) ~= "number" then
				H.wml_error(tostring(data) .. "is not a number")
			end
		end
		set_p(unit, "defense." .. terrain, math.max(20, get_p(unit, string.format("variables.terrain.%s.defense", terrain)) - math.max(0, evade) + math.max(0, get_p(equipment.torso_armor, string.format("terrain.%s.defense", terrain)) + get_p(equipment.leg_armor, string.format("terrain.%s.defense", terrain)) - shield_recoup)))
		local fixed_move = get_p(unit, string.format("variables.terrain.%s.movement", terrain))
		if fixed_move == 0 then
			fixed_move = 99
		end
		set_p(unit, "movement_costs." .. terrain, fixed_move)
	end
	set_movetype("unwalkable")
	set_movetype("castle")
	set_movetype("village")
	set_movetype("shallow_water")
	set_movetype("deep_water")
	set_movetype("flat")
	set_movetype("forest")
	set_movetype("hills")
	set_movetype("mountains")
	set_movetype("swamp_water")
	set_movetype("sand")
	set_movetype("cave")
	set_movetype("impassable")
	set_movetype("frozen")
	set_movetype("fungus")
	set_movetype("reef")

	if (get_p(unit, "variables.abilities.faerie_form") or 0) == 1 then
		set_p(unit, "resistance.impact", get_p(unit, "resistance.impact") + 10)
		set_p(unit, "movement_costs.shallow_water", 1)
		set_p(unit, "movement_costs.deep_water", 2)
		set_p(unit, "movement_costs.hills", 1)
		set_p(unit, "movement_costs.mountains", 2)
		set_p(unit, "movement_costs.swamp_water", 1)
		set_p(unit, "movement_costs.sand", 1)
		set_p(unit, "movement_costs.cave", 2)
		set_p(unit, "movement_costs.frozen", 1)
		set_p(unit, "movement_costs.reef", 1)
		set_p(unit, "defense.reef", math.max(20, get_p(unit, "defense.reef") - 20))
		set_p(unit, "defense.deep_water", math.max(20, get_p(unit, "defense.deep_water") - 10))
		set_p(unit, "defense.flat", math.max(20, get_p(unit, "defense.flat") - 10))
		set_p(unit, "defense.frozen", math.max(20, get_p(unit, "defense.frozen") - 10))
		set_p(unit, "defense.sand", math.max(20, get_p(unit, "defense.sand") - 10))
		set_p(unit, "defense.shallow_water", math.max(20, get_p(unit, "defense.shallow_water") - 10))
		set_p(unit, "defense.swamp_water", math.max(20, get_p(unit, "defense.swamp_water") - 10))
	elseif not player then
		if (get_p(unit, "variables.abilities.minotaur_magic") or 0) == 2 then
			set_p(unit, "defense", {
				unwalkable = 70,
				castle = 50,
				village = 50,
				shallow_water = 80,
				deep_water = 90,
				flat = 70,
				forest = 40,
				hills = 50,
				mountains = 30,
				swamp_water = 80,
				sand = 70,
				cave = 50,
				impassable = 70,
				frozen = 70,
				fungus = 50,
				reef = 70
			})
			set_p(unit, "movement_costs", {
				unwalkable = 1,
				castle = 1,
				village = 1,
				shallow_water = 2,
				deep_water = 2,
				flat = 1,
				forest = 1,
				hills = 1,
				mountains = 1,
				swamp_water = 1,
				sand = 1,
				cave = 1,
				impassable = 99,
				frozen = 1,
				fungus = 1,
				reef = 2
			})
		elseif (get_p(unit, "variables.abilities.devling_flyer") or 0) == 1 then
			set_p(unit, "defense", {
				unwalkable = 50,
				castle = 50,
				village = 50,
				shallow_water = 50,
				deep_water = 50,
				flat = 50,
				forest = 50,
				hills = 50,
				mountains = 50,
				swamp_water = 50,
				sand = 50,
				cave = 50,
				impassable = 50,
				frozen = 50,
				fungus = 50,
				reef = 50
			})
			set_p(unit, "movement_costs", {
				unwalkable = 1,
				castle = 1,
				village = 1,
				shallow_water = 1,
				deep_water = 1,
				flat = 1,
				forest = 1,
				hills = 1,
				mountains = 1,
				swamp_water = 1,
				sand = 1,
				cave = 1,
				impassable = 99,
				frozen = 1,
				fungus = 1,
				reef = 1
			})
		end
	end

	set_p(unit, "variables.firststrike_flag", 0)
	set_p(unit, "variables.unpoisonable_flag", 0)

	local old_traits, new_traits = get_p(unit, "modifications.trait"), {}
	if player then
		table.insert(new_traits, parse_container({
			id = "mana_counter",
			name = string.format("mana: %d/%d", get_p(unit, "variables.abilities.magic_casting.mana"), get_p(unit, "variables.abilities.magic_casting.max_mana")),
			description = " Available mana / maximum stored mana."
		}))
	end
	if type(old_traits) == "table" then
		for i = 1, #old_traits do
			local trait_id = get_p(old_traits[i], "id")
			if trait_id ~= "mana_counter" and trait_id ~= "healthy" and trait_id ~= "fearless" then
				table.insert(new_traits, old_traits[i])
			end
		end
	end
	if (get_p(unit, "variables.abilities.healthy") or 0) > 0 then
		table.insert(new_traits, parse_container({
			id = "healthy",
			name = "healthy",
			description = "Can rest while moving, halves poison damage."
		}))
	end
	if (get_p(unit, "variables.abilities.fearless") or 0) > 0 then
		table.insert(new_traits, parse_container({
			id = "fearless",
			name = "fearless",
			description = "Fight normally during unfavorable times of day/night."
		}))
	end
	clear_p(unit, "modifications.trait")
	for i = 1, #new_traits do
		set_p(unit, string.format("modifications.trait[%d]", i - 1), new_traits[i], true)
	end

	clear_p(unit, "halo")
	local abilities = {}
	if (get_p(unit, "variables.abilities.illuminates") or 0) == 1 and get_p(unit, "alignment") == "lawful" then
		set_p(unit, "halo", "halo/illuminates-aura.png")
		table.insert(abilities, { "illuminates", {
			id = "illumination",
			value = 25,
			max_value = 25,
			cumulative = "no",
			name = "illuminates",
			description = "Illuminates:\
This unit illuminates the surrounding area, making lawful units fight better, and chaotic units fight worse.\
\
Any units adjacent to this unit will fight as if it were dusk when it is night, and as if it were day when it is dusk.",
			affect_self = "yes"
		} })
	elseif not player then
		local halo_level = get_p(unit, "variables.abilities.witch_magic") or 0
		if halo_level == 2 then
			set_p(unit, "halo", "halo/coldaura.png")
			table.insert(abilities, { "resistance", {
				id = "coldaura",
				add = 50,
				max_value = 50,
				apply_to = "fire",
				name = "cold aura",
				description = "Cold Aura:\
Adjacent units receive a 50% bonus to fire resistance and a -25% bonus to cold resistance. All cold spells are very powerful here.",
				affect_self = "yes",
				affect_allies = "yes",
				affect_enemies = "yes",
				{ "affect_adjacent", {
					adjacent = "n,ne,se,s,sw,nw"
				} }
			} })
			table.insert(abilities, { "resistance", {
				id = "coldaura_2",
				add = -25,
				max_value = -25,
				apply_to = "cold",
				affect_self = "yes",
				affect_allies = "yes",
				affect_enemies = "yes",
				{ "affect_adjacent", {
					adjacent = "n,ne,se,s,sw,nw"
				} }
			} })
		elseif halo_level == 3 then
			set_p(unit, "halo", "halo/dark-cleric-aura.png")
			table.insert(abilities, { "leadership", {
				id = "darkaura",
				value = -25,
				cumulative = "no",
				name = "dark aura",
				description = "Dark aura makes all enemy units fight worse (-25% for attack).",
				affect_self = "no",
				affect_allies = "no",
				affect_enemies = "yes",
				{ "affect_adjacent", {
					adjacent = "n,ne,se,s,sw,nw"
				} }
			} })
		elseif halo_level == 4 then
			set_p(unit, "halo", "halo/deadzone.png")
			table.insert(abilities, { "resistance", {
				id = "deadzone",
				add = 99,
				max_value = 99,
				apply_to = "fire,cold,arcane",
				name = "deadzone",
				description = "Deadzone:\
Adjacent friendly units receive a 99% bonus to fire,cold and arcane resistance",
				affect_self = "yes",
				affect_allies = "yes",
				{ "affect_adjacent", {
					adjacent = "n,ne,se,s,sw,nw"
				} }
			} })
			table.insert(abilities, { "regenerate", {
				id = "regenerates",
				value = 8,
				name = "regenerates",
				female_name = "female^regenerates",
				description = "Regenerates:\
The unit will heal itself 8 HP per turn. If it is poisoned, it will remove the poison instead of healing.",
				affect_self = "yes",
				poison = "cured"
			} })
		end
	end

	if not player then
		if (get_p(unit, "variables.abilities.water") or 0) == 1 then
			table.insert(abilities, { "regenerate", {
				id = "regenerates",
				value = 6,
				name = "water",
				description = "Made of Water:\
This unit is made of water. As a result, if it is standing in water, it will receive 6 hp. If it is poisoned, it will remove it instead of healing.",
				name_inactive = "water",
				description_inactive = "Made of Water:\
This unit is made of water. As a result, if it is standing in water, it will receive 6 hp. If it is poisoned, it will remove it instead of healing.",
				affect_self = "yes",
				poison = "cured",
				{ "filter_self", {
					{ "filter_location", {
						terrain = "W*,S*"
					} }
				} }
			} })
		elseif (get_p(unit, "variables.abilities.rock") or 0) == 1 then
			table.insert(abilities, { "regenerate", {
				id = "regenerates",
				value = 6,
				name = "rock",
				description = "Made of Rock:\
This unit is made of rock. If it stands in loose rock, it will recive 6 hp. If it is poisoned, it will remove it instead of healing.",
				name_inactive = "rock",
				description_inactive = "Made of Rock:\
This unit is made of rock. If it stands in loose rock, it will recive 6 hp. If it is poisoned, it will remove it instead of healing.",
				affect_self = "yes",
				poison = "cured",
				{ "filter_self", {
					{ "filter_location", {
						terrain = "Uh,*^Dr,M*"
					} }
				} }
			} })
		elseif (get_p(unit, "variables.abilities.fire") or 0) == 1 then
			table.insert(abilities, { "regenerate", {
				id = "regenerates",
				value = 6,
				name = "fire",
				description = "Made of Fire:\
This unit is made of fire. If it stands in lava, it will recive 6 hp. If it is poisoned, it will remove it instead of healing.",
				name_inactive = "fire",
				description_inactive = "Made of Fire:\
This unit is made of fire. If it stands in lava, it will recive 6 hp. If it is poisoned, it will remove it instead of healing.",
				affect_self = "yes",
				poison = "cured",
				{ "filter_self", {
					{ "filter_location", {
						terrain = "Ql*"
					} }
				} }
			} })
		end
		local divine_health = get_p(unit, "variables.abilities.divine_health") or 0
		if divine_health == 1 then
			table.insert(abilities, { "regenerate", {
				id = "divine_health",
				value = 3,
				name = "divine health",
				description = "Divine Health: Due to this unit's relationship with its deity it is granted a magical body in which the magic is manifested as the ability to self heal. Thus this unit will be healed by 3 HP per turn, poison will not be prolonged or cured...",
				affect_self = "yes",
			} })
		elseif divine_health == 2 then
			table.insert(abilities, { "regenerate", {
				id = "divine_health_enahanced",
				value = 6,
				name = "divine health en",
				description = "Divine Health: Due to this unit's relationship with its deity it is granted a magical body in which the magic is manifested as the ability to self heal. Thus this unit will be healed by 3 HP per turn, poison will not be prolonged or cured...",
				affect_self = "yes",
			} })
		end
		if (get_p(unit, "variables.abilities.feeding") or 0) == 1 then
			table.insert(abilities, { "dummy", {
				id = "wbd_feeding",
				name = "feeding",
				female_name= "female^feeding",
				description="Feeding:\
This unit gains 1 hitpoint added to its maximum whenever it kills a living unit."
			} })
		end
		local spell_power = get_p(unit, "variables.abilities.magic_casting.power") or 0
		if (get_p(unit, "variables.abilities.human_magic") or 0) == 3 then
			spell_power = spell_power * 3 + 2
		elseif (get_p(unit, "variables.abilities.nature_heal") or 0) == 1 then
			spell_power = spell_power * 2 + 4
		elseif (get_p(unit, "variables.abilities.swamp_magic") or 0) > 0 then
			if (get_p(unit, "variables.abilities.benevolent") or 0) > 0 then
				spell_power = spell_power * 3
			end
			spell_power = spell_power + 4
		elseif (get_p(unit, "variables.abilities.witchcraft") or 0) > 0 then
			spell_power = spell_power * 2 + 2
		elseif (get_p(unit, "variables.abilities.minotaur_magic") or 0) == 3 then
			spell_power = spell_power * 2 + 6
		else
			spell_power = 0
		end
		if spell_power > 0 then
			if spell_power > 7 then
				table.insert(abilities, { "heals", {
					id = "curing",
					name = "cures",
					description = "Cures:\
A curer can cure a unit of poison, although that unit will receive no additional healing on the turn it is cured of the poison.",
					poison = "cured",
					affect_allies = "yes",
					affect_self = "yes",
					{ "affect_adjacent", {
						adjacent = "n,ne,se,s,sw,nw"
					} }
				} })
			end
			table.insert(abilities, { "heals", {
				id = "healing",
				value = spell_power,
				name = string.format("heals +%d", spell_power),
				description = string.format("Heals +%d:\
Allows the unit to heal adjacent allied units at the beginning of our turn.\
\
A unit cared for by this healer may heal up to %d HP per turn, or stop poison from taking effect for that turn.", spell_power, spell_power),
				poison = "slowed",
				affect_allies = "yes",
				affect_self = "yes",
				{ "affect_adjacent", {
					adjacent = "n,ne,se,s,sw,nw"
				} }
			} })
		end
	end
	local skill_level = get_p(unit, "variables.abilities.steadfast") or 0
	if skill_level > 0 and (get_p(equipment.shield, "special_type.steadfast") or 0) == 1 then
		local new_ability = {
			id = "steadfast",
			multiply = 2,
			apply_to = "blade,pierce,impact,fire,cold,arcane",
			name = "steadfast",
			affect_self = "yes",
			active_on = "defense",
			{ "filter_base_value", {
				greater_than = 0,
			} }
		}
		if player then
			new_ability.max_value = 30 + 10 * skill_level
			new_ability[1][2].less_than_equal_to = new_ability.max_value
			new_ability.description = string.format("Steadfast Level %d:\
This unit's resistances are doubled, up to a maximum of %d%%, when defending. Vulnerabilities are not affected.", skill_level, new_ability.max_value)
		else
			new_ability.max_value = 50
			new_ability[1][2].less_than_equal_to = 50
			new_ability.description = "Steadfast:\
This unit's resistances are doubled, up to a maximum of 50%, when defending. Vulnerabilities are not affected."
		end
		table.insert(abilities, { "resistance", new_ability })
	end
	skill_level = get_p(unit, "variables.abilities.leadership") or 0
	if skill_level > 0 and (get_p(unit, "variables.abilities.cruelty") or 0) == 1 then
		local chaotic = { "filter_wml", {
			alignment = "chaotic"
		} }
		local non_chaotic = { "filter_wml", {
			{ "not", {
				alignment = "chaotic"
			} }
		} }
		table.insert(abilities, { "leadership", {
			id = "leadership",
			name = "cruelty",
			affect_self = "no",
			affect_allies = "yes",
			cumulative = "no",
			description = string.format("Leadership Level %d:\
This unit can lead friendly units that are next to it, making them fight better.\
\
Adjacent friendly units of lower level will do more damage in battle. When a unit adjacent to, of a lower level than, and on the same side as a unit with Leadership engages in combat, its attacks do 30%% more damage times the difference in their levels if chaotic, 20%% if non-chaotic.", skill_level),
			value = 30 * skill_level,
			{ "affect_adjacent", {
				adjacent = "n,ne,se,s,sw,nw",
				{ "filter", {
					level = 0,
					chaotic
				} }
			} }
		} })
		local new_ability = {
			id = "leadership",
			affect_self = "no",
			affect_allies = "yes",
			cumulative = "no",
			value = 20 * skill_level,
			{ "affect_adjacent", {
				adjacent = "n,ne,se,s,sw,nw",
				{ "filter", {
					level = 0,
					non_chaotic
				} }
			} }
		}
		table.insert(abilities, { "leadership", new_ability })
		for i = 1, skill_level - 1 do
			new_ability.value = 30 * (skill_level - i)
			new_ability[1][2][1][2] = {
				level = i,
				chaotic
			}
			table.insert(abilities, { "leadership", new_ability })
			new_ability.value = 20 * (skill_level - i)
			new_ability[1][2][1][2] = {
				level = i,
				non_chaotic
			}
			table.insert(abilities, { "leadership", new_ability })
		end
	elseif skill_level > 0 then
		table.insert(abilities, { "leadership", {
			id = "leadership",
			name = "leadership",
			affect_self = "no",
			affect_allies = "yes",
			cumulative = "no",
			description = string.format("Leadership Level %d:\
This unit can lead friendly units that are next to it, making them fight better.\
\
Adjacent friendly units of lower level will do more damage in battle. When a unit adjacent to, of a lower level than, and on the same side as a unit with Leadership engages in combat, its attacks do 25%% more damage times the difference in their levels.", skill_level),
			value = 25 * skill_level,
			{ "affect_adjacent", {
				adjacent = "n,ne,se,s,sw,nw",
				{ "filter", {
					level = 0
				} }
			} }
		} })
		if skill_level > 1 then
			local new_ability = {
				id = "leadership",
				affect_self = "no",
				affect_allies = "yes",
				cumulative = "no",
				{ "affect_adjacent", {
					adjacent = "n,ne,se,s,sw,nw",
					{ "filter", {} }
				} }
			}
			for i = 1, skill_level - 1 do
				new_ability.value = 25 * (skill_level - i)
				new_ability[1][2][1][2].level = i
				table.insert(abilities, { "leadership", new_ability })
			end
		end
	end
	if not player then
		if (get_p(unit, "variables.abilities.battle_tutor") or 0) == 1 then
			table.insert(abilities, { "dummy", {
				id = "battletutor",
				name = "battle tutor",
				description = "Battle Tutor:\
This unit's ability to teach battle skills gives each adjacent allied unit a +1 to experience earned in battle."
			} })
		end
		if (get_p(unit, "npc_init.abilities.skeletal") or 0) == 1 then
			table.insert(abilities, { "hides", {
				id = "submerge",
				name = "submerge",
				female_name = "female^submerge",
				description = "Submerge:\
This unit can hide in deep water, and remain undetected by its enemies.\
\
Enemy units cannot see this unit while it is in deep water, except if they have units next to it. Any enemy unit that first discovers this unit immediately loses all its remaining movement.",
			        name_inactive = "submerge",
			        female_name_inactive = "female^submerge",
			        description_inactive = "Submerge:\
This unit can hide in deep water, and remain undetected by its enemies.\
\
Enemy units cannot see this unit while it is in deep water, except if they have units next to it. Any enemy unit that first discovers this unit immediately loses all its remaining movement.",
					affect_self = "yes",
					{ "filter_self", {
						{ "filter_location", {
							terrain = "Wo"
						} }
					} }
			} })
		end
	end
	if (get_p(unit, "variables.abilities.loner") or 0) == 1 then
		table.insert(abilities, { "leadership", {
			id = "loner",
			name = "loner",
			affect_self = "yes",
			cumulative = "no",
			description = "Loner\
This unit is 25% more effective in combat when not adjacent to any allied units.",
			value = 25,
			{ "filter", {
				{ "not", {
					{ "filter_adjacent", {
						is_enemy = "false"
					} }
				} }
			} }
		} })
	end
	local skirmisher_flag = false
	if (evade > 1 or get_p(unit, "race") == "undead") and (get_p(unit, "variables.abilities.skirm") or 0) > 0 then
		skirmisher_flag = true
		table.insert(abilities, { "skirmisher", {
			id = "skirmisher",
			name = "skirmisher",
			affect_self = "yes",
			description = "Skirmisher: This unit is skilled in moving past enemies quickly, and ignores all enemy Zones of Control."
		} })
		if (get_p(unit, "variables.abilities.distract") or 0) > 0 then
			table.insert(abilities, { "skirmisher", {
				id = "distract",
				name = "distract",
				affect_self = "no",
				affect_allies = "yes",
				description = "Distract:\
This unit negates enemy Zones of Control around itself for allied units (but not for itself).",
				{ "affect_adjacent", {
					adjacent = "n,ne,se,s,sw,nw"
				} }
			} })
		end
	end
	local dash_flag = evade > 5 and (get_p(unit, "variables.abilities.dash") or 0) > 0
	if dash_flag then
		table.insert(abilities, { "dummy", {
			id = "dash",
			name = "dash",
			description = "This unit can use remaining movement points after attacking."
		} })
		set_p(unit, "variables.status.dash", 1)
	else
		set_p(unit, "variables.status.dash", 0)
	end
	if evade > 0 then
		if evade > 3 then
			if (get_p(unit, "variables.abilities.ambush_forest") or 0) > 0 then
				table.insert(abilities, { "hides", {
					id = "ambush_forest",
					name = "ambush",
					name_inactive = "ambush",
					affect_self = "yes",
					description = "Ambush:\
This unit can hide in forest if wearing only light armor.",
					description_inactive = "Ambush:\
This unit can hide in forest if wearing only light armor.",
					{ "filter_self", {
						{ "filter_location", {
							terrain = "*^F*"
						} }
					} }
				} })
			end
			if (get_p(unit, "variables.abilities.ambush_mountains") or 0) > 0 then
				table.insert(abilities, { "hides", {
					id = "ambush_mountains",
					name = "ambush",
					name_inactive = "ambush",
					affect_self = "yes",
					description = "Ambush:\
This unit can hide in mountains if wearing only light armor.",
					description_inactive = "Ambush:\
This unit can hide in mountains if wearing only light armor.",
					{ "filter_self", {
						{ "filter_location", {
							terrain = "M*,M*^*"
						} }
					} }
				} })
			end
			if evade > 7 and (get_p(unit, "variables.abilities.sneak") or 0) > 0 then
				table.insert(abilities, { "hides", {
					id = "sneak",
					name = "sneak",
					name_inactive = "sneak",
					affect_self = "yes",
					description = "Sneak: This unit can hide from enemies if it has used no more than half of its movement points and light armor.",
					description_inactive = "Sneak: This unit can hide from enemies if it has used no more than half of its movement points and light armor.",
					{ "filter", {
						{ "filter_wml", {
							{ "variables", { stealthiness = 1 } }
						} }
					} }
				} })
				set_p(unit, "variables.stealthiness", math.min(1, 2 * get_p(unit, "moves") - get_p(unit, "max_moves") + 1))
				set_p(unit, "status.hidden", "yes")
			end
		end
		if (not player) and (get_p(unit, "variables.abilities.nightstalk") or 0) > 0 then
			table.insert(abilities, { "hides", {
				id = "nightstalk",
				name = "nightstalk",
				female_name = "nightstalk",
				name_inactive = "nightstalk",
				female_name_inactive = "nightstalk",
				affect_self = "yes",
				description = "Nightstalk:\
The unit becomes invisible during night.\
\
Enemy units cannot see this unit at night, except if they have units next to it. Any enemy unit that first discovers this unit immediately loses all its remaining movement.",
				description_inactive = "Nightstalk:\
The unit becomes invisible during night.\
\
Enemy units cannot see this unit at night, except if they have units next to it. Any enemy unit that first discovers this unit immediately loses all its remaining movement.",
				{ "filter_self", {
					{ "filter_location", {
						time_of_day = "chaotic"
					} }
				} }
			} })
		end
	end
	skill_level = 2 * (get_p(unit, "variables.abilities.regen") or 0)
	if skill_level > 0 then
		local new_ability = {
			id = "regenerate",
			name = string.format("regenerate +%d", skill_level),
			value = skill_level
		}
		if skill_level > 7 then
			new_ability.description = string.format("Regenerates:\
The unit will heal itself %d HP per turn. If it is poisoned, it will remove the poison instead of healing.", skill_level)
			new_ability.poison = "cured"
		else
			new_ability.description = string.format("Regenerates:\
The unit will heal itself %d HP per turn. If it is poisoned, it will slow the poison until cured.", skill_level)
			new_ability.poison = "slowed"
		end
		table.insert(abilities, { "regenerate", new_ability })
	end
	if (get_p(unit, "variables.abilities.survivalist") or 0) > 0 then
		table.insert(abilities, { "regenerate", {
			id = "survivalist",
			name = "survivalist",
			value = 8,
			description = "Survivalist:\
The unit will heal itself 8 HP per turn if in a forest. If it is poisoned, it will remove the poison instead of healing.",
			poison = "cured",
			{ "filter_self", {
				{ "filter_location", {
					terrain = "*^Fp,*^Fet,*^Ft,*^Fpa"
				} }
			} }
		} })
	end

	if player then
		local spell_list, spell_power = get_p(unit, "variables.inventory.spells"), get_p(unit, "variables.abilities.magic_casting.power")
		if type(spell_list) == "table" then
			for i = 1, #spell_list do
				local spell_name = get_p(spell_list[i], "user_name")
				if spell_name == "heals" then
					local heal_type, heal_power = get_p(spell_list[i], "command")
					if heal_type == "green_healing" then
						heal_power = 2 * spell_power + 4
					elseif heal_type == "spirit_healing" and (get_p(unit, "variables.abilities.benevolent") or 0) <= 0 then
						heal_power = spell_power + 4
					else
						heal_power = 3 * spell_power + 4
					end
					set_p(unit, string.format("variables.inventory.spells[%d].mana_cost", i - 1), math.floor(heal_power / 4) + 1)
					table.insert(abilities, { "heals", {
						id = "rpg_heals",
						name = "heals",
						description = string.format("Heals +%d:\
	<small>This can heal %d hit points.</small>", heal_power, heal_power)
					} })
					if heal_power > 7 then
						table.insert(abilities, { "heals", {
							id = "rpg_cures",
							name = "cures",
							description = string.format("Heals +%d:\
		<small>This can heal %d hit points.</small>", heal_power, heal_power)
						} })
						set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Heals +%d:\
	<small>Heal %d hitpoints. Cure if the unit is poisoned.</small>", heal_power, heal_power))
					else
						set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Heal %d hitpoints.", heal_power))
					end
				elseif spell_name == "silver_teleport" then
					table.insert(abilities, { "heals", {
						id = "rpg_teleport",
						name = "teleport",
						description = string.format("Teleport:\
	This unit may teleport %d hexes away granted it is an empty location that the unit can move to normally.", 2 * spell_power)
					} })
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Teleport:\
	<small>Teleport %d hexes away.</small>", 2 * spell_power))
				elseif spell_name == "phoenix_fire" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Phoenix Fire:\
	<small>Upon death, return to %d hitpoints. Amount decreases by 4 per turn.</small>", 4 * spell_power + 4))
					set_p(unit, string.format("variables.inventory.spells[%d].mana_cost", i - 1), "mana_cost", 2 * spell_power + 2)
				elseif spell_name == "mapping" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Magic Mapping:\
	<small>Removes shroud within a radius of %d hexes.</small>", 5 * spell_power + 10))
				elseif spell_name == "detect_gold" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Detect Gold:\
	<small>Shows gold within a radius of %d hexes.</small>", 4 * spell_power + 20))
				elseif spell_name == "detect_units" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Detect Units:\
	<small>Shows units within a radius of %d hexes.</small>", 5 * spell_power + 15))
				elseif spell_name == "improved_detect_units" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Improved Detect Units:\
	<small>Shows units within a radius of %d hexes.</small>", 4 * spell_power + 12))
				elseif spell_name == "summon_fire_elemental" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Summon Fire Elemental:\
	<small>Summon a fire elemental with a max level of %d.</small>", math.min(3, spell_power)))
				elseif spell_name == "summon_water_elemental" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Summon Water Elemental:\
	<small>Summon a water elemental with a max level of %d.</small>", math.min(3, spell_power)))
				elseif spell_name == "summon_earth_elemental" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Summon Earth Elemental:\
	<small>Summon an earth elemental with a max level of %d.</small>", math.min(3, spell_power)))
				elseif spell_name == "summon_air_elemental" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Summon Air Elemental:\
	<small>Summon an air elemental with a max level of %d.</small>", math.min(3, spell_power)))
				elseif spell_name == "protection_from_poison" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Protection from Poison:\
	<small>Protects from poison for %d rounds.</small>", spell_power))
				elseif spell_name == "protection_from_slow" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Protection from Slow:\
	<small>Protects from slowing for %d rounds.</small>", spell_power))
				elseif spell_name == "protection_armor_magic" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Magic Armor:\
	<small>Grants %d%% resistance. Amount decreases by 5%% each round.</small>", 5 * spell_power))
				elseif spell_name == "protection_from_fire" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Protection from Fire:\
	<small>Grants %d%% resistance to fire. Amount decreases by 10%% each round.</small>", 10 * spell_power))
				elseif spell_name == "metal_to_drain" then
					set_p(unit, string.format("variables.inventory.spells[%d].description", i - 1), string.format("Metal to Drain:\
	<small>Adds drain to first melee weapon, if metal, for %d rounds.</small>", spell_power))
				end
			end
		end
	end

	local spell_status = 5 * (get_p(unit, "variables.status.protection_armor_magic") or 0)
	if spell_status > 0 then
		table.insert(abilities, { "resistance", {
			id = "protection_armor_magic",
			add = spell_status,
			max_value = 200
		} })
		table.insert(abilities, { "dummy", {
			id = "protection_armor_magic",
			name = "+",
			description = string.format("This unit is protected from damage by an extra %d%%. This value degrades by 5%% every round.", spell_status)
		} })
	end
	local spell_status = 10 * (get_p(unit, "variables.status.protection_from_fire") or 0)
	if spell_status > 0 then
		table.insert(abilities, { "resistance", {
			id = "protection_from_fire",
			add = spell_status,
			max_value = 200,
			apply_to = "fire"
		} })
		table.insert(abilities, { "dummy", {
			id = "protection_from_fire",
			name = "+",
			description = string.format("This unit is protected from fire damage by an extra %d%%. This value degrades by 10%% every round.", spell_status)
		} })
	end
	spell_status = get_p(unit, "variables.status.protection_from_poison") or 0
	if spell_status > 0 then
		clear_p(unit, "status.poisoned")
		set_p(unit, "variables.unpoisonable_flag", 1)
		table.insert(abilities, { "dummy", {
			id = "protection_from_poison",
			name = "+",
			description = string.format("This unit is protected from poison for the next %d rounds.", spell_status)
		} })
	end
	spell_status = get_p(unit, "variables.status.protection_from_slow") or 0
	if spell_status > 0 then
		clear_p(unit, "status.slowed")
		set_p(unit, "variables.unslowable_flag", 1)
		table.insert(abilities, { "dummy", {
			id = "protection_from_slow",
			name = "+",
			description = string.format("This unit is protected from slowing for the next %d rounds.", spell_status)
		} })
	end
	spell_status = get_p(unit, "variables.phoenix_fire") or 0
	if spell_status > 0 then
		table.insert(abilities, { "dummy", {
			id = "phoenix_fire",
			name = "+",
			description = string.format("This unit is protected from death, and will return with %d health. This value degrades by 4 every round.", spell_status)
		} })
	end

	set_p(unit, "abilities", abilities)

	clear_p(unit, "attack")
	local attacks, variation, variation_strength = {}, "fist", 1
	local unblocked_counter, unblocked_class = 1 - (get_p(unit, "variables.blocked_attacks") or 0), get_p(unit, "variables.weapon_block_class")
	local blocked_flag = unblocked_counter == 0
	local function add_attack(weapon)
		local attack, weapon_class = get_attack_basics(unit, equipment, weapon)
		if attack.number > 0 then
			if player or get_p(unit, "type") == "Skeleton_MODRPG" then
				local attack_strength = attack.damage * attack.number
				if weapon_class ~= "spell" and (variation_strength < attack_strength) then
					variation = attack.name
					variation_strength = attack_strength
				end
			end
			if dash_flag then
				attack.movement_used = 0
			end
			local specials, new_special, special_level = {}, {}, 0
			local storm_allowed = true
			if #attacks == 0 and attack.range == "melee" then -- specials that only affect first melee weapon get handled here
				if (get_p(unit, "variables.abilities.berserk") or 0) == 1 then
					table.insert(specials, { "berserk", {
						id = "berserk",
						name = "berserk",
						description = "Berserk:\nOn offense, combat length with this weapon triples. On defense, combat length with this weapon doubles.",
						value = 3,
						active_on = "offense"
					} })
					table.insert(specials, { "berserk", {
						id = "berserk",
						name = "berserk",
						value = 2,
						active_on = "defense"
					} })
					storm_allowed = false
				elseif (get_p(unit, "variables.abilities.rage") or 0) == 1 then
					table.insert(specials, { "berserk", {
						id = "rage",
						name = "rage",
						description = "Rage:\nOn offense, combat length with this weapon doubles.",
						value = 2,
						active_on = "offense"
					} })
					storm_allowed = false
				end
				if attack.material == "metal" and (get_p(unit, "variables.status.metal_to_drain") or 0) > 0 and (get_p(weapon, "special_type.spell_drains") or 0) ~= 1 then
					set_p(weapon, "special_type.spell_drains", 2)
				end
			end
			special_level = get_p(unit, "variables.abilities.slashdash") or 0
			if special_level > 0 then
				attack.slashdash = 1
				new_special = {
					id = "slashdash",
					name = "slash+dash"
				}
				if not player then
					new_special.description = "Slash+Dash:\nWhen used offensively, every two hits with this weapon grants 1 movement point."
				elseif special_level == 1 then
					new_special.description = "Slash+Dash Level 1:\nWhen used offensively, every two hits with this weapon grants 1 movement point."
				elseif special_level == 2 then
					new_special.description = "Slash+Dash Level 2:\nWhen used offensively, every hit with this weapon grants 1 movement point."
				else
					new_special.description = "Slash+Dash Level 3:\nWhen used offensively, every hit with this weapon grants 2 movement points."
				end
				table.insert(specials, { "dummy", new_special })
			end
			local marksman_offset
			if weapon_class == "thrown_light_blade" then
				special_level = get_p(unit, "variables.abilities.marksman_thrown_light_blade") or 0
				marksman_offset = 45
			elseif (get_p(weapon, "special_type.marksman") or 0) > 0 then
				special_level = get_p(unit, "variables.abilities.marksman") or 0
				marksman_offset = 50
			elseif (not player) and attack.user_name == "chakram" then
				special_level = get_p(unit, "variables.abilities.marksman_chakram") or 0
			else
				special_level = 0
			end
			if special_level > 0 then
				new_special = {
					id = "marksman",
					name = "marksman",
					cumulative = "yes",
					active_on = "offense"
				}
				if player then
					new_special.value = marksman_offset + 5 * special_level
					new_special.description = string.format("Marksman Level %d:\nWhen used offensively, this attack always has at least a %d%% chance to hit.", special_level, new_special.value)
				else
					new_special.value = 60
					new_special.description = "Marksman:\nWhen used offensively, this attack always has at least a 60% chance to hit."
				end
				table.insert(specials, { "chance_to_hit", new_special })
			end
			if not player then
				if weapon_class == "light_blade" and (get_p(unit, "variables.abilities.accuracy_light_blade") or 0) > 0 then
					table.insert(specials, { "chance_to_hit", {
						id = "accuracy",
						name = "accuracy",
						cumulative = "yes",
						active_on = "offense",
						value = 50,
						description = "Accuracy:\
	When used offensively, this attack always has at least a 50% chance to hit."
					} })
				end
				if weapon_class == "polearm" and (get_p(unit, "variables.abilities.evasion_polearm") or 0) > 0 then
					table.insert(specials, { "damage", {
						id = "evasion",
						name = "evasion",
						name_inactive = "evasion",
						active_on = "offense",
						apply_to = "opponent",
						multiply = 0.66,
						description = "Evasion:\
	When this attack is used offensively, this unit takes one third less damage in retaliation.",
						description_inactive = "Evasion:\
	When this attack is used offensively, this unit takes one third less damage in retaliation."
					} })
				end
			end
			special_level = get_p(unit, "variables.abilities.goliath_bane") or 0
			if special_level > 0 and (get_p(weapon, "special_type.goliath_bane") or 0) > 0 then
				new_special = {
					id = "goliath_bane",
					active_on = "offense",
					{ "filter_opponent", {} }
				}
				if player then
					table.insert(specials, { "damage", {
						id = "goliath_bane",
						name = "goliath bane",
						description = string.format("Goliath Bane Level %d:\n%d%% damage bonus for each level of the enemy. Offense only.", parsed.skills.goliath_bane, 10 * parsed.skills.goliath_bane),
						multiply = 1 + 0.1 * parsed.skills.goliath_bane,
						active_on = "offense",
						{ "filter_opponent", {
							level = 1
						} }
					} })
					for i = 2, 9 do
						new_special.multiply = 1 + 0.1 * i * special_level
						new_special[1][2].level = i
						table.insert(specials, { "damage", new_special })
					end
				else
					table.insert(specials, { "damage", {
						id = "goliath_bane",
						name = "goliath bane",
						description = "Goliath Bane:\n20% damage bonus for each level of the enemy. Offense only.",
						multiply = 1.2,
						active_on = "offense",
						{ "filter_opponent", {
							level = 1
						} }
					} })
					for i = 2, 9 do
						new_special.multiply = 1 + 0.2 * i
						new_special[1][2].level = i
						table.insert(specials, { "damage", new_special })
					end
				end
			end
			if (get_p(weapon, "special_type.ensnare") or 0) > 0 then
				special_level = get_p(unit, "variables.abilities.ensnare") or 0
			elseif (get_p(weapon, "special_type.vine_ensnare") or 0) > 0 then
				special_level = get_p(unit, "variables.abilities.vine_ensnare") or 0
			else
				special_level = 0
			end
			if special_level > 0 then
				new_special = {
					id = "ensnare",
					name = "ensnare",
					add = 0,
					cumulative = "yes",
					active_on = "offense"
				}
				if player then
					new_special.description = string.format("Ensnare:\
	Each successful strike with this spell increases the chance to hit by %d%%. Active on offense.", 5 * special_level)
				else
					new_special.description = "Ensnare:\
	Each successful strike with this spell increases the chance to hit by 10%. Active on offense."
				end
				table.insert(specials, { "chance_to_hit", new_special })
				attack.ensnare = 1
			end
			if (get_p(weapon, "special_type.pointpike") or 0) > 0 then
				special_level = get_p(unit, "variables.abilities.pointpike") or 0
			else
				special_level = 0
			end
			if special_level > 0 then
				table.insert(specials, { "chance_to_hit", {
					id = "pointpike",
					name = "point+pike",
					description = string.format("Point+Pike Level %d:\
	Each miss with this weapon increases the chance to hit by %d%%, which is reset upon a successful hit. Active on offense.", special_level, 10 * special_level),
					add = 0,
					cumulative = "yes",
					active_on = "offense"
				} })
				new_special = {
					cumulative = "yes",
					active_on = "offense",
					{ "filter_self", {
						{ "filter_wml", {
							{ "variables", {
							} }
						} }
					} }
				}
				for i = 10 * special_level, 90, 10 * special_level do
					new_special.id = string.format("pointpike%d", i)
					new_special.add = i
					new_special[1][2][1][2][1][2].pointpike = i
					table.insert(specials, { "chance_to_hit", new_special })
				end
				new_special.id = "pointpike100"
				new_special.add = 100
				new_special[1][2][1][2][1][2].pointpike = 100
				table.insert(specials, { "chance_to_hit", new_special })
			end
			if storm_allowed and (get_p(weapon, "special_type.storm") or 0) > 0 then
				special_level = get_p(unit, "variables.abilities.storm") or 0
			else
				special_level = 0
			end
			if special_level > 0 then
				local storm_limit = attack.number
				if (get_p(unit, "variables.abilities.brutal") or 0) > 0 then
					storm_limit = math.ceil(storm_limit * 0.5)
					table.insert(specials, { "damage", {
						id = "brutal_damage",
						name = "brutal assault",
						description = "Brutal Assault:\
	When attacking, deal 60% more damage per strike, but get half as many strikes.",
						name_inactive = "brutal assault",
						description_inactive = "Brutal Assault:\
	When attacking, deal 60% more damage per strike, but get half as many strikes.",
						value = math.floor(attack.damage * 1.6 + 0.5),
						cumulative = "no",
						active_on = "offense",
						apply_to = "self"
					} })
					table.insert(specials, { "attacks", {
						id = "brutal_number",
						value = storm_limit,
						cumulative = "no",
						active_on = "offense",
						apply_to = "self"
					} })
				end
				storm_limit = storm_limit + 2 - special_level
				local new_special = {
					id = "storm",
					name = "storm",
					name_inactive = "storm",
					value = storm_limit,
					cumulative = "no",
					active_on = "offense",
					apply_to = "defender",
					{ "filter_base_value", {
						greater_than = storm_limit
					} }
				}
				if special_level == 1 then
					new_special.description = "Storm Level 1:\
	Enemy strikes will stop 2 strikes after this weapon's last strike."
				elseif special_level == 2 then
					new_special.description = "Storm Level 2:\
	Enemy strikes will stop 1 strike after this weapon's last strike."
				else
					new_special.description = "Storm Level 3:\
	Enemy strikes will stop after this weapon's last strike."
				end
				new_special.description_inactive = new_special.description
				table.insert(specials, { "attacks", new_special })
				table.insert(specials, { "attacks", {
					id = "storm",
					value = storm_limit + 1,
					cumulative = "no",
					active_on = "offense",
					apply_to = "defender",
					{ "filter_defender", {
						{ "filter_weapon", {
							name = "spear"
						} },
						{ "filter_wml", {
							{ "variables", {
								firststrike_flag = 1
							} }
						} }
					} },
					{ "filter_base_value", {
						greater_than = storm_limit
					} }
				} })
			end
			if ((get_p(weapon, "special_type.vine_slows") or 0) > 0 and (get_p(unit, "abilities.vine_slows") or 0) > 0) or ((not player) and attack.user_name == "kusarigama" and attack.range == "ranged" and (get_p(unit, "abilities.kusarigama_slows") or 0) > 0) then
				table.insert(specials, { "slow", {
					id = "slow",
					name = "slows",
					description = "Slow:\nThis attack slows the target until it ends a turn. Slow halves the damage caused by attacks and the movement cost for a slowed unit is doubled. A unit that is slowed will feature a snail icon in its sidebar information when it is selected.",
					name_inactive = "slows",
					description_inactive = "Slow:\nThis attack slows the target until it ends a turn. Slow halves the damage caused by attacks and the movement cost for a slowed unit is doubled. A unit that is slowed will feature a snail icon in its sidebar information when it is selected.",
					{ "filter_opponent", {
						{ "not", {
							{ "filter_wml", {
								{ "variables", {
									unslowable_flag = 1
								} }
							} }
						} }
					} }
				} })
			end
			if (get_p(weapon, "special_type.natural_poison") or 0) > 0 or (weapon_class == "thrown_light_blade" and (get_p(weapon, "special_type.allow_poison") or 0) > 0 and ((get_p(unit, "special_type.variables.abilities.poison_thrown_light_blade") or 0) > 0 or (get_p(unit, "variables.abilities.poison_thrown_light_blade_orc") or 0) > 0)) or (weapon_class == "light_blade" and (get_p(unit, "variables.abilities.poison_light_blade") or 0) == 1) or ((not player) and ((attack.user_name == "kusarigama" and attack.range == "melee" and (get_p(unit, "variables.abilities.kusarigama_poison") or 0) > 0) or (weapon_class == "light_blade" and (get_p(unit, "variables.abilities.witchcraft") or 0) == 1 and (get_p(unit, "variables.abilities.magic_casting.power") or 0) > 0))) then
				table.insert(specials, { "poison", {
					id = "poison",
					name = "poison",
					name_inactive = "poison",
					description = "Poison:\
	This attack poisons living targets. Poisoned units lose 8 HP every turn until they are cured or are reduced to 1 HP. Poison can not, of itself, kill a unit.",
					description_inactive = "Poison:\
	This attack poisons living targets. Poisoned units lose 8 HP every turn until they are cured or are reduced to 1 HP. Poison can not, of itself, kill a unit.",
					icon = "attacks/dagger-thrown-poison-human.png",
					{ "filter_opponent", {
						{ "not", {
							{ "filter_wml", {
								{ "variables", {
									unpoisonable_flag = 1
								} }
							} }
						} }
					} }
				} })
			end
			if (get_p(unit, "variables.abilities.witch_magic") or 0) == 4 then
				special_level = 1
			else
				special_level = get_p(weapon, "special_type.spell_drains") or 0
			end
			if special_level > 0 then
				new_special = {
					name = "drains",
					description = "Drain:\
	This unit drains health from living units, healing itself for half the amount of damage it deals (rounded down)."
				}
				if special_level == 2 then
					new_special.id = "metal_to_drain"
				else
					new_special.id = "drains"
				end
				table.insert(specials, { "drains", new_special })
			end
			if (not player) and attack.range == "melee" and attack.class == "bludgeon" and (get_p(unit, "variables.abilities.dread") or 0) > 0 then
				table.insert(specials, { "damage", {
					id = "dread",
					name = "dread",
					name_inactive = "dread",
					description = "Dread:\
	When this attack is used offensively, this unit takes one third less damage in retaliation.",
					description_inactive = "Dread:\
	When this attack is used offensively, this unit takes one third less damage in retaliation.",
					active_on = "offense",
					apply_to = "opponent",
					multiply = 0.66
				} })
			end
			if (get_p(unit, "variables.abilities.readied_bolt") or 0) > 0 and (get_p(weapon, "special_type.readied_bolt") or 0) > 0 then
				table.insert(specials, { "firststrike", {
					id = "firststrike",
					name = "readied bolt",
					description = "Readied Bolt:\
	This attack always strikes first, even when defending."
				} })
			end
			if (not skirmisher_flag) and (get_p(weapon, "special_type.firststrike") or 0) > 0 and (get_p(unit, "variables.abilities.firststrike") or 0) > 0 then
				table.insert(specials, { "firststrike", {
					id = "firststrike",
					name = "firststrike",
					description = "First Strike:\
	This unit always strikes first with this attack, even if they are defending."
				} })
				set_p(unit, "variables.firststrike_flag", 1)
			end
			if (get_p(weapon, "special_type.backstab") or 0) > 0 then
				special_level = get_p(unit, "variables.abilities.backstab") or 0
			else
				special_level = 0
			end
			if special_level > 0 then
				new_special = {
					id = "backstab",
					name = "backstab",
					backstab = "yes",
					active_on = "offense"
				}
				if player then
					new_special.description = string.format("Backstab Level %d:\
	This attack deals %d%% damage if there is an enemy of the target on the opposite side of the target, and that unit is not incapacitated (e.g. turned to stone). Active on offense.", special_level, 150 + special_level * 50)
					new_special.multiply = 1.5 + special_level * 0.5
				else
					new_special.description = "Backstab:\
	This attack deals double damage if there is an enemy of the target on the opposite side of the target, and that unit is not incapacitated (e.g. turned to stone). Active on offense."
					new_special.multiply = 2
				end
				table.insert(specials, { "damage", new_special })
			end
			if (get_p(weapon, "special_type.backstab") or 0) > 0 then
				special_level = get_p(unit, "variables.abilities.target") or 0
			else
				special_level = 0
			end
			if special_level > 0 then
				new_special = {
					id = "target",
					name = "target"
				}
				if player then
					new_special.description = string.format("Target Level %d:\
	This attack deals %d%% damage but strikes are reduced by half. Always active.", special_level, 150 + special_level * 50)
				else
					new_special.description = "Target:\
	This attack deals double damage but strikes are reduced by half. Always active."
				end
				table.insert(specials, { "dummy", new_special })
			end
			if (get_p(weapon, "special_type.cleave") or 0) > 0 then
				special_level = get_p(unit, "variables.abilities.cleave") or 0
			else
				special_level = 0
			end
			if special_level > 0 then
				attack.cleave = 1
				new_special = {
					id = "cleave",
					name = "cleave"
				}
				if player then
					new_special.description = string.format("Cleave Level %d:\
	Enemy units adjacent to both units in attack with this weapon can take 1/%dth of this weapon's damage. Terrain defense and resistances apply, chance to hit reduced to %d/%d normal. Active on offense.", special_level, 10 - 2 * special_level, special_level, special_level + 1)
				else
					new_special.description = "Cleave:\
	Enemy units adjacent to both units in attack with this weapon can take 1/8th of this weapon's damage. Terrain defense and resistances apply, chance to hit reduced to 1/2 normal. Active on offense."
				end
				table.insert(specials, { "dummy", new_special })
			end
			if (get_p(weapon, "special_type.riposte") or 0) > 0 then
				special_level = get_p(unit, "variables.abilities.riposte") or 0
			else
				special_level = 0
			end
			if special_level > 0 then
				attack.riposte = 1
				new_special = {
					id = "riposte",
					name = "riposte",
					name_inactive = "riposte",
					cumulative = "yes",
					active_on = "defense",
					{ "filter_self", {
						{ "filter_wml", {
							{ "variables", {
								right_of_way = 1
							} }
						} }
					} }
				}
				if player then
					new_special.value = 40 + 20 * special_level
					if special_level == 3 then
						new_special.description = "Riposte Level 3:\
	If an enemy misses versus this attack, the returning attack will automatically hit. Active on defense."
					else
						new_special.description = string.format("Riposte Level %d:\
	If an enemy misses versus this attack, the returning attack will have at least a %d%% chance to hit. Active on defense.", special_level, new_special.value)
					end
				else
					new_special.value = 80
					new_special.description = "Riposte:\
	If an enemy misses versus this attack, the returning attack will have at least a 80% chance to hit. Active on defense."
				end
				new_special.description_inactive = new_special.description
				table.insert(specials, { "chance_to_hit", new_special })
			end
			if (weapon_class == "bow" or weapon_class == "javelin" or weapon_class == "thrown_light_blade" or weapon_class == "thrown_heavy_blade") and (get_p(weapon, "special_type.remaining_ammo_" .. weapon_class) or 0) > 0 then
				special_level = get_p(unit, "variables.abilities.remaining_ammo_" .. weapon_class) or 0
			else
				special_level = 0
			end
			if special_level > 0 then
				attack.remaining_ammo = 1
				new_special = {
					id = "remaining_ammo",
					name = "remaining_ammo"
				}
				if not player then
					new_special.description = "Remaining Ammo:\
	If any ammo remains after killing a unit with this attack, then it may be used in another attack."
				elseif special_level == 1 then
					new_special.description = "Remaining Ammo Level 1:\
	If any ammo remains after killing a unit with this attack, then it may be used in another attack, minus one strike."
				elseif special_level == 2 then
					new_special.description = "Remaining Ammo Level 2:\
	If any ammo remains after killing a unit with this attack, then it may be used in another attack."
				else
					new_special.description = "Remaining Ammo Level 3:\
	If any ammo remains after killing a unit with this attack, then it may be used in another attack, plus one strike."
				end
				table.insert(specials, { "dummy", new_special })
			end
			if (get_p(weapon, "special_type.plague") or 0) > 0 and (get_p(unit, "variables.abilities.plague") or 0) > 0 then
				table.insert(specials, { "plague", {
					id = "plague",
					name = "plague",
					description = "Plague:\
	When a unit is killed by a Plague attack, that unit is replaced with a Walking Corpse on the same side as the unit with the Plague attack. This doesn't work on Undead.",
					type = "Walking Corpse_MODRPG"
				} })
			end
			if (get_p(weapon, "special_type.soultrap") or 0) > 0 and (get_p(unit, "variables.abilities.soultrap") or 0) > 0 then
				table.insert(specials, { "plague", {
					id = "soultrap",
					name = "soul trap",
					description = "Soul Trap:\
	When a unit is killed with a dagger embued with the power of Soul Trap, its spirit doesn't ascend to the next world but instead is trapped to serve its new master.",
					type = "Trapped Spirit"
				} })
			end
			if attack.material == "metal" and attack.range == "melee" and (get_p(unit, "variables.abilities.metal_to_arcane") or 0) > 0 then
				attack.type = "arcane"
			end
			if (not skirmisher_flag) and attack.range == "melee" then
				special_level = get_p(unit, "variables.abilities.bloodlust") or 0
			else
				special_level = 0
			end
			if special_level > 0 then
				attack.bloodlust = 1
				new_special = {
					id = "bloodlust",
					name = "bloodlust",
				}
				if not player then
					new_special.description = "Bloodlust:\
	If this attack kills the target within two strikes, this unit can attack again.\
	If this attack kills the target on the first strike, this unit also recovers one movement point."
				elseif special_level == 1 then
					new_special.description = "Bloodlust Level 1:\
	If this attack kills the target on the first strike, this unit can attack again."
				elseif special_level == 2 then
					new_special.description = "Bloodlust Level 2:\
	If this attack kills the target within two strikes, this unit can attack again.\
	If this attack kills the target on the first strike, this unit also recovers one movement point."
				else
					new_special.description = "Bloodlust Level 3:\
	If this attack kills the target within three strikes, this unit can attack again.\
	If this attack kills the target within two strikes, this unit also recovers one movement point."
				end
				table.insert(specials, { "dummy", new_special })
			end
			if dash_flag and evade > 7 and attack.range == "melee" and (get_p(unit, "variables.abilities.grace") or 0) > 0 then
				attack.grace = 1
				table.insert(specials, { "dummy", {
					id = "grace",
					name = "deadly grace",
					description = "Deadly Grace:\
	If this unit avoids all defending strikes while using this attack, it can attack again.\
	\
	NOTE: The defending unit must have the chance to strike at least one time for special to trigger."
				} })
			end
			if (get_p(weapon, "special_type.magical_to_hit") or 0) > 0 then
				table.insert(specials, { "chance_to_hit", {
					id = "magical",
					name = "magical",
					description = "Magical:\
	This attack always has a 70% chance to hit regardless of the defensive ability of the unit being attacked.",
					value = 70,
					cumulative = "no"
				} })
			end
			if (get_p(weapon, "special_type.precision") or 0) > 0 then
				table.insert(specials, { "chance_to_hit", {
					id = "precision",
					name = "precision",
					description = "Precision:\
	This attack always has a 80% chance to hit",
					value = 80,
					cumulative = "no"
				} })
			end
			if (get_p(weapon, "special_type.swarm") or 0) > 0 then
				table.insert(specials, { "swarm", {
					id = "swarm",
					name = "swarm",
					description = "Swarm:\
The number of strikes of this attack decreases when the unit is wounded. The number of strikes is proportional to the percentage of its of maximum HP the unit has. For example a unit with 3/4 of its maximum HP will get 3/4 of the number of strikes."
				} })
			end

			if blocked_flag then
				if weapon_class == unblocked_class or (attack[unblocked_class] or 0) > 0 then
					if (get_p(unit, "variables.ammo_stored") or -1) >= 0 then
						local available_ammo = get_p(unit, "variables.current_ammo") or 0
						set_p(unit, "variables.base_ammo", attack.number)
						if available_ammo > attack.number then
							set_p(unit, "variables.current_ammo", attack.number)
						else
							attack.number = available_ammo
						end
						set_p(unit, "variables.ammo_stored", #attacks)
					end
					unblocked_counter = unblocked_counter + 1
				else
					attack.attack_weight = 0
				end
			end
			if #specials > 0 then
				table.insert(attack, { "specials", specials })
			end
			table.insert(attacks, attack)
			if attack.user_name == "hammer" and (get_p(unit, "variables.abilities.devling_spiker") or 0) > 0 then
				local spikes = get_p(weapon)
				set_p(spikes, "type", "pierce")
				set_p(spikes, "description", "spike 'em")
				set_p(spikes, "user_name", "spike 'em")
				add_attack(spikes)
			end
			if ((get_p(weapon, "special_type.fire_shot_bow") or 0) > 0 and (get_p(unit, "variables.abilities.fire_shot_bow") or 0) > 0) or ((get_p(weapon, "special_type.fire_shot_xbow") or 0) > 0 and (get_p(unit, "variables.abilities.fire_shot_xbow") or 0) > 0) then
				local fire_shot = get_p(weapon)
				set_p(fire_shot, "type", "fire")
				set_p(fire_shot, "damage", get_p(weapon, "damage") + 2)
				set_p(fire_shot, "number", get_p(weapon, "number") - 1)
				set_p(fire_shot, "special_type.fire_shot_bow", 0)
				set_p(fire_shot, "special_type.fire_shot_xbow", 0)
				add_attack(fire_shot)
			end
		end
	end

	add_attack(equipment.melee_1)
	if equipment.melee_2 then
		add_attack(equipment.melee_2)
	end
	if equipment.melee_3 then
		add_attack(equipment.melee_3)
	end
	if equipment.thrown then
		add_attack(equipment.thrown)
	end
	if equipment.ranged then
		add_attack(equipment.ranged)
	end
	if (get_p(unit, "variables.abilities.net") or 0) > 0 then
		table.insert(attacks, {
			name = "net",
			description = "net",
			icon = "attacks/net.png",
			range = "ranged",
			type = "impact",
			damage = 5,
			number = 2,
			{ "specials", {
				{ "slow", {
					id = "slow",
					name = "slows",
					description = "Slow:\nThis attack slows the target until it ends a turn. Slow halves the damage caused by attacks and the movement cost for a slowed unit is doubled. A unit that is slowed will feature a snail icon in its sidebar information when it is selected.",
					name_inactive = "slows",
					description_inactive = "Slow:\nThis attack slows the target until it ends a turn. Slow halves the damage caused by attacks and the movement cost for a slowed unit is doubled. A unit that is slowed will feature a snail icon in its sidebar information when it is selected.",
					{ "filter_opponent", {
						{ "not", {
							{ "filter_wml", {
								{ "variables", {
									unslowable_flag = 1
								} }
							} }
						} }
					} }
				} }
			} }
		})
	end
	local spells, magic_level = {}, 0
	magic_level = get_p(unit, "variables.abilities.human_magic") or 0
	if magic_level > 0 then
		if magic_level == 2 then
			table.insert(spells, {
				description = "fireball",
				icon = "fireball",
				name = "fireball",
				damage = 3,
				number = 2,
				range = "ranged",
				type = "fire",
				class = "spell",
				spell_power = 2,
				bonus_type = "human_magic_adjust",
				mind_damage_rate = 35,
				{ "special_type", { magical_to_hit = 1 } }
			})
		elseif magic_level == 3 then
			table.insert(spells, {
				description = "lightbeam",
				icon = "lightbeam",
				name = "lightbeam",
				damage = 4,
				number = 1,
				range = "ranged",
				type = "arcane",
				class = "spell",
				spell_power = 2,
				bonus_type = "human_magic_adjust",
				mind_damage_rate = 25,
				{ "special_type", { magical_to_hit = 1 } }
			})
		elseif magic_level == 5 then
			table.insert(spells, {
				description = "lightning",
				icon = "lightning",
				name = "lightning",
				damage = 2,
				number = 1,
				range = "ranged",
				type = "fire",
				class = "spell",
				spell_power = 3,
				bonus_type = "human_magic_adjust",
				mind_damage_rate = 40,
				{ "special_type", { magical_to_hit = 1 } }
			})
		else
			table.insert(spells, {
				description = "magic missile",
				icon = "magic-missile",
				name = "magic missile",
				damage = 4,
				number = 2,
				range = "ranged",
				type = "fire",
				class = "spell",
				bonus_type = "human_magic_adjust",
				mind_damage_rate = 25,
				{ "special_type", { magical_to_hit = 1 } }
			})
		end
	end
	magic_level = get_p(unit, "variables.abilities.dark_magic") or 0
	if magic_level > 0 then
		table.insert(spells, {
			description = "chill wave",
			icon = "iceball",
			name = "dark wave",
			damage = 8,
			number = 1,
			range = "ranged",
			type = "cold",
			class = "spell",
			spell_power = 2,
			bonus_type = "dark_magic_adjust",
			mind_damage_rate = 15,
			{ "special_type", { magical_to_hit = 1 } }
		})
		table.insert(spells, {
			description = "shadow wave",
			icon = "dark-missile",
			name = "dark wave",
			damage = 5,
			number = 1,
			range = "ranged",
			type = "arcane",
			class = "spell",
			spell_power = 2,
			bonus_type = "dark_magic_adjust",
			mind_damage_rate = 15,
			{ "special_type", { magical_to_hit = 1 } }
		})
	end
	magic_level = get_p(unit, "variables.abilities.runic_magic") or 0
	if magic_level > 0 then
		table.insert(spells, {
			description = "lightning",
			icon = "lightning",
			name = "lightning",
			damage = 3,
			number = 1,
			range = "ranged",
			type = "fire",
			class = "spell",
			spell_power = 2,
			bonus_type = "runic_magic_adjust",
			mind_damage_rate = 30,
			{ "special_type", { magical_to_hit = 1 } }
		})
	end
	magic_level = get_p(unit, "variables.abilities.faerie_magic") or 0
	if magic_level > 0 then
		table.insert(spells, {
			description = "faerie fire",
			icon = "faerie-fire",
			name = "faerie fire",
			damage = 2,
			number = 3,
			range = "ranged",
			type = "arcane",
			class = "spell",
			spell_power = 2,
			bonus_type = "faerie_magic_adjust",
			mind_damage_rate = 15,
			{ "special_type", { magical_to_hit = 1 } }
		})
	end
	magic_level = get_p(unit, "variables.abilities.wood_magic") or 0
	if magic_level > 0 then
		table.insert(spells, 1, {
			description = "vines",
			icon = "entangle",
			name = "vines",
			damage = 1,
			number = 2,
			range = "ranged",
			type = "impact",
			class = "spell",
			bonus_type = "faerie_magic_adjust",
			mind_damage_rate = 30,
			{ "special_type", { vine_slows = 1, vine_ensnare = 1 } }
		})
		if (get_p(unit, "variables.abilities.brambles") or 0) == 1 then
			spells[1].spell_power = 2
			table.insert(spells, {
				description = "thorns",
				icon = "thorns",
				name = "thorns",
				damage = 2,
				number = 2,
				range = "ranged",
				type = "pierce",
				class = "spell",
				spell_power = 2,
				bonus_type = "faerie_magic_adjust",
				mind_damage_rate = 30,
				{ "special_type", { magical_to_hit = 1 } }
			})
		end
	end
	magic_level = get_p(unit, "variables.abilities.troll_magic") or 0
	if magic_level > 0 then
		table.insert(spells, {
			description = "flame blast",
			icon = "fireball",
			name = "flame blast",
			damage = 5,
			number = 2,
			range = "ranged",
			type = "fire",
			class = "spell",
			bonus_type = "spirit_magic_adjust",
			mind_damage_rate = 25,
			{ "special_type", { magical_to_hit = 1 } }
		})
	end
	magic_level = get_p(unit, "variables.abilities.swamp_magic") or 0
	if magic_level > 0 then
		table.insert(spells, {
			description = "curse",
			icon = "curse",
			name = "curse",
			damage = 3,
			number = 2,
			range = "ranged",
			type = "cold",
			class = "spell",
			bonus_type = "spirit_magic_adjust",
			mind_damage_rate = 10,
			{ "special_type", { magical_to_hit = 1 } }
		})
		if (get_p(unit, "variables.abilities.baleful") or 0) > 0 then
			spells[#spells].spell_power = 3
		end
	end
	magic_level = get_p(unit, "variables.abilities.tribal_magic") or 0
	if magic_level > 0 then
		table.insert(spells, {
			description = "curse",
			icon = "curse",
			name = "curse",
			damage = 6,
			number = 1,
			range = "ranged",
			type = "pierce",
			class = "spell",
			spell_power = 2,
			bonus_type = "spirit_magic_adjust",
			mind_damage_rate = 30,
			{ "special_type", { spell_drains = 1 } }
		})
	end
	if not player then
		magic_level = get_p(unit, "variables.abilities.witchcraft") or 0
		if magic_level > 0 then
			table.insert(spells, {
				description = "hex",
				icon = "curse",
				name = "curse",
				damage = 4,
				number = 0,
				range = "ranged",
				type = "cold",
				class = "spell",
				spell_power = 2,
				bonus_type = "spirit_magic_adjust",
				mind_damage_rate = 20,
				mind_number_rate = 7,
				{ "special_type", { magical_to_hit = 1 } }
			})
		end
		magic_level = get_p(unit, "variables.abilities.minotaur_magic") or 0
		if magic_level > 0 then
			table.insert(spells, {
				description = "aura blast",
				icon = "aura-blast",
				name = "aura blast",
				damage = 6,
				number = 1,
				range = "ranged",
				type = "arcane",
				class = "spell",
				bonus_type = "spirit_magic_adjust",
				mind_damage_rate = 10,
				{ "special_type", { magical_to_hit = 1 } }
			})
			if magic_level == 3 then
				spells[#spells].spell_power = 2
				table.insert(spells, {
					description = "fireball",
					icon = "fireball",
					name = "fireball",
					damage = 6,
					number = 1,
					range = "ranged",
					type = "fire",
					class = "spell",
					bonus_type = "none",
					mind_damage_rate = 7,
					{ "special_type", { magical_to_hit = 1 } }
				})
			end
		end
		magic_level = get_p(unit, "variables.abilities.witch_magic") or 0
		if magic_level > 0 and magic_level < 4 then
			local new_spell = {
				damage = 4,
				number = 2,
				range = "ranged",
				type = "fire",
				mind_number_rate = 10
			}
			if (get_p(equipment.shield, "magic_adjust") + get_p(equipment.head_armor, "magic_adjust") + get_p(equipment.torso_armor, "magic_adjust") + get_p(equipment.leg_armor, "magic_adjust")) > -5 then
				new_spell.description = "witch fire"
				new_spell.icon = "witch-fire"
				new_spell.name = "witch fire"
				table.insert(new_spell, { "special_type", { magical_to_hit = 1, spell_drains = 1 } })
				if magic_level == 2 then
					new_spell.type = "cold"
				end
			else
				if magic_level == 2 then
					new_spell.description = "cold fire"
					new_spell.icon = "iceball"
					new_spell.type = "cold"
				else
					new_spell.description = "fireball"
					new_spell.icon = "fireball"
				end
				new_spell.name = "fireball"
				table.insert(new_spell, { "special_type", { magical_to_hit = 1 } })
			end
		end
		magic_level = get_p(unit, "variables.abilities.warlock_magic") or 0
		if magic_level > 0 then
			table.insert(spells, {
				description = "implosion",
				icon = "implosion",
				name = "implosion",
				damage = 6,
				number = 2,
				range = "ranged",
				type = "cold",
				class = "spell",
				spell_power = 2,
				bonus_type = "spirit_magic_adjust",
				mind_damage_rate = 25,
				{ "special_type", { magical_to_hit = 1 } }
			})
		end
		magic_level = get_p(unit, "variables.abilities.devling_flyer") or 0
		if magic_level > 0 then
			table.insert(spells, {
				description = "breath",
				icon = "fireball",
				name = "breath",
				damage = 2,
				number = 2,
				range = "ranged",
				type = "fire",
				class = "none",
				deft_damage_rate = 75,
				deft_number_rate = 10
			})
		end
		magic_level = get_p(unit, "variables.abilities.devling_magic") or 0
		if magic_level > 0 then
			table.insert(spells, {
				description = "wail",
				icon = "curse",
				name = "wail",
				damage = 5,
				number = 2,
				range = "ranged",
				type = "cold",
				class = "spell",
				bonus_type = "none",
				mind_damage_rate = 20,
				{ "special_type", { magical_to_hit = 1 } }
			})
		end
	end
	for i = 1, #spells do
		add_attack(parse_container(spells[i]))
	end
	for i = 1, #attacks do
		set_p(unit, string.format("attack[%d]", i - 1), attacks[i])
	end
	if unblocked_counter == 0 then
		set_p(unit, "attacks_left", 0)
	end

	if player or get_p(unit, "type") == "Skeleton_MODRPG" then
		set_p(unit, "variation", variation)
	end

	if not player then
		set_p(unit, "variables.absolute_value", find_npc_value(unit))
		set_p(unit, "variables.equipment_value", find_equipment_value(unit))
	end

	wesnoth.set_variable(var, unparse_container(unit))
	if unstore then
		W.unstore_unit { variable = var }
		local unit_x, unit_y = get_p(unit, "x"), get_p(unit, "y")
		-- in 1.9 it might be possible to replace this w/ a call to wesnoth.select_hex()?
		W.object {
			silent = "yes",
			{ "filter", {
				x = unit_x,
				y = unit_y
			} },
			{ "effect", {
				apply_to = "status",
				remove = "aids"
			} }
		}
	end
end
function wesnoth.wml_actions.construct_unit(cfg)
	local var = cfg.variable or H.wml_error("[construct_unit] requires a variable= key")
	local unstore
	if type(cfg.unstore) ~= "boolean" then
		unstore = true
	else
		unstore = cfg.unstore
	end
	construct_unit(var, unstore)
end