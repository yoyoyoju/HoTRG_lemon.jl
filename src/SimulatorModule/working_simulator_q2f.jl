# simulator_quantum_2d_fractal.jl

"""
	Quantum2dFractalSimulator

# arguments

* `lattice::Quantum2dFractalLattice`
* `dimM::Int` the maximum dimension for the tensors
* `inititeration::Int` initial iteration (default=0)


# to do:

1. fix the way to store norms


# note:

* `logNorms::Array{T,1}` - store logarithm of normalization factors
* `numberOfSites::T` - store number of sites

"""
type Quantum2dFractalSimulator{T} <: Quantum2dSimulator{T}
	dimM::Int
	wholeiteration::Int
	inititeration::Int
	countiteration::Int
	trottercount::Int
	lattice::Quantum2dFractalLattice{T}
	logNorms::Array{T,1}
	numberOfSites::T

	function Quantum2dFractalSimulator{T}(lattice::Quantum2dFractalLattice{T}, dimM::Int, inititeration::Int)
		this = new{T}()
		this.dimM = dimM
		this.inititeration = inititeration
		wholeiteration = getTrotteriteration(lattice) * 2 + inititeration
		this.wholeiteration = wholeiteration
		this.lattice = lattice
		initializeCount!(this)
		this.logNorms = zeros(T,4)
		this.numberOfSites = one(T)
		return this
	end
end

Quantum2dFractalSimulator{T}(lattice::Quantum2dFractalLattice{T}, dimM::Int, inititeration::Int) = 
Quantum2dFractalSimulator{T}(lattice,dimM,inititeration)
Quantum2dFractalSimulator{T}(lattice::Quantum2dFractalLattice{T}, dimM::Int) = 
Quantum2dFractalSimulator{T}(lattice,dimM, 0)


#---
# methods
function getLogNorms(simulator::Quantum2dFractalSimulator)
	return simulator.logNorms
end

"""
	getLogNorms
return stored log(Norm) value

# arguments:

* simulator
* which::String 4, 5x, 5y, 6 (optional, without will return the Array{T,1})
  - `6` for log(T6) : stored in the logNorms[1]
  - `5x` for log(T5x) : stored in the logNorms[2]
  - `5y` for log(T5y) : stored in the logNorms[3]
  - `4` for log(T4) : stored in the logNorms[4]

"""
function getLogNorms(simulator::Quantum2dFractalSimulator, which::AbstractString)
	indexNumber = getIndexWhich(which)
	return simulator.logNorms[indexNumber]
end

function getIndexWhich(which::AbstractString)
	if which == "6"
		indexNumber = 1
	elseif which == "5x"
		indexNumber = 2
	elseif which == "5y"
		indexNumber = 3
	elseif which == "4"
		indexNumber = 4
	end
	return indexNumber
end

"""
	setLogNorms!{T}(simulator::Quantum2dFractalSimulator{T}, which::String, lognorm::T)
"""
function setLogNorms!{T}(simulator::Quantum2dFractalSimulator{T}, which::AbstractString, lognorm::T)
	indexNumber = getIndexWhich(which)
	simulator.logNorms[indexNumber] = lognorm
end

function setLogNorms!{T}(simulator::Quantum2dFractalSimulator{T}, lognorms::Array{T,1})
	simulator.logNorms = lognorms
end

"""
	getNumberOfSites(simulator::Quantum2dFractalSimulator{T})
"""
function getNumberOfSites{T}(simulator::Quantum2dFractalSimulator{T})
	return simulator.numberOfSites
end

"""
	setNumberOfSites!(simulator::Quantum2dFractalSimulator, NOS)
"""
function setNumberOfSites!{T}(simulator::Quantum2dFractalSimulator{T}, NOS::T)
	simulator.numberOfSites = NOS
end

"""
	updateNumberOfSites!{T}(simulator::Quantum2dFractalSimulator{T}, which::AbstractString)

# argurments:

* simulator
* which::String - "space" or "trotter"  
  - 'space' multiply by 12 times
  - 'trotter' multiply by 2 times
"""
function updateNumberOfSites!{T}(simulator::Quantum2dFractalSimulator{T}, which::AbstractString)
	if which == "space"
		coef = 12
	elseif which == "trotter"
		coef = 2
	end
	setNumberOfSites!(simulator, coef * getNumberOfSites(simulator))
end

"""
	initializeSim(simulator::Quantum2dFractalSimulator)

# set:

* count = 1
* NumberOfSites = 1
* logNorms = {0,0,0,0}
"""
function initializeSim{T}(simulator::Quantum2dFractalSimulator{T})
	initializeCount!(simulator) # set to be zero
	countUp!(simulator)
	setNumberOfSites!(simulator,one(T))
	setLogNorms!(simulator, zeros(T,4))
end

#---
# run the simulator

function (simulator::Quantum2dFractalSimulator)(;printlog="none")
	initializeSim(simulator)

	setLogNorms!(simulator, normalizeTensor!(simulator))

	### printLog should be fixed
# 	if printlog in ["coef", "norm"]
# 		printLog(simulator, printlog="label")
# 		printLog(simulator, printlog=printlog)
# 	end
 		printLog(simulator, printlog=printlog)
 
 	if getInititeration(simulator) >= 1
 		for i = 1:getInititeration(simulator)
 			countUp!(simulator, "trotter")
			renormalizeTrotter!(simulator, getDimM(simulator))
 			printLog(simulator, printlog=printlog)
			normalizeUpdateLogNorms!(simulator, "trotter")
 			printLog(simulator, printlog=printlog)
			### gotta update "length" (numberOfSites)
 		end
 	end
 
 	while true
 		countUp!(simulator)
 		renormalizeSpace!(simulator, getDimM(simulator))
 		printLog(simulator, printlog=printlog)
		normalizeUpdateLogNorms!(simulator, "space")
 		printLog(simulator, printlog=printlog)
  
  		countUp!(simulator, "trotter")
  		renormalizeTrotter!(simulator, getDimM(simulator))
 		printLog(simulator, printlog=printlog)
		normalizeUpdateLogNorms!(simulator, "trotter")
 		printLog(simulator, printlog=printlog)
  		if getCount(simulator) > getWholeiteration(simulator)
  			break
  		end
 	end
 	freeenergy = getFreeEnergy(simulator)
 	magnetization = getExpectationValue(simulator)
 	return freeenergy, magnetization
end

#---
# functions for simulate

# functions about free energy
function getFreeEnergy{T}(simulator::Quantum2dFractalSimulator{T})
	freeenergy = getLogNorms(simulator, "6") / getTrotterparameter(simulator)

	return freeenergy
end

# normalization

"""
	normalizeTensor!{T}(simulator::Quantum2dFractalSimulator{T})

# fucntion:

* normalize T,Px,Py,Q tensors  
* set the normed tensors back to the lattice in simulator
* return a vector with [log(normT), log(normPx), log(normPy), log(normQ)]  
  in other notation: [logt6 logt5x logt5y logt4]
"""
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
	
	return [log(normT), log(normPx), log(normPy), log(normQ)]
end


"""
	normalizeUpdateLogNorms!{T}(simulator::Quantum2dFractalSimulator{T}, which::AbstractString)

# function:

* update number of sites according to 'which'
* normalize tensors from the input simulator
* set the normalized tensors to the input simulator
* set and return the next logNorms based on the previous logNorms and the normalization factors

# arguments:

* which::AbstractString - either 'space' or 'trotter'  
  calculate the logNorms based on one of the input
"""
function normalizeUpdateLogNorms!{T}(simulator::Quantum2dFractalSimulator{T}, which::AbstractString)
	updateNumberOfSites!(simulator, which)
	previousLogNorms = getLogNorms(simulator)
	currentLogt = normalizeTensor!(simulator)
	if which == "space"
		eMatrix = [4 4 4 0; 4 4 2 2; 4 2 4 2 ; 4 2 2 4] ./ 12
	elseif which == "trotter"
		eMatrix = eye(T,4)
	end

	nextLogNorms = eMatrix * previousLogNorms + currentLogt./getNumberOfSites(simulator)
	setLogNorms!(simulator, nextLogNorms)
	return nextLogNorms
end


#---
# functions for initialize


#---
# test function

function testQuantum2dFractalSimulator()
	# parameters:
	externalfield = 0.1
	temperature = 0.0
	trotterparameter = 0.01
	trotteriteration = 30
	dimM = 3
	# build simulator
	spininfo = SpinInfo("quantum_ising_2","asym",externalfield,temperature)
	trotterinfo = TrotterInfo(trotterparameter, trotteriteration)
	spinmodel = QuantumIsingModel(spininfo, trotterinfo)
	lattice = buildLattice("quantum_2d_fractal_1", spinmodel)
	simulator = Quantum2dFractalSimulator(lattice, dimM)
	return simulator
end
