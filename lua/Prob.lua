-- these are global functions for ease of use in lua scripts as well as WML
function wesnoth.wml_actions.prob_list(cfg)
	local list = cfg.name or H.wml_error("[prob_list] requires a name= key")
	local items = cfg.items or H.wml_error("[prob_list] requires a items= key")
	local weights = cfg.weights or H.wml_error("[prob_list] requires a weights= key")
	local entries = {}
	for i in string.gmatch(items, "[%s]*([^,]+),?") do
		table.insert(entries, i)
	end
	if #entries > 0 then
		local ct, ix = 0, 0
		for w in string.gmatch(weights, "[%s]*([%d]+),?") do
			if ix == 0 then
				wesnoth.set_variable(list)
			end
			local i = entries[ix + 1]
			if i then
				ct = ct + w
				wesnoth.set_variable(string.format("%s.entry[%d].item", list, ix), i)
				wesnoth.set_variable(string.format("%s.entry[%d].weight", list, ix), w)
				ix = ix + 1
			else
				break
			end
		end
		wesnoth.set_variable(string.format("%s.total_weight", list), ct)
	end
end

function wesnoth.wml_actions.set_prob(cfg)
	local weight, list, id
	local function probClear()
		local item_count = wesnoth.get_variable(string.format("%s.entry.length", list)) or 0
		for i = 0, item_count - 1 do
			if wesnoth.get_variable(string.format("%s.entry[%i].item", list, i)) == id then
				wesnoth.set_variable(string.format("%s.total_weight", list), wesnoth.get_variable(string.format("%s.total_weight", list)) - wesnoth.get_variable(string.format("%s.entry[%i].weight", list, i)))
				wesnoth.set_variable(string.format("%s.entry[%i]", list, i))
				break
			end
		end
	end
	
	local function probSet()
		local item_count = wesnoth.get_variable(string.format("%s.entry.length", list)) or 0
		for i = 0, item_count - 1 do
			if wesnoth.get_variable(string.format("%s.entry[%i].item", list, i)) == id then
				wesnoth.set_variable(string.format("%s.total_weight", list), wesnoth.get_variable(string.format("%s.total_weight", cfg.name)) - wesnoth.get_variable(string.format("%s.entry[%i].weight", list, i)) + weight)
				wesnoth.set_variable(string.format("%s.entry[%i].weight", list, i), weight)
				break
			end
		end
	end
	
	local function probAdd()
		local success = false
		local item_count = wesnoth.get_variable(string.format("%s.entry.length", list)) or 0
		for i = 0, item_count - 1 do
			if wesnoth.get_variable(string.format("%s.entry[%i].item", list, i)) == id then
				wesnoth.set_variable(string.format("%s.entry[%i].weight", list, i), wesnoth.get_variable(string.format("%s.entry[%i].weight", list, i)) + weight)
				success = true
				break
			end
		end
		if not success then
			W.set_variables {
					name = string.format("%s.entry", list),
					mode = "append",
					{ "value", {
						item = id,
						weight = weight
					} }
				}
		end
		local count = wesnoth.get_variable(string.format("%s.total_weight", list)) or 0
		wesnoth.set_variable(string.format("%s.total_weight", list), count + weight)
	end
	
	local function probSub()
		local item_count = wesnoth.get_variable(string.format("%s.entry.length", list)) or 0
		for i = 0, item_count - 1 do
			if wesnoth.get_variable(string.format("%s.entry[%i].item", list, i)) == id then
				local old = wesnoth.get_variable(string.format("%s.entry[%i].weight", list, i))
				if old <= weight then
					wesnoth.set_variable(string.format("%s.entry[%i]", list, i))
					wesnoth.set_variable(string.format("%s.total_weight", list), wesnoth.get_variable(string.format("%s.total_weight", list)) - old)
				else
					wesnoth.set_variable(string.format("%s.entry[%i].weight", list, i), old - weight)
					wesnoth.set_variable(string.format("%s.total_weight", list), wesnoth.get_variable(string.format("%s.total_weight", list)) - weight)
				end
				break
			end
		end
	end
	
	local function probScale()
		local item_count = wesnoth.get_variable(string.format("%s.entry.length", list)) or 0
		for i = 0, item_count - 1 do
			if wesnoth.get_variable(string.format("%s.entry[%i].item", list, i)) == id then
				local old = wesnoth.get_variable(string.format("%s.entry[%i].weight", list, i))
				local new = math.max(1, math.floor(old * weight * 0.01 + 0.5))
				wesnoth.set_variable(string.format("%s.entry[%i].weight", list, i), new)
				wesnoth.set_variable(string.format("%s.total_weight", list), wesnoth.get_variable(string.format("%s.total_weight", list)) - old + new)
				break
			end
		end
	end
	
	local var
	local function probUnion()
		local item_count = wesnoth.get_variable(string.format("%s.entry.length", var)) or 0
		for i = 0, item_count -1 do
			id = wesnoth.get_variable(string.format("%s.entry[%i].item", var, i))
			weight = wesnoth.get_variable(string.format("%s.entry[%i].weight", var, i))
			probAdd()
		end
	end
	
	local function probDiff()
		local item_count = wesnoth.get_variable(string.format("%s.entry.length", var)) or 0
		for i = 0, item_count -1 do
			id = wesnoth.get_variable(string.format("%s.entry[%i].item", var, i))
			weight = wesnoth.get_variable(string.format("%s.entry[%i].weight", var, i))
			probSub()
		end
	end
	
	local op = cfg.op or H.wml_error("[set_prob] requires an op= key.")
	list = cfg.name or H.wml_error("[set_prob] requires a name= key.")
	if op == "clear" then
		id = cfg.item or H.wml_error("[set_prob] clear requires an item= key.")
		probClear()
	elseif op == "set" then
		id = cfg.item or H.wml_error("[set_prob] set requires an item= key.")
		weight = cfg.weight or H.wml_error("[set_prob] set requires a weight= key.")
		if weight > 0 then
			probSet()
		else
			probClear()
		end
	elseif op == "add" then
		id = cfg.item or H.wml_error("[set_prob] add requires an item= key.")
		weight = cfg.weight or H.wml_error("[set_prob] add requires a weight= key.")
		if weight > 0 then
			probAdd()
		elseif cfg.weight < 0 then
			weight = 0 - weight
			probSub()
		end
	elseif op == "sub" then
		id = cfg.item or H.wml_error("[set_prob] sub requires an item= key.")
		weight = cfg.weight or H.wml_error("[set_prob] sub requires a weight= key.")
		if weight > 0 then
			probSub()
		elseif weight < 0 then
			weight = 0 - weight
			probAdd()
		end
	elseif op == "scale" then
		id = cfg.item or H.wml_error("[set_prob] scale requires an item= key.")
		weight = cfg.weight or H.wml_error("[set_prob] scale requires a weight= key.")
		if weight <= 0 then
			probClear()
		elseif weight ~= 100 then
			probScale()
		end
	elseif op == "union" then
		var = cfg.with_list or H.wml_error("[set_prob] union operation requires a with_list= key.")
		probUnion()
	elseif op == "diff" then
		var = cfg.with_list or H.wml_error("[set_prob] diff operation requires a with_list= key.")
		probDiff()
	else
		H.wml_error(string.format("Invalid [set_prob] operation: %s.", op))
	end
end

function wesnoth.wml_actions.get_prob(cfg)
	local var, list, id
	local function probRand()
		local item_count = wesnoth.get_variable(string.format("%s.entry.length", list)) or 0
		local r_val = H.rand(string.format("1..$%s.total_weight", list))
		for i = 0, item_count - 1 do
			r_val = r_val - wesnoth.get_variable(string.format("%s.entry[%i].weight", list, i))
			if r_val <= 0 then
				wesnoth.set_variable(var, wesnoth.get_variable(string.format("%s.entry[%i].item", list, i)))
				break
			end
		end
	end
	
	local function probGet()
		local item_count = wesnoth.get_variable(string.format("%s.entry.length", list)) or 0
		local val = 0
		for i = 0, item_count - 1 do
			if wesnoth.get_variable(string.format("%s.entry[%i].item", list, i)) == id then
				val = wesnoth.get_variable(string.format("%s.entry[%i].weight", list, i))
				break
			end
		end
		wesnoth.set_variable(var, val)
	end
	
	var = cfg.variable or H.wml_error("[get_prob] requires a variable= key.")
	list = cfg.name or H.wml_error("[get_prob] requires a name= key.")
	local op = cfg.op or H.wml_error("[get_prob] requires an op= key.")
	if op == "rand" then
		probRand()
	elseif op == "weight" then
		id = cfg.item or H.wml_error("[get_prob] weight requires an item= key.")
		probGet()
	else
		H.wml_error(string.format("Invalid [get_prob] operation: %s.", op))
	end
end