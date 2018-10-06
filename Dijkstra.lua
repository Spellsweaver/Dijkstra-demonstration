-- Dijkstra's map and pathfinding functions for cell-map
-- Code by Spellweaver (spellsweaver@gmail.com)

function dijkstra_scan(field,diagonal_forbidden,movement_cost) 
-- this function makes a scan of a pre-initialized field, creating Dijkstra's map out of it
--[[	field format is 
		{
		{field[1,1], field[1,2], field[1,3]},
		{field[2,1], field[2,1], field[2,3]},
		{field[3,1], field[3,1], field[3,3]}
		}
		Size is detected automatically.
		For proper Dijkstra's map creation, sources must be 0 while all the other field must be math.huge.
		For some applications, like a fleeing pathfinding, a "special" initialized map should be used.
		If you pass an already finished Dijkstra's map to the function, the result will be the same.
		nil values are treated as math.huge (infinity)

		diagonal_forbidden parameter set to false means that all 8 directions are available. It produces maps like
		22222
		21112
		21012
		21112
		22222
		Otherwise the same map returns the result of
		43234
		32123
		21012
		32123
		43234
		By default, diagonal movement is allowed.

		movement_cost is the matrix of the same size as field.
		It's a cost of going TO that place.
		Nil value is treated like 1
		Nil movement_cost means a field of 1's.
		Values <0 mean unpassable terrain.
]]--
	local map={}
		for i=1,#field do
			map[i]={}
			for j=1,#field[i] do
				map[i][j]=field[i][j]
			end
		end
	
	movement_cost = movement_cost or {} -- empty table if nil value
		for i=1,#map do
			movement_cost[i] = movement_cost[i] or {}
		end
	local has_changed=true -- false means no changes were made on the last iteration, so we should stop
	while has_changed do
		has_changed=false



		for i=1,#map do
			for j=1,#map[i] do
				-- if not impassable
				if (movement_cost[i][j] or 1) >=0 then
				-- first, find the minimum of the surrounding cells
					local minround=math.huge
					if diagonal_forbidden then -- only checking cardinal directions
						for k=-1,1 do
							if i+k<=#map and i+k>0 then
								minround=math.min(minround,map[i+k][j] or math.huge)
							end
						end
						for l=-1,1 do
							minround=math.min(minround,map[i][j+l] or math.huge)
						end
					else -- checking all directions
						for k=-1,1 do
							for l=-1,1 do
								if i+k<=#map and i+k>0 then
								minround=math.min(minround,map[i+k][j+l] or math.huge)
								end
							end
						end
					end
				-- if can be accessed faster, adjust
					if (map[i][j] or math.huge) > minround+(movement_cost[i][j] or 1) then
					map[i][j]=minround+(movement_cost[i][j] or 1)
					has_changed=true
					end
				end
			end
		end
	end
	return map
end

function dijkstra_step(map,x,y,diagonal_forbidden)
--[[	
	This function gives the direction of the first step to the nearest source using already created Dijkstra's map
	You can use dijkstra_scan function to get map for this function but it's advised to create a map beforehand unless you'll be only using it once
	If you pass an improper map to this function, strange results are going to occur
	Function returns increment to x and y, and then movement cost
]]--
	local minround,dx,dy=(map[x][y] or 0),0,0

	if diagonal_forbidden then -- only checking cardinal directions
		for k=-1,1 do
			if x+k>0 and x+k<=#map and (map[x+k][y] or math.huge)<minround then
				minround=map[x+k][y]
				dx=k
				dy=0
			end
		end
		for l=-1,1 do
			if (map[x][y+l] or math.huge)<minround then
				minround=map[x][y+l]
				dx=0
				dy=l
			end
		end
	else
		for k=-1,1 do
			for l=-1,1 do
				if x+k>0 and x+k<=#map and ((map[x+k][y+l] or math.huge)<minround or (map[x+k][y+l] or math.huge)==minround and (k==0 or l==0) and minround~=math.huge) then
				-- despite the same cost for moving diagonally, paths with diagonals prefered over cardinal directions look weird
				-- that's why we switch to cardinal directions whenever possible without hurting the path length
					minround=map[x+k][y+l]
					dx=k
					dy=l
				end
			end
		end
	end
	return dx,dy,(map[x][y]-minround)
end

function dijkstra_path(map,x,y,diagonal_forbidden)

--[[ 
	This function finds the way from the particular point to the nearest source using already created Dijkstra's map.
	You can use dijkstra_scan function to get map for this function but it's advised to create a map beforehand unless you'll be only using it once
	if you pass an improper map to this function, strange results are going to occur
	the path is finished when there is no place with lower value nearby
	this means that, for normal dijkstra maps it finds the way to the nearest (or the only) source
	it returns lists of x, y, movement cost
	In case you only need to do a single step, dijkstra_step is advised
]]--
	local pathx={x}
	local pathy={y}
	local pathcost = {0}
	local dx,dy
	dx,dy,pathcost[#pathcost+1]=dijkstra_step(map,pathx[#pathx],pathy[#pathy],diagonal_forbidden)
	while dx~=0 or dy~=0 do
		pathx[#pathx+1]=pathx[#pathx]+dx
		pathy[#pathy+1]=pathy[#pathy]+dy
		dx,dy,pathcost[#pathcost+1]=dijkstra_step(map,pathx[#pathx],pathy[#pathy],diagonal_forbidden)
	end
	pathcost[#pathcost]=nil
	return pathx,pathy,pathcost
end

function dijkstra_reversed(field,diagonal_forbidden,movement_cost,constant)
--[[
	This function creates a map for path as far away from the sources as possible.
	It can be used, for example, to create a path of a fleeing monster.
	Pathfinding functions, that are applied to this map, work properly except they lead away from sources.
	The higher the constant is, the farther away from the source path leads.
	With very low values it stops in the first corner, with vary high values it leads only to the farthest point of map.
	Default is 1.3
]]--
	constant=constant or 1.3
	local map=dijkstra_scan(field,diagonal_forbidden,movement_cost) -- initial Dijkstra's map
	for i=1,#map do -- multiplied by -constant
		for j=1,#map[i] do
			if map[i][j]~=math.huge then
			map[i][j]=-constant*map[i][j]
			end
		end
	end
	local movcost={}
	--we make what was sources unpassable, to make the path avoid them
		for i=1,#map do
			movcost[i]={}
			for j=1,#map[i] do
				if map[i][j]==0 then
					movcost[i][j]=-1
				else
					movcost[i][j]=movement_cost[i][j]
				end
			end
		end
	map=dijkstra_scan(map,diagonal_forbidden,movcost) --essentially, a map with farthest cells as sources
	return map
end