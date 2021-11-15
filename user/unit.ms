// This module defines the Unit class, which represents
// one moveable game token (soldier, tank, dragon, etc.)
// It's responsible for creating the sprites that represent
// this unit in the display, as well as managing the unit
// state.

import "mathUtil"

Unit = {}

display(4).mode = displayMode.sprite
unitDisp = display(4)
unitDisp.clear

discImage = file.loadImage("pics/disc.png")
healthBarBG = file.loadImage("pics/disc-healthbar-bg.png")
healthBarFill = file.loadImage("pics/disc-healthbar-fill.png")

// Add this unit to the display.
Unit.show = function()
	self.base = new Sprite
	self.base.image = composeDisc
	//self.base.scale = 0.5
	unitDisp.sprites.push self.base
	self.base.x = 480   // for now!
	self.base.y = 320
end function

// Remove this unit from the display
Unit.hide = function()
	
end function

// Update this method.  Called frequently while the unit is
// visible on the game board.
Unit.update = function()
	
end function

workBuffer = new PixelDisplay
workBuffer.drawTinted = function(img, tint="#FFFFFF")
	self.drawImage img, 0, 0, img.width, img.height,
	  0, 0, img.width, img.height, tint
end function

composeDisc = function(baseColor="#CCCCFF", healthPercent=50)
	workBuffer.clear color.clear, discImage.width, discImage.height
	workBuffer.drawTinted discImage, baseColor
	workBuffer.drawTinted healthBarBG
	
	t = healthPercent * 0.01
	healthColor = color.lerp(color.red, color.green, t)
	// we need to interpolate over just the portion of the image
	// where the health bar resides -- from 81-114 (in X).
	w = mathUtil.lerp(81, 114, t)
	workBuffer.drawImage healthBarFill, 0, 0, w, healthBarFill.height,
	  0, 0, w, healthBarFill.height, healthColor
	  
	return workBuffer.getImage(0, 0, workBuffer.width, workBuffer.height)
end function

if locals == globals then
	// Test this module.
	u = new Unit
	u.show
	while true
		for health in range(100,0)
			u.base.image = composeDisc("#CCCCFF", health)
			yield
		end for
	end while
end if