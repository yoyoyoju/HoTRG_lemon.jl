
type Classical2dSquareSimulator{T} <: Classical2dSimulator{T}
	dimM::Int
	wholeiteration::Int
	countiteration::Int
	normalizationFactor::Array{T}
	data4energy::Array{T}
	lattice::Classical2dSquareLattice{T}

	function Classical2dSquareSimulator{T}(lattice::Classical2dSquareLattice{T}, dimM::Int, wholeiteration::Int)
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

Classical2dSquareSimulator{T}(lattice::Classical2dSquareLattice{T}, dimM::Int, wholeiteration::Int) =
Classical2dSquareSimulator{T}(lattice,dimM,wholeiteration)

function (simulator::Classical2dSquareSimulator){T}(temperature::T = getTemperature(simulator), externalfield::T = getExternalfield(simulator))
	setEnvParameters!(simulator, temperature, externalfield)
	initializeCount!(simulator)
	while true
		countUp!(simulator)
		norm = renormalize!(simulator.lattice, getDimM(simulator))
		setNormalizationfactor!(simulator, norm)
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
function testClassical2dSquareSimulator()
	lattice = testClassical2dSquareLattice()
	dimM = 5
	wholeiteration = 10
	simulator = Classical2dSquareSimulator(lattice, dimM, wholeiteration)
	return simulator
end
