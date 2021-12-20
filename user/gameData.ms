// This module represents the data model for the game:
// Players, their units, state of the map, etc.

Player = {}
Player.color = color.gray
Player.number = 0    // 0-based player number
Player.name = ""     // player name as shown to the user
Player.units = null  // list of Unit

Player.addStarterUnits = function()
	row = 19 - 3 * self.number
	for col in range(6,10,2)
		u = new Unit
		u.init self
		u.figure.image = unit.unitImages.dwarf
		u.setPosition col, row
		self.units.push u
	end for
end function

GameState = {}
GameState.players = null // list of Player
GameState.curPlayer = null // some Player from self.players

GameState.unitAtCell = function(colRowList)
	for pl in self.players
		for u in pl.units
			if u.col == colRowList[0] and u.row == colRowList[1] then
				return u
			end if
		end for
	end for
	return null
end function

GameState.allUnitsAtCell = function(colRowList)
	result = []
	for pl in self.players
		for u in pl.units
			if u.col == colRowList[0] and u.row == colRowList[1] then
				result.push u
			end if
		end for
	end for
	return result
end function

newGame = function(numPlayers=3)
	gs = new GameState
	gs.players = []
	colors = ["#808BFFFF", "#FFB9FFFF", "#9CFF99FF"]
	names = ["Alice", "Bob", "Carol", "Dave", "Edna"]
	for i in range(0, numPlayers-1)
		pl = new Player
		pl.units = []
		pl.color = colors[i]
		pl.number = i
		pl.name = names[i]
		pl.addStarterUnits
		gs.players.push pl
	end for
	gs.curPlayer = gs.players[0]
	return gs
end function
