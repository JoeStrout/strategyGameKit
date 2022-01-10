// This module is responsible for drawing the map.

// Tile (terrain) types in our tile map:
kDesert = 0
kGrass = 1
kWater = 2
kWheat = 3
kMountains = 4
kForest = 5

init = function()
	clear
	display(5).mode = displayMode.off
	display(6).mode = displayMode.tile
	outer.td = display(6)
	td.tileSet = file.loadImage("/sys/pics/hextiles-55x64.png")
	td.tileSetTileSize = [55,64]
	td.cellSize = [55,32]
	td.oddRowOffset = 0.5
	td.extent = [50, 50]
	td.overlap = [0, 8]
	td.clear kWater
	
	outer.spacing = [td.cellSize[0] - td.overlap[0], td.cellSize[1] - td.overlap[1]]
end function

mapWidth = function()
	return td.extent[0]
end function

mapHeight = function()
	return td.extent[1]
end function

//----------------------------------------------------------------------
// Make a couple of functions to convert between hex cell
// coordinates, and pixel coordinates.
//----------------------------------------------------------------------
xForCell = function(col, row)
	x = td.cellSize[0]*0.5 + col * spacing[0] - td.scrollX
	x = x + (row%2) * td.oddRowOffset * spacing[0]
	return x
end function

yForCell = function(col, row)
	y = td.cellSize[1]*0.5 + row * spacing[1] - td.scrollY
	return y
end function

colForXY = function(x, y)
	if x isa map and y == null then
		y = x.y
		x = x.x
	end if
	row = rowForXY(x, y)
	col = (x + td.scrollX - td.cellSize[0]*0.5 - 
	(row%2)*td.oddRowOffset*spacing[0]) / spacing[0]
	return round(col)
end function

rowForXY = function(x, y)
	if x isa map and y == null then
		y = x.y
		x = x.x
	end if
	row = (y + td.scrollY - td.cellSize[1]*0.5) / spacing[1]
	return round(row)
end function

inBounds = function(col, row)
	return col >= 0 and col < td.extent[0] and row >= 0 and row < td.extent[1]
end function

cellAt = function(xy)
	c = colForXY(xy.x, xy.y)
	r = rowForXY(xy.x, xy.y)
	if not inBounds(c, r) then return null
	return [c, r]
end function

isWater = function(col, row)
	return td.cell(col, row) == kWater
end function

//----------------------------------------------------------------------
// Get the neighbors of any given hex cell.
// Slightly tricky since it depends on which row you're on.
//----------------------------------------------------------------------
neighbors = function(col, row, allowWater = false)
	result = [[col-1,row], [col+1,row]]
	if row%2 then
		result = result + [[col,row-1], [col+1,row-1]]
		result = result + [[col,row+1], [col+1,row+1]]
	else
		result = result + [[col-1,row-1], [col,row-1]]
		result = result + [[col-1,row+1], [col,row+1]]
	end if
	// Remove any neighbors which are out of bounds or (optionally) water.
	for i in range(result.len-1, 0)
		c = result[i][0]
		r = result[i][1]
		if not inBounds(c,r) or (not allowWater and isWater(c,r)) then
			result.remove i
		end if
	end for
	return result
end function

isNeighboring = function(cell1, cell2)
	return neighbors(cell1.col, cell1.row).indexOf([cell2.col, cell2.row]) != null
end function

// Darken the entire map except for cells that are
// specified in the exceptForCells argument as [col,row],
// which will be untinted.
darkenMap = function(exceptForCells)
	for row in range(0, mapHeight-1)
		for col in range(0, mapWidth-1)
			if exceptForCells.indexOf([col,row]) == null then
				td.setCellTint col, row, "#444444"
			else
				td.setCellTint col, row, "#FFFFFF"
			end if
		end for
	end for
end function

undarkenMap = function(exceptForCells)
	for row in range(0, mapHeight-1)
		for col in range(0, mapWidth-1)
			td.setCellTint col, row, "#FFFFFF"
		end for
	end for
end function

tintCell = function(col, row, tint="#FFFFFF")
	td.setCellTint col, row, tint
end function

//----------------------------------------------------------------------
// World generation functions
//----------------------------------------------------------------------

generateMap = function()
	// generate a round island
	r = 22
	for row in range(0, 49)
		for col in range(0, 49)
			d = sqrt((row-25)^2 + (col-25)^2)
			if d > r then continue
			if d < 3 then
				td.setCell col, row, 5
			else if d < r-1.5 then
				td.setCell col, row, 1
			else
				td.setCell col, row, 0
			end if
			td.setCellTint col, row
		end for
	end for
end function

//----------------------------------------------------------------------
// Tests (load this module and run it directly to run these tests
//----------------------------------------------------------------------

if locals == globals then	
	init
	generateMap
	
	td.scrollX = 30
	td.scrollY = 16
	
	row = 0; col = 0
	while true
		yield
		td.setCellTint col, row, color.white
		row = rowForXY(mouse)
		col = colForXY(mouse)
		td.setCellTint col, row, color.aqua
		text.row=24; print "Row: " + row + "  Col: " + col + "   "
	end while
end if
