// This module defines the Unit class, which represents
// one moveable game token (soldier, tank, dragon, etc.)
// It's responsible for creating the sprites that represent
// this unit in the display, as well as managing the unit
// state.

import "mathUtil"
import "listUtil"
import "utils"
ensureImport "qa"
ensureImport "mapview"

Unit = {}
Unit.figure = null  // sprite that stands on top of the base
Unit.col = 0
Unit.row = 0
Unit.position = function;	 return [col, row]; end function
Unit.maxHP = 5
Unit.hp = 5
Unit.maxAP = 3
Unit.ap = 3
Unit.hasOrders = false
Unit.player = null  // Player that owns this unit

display(4).mode = displayMode.sprite
unitDisp = display(4)
unitDisp.clear

discImage = file.loadImage("pics/disc.png")
healthBarBG = file.loadImage("pics/disc-healthbar-bg.png")
healthBarFill = file.loadImage("pics/disc-healthbar-fill.png")
actionPointImage = [
file.loadImage("pics/discAP1.png"),
file.loadImage("pics/discAP2.png"),
file.loadImage("pics/discAP3.png") ]

unitImages = {}
unitImages.dwarf = file.loadImage("pics/dorf2.png")

// Initialize this unit.  Call this after creating the unit with `new`.
Unit.init = function(owningPlayer)
	qa.assert owningPlayer != null
	self.player = owningPlayer
	self.base = new Sprite
	self.figure = new Sprite
end function

Unit.startTurn = function
	if self.ap != self.maxAP then
		self.ap = self.maxAP
		self.updateBase
	end if
end function

Unit.hitBy = function(xyMap)
	if self.base.hitBy(xyMap) then return true
	if self.figure.tint != color.clear and self.figure.hitBy(xyMap) then
		return true
	end if
	return false
end function

Unit.updateBase = function
	self.base.image = composeDisc(self.player.color,
	self.hp / self.maxHP * 100, self.ap, self.maxAP, self.hasOrders)
end function

// Add this unit to the display.
Unit.show = function(includeFigure = false)
	self.updateBase
	self.base.scale = 0.5
	unitDisp.sprites.push self.base
	
	if includeFigure and self.figure then
		unitDisp.sprites.push self.figure
	end if
end function

// Remove this unit from the display
Unit.hide = function()
	unitDisp.sprites.removeVal self.base
	unitDisp.sprites.removeVal self.figure	
end function

// Update this method.  Called frequently while the unit is
// visible on the game board.
Unit.update = function()
	
end function

// Remove this unit from the game.
Unit.die = function()
	self.hide
	self.player.units.removeVal self
	qa.assert self.player.units.indexOf(self) == null
	self.player = null
end function

Unit.setPositionXY = function(x, y, sort=true)
	self.base.x = x
	self.base.y = y
	self.base.sortOrder = -self.base.y
	if self.figure then
		self.figure.x = self.base.x
		self.figure.y = self.base.y +
		self.figure.image.height * self.figure.scale / 2
		self.figure.sortOrder = self.base.sortOrder + 1
	end if
	if sort then unitDisp.sprites.sort "sortOrder"
end function

Unit.setPosition = function(col, row)
	prevCol = self.col; prevRow = self.row
	self.col = col
	self.row = row
	self.player.units.removeVal self
	self.player.units.push self
	self.setPositionXY mapview.xForCell(col, row), mapview.yForCell(col, row)
	updateStack prevCol, prevRow
	updateStack col, row
end function

// Consume the given number of AP.  Return true
// if successful, false if we don't have enough AP.
Unit.spendAP = function(actionPointsToSpend=1)
	if self.ap < actionPointsToSpend then return false
	self.ap = self.ap - actionPointsToSpend
	self.updateBase
	return true
end function

Unit.canEnter = function(col, row)
	if mapview.isWater(col, row) then return false
	u = game.unitAtCell([col, row])
	if u != null and u.player != self.player then return false
	return true
end function

Unit.goTo = function(colRowList, moveCostMap)
	if not moveCostMap.hasIndex(colRowList) then return // can't reach it
	cost = moveCostMap[colRowList]
	if not self.spendAP(cost) then return  // out of action points!
	self.setPosition colRowList[0], colRowList[1]
end function

Unit.attack = function(targetUnit)
	// make sure target is only 1 move away
	if not mapview.isNeighboring(self, targetUnit) then
		return // too far away (ToDo: ranged attacks!)
	end if
	if not self.spendAP(1) then return  // out of action points!
	
	// move (animate) towards the target
	startX = self.base.x
	startY = self.base.y
	midX = (startX + targetUnit.base.x) * 0.5
	midY = (startY + targetUnit.base.y) * 0.5
	for t in range(0, 1, 0.1)
		self.setPositionXY mathUtil.lerp(startX, midX, t),
		mathUtil.lerp(startY, midY, t)
		yield
	end for
	
	// calculate and apply damage
	damage = utils.roll(1, 4)
	targetUnit.hp = targetUnit.hp - damage
	if targetUnit.hp <= 0 then
		// target unit is destroyed!
		endX = targetUnit.base.x
		endY = targetUnit.base.y
		targetUnit.die
		self.setPosition targetUnit.col, targetUnit.row
	else
		// target unit is not destroyed; this unit is repelled
		targetUnit.updateBase
		endX = startX
		endY = startY
	end if
	
	// move (animate) back to our starting position
	for t in range(1, 0, -0.1)
		self.setPositionXY mathUtil.lerp(endX, midX, t),
		mathUtil.lerp(endY, midY, t)
		yield
	end for
end function

Unit.moveToTopOfStack = function
	units = game.allUnitsAtCell( [self.col, self.row] )
	if units.len < 2 then return  // only one unit (no stack)
	idx = units.indexOf(self)
	if idx == units.len - 1 then return // already on top
	self.player.units.removeVal self
	self.player.units.push self
	updateStack self.col, self.row
end function

updateStack = function(col, row)
	// Find the units at this column and row.
	// Hide all but the topmost figure, and adjust
	// Y positions accordingly.
	if not globals.hasIndex("game") then return // (happens during setup)
	units = game.allUnitsAtCell( [col,row] )
	if not units then return
	x = mapview.xForCell(col, row)
	y = mapview.yForCell(col, row)
	sortOrder = -y
	for u in units
		u.setPositionXY x, y, false
		u.base.sortOrder = sortOrder
		y = y + 8
		sortOrder = sortOrder + 1
		if u == units[-1] then
			u.figure.tint = color.white
			u.figure.sortOrder = sortOrder
		else
			u.figure.tint = color.clear
		end if
	end for
	unitDisp.sprites.sort "sortOrder"
end function

workBuffer = new PixelDisplay
workBuffer.drawTinted = function(img, tint="#FFFFFF")
	self.drawImage img, 0, 0, img.width, img.height,
	0, 0, img.width, img.height, tint
end function

composeDisc = function(baseColor="#CCCCFF", healthPercent=50, apLeft=3, apTotal=3, hasOrders=false)
	// draw the disc base
	workBuffer.clear color.clear, discImage.width, discImage.height
	workBuffer.drawTinted discImage, baseColor
	
	// draw the health bar
	workBuffer.drawTinted healthBarBG	
	t = healthPercent * 0.01
	healthColor = color.lerp(color.red, color.green, t)
	// we need to interpolate over just the portion of the image
	// where the health bar resides -- from 81-114 (in X).
	w = mathUtil.lerp(81, 114, t)
	workBuffer.drawImage healthBarFill, 0, 0, w, healthBarFill.height,
	0, 0, w, healthBarFill.height, healthColor
	
	// draw the action points
	for i in range(0, apTotal-1)
		if i >= apLeft then
			c = "#222222"
		else if hasOrders then
			c = color.yellow
		else
			c = color.lime
		end if
		workBuffer.drawImage actionPointImage[i],
		0, 0, workBuffer.width, workBuffer.height,
		0, 0, workBuffer.width, workBuffer.height, c
	end for
	
	// return the composite image
	return workBuffer.getImage(0, 0, workBuffer.width, workBuffer.height)
end function

if locals == globals then
	// Test this module.
	clear
	fakePlayer = {}
	fakePlayer.color = "#8888FF"
	u = new Unit
	u.init fakePlayer
	u.figure.image = unitImages.dwarf
	u.setPosition 10,10
	u.hp = 3
	u.ap = 2
	u.hasOrders = true
	u.show true
else
	// imported as a module: move Unit into the global namespace
	globals.Unit = Unit
end if