##### editting for the multiple normalization factor

type Classical2dFractalSimulator{T} <: Classical2dSimulator{T}
	dimM::Int
	wholeiteration::Int
	countiteration::Int
	normalizationFactor::Array{T,2}
	coefficients::Array{T,2}
	lattice::Classical2dFractalLattice{T}

	function Classical2dFractalSimulator{T}(lattice::Classical2dFractalLattice{T}, dimM::Int, wholeiteration::Int)
		this = new{T}()
		this.dimM = dimM
		this.wholeiteration = wholeiteration
		this.lattice = lattice
		this.normalizationFactor = Array{T,2}(wholeiteration+1,4)
		this.coefficients = Array{T,2}(wholeiteration+1,4)
		initializeCount!(this)
		return this
	end
end

Classical2dFractalSimulator{T}(lattice::Classical2dFractalLattice{T}, dimM::Int, wholeiteration::Int) =
Classical2dFractalSimulator{T}(lattice,dimM,wholeiteration)

function (simulator::Classical2dFractalSimulator){T}(temperature::T = getTemperature(simulator), externalfield::T = getExternalfield(simulator))
	setEnvParameters!(simulator, temperature, externalfield)
	initializeCount!(simulator)
	countUp!(simulator)
	normalizeTensor!(simulator)
	initializeCoefficients!(simulator)
	while true
		countUp!(simulator)
		renormalize!(simulator.lattice, getDimM(simulator))
		normalizeTensor!(simulator)
		updateCoefficients!(simulator)


		##### debug
		##### maybe the norm gets too small
		# println(maximum(abs(tenT)))
		# println(sum(isnan(tenT)))
		# norm = getNorm(simulator,3,getCount(simulator))
		# println(norm)
		##### debug/
		if getCount(simulator) > getWholeiteration(simulator)
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


function getFreeEnergy{T}(simulator::Classical2dFractalSimulator{T})
	numberofsites = sum(getCoefficient(simulator, 0, 1))

	tensorT = getTensorT(simulator)[1]
	termcorrection = log(traceTensorTPeriodic(tensorT))

	freeenergy = - getFirstTerm(simulator) * (
											termFromNormFactor(simulator) +	
										    termcorrection
										   ) / numberofsites
	return freeenergy
end

function termFromNormFactor{T}(simulator::Classical2dFractalSimulator{T})
	termNorm = zero(T)
	for i in 1:getCount(simulator)
		for j in 1:4
			termNorm += getCoefficient(simulator, j, i) * log(getNorm(simulator, j, i))
		end
	end
	return termNorm
end


function normalizeTensor!{T}(simulator::Classical2dFractalSimulator{T})
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

function setNorm!{T}(simulator::Classical2dFractalSimulator{T}, norm::T, which::Int)
	iteration = getCount(simulator)
	setNorm!(simulator, norm, which, iteration)
end

function initializeCoefficients!{T}(simulator::Classical2dFractalSimulator{T})
	wholeiteration = getWholeiteration(simulator) 
	setCoefficient!(simulator, 1.0, 1, wholeiteration + 1)
	setCoefficient!(simulator, 0.0, 2, wholeiteration + 1)
	setCoefficient!(simulator, 0.0, 3, wholeiteration + 1)
	setCoefficient!(simulator, 0.0, 4, wholeiteration + 1)
end

function updateCoefficients!{T}(simulator::Classical2dFractalSimulator{T})
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
function testClassical2dFractalSimulator()
	lattice = testClassical2dFractalLattice()
	dimM = 5
	wholeiteration = 15
	simulator = Classical2dFractalSimulator(lattice, dimM, wholeiteration)
	return simulator
end
