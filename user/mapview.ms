// This module is responsible for drawing the map.

display(6).mode = displayMode.tile
td = display(6)
td.tileSet = file.loadImage("hextiles-55x64.png")
td.tileSetTileSize = [55,64]
td.cellSize = [55,32]
td.oddRowOffset = 0.5
td.extent = [50, 50]
td.overlap = [0, 8]
td.clear 2

// for now: generate a round island
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
	end for
end for

td.scrollX = 30
td.scrollY = 16
