--Dijkstra map demonstration
--by Spellweaver (spellsweaver@gmail.com)

dijkstra = require ('Dijkstra')

function distcolor(distance)
	distance = distance or 0
	if distance%24==0 then
		return 1,0,0
	elseif distance%24==1 then
		return 1,0.25,0
	elseif distance%24==2 then
		return 1,0.5,0
	elseif distance%24==3 then
		return 1,0.75,0
	elseif distance%24==4 then
		return 1,1,0
	elseif distance%24==5 then
		return 0.75,1,0
	elseif distance%24==6 then
		return 0.5,1,0
	elseif distance%24==7 then
		return 0.25,1,0
	elseif distance%24==8 then
		return 0,1,0
	elseif distance%24==9 then
		return 0,1,0.25
	elseif distance%24==10 then
		return 0,1,0.5
	elseif distance%24==11 then
		return 0,1,0.75
	elseif distance%24==12 then
		return 0,1,1
	elseif distance%24==13 then
		return 0,0.75,1
	elseif distance%24==14 then
		return 0,0.5,1
	elseif distance%24==15 then
		return 0,0.25,1
	elseif distance%24==16 then
		return 0,0,1
	elseif distance%24==17 then
		return 0.25,0,1
	elseif distance%24==18 then
		return 0.5,0,1
	elseif distance%24==19 then
		return 0.75,0,1
	elseif distance%24==20 then
		return 1,0,1
	elseif distance%24==21 then
		return 1,0,0.75
	elseif distance%24==22 then
		return 1,0,0.5
	elseif distance%24==23 then
		return 1,0,0.25
	else
		return 0,0,0
	end
end

function rescan() --to simplify dijkstra scan use
	if inverted then
		map_drawn=dijkstra_reversed(map,diagonal_disabled,path,const)
	else
		map_drawn=dijkstra_scan(map,diagonal_disabled,path)
	end
end

function wheremouse() --returns x,y of the cell mouse is pointed at
	local cellx = math.ceil(love.mouse.getX()/cell_width)
	cellx=math.max(cellx,0)
	local celly = math.ceil(love.mouse.getY()/cell_height)
	celly=math.max(celly,0)
	return {x=cellx,y=celly}
end

function love.load()
	cell_width,cell_height=40,40
	love.window.setMode (24*cell_width,24*cell_height,{fullscreen=false,vsync=true,resizable=false,borderless=false})
	love.window.setTitle ("Dijkstra's algorithm demonstration")

	map={}
	for i=1,24 do
		map[i]={}
		for j=1,24 do
			map[i][j]=math.huge
		end
	end

	map[1][1]=0

	path={}
		for i=1,24 do
		path[i]={}
			for j=1,24 do
				path[i][j]=1
			end
	end

	inverted=false
	diagonal_disabled=false
	numbers_shown=false
	xmarks=false
	colors=true
	pathfind=true
	const=1.3

	rescan()

end

function love.draw()
	for i=1,24 do
		for j=1,24 do
			if colors then
				love.graphics.setColor(distcolor(math.floor(map_drawn[i][j])))
				love.graphics.rectangle('fill',cell_width*(i-1),cell_height*(j-1),cell_width,cell_height)
			end
			if path[i][j]==-1 then
				love.graphics.setColor(1,1,1)
				love.graphics.rectangle('line',cell_width*(i-1),cell_height*(j-1),cell_width,cell_height)
			end
			if xmarks and map[i][j]==0 then
				if colors then
					love.graphics.setColor(0,0,0)
				else
					love.graphics.setColor(1,1,1)
				end
				love.graphics.line(cell_width*(i-1),cell_height*(j-1),cell_width*(i),cell_height*(j))
				love.graphics.line(cell_width*(i-1),cell_height*(j),cell_width*(i),cell_height*(j-1))
			end
			if numbers_shown then
				if colors then
					love.graphics.setColor(0,0,0)
				else
					love.graphics.setColor(1,1,1)
				end
				love.graphics.print(string.format("%.1f",map_drawn[i][j]),cell_width*(i-1),cell_height*(j-0.5))
			end
		end
	end
	if pathfind and wheremouse().x<=24 and wheremouse().x>0 and wheremouse().y<=24 and wheremouse().y>0 then
		if colors then
			love.graphics.setColor(0,0,0)
		else
			love.graphics.setColor(1,1,1)
		end
		pathx,pathy=dijkstra_path(map_drawn,wheremouse().x,wheremouse().y,diagonal_disabled)
			for i=1, #pathx-1 do
				love.graphics.line( cell_width*(pathx[i]-0.5),cell_height*(pathy[i]-0.5),cell_width*(pathx[i+1]-0.5),cell_height*(pathy[i+1]-0.5))
			end

	end
end

function love.mousepressed( x, y, button )
	if button==1 then
		if map[wheremouse().x][wheremouse().y]==0 then map[wheremouse().x][wheremouse().y]=math.huge
		else map[wheremouse().x][wheremouse().y]=0
		end
		rescan()
	elseif button==2 then
		if path[wheremouse().x][wheremouse().y]==-1 then path[wheremouse().x][wheremouse().y]=nil
		else path[wheremouse().x][wheremouse().y]=-1
		end
		rescan()
	end
end


function love.keypressed(key)
	if key=='f' or key=='F' or key=='а' or key=='А' then
		inverted = not inverted
		rescan()
	elseif key=='d' or key=='D' or key=='в' or key=='В' then
		diagonal_disabled = not diagonal_disabled
		rescan()
	elseif key=='x' or key=='X' or key=='ч' or key=='Ч' then
		xmarks=not xmarks
	elseif key=='c' or key=='C' or key=='с' or key=='С' then
		colors=not colors
	elseif key=='p' or key=='P' or key=='з' or key=='З' then
		pathfind=not pathfind
	elseif key=='+' or key=='kp+' or key=='=' then
		const=const+0.1
		rescan()
	elseif key=='-' or key=='kp-' then
		const=const-0.1
		rescan()
	elseif key=='n' or key=='N' or key=='т' or key=='Т' then
		numbers_shown=not numbers_shown
	end

end