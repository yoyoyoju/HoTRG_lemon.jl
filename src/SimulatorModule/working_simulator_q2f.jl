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
		this.logNorms = zeros(T,3)
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
* which::Int 4 to 6
  - `6` for log(T6) : stored in the logNorms[1]
  - `5` for log(T5) : stored in the logNorms[2]
  - `4` for log(T4) : stored in the logNorms[3]

"""
function getLogNorms(simulator::Quantum2dFractalSimulator, which::Int)
	return simulator.logNorms[7-which]
end

"""
	setLogNorms!{T}(simulator::Quantum2dFractalSimulator{T}, which::Int, lognorm::T)
"""
function setLogNorms!{T}(simulator::Quantum2dFractalSimulator{T}, which::Int, lognorm::T)
	simulator.logNorms[7-which] = lognorm
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
	initializeSim(simulator::Quantum2dFractalSimulator)

# set:

* count = 1
* NumberOfSites = 1
* logNorms = {0,0,0}
"""
function initializeSim{T}(simulator::Quantum2dFractalSimulator{T})
	initializeCount!(simulator) # set to be zero
	countUp!(simulator)
	setNumberOfSites!(simulator,one(T))
	for which = 4:6
		setLogNorms!(simulator, which, zero(T))
	end
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
 
 	if getInititeration(simulator) >= 1
 		for i = 1:getInititeration(simulator)
 			countUp!(simulator, "trotter")
#			renormalizeTrotter!(simulator, getDimM(simulator))
# 			updateCoefficients!(simulator, "trotter")
# 			printLog(simulator, printlog=printlog)
 		end
 	end
# 
# 	while true
# 		countUp!(simulator)
# 		renormalizeSpace!(simulator, getDimM(simulator))
#  		updateCoefficients!(simulator)
# 		printLog(simulator, printlog=printlog)
#  
#  		countUp!(simulator, "trotter")
#  		renormalizeTrotter!(simulator, getDimM(simulator))
#  		updateCoefficients!(simulator,"trotter")
# 		printLog(simulator, printlog=printlog)
#  		if getCount(simulator) > getWholeiteration(simulator)
#  			break
#  		end
# 	end
# 	freeenergy = getFreeEnergy(simulator) ###### count the trotter into
# 	magnetization = getExpectationValue(simulator)
# 	return freeenergy, magnetization
	return 0.1, 0.2
end

#---
# functions for simulate

# functions about free energy
function getFreeEnergy{T}(simulator::Quantum2dFractalSimulator{T})
	numberofsites = sum(getCoefficient(simulator,0,1)[1:4])


	tensorT = getTensorT(simulator)[1]
	termcorrection = log(traceTensorTPeriodic(tensorT))

	freeenergy = - getFirstTerm(simulator) * (
											termFromNormFactor(simulator) +	
										    termcorrection
										   ) / numberofsites
# 	println(getFirstTerm(simulator))
# 	println(termFromNormFactor(simulator))
# 	println(termcorrection)
# 	println(numberofsites)
	return freeenergy
end

function termFromNormFactor{T}(simulator::Quantum2dFractalSimulator{T})
	termNorm = zero(T)
	for i in 1:getCount(simulator)
		for j in 1:getLengthOfNormList(simulator)
			termNorm += getCoefficient(simulator, j, i) * log(getNorm(simulator, j, i))
		end
	end
	return termNorm
end

# coefficients

function initializeCoefficients!{T}(simulator::Quantum2dFractalSimulator{T})
	wholeiteration = getWholeiteration(simulator) 
	setCoefficient!(simulator, 1.0, getIndexOf(simulator, "t"), wholeiteration + 1)
end

function updateCoefficients!{T}(simulator::Quantum2dFractalSimulator{T})
	iteration = getWholeiteration(simulator) +2 -getCount(simulator)
	# depends on the order of the storing of the coefficients! 
	currentCoef = getCoefficient(simulator, 0, iteration+1)[1:4]
	evolveMatrix = # this is 16 x 4 matrix
	#	t	px	py	q
	[	4	4	4	4; #t
  		4	2	4	2; #px
		4	4	2	2; #py
		0	4	0	4; #q
		2	2	2	2; #c
		2	1	2	1; #ly
		0	1	0	1; #ey
		2	1	2	1; #lc
		0	0	0	0; #cl
		0	1	0	1; #ec
		1	0	1	0; #lccl
		0	1	0	1; #eccl
		2	2	1	1; #lx
		0	0	1	1; #ex
		1	0	1	0; #lccll
		0	1	0	1] #eccll
	nextCoef = evolveMatrix * currentCoef
	setCoefficients!(simulator, nextCoef, iteration)
end

# move them to 'simulator_fractal.jl' when it works
function setCoefficients!{T}(simulator::Quantum2dFractalSimulator{T}, nextCoef::Array{T,1}, iteration::Int; lengthNextCoef::Int = getLengthOfNormList(simulator))
	length(nextCoef) == lengthNextCoef || error("input length does not match")
	for i in 1:lengthNextCoef 
		setCoefficient!(simulator, nextCoef[i], i, iteration)
	end
end

##### input: simulator
#=
from the input get
iteration: the current step
currentCoef: the current coefficients in vector (1-dim array) form
	(but what we need is only the four values,,, so, actually
	it does not work directly from the getCoef function. Either
		-del- change the getCoef function
		-change the results by limiting 
		WE DO DEAL WITH THE RESULTS (but still check the func getCoef)
-
store a 2-dim array to get the way to evolve the coefficients
-
output a one-dim array with more values than the currentCoef
	-del- Do not, yet, set the values to the simulator?
Or, yes, do store the new values to the simulator?
WE DO SET THE VALUES TO THE SIMULATOR
=# 

function updateCoefficients!{T}(simulator::Quantum2dFractalSimulator{T}, trotter::AbstractString)
	if trotter == "trotter"
		iteration = getWholeiteration(simulator) +2 -getCount(simulator)
		currentCoef = getCoefficient(simulator, 0, iteration+1)[1:4]
		newCoef = currentCoef .* 2.0
		setCoefficients!(simulator, newCoef, iteration, lengthNextCoef = 4)
	end
end

# normalization

"""
	normalizeTensor!{T}(simulator::Quantum2dFractalSimulator{T})
normalize T,Px,Py,Q tensors  
set the normed tensors back to the lattice in simulator
return a vector with [log(normT), log(normP), log(normQ)]
"""
function normalizeTensor!{T}(simulator::Quantum2dFractalSimulator{T})
	tensorT, tensorTtilde = getTensorT(simulator)
	newTensorT, normT = normalizeTensor(tensorT)
	newTensorTtilde = tensorTtilde ./ normT
	setTensorT!(simulator, newTensorT)
	setTensorT!(simulator, newTensorTtilde; tilde = true)

	newTensorPx, normP = normalizeTensor(getTensorP(simulator, 1))
	setTensorP!(simulator, 1, newTensorPx)
	newTensorPy = getTensorP(simulator,2) ./ normP
	setTensorP!(simulator, 2, newTensorPy)

	newTensorQ, normQ = normalizeTensor(getTensorQ(simulator))
	setTensorQ!(simulator, newTensorQ)
	
	return [log(normT), log(normP), log(normQ)]
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
