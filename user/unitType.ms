// Unit types.
// Make a subclass of UnitType for every kind of unit in your game.

UnitType = {}
UnitType.image = null
UnitType.maxHP = 5
UnitType.maxAP = 3
UnitType.attack = 5
UnitType.defense = 1

Dwarf = new UnitType
Dwarf.image = file.loadImage("pics/dorf2.png")
Dwarf.defense = 2

Dragon = new UnitType
Dragon.image = file.loadImage("pics/dragon.png")
Dragon.maxHP = 20
Dragon.maxAP = 2
Dragon.attack = 10