
type Classical3dSquareSimulator{T} <: Classical3dSimulator{T}
	dimM::Int
	wholeiteration::Int
	countiteration::Int
	normalizationFactor::Array{T}
	data4energy::Array{T}
	lattice::Classical3dSquareLattice{T}

	function Classical3dSquareSimulator{T}(lattice::Classical3dSquareLattice{T}, dimM::Int, wholeiteration::Int)
		this = new{T}()
		this.dimM = dimM
		this.wholeiteration = wholeiteration
		this.lattice = lattice
		this.normalizationFactor = Array{T}(wholeiteration)
		this.data4energy = Array{T}(wholeiteration)
		initializeCount!(this)
		return this
	end
end

Classical3dSquareSimulator{T}(lattice::Classical3dSquareLattice{T}, dimM::Int, wholeiteration::Int) =
Classical3dSquareSimulator{T}(lattice,dimM,wholeiteration)

#####
function (simulator::Classical3dSquareSimulator){T}(temperature::T = getTemperature(simulator), externalfield::T = getExternalfield(simulator))
	setEnvParameters!(simulator, temperature, externalfield)
	initializeCount!(simulator)
	while true
		whichIsTensorT = 1
		countUp!(simulator)
		renormalizeX!(simulator; whichIsTensorT = whichIsTensorT) 
		countUp!(simulator)
		renormalizeY!(simulator; whichIsTensorT = whichIsTensorT) 
		countUp!(simulator)
		renormalizeZ!(simulator; whichIsTensorT = whichIsTensorT) 
		whichIsTensorT = 2
		countUp!(simulator)
		renormalizeX!(simulator; whichIsTensorT = whichIsTensorT) 
		countUp!(simulator)
		renormalizeY!(simulator; whichIsTensorT = whichIsTensorT) 
		countUp!(simulator)
		renormalizeZ!(simulator; whichIsTensorT = whichIsTensorT) 
		if isDone(simulator)
			break
		end
	end
	freeenergy = getFreeEnergy(simulator)
	magnetization = getExpectationValue(simulator)
	if isPottsModel(simulator)
		NOS = convert(T,getStates(simulator))
		magnetization = (NOS * magnetization - one(T))/(NOS - one(T))
	end

	return freeenergy, magnetization
end


#---
# test Function
function testClassical3dSquareSimulator()
	lattice = testClassical3dSquareLattice()
	dimM = 5
	wholeiteration = 12
	simulator = Classical3dSquareSimulator(lattice, dimM, wholeiteration)
	return simulator
end
