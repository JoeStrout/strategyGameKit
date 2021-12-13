// This module defines the Unit class, which represents
// one moveable game token (soldier, tank, dragon, etc.)
// It's responsible for creating the sprites that represent
// this unit in the display, as well as managing the unit
// state.

import "mathUtil"
import "listUtil"
import "utils"
import "qa"
ensureImport "mapview"

Unit = {}
Unit.figure = null  // sprite that stands on top of the base
Unit.col = 0
Unit.row = 0
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

Unit.updateBase = function()
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
	self.player = null
end function

Unit.setPositionXY = function(x, y)
	self.base.x = x
	self.base.y = y
	self.base.sortOrder = -self.base.y
	if self.figure then
		self.figure.x = self.base.x
		self.figure.y = self.base.y +
		self.figure.image.height * self.figure.scale / 2
		self.figure.sortOrder = self.base.sortOrder + 1
	end if
	unitDisp.sprites.sort "sortOrder"
end function

Unit.setPosition = function(col, row)
	self.col = col
	self.row = row
	self.setPositionXY mapview.xForCell(col, row), mapview.yForCell(col, row)
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
	if u != null then return false
	return true
end function

Unit.goTo = function(colRowList, moveCostMap)
	cost = moveCostMap[colRowList]
	if not self.spendAP(cost) then return  // out of action points!
	self.setPosition colRowList[0], colRowList[1]
end function

Unit.attack = function(targetUnit)
	if not self.spendAP then return  // out of action points!
	
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