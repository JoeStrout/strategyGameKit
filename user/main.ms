// Strategy Game Kit
// Main Program

import "utils"
import "qa"
ensureImport "mapview"
ensureImport "unit"
ensureImport "gameData"

mapview.init
mapview.generateMap
game = gameData.newGame

for pl in game.players
	for u in pl.units
		u.show true
	end for	
end for

startTurn = function()
	text.row = 25; print game.curPlayer.name + "'s Turn!" + " "*30
	globals.selectedUnit = null
	game.curPlayer.startTurn
end function

nextPlayer = function()
	index = game.curPlayer.number
	index = (index + 1) % game.players.len
	game.curPlayer = game.players[index]
	startTurn
end function

costColors = ["#FFFFFF","#FFFFFF", "#CCCCCC", "#AAAAAA", "#888888"]
considerMoveTarget = function(unitMoving, colRow, cost, toDoList)
	if cost > unitMoving.ap then return
	if not unitMoving.canEnter(colRow[0], colRow[1]) then return
	if moveCost.hasIndex(colRow) and moveCost[colRow] <= cost then return
	moveCost[colRow] = cost
	mapview.tintCell colRow[0], colRow[1], costColors[cost]
	toDoList.push colRow
end function

selectedUnit = null  // currently selected unit receiving orders
selectUnit = function(unit)
	if unit.player != game.curPlayer then
		// not our unit to select
		return
	end if
	globals.selectedUnit = unit
	unit.moveToTopOfStack
	
	// start with the whole map dark
	mapview.darkenMap [unit.col, unit.row]
	if unit.ap < 1 then return
	
	// then highlight (undarken) reachable spaces
	globals.moveCost = {}  // key: [col,row]; value: AP required to reach this cell
	toDo = []  // list of cells to consider expanding
	for n in mapview.neighbors(unit.col, unit.row)
		considerMoveTarget unit, n, 1, toDo
	end for
	while toDo
		cell = toDo.pull  // (pull does a breadth-first search)
		cost = moveCost[cell] + 1
		for n in mapview.neighbors(cell[0], cell[1])
			considerMoveTarget unit, n, cost, toDo
		end for
	end while	
end function

handleKey = function(keyChar)
	if keyChar == char(10) then
		nextPlayer
	else
		text.row = 25
		print "keyChar: " + keyChar.code
	end if
end function

unitAtPosition = function(xyMap)
	for pl in game.players
		for i in range(pl.units.len - 1)
			u = pl.units[i]
			if u.hitBy(xyMap) then return u
		end for
	end for
end function

handleMouse = function()
	colRow = mapview.cellAt(mouse)
	unit = unitAtPosition(mouse)
	if unit then colRow = [unit.col, unit.row]
	
	// move the selected unit on top of the clicked unit
	// IF it is in range, and (ToDo) stackable
	// and not already part of the same stack
	if unit and selectedUnit and 
	  (selectedUnit.col != colRow[0] or selectedUnit.row != colRow[1]) and
	  unit.player == game.curPlayer and 
	  moveCost.hasIndex(colRow) and
	  moveCost[colRow] <= selectedUnit.ap then
		unit = null  // go to the cell; forget about the unit clicked
	end if
	
	if unit then
		if unit.player == game.curPlayer then
			// select the unit clicked
			selectUnit unit
		else if selectedUnit != null then
			// attack the unit clicked with previously-selected unit
			selectedUnit.attack unit
			selectUnit selectedUnit
		end if
	else if selectedUnit then
		selectedUnit.goTo colRow, moveCost
		selectUnit selectedUnit
	end if
	// wait for mouse-up
	while mouse.button; yield; end while
end function

startTurn

// Main Loop
while true
	if key.available then handleKey key.get
	if mouse.button then handleMouse
end while
