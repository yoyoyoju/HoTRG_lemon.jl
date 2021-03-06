# simulator_quantum_2d_fractal.jl

"""
	Quantum2dFractalSimulator

# arguments

* `lattice::Quantum2dFractalLattice`
* `dimM::Int` the maximum dimension for the tensors
* `inititeration::Int` initial iteration (default=0)

# to do:
1. bug fixing - DONE
2. merge inititer to this

"""
type Quantum2dFractalSimulator{T} <: Quantum2dSimulator{T}
	dimM::Int
	wholeiteration::Int
	inititeration::Int
	countiteration::Int
	trottercount::Int
	normalizationFactor::Array{T,2}
	coefficients::Array{T,2}
	lattice::Quantum2dFractalLattice{T}
	infoCoefficients::Array{AbstractString,1}

	function Quantum2dFractalSimulator{T}(lattice::Quantum2dFractalLattice{T}, dimM::Int, inititeration::Int)
		this = new{T}()
		this.dimM = dimM
		this.inititeration = inititeration
		wholeiteration = getTrotteriteration(lattice) * 2 + inititeration
		this.wholeiteration = wholeiteration
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

Quantum2dFractalSimulator{T}(lattice::Quantum2dFractalLattice{T}, dimM::Int, inititeration::Int) = 
Quantum2dFractalSimulator{T}(lattice,dimM,inititeration)
Quantum2dFractalSimulator{T}(lattice::Quantum2dFractalLattice{T}, dimM::Int) = 
Quantum2dFractalSimulator{T}(lattice,dimM, 0)


#--- refactor
function getLengthOfNormList(simulator::Quantum2dFractalSimulator)
	return length(simulator.infoCoefficients)
end

function getListOfNormFactors(simulator::Quantum2dFractalSimulator)
	return simulator.infoCoefficients
end

function getIndexOf(simulator::Quantum2dFractalSimulator, normname::AbstractString)
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


#---
# run the simulator



function (simulator::Quantum2dFractalSimulator)(;printlog="none")
	initializeCount!(simulator) # set to be zero
	initializeCoefficients!(simulator)
	countUp!(simulator)
	normalizeTensor!(simulator) 
	
	if printlog in ["coef", "norm"]
		printLog(simulator, printlog="label")
		printLog(simulator, printlog=printlog)
	end

	if getInititeration(simulator) >= 1
		for i = 1:getInititeration(simulator)
			countUp!(simulator, "trotter")
			renormalizeTrotter!(simulator, getDimM(simulator))
			updateCoefficients!(simulator, "trotter")
			printLog(simulator, printlog=printlog)
		end
	end

	while true
		countUp!(simulator)
		renormalizeSpace!(simulator, getDimM(simulator))
 		updateCoefficients!(simulator)
		printLog(simulator, printlog=printlog)
 
 		countUp!(simulator, "trotter")
 		renormalizeTrotter!(simulator, getDimM(simulator))
 		updateCoefficients!(simulator,"trotter")
		printLog(simulator, printlog=printlog)
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
set the Norm to normalizationFactor  
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

	setNorm!(simulator, normT, getIndexOf(simulator, "t"))
	setNorm!(simulator, normPx, getIndexOf(simulator, "px"))
	setNorm!(simulator, normPy, getIndexOf(simulator, "py"))
	setNorm!(simulator, normQ, getIndexOf(simulator, "q"))
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
