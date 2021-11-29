// Strategy Game Kit
// Main Program

import "utils"
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
	text.row = 25; print game.curPlayer.name + "'s Turn!"
	globals.selectedUnit = null
end function

nextPlayer = function()
	index = game.curPlayer.number
	index = (index + 1) % game.players.len
	game.curPlayer = game.players[index]
	startTurn
end function

selectedUnit = null  // currently selected unit receiving orders
selectUnit = function(unit)
	if unit.player != game.curPlayer then
		// not our unit to select
		return
	end if
	globals.selectedUnit = unit
end function

handleKey = function(keyChar)
	if keyChar == char(10) then
		nextPlayer
	else
		text.row = 25
		print "keyChar: " + keyChar.code
	end if
end function

handleMouse = function()
	colRow = mapview.cellAt(mouse)
	unit = game.unitAtCell(colRow)
	if unit then
		selectUnit unit
	else if selectedUnit then
		selectedUnit.goTo colRow
	end if
end function

startTurn

// Main Loop
while true
	if key.available then handleKey key.get
	if mouse.button then handleMouse
end while
