if globals.indexOf("qa") == null then import "qa"

// ensureImport: check whether the given module has been imported already
// (or is in the process of being imported).  If so, return immediately.
// If not, then import that module into the global namespace.
globals.ensureImport = function(moduleName)
	if globals.hasIndex(moduleName) then return
	globals[moduleName] = "PENDING"	// (module is being imported now)
	import moduleName
	globals[moduleName] = locals[moduleName]
end function

roll = function(qtyDice=1, sides=6)
	sum = 0
	for i in range(1, qtyDice)
		sum = sum + ceil(rnd * sides)
	end for
	return sum
end function

// Sprite.hitBy: check whether xyMap hits this sprite, 
// optionally checking whether the actual image at 
// the point hit is not transparent.
// Note: works only for non-rotated sprites (for now).
Sprite.hitBy = function(xyMap, pixelLevelCheck=true)
	qa.assert self.rotation == 0
	// First check the bounding box
	if self.localBounds == null then
		self.localBounds = new Bounds
		self.localBounds.width = self.image.width
		self.localBounds.height = self.image.height
	end if
	if not self.worldBounds.contains(xyMap) then return false
	// Then check the pixel hit.
	// We'll consider it a hit if the alpha is more than half opaque.
	x = (xyMap.x - self.x) / self.scale
	y = (xyMap.y - self.y) / self.scale
	c = self.image.pixel(self.image.width/2 + x, self.image.height/2 + y)
	text.row = 25; print c	
	return c[-2:] > "80"
end function


if locals == globals then
	clear
	sp = new Sprite
	sp.image = file.loadImage("pics/dorf2.png")
	sp.scale = 5
	sp.x = 480; sp.y = 320
	display(4).sprites.push sp
	while true
		if sp.hitBy(mouse) then
			sp.tint = color.yellow
		else
			sp.tint = color.white			
		end if
		yield
	end while	
end if