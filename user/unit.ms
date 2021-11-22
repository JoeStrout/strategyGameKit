// This module defines the Unit class, which represents
// one moveable game token (soldier, tank, dragon, etc.)
// It's responsible for creating the sprites that represent
// this unit in the display, as well as managing the unit
// state.

import "mathUtil"
import "utils"
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
Unit.teamColor = "#CCCCFF"

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
Unit.init = function()
	self.base = new Sprite
	self.figure = new Sprite
end function

// Add this unit to the display.
Unit.show = function(includeFigure = false)
	self.base.image = composeDisc(self.teamColor,
	  self.hp / self.maxHP * 100, self.ap, self.maxAP, self.hasOrders)
	self.base.scale = 0.5
	unitDisp.sprites.push self.base
	
	if includeFigure and self.figure then
		unitDisp.sprites.push self.figure
	end if
end function

// Remove this unit from the display
Unit.hide = function()
	
end function

// Update this method.  Called frequently while the unit is
// visible on the game board.
Unit.update = function()
	
end function

Unit.setPosition = function(col, row)
	self.col = col
	self.row = row
	self.base.x = mapview.xForCell(col, row)
	self.base.y = mapview.yForCell(col, row)
	if self.figure then
		self.figure.x = self.base.x
		self.figure.y = self.base.y +
		   self.figure.image.height * self.figure.scale / 2
	end if
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
	u = new Unit
	u.init
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