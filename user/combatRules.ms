// Combat Rules.
//
// Put here all the logic for controlling combat.

import "utils"
roll = @utils.roll

// Return how many hit points of damage should be applied
// to defender (Unit) due to attack from attacker (Unit).
calcDamage = function(attacker, defender)
	attack = attacker.type.attack
	defense = defender.type.defense
	
	//print "attack: " + attack + "   defense: " + defense
	if defense >= attack then return 0
	
	result = roll(1, attack-defense)
	//print "damage: " + result
	return result
	
end function