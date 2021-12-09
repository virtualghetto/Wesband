-- these are global functions for ease of use in lua scripts as well as WML
function probList(args)
	local list = args.name or H.wml_error("[prob_list] requires a name= key")
	local items = args.items or H.wml_error("[prob_list] requires a items= key")
	local weights = args.weights or H.wml_error("[prob_list] requires a weights= key")
	W.set_variables {
			name = string.format("%s.entry", list),
			mode = "replace",
			{ "split", {
				list = items,
				key = "item",
				separator = ",",
				remove_empty = "yes"
			} }
		}
	W.set_variables {
			name = "prob_temp_array",
			mode = "replace",
			{ "split", {
				list = weights,
				key = "weight",
				separator = ",",
				remove_empty = "yes"
			} }
		}
	local count = 0
	local item_count = wesnoth.get_variable(string.format("%s.entry.length", list))
	for i = item_count - 1, 0, -1 do
		if i < prob_temp_array.length and prob_temp_array[i].weight > 0 then
			wesnoth.set_variable(string.format("%s.entry[%i].weight", list, i), prob_temp_array[i].weight)
			count = count + prob_temp_array[i].weight
		else
			W.clear_variable { name = string.format("%s.entry[%i]", list, i) }
		end
	end
	wesnoth.set_variable(string.format("%s.total_weight", list), count)
	W.clear_variable { name = "prob_temp_array" }
end
wesnoth.register_wml_action("prob_list", probList)

function setProb(args)
	local weight, list, id
	local function probClear()
		local item_count = wesnoth.get_variable(string.format("%s.entry.length", list)) or 0
		local item
		for i = 0, item_count - 1 do
			item = wesnoth.get_variable(string.format("%s.entry[%i].item", list, i))
			if item == id then
				wesnoth.set_variable(string.format("%s.total_weight", list), wesnoth.get_variable(string.format("%s.total_weight", list)) - wesnoth.get_variable(string.format("%s.entry[%i].weight", list, i)))
				W.clear_variable { name = string.format("%s.entry[%i]", list, i) }
				break
			end
		end
	end
	
	local function probSet()
		local item_count = wesnoth.get_variable(string.format("%s.entry.length", list)) or 0
		local item
		for i = 0, item_count - 1 do
			item = wesnoth.get_variable(string.format("%s.entry[%i].item", list, i))
			if item == id then
				wesnoth.set_variable(string.format("%s.total_weight", list), wesnoth.get_variable(string.format("%s.total_weight", args.name)) - wesnoth.get_variable(string.format("%s.entry[%i].weight", list, i)) + weight)
				wesnoth.set_variable(string.format("%s.entry[%i].weight", list, i), weight)
				break
			end
		end
	end
	
	local function probAdd()
		local success = false
		local item_count = wesnoth.get_variable(string.format("%s.entry.length", list)) or 0
		local item
		for i = 0, item_count - 1 do
			item = wesnoth.get_variable(string.format("%s.entry[%i].item", list, i))
			if item == id then
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
		local count = wesnoth.get_variable(string.format("%s.total_weight", list))
		if count and count > 0 then
			wesnoth.set_variable(string.format("%s.total_weight", list), count + weight)
		else
			wesnoth.set_variable(string.format("%s.total_weight", list), weight)
		end
	end
	
	local function probSub()
		local item_count = wesnoth.get_variable(string.format("%s.entry.length", list)) or 0
		local item
		for i = 0, item_count - 1 do
			item = wesnoth.get_variable(string.format("%s.entry[%i].item", list, i))
			if item == id then
				local old = wesnoth.get_variable(string.format("%s.entry[%i].weight", list, i))
				local new = math.max(0, old - weight)
				wesnoth.set_variable(string.format("%s.entry[%i].weight", list, i), new)
				wesnoth.set_variable(string.format("%s.total_weight", list), wesnoth.get_variable(string.format("%s.total_weight", list)) - old + new)
				break
			end
		end
	end
	
	local function probScale()
		local item_count = wesnoth.get_variable(string.format("%s.entry.length", list)) or 0
		local item
		for i = 0, item_count - 1 do
			item = wesnoth.get_variable(string.format("%s.entry[%i].item", list, i))
			if item == id then
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
	
	local op = args.op or H.wml_error("[set_prob] requires an op= key.")
	list = args.name or H.wml_error("[set_prob] requires a name= key.")
	if op == "clear" then
		id = args.item or H.wml_error("[set_prob] clear requires an item= key.")
		probClear()
	elseif op == "set" then
		id = args.item or H.wml_error("[set_prob] set requires an item= key.")
		weight = args.weight or H.wml_error("[set_prob] set requires a weight= key.")
		if weight > 0 then
			probSet()
		else
			probClear()
		end
	elseif op == "add" then
		id = args.item or H.wml_error("[set_prob] add requires an item= key.")
		weight = args.weight or H.wml_error("[set_prob] add requires a weight= key.")
		if weight > 0 then
			probAdd()
		elseif args.weight < 0 then
			weight = 0 - weight
			probSub()
		end
	elseif op == "sub" then
		id = args.item or H.wml_error("[set_prob] sub requires an item= key.")
		weight = args.weight or H.wml_error("[set_prob] sub requires a weight= key.")
		if weight > 0 then
			probSub()
		elseif weight < 0 then
			weight = 0 - weight
			probAdd()
		end
	elseif op == "scale" then
		id = args.item or H.wml_error("[set_prob] scale requires an item= key.")
		weight = args.weight or H.wml_error("[set_prob] scale requires a weight= key.")
		if weight <= 0 then
			probClear()
		elseif weight ~= 100 then
			probScale()
		end
	elseif op == "union" then
		var = args.with_list or H.wml_error("[set_prob] union operation requires a with_list= key.")
		probUnion()
	elseif op == "diff" then
		var = args.with_list or H.wml_error("[set_prob] diff operation requires a with_list= key.")
		probDiff()
	else
		H.wml_error(string.format("Invalid [set_prob] operation: %s.", op))
	end
end
wesnoth.register_wml_action("set_prob", setProb)

function getProb(args)
	local var, list, id
	local function probRand()
		W.set_variable { name = "r_temp", rand = string.format("1..$%s.total_weight", list) }
		local item_count = wesnoth.get_variable(string.format("%s.entry.length", list)) or 0
		local r_val = r_temp
		for i = 0, item_count - 1 do
			r_val = r_val - wesnoth.get_variable(string.format("%s.entry[%i].weight", list, i))
			if r_val <= 0 then
				W.set_variable { name = var, value = wesnoth.get_variable(string.format("%s.entry[%i].item", list, i)) }
				break
			end
		end
		W.clear_variable { name = r_temp }
	end
	
	local function probGet()
		local item_count = wesnoth.get_variable(string.format("%s.entry.length", list)) or 0
		W.set_variable { name = var, value = 0 }
		local item
		for i = 0, item_count - 1 do
			item = wesnoth.get_variable(string.format("%s.entry[%i].item", list, i))
			if item == id then
				W.set_variable { name = var, value = wesnoth.get_variable(string.format("%s.entry[%i].weight", list, i)) }
				break
			end
		end
	end
	
	var = args.variable or H.wml_error("[get_prob] requires a variable= key.")
	list = args.name or H.wml_error("[get_prob] requires a name= key.")
	local op = args.op or H.wml_error("[get_prob] requires an op= key.")
	if op == "rand" then
		probRand()
	elseif op == "weight" then
		id = args.item or H.wml_error("[get_prob] weight requires an item= key.")
		probGet()
	else
		H.wml_error(string.format("Invalid [get_prob] operation: %s.", op))
	end
end
wesnoth.register_wml_action("get_prob", getProb)