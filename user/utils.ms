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