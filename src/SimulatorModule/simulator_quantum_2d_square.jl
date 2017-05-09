#=
function Quantum2dSquareSimulator{T}(lattice::Quantum2dSquareLattice{T}, dimM::Int, wholeiteration::Int)
function (simulator::Quantum2dSquareSimulator)()
=#
type Quantum2dSquareSimulator{T} <: Quantum2dSimulator{T}
	dimM::Int
	wholeiteration::Int
	countiteration::Int
	trottercount::Int
	normalizationFactor::Array{T}
	coefficients::Array{T}
	data4energy::Array{T}
	lattice::Quantum2dSquareLattice{T}


	function Quantum2dSquareSimulator{T}(lattice::Quantum2dSquareLattice{T}, dimM::Int)
		this = new{T}()
		this.dimM = dimM
		this.wholeiteration = getTrotteriteration(lattice) * 3
		this.lattice = lattice
		this.normalizationFactor = Array{T}(this.wholeiteration+1)
		this.coefficients = Array{T}(this.wholeiteration+1)
		this.data4energy = Array{T}(this.wholeiteration+1)
		initializeCount!(this)
		return this
	end
end

Quantum2dSquareSimulator{T}(lattice::Quantum2dSquareLattice{T}, dimM::Int) =
Quantum2dSquareSimulator{T}(lattice,dimM)

#---
# run the simulator

function (simulator::Quantum2dSquareSimulator)()
	initializeCount!(simulator)
	countUp!(simulator)
	normalizeTensor!(simulator)
	initializeCoefficient!(simulator)
	while true
		whichIsTensorT = 1
		countUp!(simulator)
		renormalizeX!(simulator; whichIsTensorT = whichIsTensorT) 
		normalizeTensor!(simulator)
		updateCoefficient!(simulator)
		# println("sq")
		# println(getCount(simulator))
		# println(simulator.normalizationFactor[getCount(simulator)])
		countUp!(simulator)
 		renormalizeY!(simulator; whichIsTensorT = whichIsTensorT) 
		normalizeTensor!(simulator)
		updateCoefficient!(simulator)
		# println(getCount(simulator))
		# println(simulator.normalizationFactor[getCount(simulator)])

 		countUp!(simulator,"trotter")
 		renormalizeZ!(simulator; whichIsTensorT = whichIsTensorT) 
		normalizeTensor!(simulator)
		updateCoefficient!(simulator;trotter=true)
		# println(getCount(simulator))
		# println(simulator.normalizationFactor[getCount(simulator)])
		
		
 		whichIsTensorT = 2
 		countUp!(simulator)
 		renormalizeX!(simulator; whichIsTensorT = whichIsTensorT) 
		normalizeTensor!(simulator)
		updateCoefficient!(simulator)
		countUp!(simulator)
 		renormalizeY!(simulator; whichIsTensorT = whichIsTensorT) 
		normalizeTensor!(simulator)
		updateCoefficient!(simulator)

 		countUp!(simulator,"trotter")
 		renormalizeZ!(simulator; whichIsTensorT = whichIsTensorT) 
		normalizeTensor!(simulator)
		updateCoefficient!(simulator;trotter=true)
 		if isDone(simulator)
 			break
 		end
 	end
 	freeenergy = getFreeEnergy(simulator)
 	magnetization = getExpectationValue(simulator)
# 	if isPottsModel(simulator)
# 		NOS = convert(T,getStates(simulator))
# 		magnetization = (NOS * magnetization - one(T))/(NOS - one(T))
# 	end
# 
 	return freeenergy, magnetization
end


#---
# functions to get the results
function getFreeEnergy{T}(simulator::Quantum2dSquareSimulator{T})
	numberofsites = getCoefficient(simulator, 1)
	tensorT = getTensorT(simulator)[1]
	termcorrection = log(traceTensorTPeriodic(tensorT))

	freeenergy = - getFirstTerm(simulator) * (
											termFromNormFactor(simulator) +	
										    termcorrection
										   ) / numberofsites

	return freeenergy
end
function termFromNormFactor{T}(simulator::Quantum2dSquareSimulator{T})
	termNorm = zero(T)
	for i in 1:getCount(simulator)
		termNorm += getCoefficient(simulator, i) * log(getNormalizationfactors(simulator)[i])
	end
	return termNorm
end

#---
# functions in simulator
#= 
function renormalize(tensorT1, tensorT2, dimM; whichIsTensorT = 1)
return newTensorT, newTensorTtilde, normalizationFactor
	in simulate_2dQ_renormalize.jl file
=# 
function renormalizeZ!{T}(simulator::Quantum2dSquareSimulator{T}; whichIsTensorT::Int = 1)
	# time axis
	tensorT1, tensorT2 = getTensorT(simulator, whichIsTensorT)
	newTensorT, newTensorTtilde = renormalize(tensorT1, tensorT2, getDimM(simulator); whichIsTensorT = whichIsTensorT) 

	setTensorT!(simulator.lattice, newTensorT)
	setTensorT!(simulator.lattice, newTensorTtilde; tilde = true)
end

function renormalizeX!{T}(simulator::Quantum2dSquareSimulator{T}; whichIsTensorT::Int = 1)
	tensorT1, tensorT2 = getTensorT(simulator, whichIsTensorT)
	newTensorT, newTensorTtilde = renormalize(permutedims(tensorT1,[3,4,5,6,1,2]), permutedims(tensorT2,[3,4,5,6,1,2]), getDimM(simulator); whichIsTensorT = whichIsTensorT) 

	setTensorT!(simulator.lattice, permutedims(newTensorT,[5,6,1,2,3,4]))
	setTensorT!(simulator.lattice, permutedims(newTensorTtilde,[5,6,1,2,3,4]); tilde = true)
end

function renormalizeY!{T}(simulator::Quantum2dSquareSimulator{T}; whichIsTensorT::Int = 1)
	tensorT1, tensorT2 = getTensorT(simulator, whichIsTensorT)
	newTensorT, newTensorTtilde = renormalize(permutedims(tensorT1,[5,6,1,2,3,4]), permutedims(tensorT2,[5,6,1,2,3,4]), getDimM(simulator); whichIsTensorT = whichIsTensorT) 

	setTensorT!(simulator.lattice, permutedims(newTensorT,[3,4,5,6,1,2]))
	setTensorT!(simulator.lattice, permutedims(newTensorTtilde,[3,4,5,6,1,2]); tilde = true)
end

#---
# normalize function for the initial tensors
function normalizeTensor!{T}(simulator::Quantum2dSquareSimulator{T})
	tensorT, tensorTtilde = getTensorT(simulator)
	newTensorT, normT = normalizeTensor(tensorT)
	newTensorTtilde = tensorTtilde ./ normT
	setTensorT!(simulator, newTensorT)
	setTensorT!(simulator, newTensorTtilde; tilde = true)

	setNormalizationfactor!(simulator, normT)
	##### maybe have to modify the data4energy part??
	# but let's leave as it is..
	# just use the coefficients and normlaizationfactor
end

#
function initializeCoefficient!{T}(simulator::Quantum2dSquareSimulator{T})
	wholeiteration = getWholeiteration(simulator) 
	setCoefficient!(simulator, 1.0, wholeiteration + 1)
	##### initilaizeCoefficients!(simulator)
	# -> make a function for simulator::Quantum2dSquareLattice
end

function updateCoefficient!{T}(simulator::Quantum2dSquareSimulator{T}; trotter::Bool = false)
	iteration = getWholeiteration(simulator) + 2 - getCount(simulator)
	currentCoef = getCoefficient(simulator, iteration + 1)
	if trotter 
		newCoef = 2.0 * currentCoef
	else 
		newCoef = 2.0 * currentCoef
	end
	setCoefficient!(simulator, newCoef, iteration)
end

function setCoefficient!{T}(simulator::Quantum2dSquareSimulator{T}, coefficient::T, iteration::Int)
	simulator.coefficients[iteration] = coefficient
end

function getCoefficient{T}(simulator::Quantum2dSquareSimulator{T}, iteration::Int)
	return simulator.coefficients[iteration]
end

#---
# test Function
function testQuantum2dSquareSimulator()
	externalfield = 1.0e-13
	temperature = 0.0
	spininfo = SpinInfo("quantum_ising_2",externalfield, temperature)
	trotterparameter = 0.01
	trotteriteration = 2
	trotterinfo = TrotterInfo(trotterparameter, trotteriteration)
	testModel = QuantumIsingModel(spininfo, trotterinfo)
	lattice = buildLattice("quantum_2d_square", testModel)
	dimM = 3
	simulator = Quantum2dSquareSimulator(lattice, dimM)
	simulator()
	return simulator
end
