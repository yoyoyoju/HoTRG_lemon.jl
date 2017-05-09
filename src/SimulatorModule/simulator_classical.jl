abstract ClassicalSimulator{T} <: Simulator{T}
abstract Classical2dSimulator{T} <: ClassicalSimulator{T}
abstract Classical3dSimulator{T} <: ClassicalSimulator{T}

function initializeCount!(simulator::ClassicalSimulator)
	simulator.countiteration = 0
end

function getSpaceCount(simulator::ClassicalSimulator)
	return getCount(simulator)
end

function getTrotterCount(simulator::ClassicalSimulator)
	return 0
end

function getFirstTerm(simulator::ClassicalSimulator)
	return getTemperature(simulator)
end
