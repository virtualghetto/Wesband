local function randomize_terrain(base, variations)
	W.store_locations {
			terrain = base,
			variable = "dungeon_creation.temp.rand_terrain"
		}
	W.set_variable { name = "r_temp", rand = "0,0,0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,3,3,3,3,4,4,4,5,5,6" }
	local rand_count = r_temp
	while rand_count < dungeon_creation.temp.rand_terrain.length do
		W.set_variable { name = "r_temp", rand = variations }
		wesnoth.set_terrain(dungeon_creation.temp.rand_terrain[rand_count].x, dungeon_creation.temp.rand_terrain[rand_count].y, r_temp)
		W.set_variable { name = "r_temp", rand = "1,2,2,3,3,3,4,4,4,4" }
		rand_count = rand_count + r_temp
	end
end

if dungeon_creation.temp.terrain_variation == "Rd" then
	randomize_terrain("Re,Aa", "Rd^Wel,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Rd^Dr,Uh,Uh,Uh,Uh,Uh,Uh,Uu,Uu,Uu,Uu,Uu,Uu,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf")
elseif dungeon_creation.temp.terrain_variation == "Re" then
	randomize_terrain("Re,Aa", "Re^Wel,Re^Dr,Re^Dr,Re^Dr,Re^Dr,Re^Dr,Re^Dr,Re^Dr,Re^Dr,Re^Dr,Re^Dr,Uh,Uh,Uh,Uh,Uh,Uu,Uu,Uu,Uu,Uu,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf")
elseif dungeon_creation.temp.terrain_variation == "Ryc" then
	randomize_terrain("Re,Aa", "Ryc^Wel,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Uh,Uh,Uh,Uh,Uh,Uu,Uu,Uu,Uu,Uu,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Ryc^Dr,Uh,Uh,Uh,Uh,Uh,Uu,Uu,Uu,Uu,Uu,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf")
elseif dungeon_creation.temp.terrain_variation == "Ur" then
	randomize_terrain("Re,Aa", "Ur^Wel,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uh,Uh,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uu,Uu,Uh,Uu,Uh,Uh,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Rd,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Ur^Dr,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf")
elseif dungeon_creation.temp.terrain_variation == "Wwf" then
	randomize_terrain("Re,Aa", "Wwf^Wel,Wwf^Wel,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Wwr,Ds,Ds,Ds,Ds,Ds,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Ss,Wwf^Dr,Wwf^Dr,Wwf^Dr,Wwf^Dr,Wwf^Dr,Wwf^Dr,Wwf^Dr,Wwf^Dr,Wwf^Dr,Wwf^Dr,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf")
elseif dungeon_creation.temp.terrain_variation == "Rr" then
	randomize_terrain("Re,Aa", "Rr^Wel,Rr^Dr,Rr^Dr,Rr^Dr,Rr^Dr,Ur,Rd,Uh,Uu,Uu^Uf,Rr^Dr,Rr^Dr,Rr^Dr,Rr^Dr,Ur,Rd,Uh,Uu,Uu^Uf,Rr^Dr,Rr^Dr,Rr^Dr,Rr^Dr,Ur,Rd,Uh,Uu,Uu^Uf,Rr^Dr,Rr^Dr,Rr^Dr,Rr^Dr,Ur,Rd,Uh,Uu,Uu^Uf,Rr^Dr,Rr^Dr,Rr^Dr,Rr^Dr,Ur,Rd,Uh,Uu,Uu^Uf,Rr^Dr,Rr^Dr,Rr^Dr,Rr^Dr,Ur,Rd,Uh,Uu,Uu^Uf,Rr^Dr,Rr^Dr,Rr^Dr,Rr^Dr,Ur,Rd,Uh,Uu,Uu^Uf")
elseif dungeon_creation.temp.terrain_variation == "Ryv" then
	randomize_terrain("Re,Aa", "Ryv^Wel,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Ryv^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf")
elseif dungeon_creation.temp.terrain_variation == "Rys" then
	randomize_terrain("Re,Aa", "Rys^Wel,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Rys^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf")
else
	randomize_terrain("Re,Aa", "Ryf^Wel,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Ryf^Dr,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uh,Uu,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf,Uu^Uf")
end

local trapdoor_data = {}
local function select_trapdoor_location(dir)
	local loc_index = H.rand("0..$($chamber_terrain.hexes.length-1)")
	trapdoor_data[dir] = wesnoth.get_variable(string.format("chamber_terrain.hexes[%d]", loc_index))
end
local function invalid_trapdoor_placement()
	return H.distance_between(trapdoor_data.up.x, trapdoor_data.up.y, trapdoor_data.down.x, trapdoor_data.down.y) < 35
end

select_trapdoor_location("up")
select_trapdoor_location("down")
while invalid_trapdoor_placement() do
	select_trapdoor_location("up")
	if invalid_trapdoor_placement() then
		select_trapdoor_location("down")
	end
end

wesnoth.set_variable("dungeon_exit.x", trapdoor_data.up.x)
wesnoth.set_variable("dungeon_exit.y", trapdoor_data.up.y)
wesnoth.set_terrain(trapdoor_data.down.x, trapdoor_data.down.y, "Re")
wesnoth.set_terrain(trapdoor_data.up.x, trapdoor_data.up.y, "Re")
W.create_exit {
	x = trapdoor_data.down.x,
	y = trapdoor_data.down.y,
	destination = "Dungeon",
	label = string.format("Down to level %d", wesnoth.get_variable("dungeon_level.current") + 1),
	image = "scenery/trapdoor-open.png"
}
W.create_exit {
	x = trapdoor_data.up.x,
	y = trapdoor_data.up.y,
	destination = "Town",
	label = "To Overworld",
	image = "stairs-up.png"
}

local mapData
if dungeon_creation.temp.flow_type == 1 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_1.lua")
elseif dungeon_creation.temp.flow_type == 2 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_2.lua")
elseif dungeon_creation.temp.flow_type == 3 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_3.lua")
elseif dungeon_creation.temp.flow_type == 4 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_4.lua")
elseif dungeon_creation.temp.flow_type == 5 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_5.lua")
elseif dungeon_creation.temp.flow_type == 6 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_6.lua")
elseif dungeon_creation.temp.flow_type == 7 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_7.lua")
elseif dungeon_creation.temp.flow_type == 8 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_8.lua")
elseif dungeon_creation.temp.flow_type == 9 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_9.lua")
elseif dungeon_creation.temp.flow_type == 10 then
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_10.lua")
else
	mapData = wesnoth.dofile("~add-ons/Wesband/masks/cross_none.lua")
end
W.terrain_mask {
	x = 1,
	y = 1,
	mask = mapData,
	{"rule", { old = "Xu", new = "Ai", terrain = "$dungeon_creation.temp.flow_flavor" } },
	{"rule", { old = "Ai", new = "Re,Ai", terrain = "$dungeon_creation.temp.pool_flavor" } },
	{"rule", { old = "Re,Aa", new = "Re,Ai", terrain = "$dungeon_creation.temp.terrain_variation" } },
	{"rule", { old = "Xu", new = "Re", terrain = "$dungeon_creation.temp.wall_flavor" } },
	{"rule", { use_old = "yes" } }
}