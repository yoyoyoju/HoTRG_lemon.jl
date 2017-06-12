# simulator_quantum_2d_fractal_inititer.jl

"""
	Quantum2dFractalInititerSimulator
simulator for 2d quantum spins on fractal lattice with initial iteration.  

`inititeration::Int` is added to the `Quantum2dFractalSimulator`.  

# Internal Note:

* change in:
  * wholeiteration
    * -> the length in the coefficients and normalizationFactor

# Test whether it works:

* build the Simulator
get things from testQuantumInit or something...
```julia
ising = HoTRG_lemon.SpinModule.Spin
```

"""
type Quantum2dFractalInititerSimulator{T} <: Quantum2dSimulator{T}
	dimM::Int
	wholeiteration::Int
	countiteration::Int
	inititeration::Int
	trottercount::Int
	normalizationFactor::Array{T,2}
	coefficients::Array{T,2}
	lattice::Quantum2dFractalLattice{T}
	infoCoefficients::Array{AbstractString,1}

	function Quantum2dFractalInititerSimulator{T}(lattice::Quantum2dFractalLattice{T}, dimM::Int, inititeration::Int)
		this = new{T}()
		this.dimM = dimM
		wholeiteration = getTrotteriteration(lattice) * 2 + inititeration
		this.wholeiteration = wholeiteration
		this.inititeration = inititeration
		this.lattice = lattice
		this.infoCoefficients = ["t", "px", "py", "q",
					  "c", "ly", "ey",
					  "lc", "cl", "ec", 
					  "lccl", "eccl",
					  "lx", "ex",
					  "lccll", "eccll"]
		numberOfCoefficients = getLengthOfNormList(this)
		this.normalizationFactor = ones(T,wholeiteration+1,numberOfCoefficients)
		this.coefficients = zeros(T,wholeiteration+1,numberOfCoefficients)
		initializeCoefficients!(this)
		initializeCount!(this)
		return this
	end
end

Quantum2dFractalInititerSimulator{T}(lattice::Quantum2dFractalLattice{T}, dimM::Int, inititeration::Int) = 
Quantum2dFractalInititerSimulator{T}(lattice,dimM, inititeration)

#--- refactor make it more general ( for all the simulators )
function getLengthOfNormList(simulator::Quantum2dFractalInititerSimulator)
	return length(simulator.infoCoefficients)
end

function getListOfNormFactors(simulator::Quantum2dFractalInititerSimulator)
	return simulator.infoCoefficients
end

function getInititeration(simulator::Quantum2dFractalInititerSimulator)
	return simulator.inititeration
end
#---

function getIndexOf(simulator::Quantum2dFractalInititerSimulator, normname::AbstractString)
	listOfNormFactors = getListOfNormFactors(simulator)
	indexof = 0
	for (i,a) in enumerate(listOfNormFactors)
		if a == normname
			indexof = i
		end
	end
	indexof == 0 && error("input for getIndexOf is wrong")
	return indexof
end

function printCoefficients(simulator::Quantum2dFractalInititerSimulator)
	iteration = getWholeiteration(simulator) +2 -getCount(simulator)
	println(simulator.coefficients[iteration,:])
end
function printNormalizationFactor(simulator::Quantum2dFractalInititerSimulator)
	iteration = getCount(simulator)
	println(simulator.normalizationFactor[iteration,:])
end

#---
# run the simulator

##### the dimension values to store the norms and coefs:
##### figure out better way to point them in:
##### normalizeTensor!
##### initializeCoefficients!

"""
simulate the Simulator.   
"""
function (simulator::Quantum2dFractalInititerSimulator)()
	initializeCount!(simulator) # set to be zero
	initializeCoefficients!(simulator)
	countUp!(simulator)
	normalizeTensor!(simulator) 
	for i = 1:getInititeration(simulator)
		countUp!(simulator)
		renormalizeSpace!(simulator, getDimM(simulator))
 		updateCoefficients!(simulator)
	end
	while true
		countUp!(simulator)
		renormalizeSpace!(simulator, getDimM(simulator))
 		updateCoefficients!(simulator)
 
 		countUp!(simulator, "trotter")
 		renormalizeTrotter!(simulator, getDimM(simulator))
 		normalizeTensor!(simulator)
 		updateCoefficients!(simulator,"trotter")
 		if getCount(simulator) > getWholeiteration(simulator)
 			break
 		end
	end
	freeenergy = getFreeEnergy(simulator) ###### count the trotter into
	magnetization = getExpectationValue(simulator)
	return freeenergy, magnetization
end

#---
# functions for simulate

#--- ##### need to be fixed
# functions about free energy
function getFreeEnergy{T}(simulator::Quantum2dFractalInititerSimulator{T})
	# numberofsites = sum(getCoefficient(simulator, 0, 1))
	numberofsites = sum(getCoefficient(simulator,0,1)[1:4])


	tensorT = getTensorT(simulator)[1]
	termcorrection = log(traceTensorTPeriodic(tensorT))

	freeenergy = - getFirstTerm(simulator) * (
											termFromNormFactor(simulator) +	
										    termcorrection
										   ) / numberofsites
	return freeenergy
end

function termFromNormFactor{T}(simulator::Quantum2dFractalInititerSimulator{T})
	termNorm = zero(T)
	for i in 1:getCount(simulator)
		for j in 1:getLengthOfNormList(simulator)
			termNorm += getCoefficient(simulator, j, i) * log(getNorm(simulator, j, i))
		end
	end
	return termNorm
end

# coefficients

function initializeCoefficients!{T}(simulator::Quantum2dFractalInititerSimulator{T})
	wholeiteration = getWholeiteration(simulator) 
	setCoefficient!(simulator, 1.0, getIndexOf(simulator, "t"), wholeiteration + 1)
end

function updateCoefficients!{T}(simulator::Quantum2dFractalInititerSimulator{T})
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
function setCoefficients!{T}(simulator::Quantum2dFractalInititerSimulator{T}, nextCoef::Array{T,1}, iteration::Int; lengthNextCoef::Int = getLengthOfNormList(simulator))
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

function updateCoefficients!{T}(simulator::Quantum2dFractalInititerSimulator{T}, trotter::AbstractString)
	if trotter == "trotter"
		iteration = getWholeiteration(simulator) +2 -getCount(simulator)
		currentCoef = getCoefficient(simulator, 0, iteration+1)[1:4]
		newCoef = currentCoef .* 2.0
		setCoefficients!(simulator, newCoef, iteration, lengthNextCoef = 4)
	end
end

# normalization
function normalizeTensor!{T}(simulator::Quantum2dFractalInititerSimulator{T})
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

	setNorm!(simulator, normT, getIndexOf(simulator, "t"))
	setNorm!(simulator, normPx, getIndexOf(simulator, "px"))
	setNorm!(simulator, normPy, getIndexOf(simulator, "py"))
	setNorm!(simulator, normQ, getIndexOf(simulator, "q"))
end

function setNorm!{T}(simulator::Quantum2dFractalInititerSimulator{T}, norm::T, which::Int)
	iteration = getCount(simulator)
	setNorm!(simulator, norm, which, iteration)
end

#---
# functions for initialize


#---
# test function

function testQuantum2dFractalInititerSimulator()
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
	simulator = Quantum2dFractalInititerSimulator(lattice, dimM)
	return simulator
end
