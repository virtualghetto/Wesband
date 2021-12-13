local function randomize_terrain(base, variations)
	W.store_locations {
			terrain = base,
			variable = "dungeon_creation.temp.rand_terrain"
		}
	W.set_variable { name = "r_temp", rand = "0,0,0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,3,3,3,3,4,4,4,5,5,6" }
	local rand_count = wml.variables['r_temp']
	while rand_count < wml.variables['dungeon_creation.temp.rand_terrain.length'] do
		W.set_variable { name = "r_temp", rand = variations }
		wesnoth.set_terrain(wml.variables[("dungeon_creation.temp.rand_terrain[%d].x"):format(rand_count)], wml.variables[("dungeon_creation.temp.rand_terrain[%d].y"):format(rand_count)], wml.variables['r_temp'])
		W.set_variable { name = "r_temp", rand = "1,2,2,3,3,3,4,4,4,4" }
		rand_count = rand_count + wml.variables['r_temp']
	end
end

if wml.variables['dungeon_creation.temp.terrain_variation'] == "Rd" then
	randomize_terrain("Re,Aa", "Rd^Wel,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Uh,Uh,Uh,Uh,Uh,Uh,Uu,Uu,Uu,Uu,Uu,Uu,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf")
elseif wml.variables['dungeon_creation.temp.terrain_variation'] == "Re" then
	randomize_terrain("Re,Aa", "Re^Wel,Re^Dr,Re^Dr,Re^Dr,Re^Dr,Re^Dr,Re^Dr,Re^Dr,Re^Dr,Re^Dr,Re^Dr,Uh,Uh,Uh,Uh,Uh,Uu,Uu,Uu,Uu,Uu,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf")
elseif wml.variables['dungeon_creation.temp.terrain_variation'] == "Ryc" then
	randomize_terrain("Re,Aa", "Ryc^Wel,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Uh,Uh,Uh,Uh,Uh,Uu,Uu,Uu,Uu,Uu,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Uh,Uh,Uh,Uh,Uh,Uu,Uu,Uu,Uu,Uu,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf")
elseif wml.variables['dungeon_creation.temp.terrain_variation'] == "Ur" then
	randomize_terrain("Re,Aa", "Ur^Wel,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uh,Uh,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uh,Uh,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf")
elseif wml.variables['dungeon_creation.temp.terrain_variation'] == "Wwf" then
	randomize_terrain("Re,Aa", "Wwf^Wel,Wwf^Wel,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Ds,Ds,Ds,Ds,Ds,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Wwf^Dr,Wwf^Dr,Wwf^Dr,Wwf^Dr,Wwf^Dr,Wwf^Dr,Wwf^Dr,Wwf^Dr,Wwf^Dr,Wwf^Dr,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf")
elseif wml.variables['dungeon_creation.temp.terrain_variation'] == "Rr" then
	randomize_terrain("Re,Aa", "Rr^Wel,Rr^Dr,Rr^Dr,Rr^Dr,Rr^Dr,Ur,Rd,Uh,Uu,Uu^Tf,Rr^Dr,Rr^Dr,Rr^Dr,Rr^Dr,Ur,Rd,Uh,Uu,Uu^Tf,Rr^Dr,Rr^Dr,Rr^Dr,Rr^Dr,Ur,Rd,Uh,Uu,Uu^Tf,Rr^Dr,Rr^Dr,Rr^Dr,Rr^Dr,Ur,Rd,Uh,Uu,Uu^Tf,Rr^Dr,Rr^Dr,Rr^Dr,Rr^Dr,Ur,Rd,Uh,Uu,Uu^Tf,Rr^Dr,Rr^Dr,Rr^Dr,Rr^Dr,Ur,Rd,Uh,Uu,Uu^Tf,Rr^Dr,Rr^Dr,Rr^Dr,Rr^Dr,Ur,Rd,Uh,Uu,Uu^Tf")
elseif wml.variables['dungeon_creation.temp.terrain_variation'] == "Ryv" then
	randomize_terrain("Re,Aa", "Ryv^Wel,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf")
elseif wml.variables['dungeon_creation.temp.terrain_variation'] == "Rys" then
	randomize_terrain("Re,Aa", "Rys^Wel,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf")
else
	randomize_terrain("Re,Aa", "Ryf^Wel,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf,Uu^Tf")
end

local trapdoor_data = {}
local function select_trapdoor_location(dir)
	local cthl = tonumber(wml.variables["chamber_terrain.hexes.length"]) or 0
	--local loc_index = H.rand("0..$($chamber_terrain.hexes.length-1)")
	local loc_index = tonumber(H.rand(string.format("0..%i",  cthl - 1)))
	trapdoor_data[dir] = wml.variables[string.format("chamber_terrain.hexes[%d]", loc_index)]
end
local function trapdoor_on_board(x, y)
	if type(x) ~= "number" or type(y) ~= "number" then
		return false
	end
	local w, h, b = wesnoth.get_map_size()
	return x >= 1 and y >= 1 and x <= w and y <= h
end
local function invalid_trapdoor_placement()
	if not trapdoor_on_board(trapdoor_data.up.x, trapdoor_data.up.y) then
		return true
	end
	if not trapdoor_on_board(trapdoor_data.down.x, trapdoor_data.down.y) then
		return true
	end
	return wesnoth.map.distance_between(trapdoor_data.up.x, trapdoor_data.up.y, trapdoor_data.down.x, trapdoor_data.down.y) < 35
end

select_trapdoor_location("up")
select_trapdoor_location("down")
while invalid_trapdoor_placement() do
	select_trapdoor_location("up")
	if invalid_trapdoor_placement() then
		select_trapdoor_location("down")
	end
end

wml.variables["dungeon_exit.x"] = trapdoor_data.up.x
wml.variables["dungeon_exit.y"] = trapdoor_data.up.y
wesnoth.set_terrain(trapdoor_data.down.x, trapdoor_data.down.y, "Re")
wesnoth.set_terrain(trapdoor_data.up.x, trapdoor_data.up.y, "Re")
W.create_exit {
	x = trapdoor_data.down.x,
	y = trapdoor_data.down.y,
	destination = "Dungeon",
	label = string.format("Down to level %d", wml.variables["dungeon_level.current"] + 1),
	image = "scenery/trapdoor-open.png"
}
W.create_exit {
	x = trapdoor_data.up.x,
	y = trapdoor_data.up.y,
	destination = "Town",
	label = "To Overworld",
	image = "stairs-up.png"
}
wml.variables["dungeon_up.x"] = trapdoor_data.up.x
wml.variables["dungeon_up.y"] = trapdoor_data.up.y
wml.variables["dungeon_down.x"] = trapdoor_data.down.x
wml.variables["dungeon_down.y"] = trapdoor_data.down.y

local mapData
if wml.variables['dungeon_creation.temp.flow_type'] == 1 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_1.lua")
elseif wml.variables['dungeon_creation.temp.flow_type'] == 2 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_2.lua")
elseif wml.variables['dungeon_creation.temp.flow_type'] == 3 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_3.lua")
elseif wml.variables['dungeon_creation.temp.flow_type'] == 4 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_4.lua")
elseif wml.variables['dungeon_creation.temp.flow_type'] == 5 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_5.lua")
elseif wml.variables['dungeon_creation.temp.flow_type'] == 6 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_6.lua")
elseif wml.variables['dungeon_creation.temp.flow_type'] == 7 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_7.lua")
elseif wml.variables['dungeon_creation.temp.flow_type'] == 8 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_8.lua")
elseif wml.variables['dungeon_creation.temp.flow_type'] == 9 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_9.lua")
elseif wml.variables['dungeon_creation.temp.flow_type'] == 10 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_10.lua")
else
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_none.lua")
end

W.terrain_mask {
	x = 1,
	y = 1,
	mask = mapData,
	{"rule", { old = "Xu", new = "Ai", terrain = wml.variables['dungeon_creation.temp.flow_flavor'] } },
	{"rule", { old = "Ai", new = "Re,Ai", terrain = wml.variables['dungeon_creation.temp.pool_flavor'] } },
	{"rule", { old = "Re,Aa", new = "Re,Ai", terrain = wml.variables['dungeon_creation.temp.terrain_variation'] } },
	{"rule", { old = "Xu", new = "Re", terrain = wml.variables['dungeon_creation.temp.wall_flavor'] } },
	{"rule", { use_old = "yes" } }
}
