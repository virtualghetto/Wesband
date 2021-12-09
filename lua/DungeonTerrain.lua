local function randomize_terrain(base, variations)
	W.store_locations {
			terrain = base,
			variable = "temp_rand_terrain"
		}
	W.set_variable { name = "r_temp", rand = "0,0,0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,3,3,3,3,4,4,4,5,5,6" }
	local rand_count = r_temp
	while rand_count < temp_rand_terrain.length do
		W.set_variable { name = "r_temp", rand = variations }
		wesnoth.set_terrain(temp_rand_terrain[rand_count].x, temp_rand_terrain[rand_count].y, r_temp)
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

W.set_variable { name = "r_temp", rand = "0..$($chamber_terrain.length-1)" }
trapdoor_up.x, trapdoor_up.y = chamber_terrain[r_temp].x, chamber_terrain[r_temp].y
W.set_variable { name = "r_temp", rand = "0..$($chamber_terrain.length-1)" }
trapdoor_down.x, trapdoor_down.y = chamber_terrain[r_temp].x, chamber_terrain[r_temp].y
while H.distance_between(trapdoor_up.x, trapdoor_up.y, trapdoor_down.x, trapdoor_down.y) < 35 do
	W.set_variable { name = "r_temp", rand = "0..$($chamber_terrain.length-1)" }
	trapdoor_up.x, trapdoor_up.y = chamber_terrain[r_temp].x, chamber_terrain[r_temp].y
	if H.distance_between(trapdoor_up.x, trapdoor_up.y, trapdoor_down.x, trapdoor_down.y) < 35 then
		W.set_variable { name = "r_temp", rand = "0..$($chamber_terrain.length-1)" }
		trapdoor_down.x, trapdoor_down.y = chamber_terrain[r_temp].x, chamber_terrain[r_temp].y
	end
end
wesnoth.set_terrain(trapdoor_down.x, trapdoor_down.y, "Re")
W.item {
	x = trapdoor_up.x,
	y = trapdoor_up.y,
	image = "stairs-up.png",
	visible_in_fog = "yes"
}
wesnoth.set_terrain(trapdoor_up.x, trapdoor_up.y, "Re")
W.item {
	x = trapdoor_down.x,
	y = trapdoor_down.y,
	image = "scenery/trapdoor-open.png",
	visible_in_fog = "yes"
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