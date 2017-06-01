"""
	Quantum2dFractalSimulator

# arguments
* `lattice::Quantum2dFractalLattice`
* `dimM::Int` the maximum dimension for the tensors
"""
type Quantum2dFractalSimulator{T} <: Quantum2dSimulator{T}
	dimM::Int
	wholeiteration::Int
	countiteration::Int
	trottercount::Int
	normalizationFactor::Array{T,2}
	coefficients::Array{T,2}
	lattice::Quantum2dFractalLattice{T}

	function Quantum2dFractalSimulator{T}(lattice::Quantum2dFractalLattice{T}, dimM::Int)
		this = new{T}()
		this.dimM = dimM
		trotteriteration = getTrotteriteration(lattice)
		this.wholeiteration = trotteriteration * 2
		this.lattice = lattice
		this.normalizationFactor = Array{T,2}(this.wholeiteration+1,4)
		this.coefficients = Array{T,2}(this.wholeiteration+1,4)
		initializeCount!(this)
		return this
	end
end

Quantum2dFractalSimulator{T}(lattice::Quantum2dFractalLattice{T}, dimM::Int) = 
Quantum2dFractalSimulator{T}(lattice,dimM)
#= 
countUp(space)
the space update
normalize
#updateCoef
countUp(trotter)
the time update
normalize
#updateCoef("trotter")
=#

function (simulator::Quantum2dFractalSimulator){T}()
	initializeCount!(simulator)
	countUp!(simulator)
	normalizeTensor!(simulator)
	initializeCoefficients!(simulator)
	while true
		countUp!(simulator) # space count
		renormalizeSpace!(simulator.lattice, getDimM(simulator))
		normalizeTensor!(simulator)
		updateCoefficients!(simulator)

		countUp!(simulator, "trotter") # trotter count
		renormalizeTrotter!()
		normalizeTensor!(simulator)
		updateCoefficients!(simulator,"trotter")

		if getCount(simulator) > getWholeiteration(simulator)
			break
		end
	end
	freeenergy = getFreeEnergy(simulator) ###### count the trotter into
	magnetization = getExpectationValue(simulator)
	if isPottsModel(simulator)
		NOS = convert(T,getStates(simulator))
		magnetization = (NOS * magnetization - one(T))/(NOS - one(T))
	end

	return freeenergy, magnetization
end

#--- ##### need to be fixed
# functions about free energy
function getFreeEnergy{T}(simulator::Quantum2dFractalSimulator{T})
	numberofsites = sum(getCoefficient(simulator, 0, 1))

	tensorT = getTensorT(simulator)[1]
	termcorrection = log(traceTensorTPeriodic(tensorT))

	freeenergy = - getFirstTerm(simulator) * (
											termFromNormFactor(simulator) +	
										    termcorrection
										   ) / numberofsites
	return freeenergy
end

function termFromNormFactor{T}(simulator::Quantum2dFractalSimulator{T})
	termNorm = zero(T)
	for i in 1:getCount(simulator)
		for j in 1:4
			termNorm += getCoefficient(simulator, j, i) * log(getNorm(simulator, j, i))
		end
	end
	return termNorm
end
#---

function normalizeTensor!{T}(simulator::Quantum2dFractalSimulator{T})
	tensorT, tensorTtilde = getTensorT(simulator)
	newTensorT, normT = normalizeTensor(tensorT)
	newTensorTtilde = tensorTtilde ./ normT
	setTensorT!(simulator, newTensorT)
	setTensorT!(simulator, newTensorTtilde; tilde = true)

	newTensorPx, normPx = normalizeTensor(getTensorP(simulator, 1))
	setTensorP!(simulator, 1, newTensorPx)
	newTensorPy, normPy = normalizeTensor(getTensorP(simulator, 2))
	setTensorP!(simulator, 2, newTensorPy)

	newTensorQ, normQ = normalizeTensor(getTensorQ(simulator))
	setTensorQ!(simulator, newTensorQ)

	setNorm!(simulator, normT, 1)
	setNorm!(simulator, normPx, 2)
	setNorm!(simulator, normPy, 3)
	setNorm!(simulator, normQ, 4)
end

function setNorm!{T}(simulator::Quantum2dFractalSimulator{T}, norm::T, which::Int)
	iteration = getCount(simulator)
	setNorm!(simulator, norm, which, iteration)
end

#---
# functions about the coefficients

function initializeCoefficients!{T}(simulator::Quantum2dFractalSimulator{T})
	wholeiteration = getWholeiteration(simulator) 
	setCoefficient!(simulator, 1.0, 1, wholeiteration + 1)
	setCoefficient!(simulator, 0.0, 2, wholeiteration + 1)
	setCoefficient!(simulator, 0.0, 3, wholeiteration + 1)
	setCoefficient!(simulator, 0.0, 4, wholeiteration + 1)
end

function updateCoefficients!{T}(simulator::Quantum2dFractalSimulator{T})
	iteration = getWholeiteration(simulator) +2 -getCount(simulator)
	currentCoef = getCoefficient(simulator, 0, iteration+1)
	newCoefT = updateCoefT(currentCoef)
	newCoefPx = updateCoefPx(currentCoef, getLegextension(simulator))
	newCoefPy = updateCoefPy(currentCoef, getLegextension(simulator))
	newCoefQ = updateCoefQ(currentCoef)

	setCoefficient!(simulator, newCoefT, 1, iteration)
	setCoefficient!(simulator, newCoefPx, 2, iteration)
	setCoefficient!(simulator, newCoefPy, 3, iteration)
	setCoefficient!(simulator, newCoefQ, 4, iteration)
end

function updateCoefficients!{T}(simulator::Quantum2dFractalSimulator{T}, trotter::AbstractString)
	if trotter == "trotter"
		iteration = getWholeiteration(simulator) +2 -getCount(simulator)
		currentCoef = getCoefficient(simulator, 0, iteration+1)
		newCoef = currentCoef .* 2.0
		newCoefT = newCoef[1]
		newCoefPx = newCoef[2]
		newCoefPy = newCoef[3]
		newCoefQ = newCoef[4]

		setCoefficient!(simulator, newCoefT, 1, iteration)
		setCoefficient!(simulator, newCoefPx, 2, iteration)
		setCoefficient!(simulator, newCoefPy, 3, iteration)
		setCoefficient!(simulator, newCoefQ, 4, iteration)
	end
end

function updateCoefT{T}(previousCoef::Array{T,1})
	newCoefT = 4.0 * sum(previousCoef)
	return newCoefT
end

function updateCoefPx{T}(previousCoef::Array{T,1}, legExtension::Int)
	newCoefPx = 4.0 * legExtension * previousCoef[1] +
		(4.0 * legExtension - 1.0) * previousCoef[2] +
		(4.0 * legExtension - 1.0) * previousCoef[3] +
		(4.0 * legExtension -2.0) * previousCoef[4]
	return newCoefPx
end

function updateCoefPy{T}(previousCoef::Array{T,1}, legExtension::Int)
	return updateCoefPx(previousCoef, legExtension)
end

function updateCoefQ{T}(previousCoef::Array{T,1})
	newCoefQ = 2.0 * previousCoef[2] +
		2.0 * previousCoef[3] +
		4.0 * previousCoef[4]
	return newCoefQ
end

#---
# test Function
function testQuantum2dFractalSimulator()
	##### change to set the trotter iteration
	lattice = testQuantum2dFractalLattice()
	dimM = 5
	wholeiteration = 15
	simulator = Quantum2dFractalSimulator(lattice, dimM, wholeiteration)
	return simulator
end
