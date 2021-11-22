// Strategy Game Kit
// Main Program

import "utils"
ensureImport "mapview"
ensureImport "unit"

mapview.generateMap

u = new Unit
u.init
u.figure.image = unit.unitImages.dwarf
u.setPosition 4, 19
u.show true
