#=
function Quantum2dSquareSimulator{T}(lattice::Quantum2dSquareLattice{T}, dimM::Int, wholeiteration::Int)
function (simulator::Quantum2dSquareSimulator)()
=#
type Quantum2dSquareSimulator{T} <: Quantum2dSimulator{T}
	dimM::Int
	wholeiteration::Int
	normalizationFactor::Array{T}
	data4energy::Array{T}
	countiteration::Int
	trottercount::Int
	lattice::Quantum2dSquareLattice{T}


	function Quantum2dSquareSimulator{T}(lattice::Quantum2dSquareLattice{T}, dimM::Int)
		this = new{T}()
		this.dimM = dimM
		this.wholeiteration = getTrotteriteration(lattice) * 3
		this.lattice = lattice
		this.normalizationFactor = Array{T}(this.wholeiteration)
		this.data4energy = Array{T}(this.wholeiteration)
		initializeCount!(this)
		return this
	end
end

Quantum2dSquareSimulator{T}(lattice::Quantum2dSquareLattice{T}, dimM::Int) =
Quantum2dSquareSimulator{T}(lattice,dimM)

#=
<info>
tensorT[l,r,f,b,u,v]

<The steps in simulator>
renormalizex(tensorT1, tensorT2; isTensorT::Int = 1) 
renormalizey and renormalizez uses renormalizeX but with permutedims on input and output tensors

	getTensorU(tensorT, dimM)
	getTensorV is from getTensorU with permutedims
		getTenmatMMd(tensorT)  -> tenmatM
		svd(tenmatM)
		truncate
		Ul, lambdaVector, Uld = svd(matrixMMd)
		trunUl = truncMatrixU(Ul,dimM)
		tensorUl = matU2tenU(trunUl)

	getNewTensorT(tensorT1, tensorT2, tensorU, tensorV)

	setTensorT

	return renoramalizationFactor

=# 

function (simulator::Quantum2dSquareSimulator)()
	initializeCount!(simulator)
	while true
		whichIsTensorT = 1
		countUp!(simulator)
		renormalizeX!(simulator; whichIsTensorT = whichIsTensorT) 
		countUp!(simulator)
		renormalizeY!(simulator; whichIsTensorT = whichIsTensorT) 
		countUp!(simulator,"trotter")
		renormalizeZ!(simulator; whichIsTensorT = whichIsTensorT) 
		whichIsTensorT = 2
		countUp!(simulator)
		renormalizeX!(simulator; whichIsTensorT = whichIsTensorT) 
		countUp!(simulator)
		renormalizeY!(simulator; whichIsTensorT = whichIsTensorT) 
		countUp!(simulator,"trotter")
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
# functions in simulator
#= 
function renormalize(tensorT1, tensorT2, dimM; whichIsTensorT = 1)
return newTensorT, newTensorTtilde, normalizationFactor
	in simulate_2dQ_renormalize.jl file
=# 
function renormalizeZ!{T}(simulator::Quantum2dSquareSimulator{T}; whichIsTensorT::Int = 1)
	# time axis
	tensorT1, tensorT2 = getTensorT(simulator, whichIsTensorT)
	newTensorT, newTensorTtilde, normalizationFactor = renormalize(tensorT1, tensorT2, getDimM(simulator); whichIsTensorT = whichIsTensorT) 

	setTensorT!(simulator.lattice, newTensorT)
	setTensorT!(simulator.lattice, newTensorTtilde; tilde = true)
	setNormalizationfactor!(simulator, normalizationFactor)
end

function renormalizeX!{T}(simulator::Quantum2dSquareSimulator{T}; whichIsTensorT::Int = 1)
	tensorT1, tensorT2 = getTensorT(simulator, whichIsTensorT)
	newTensorT, newTensorTtilde, normalizationFactor = renormalize(permutedims(tensorT1,[3,4,5,6,1,2]), permutedims(tensorT2,[3,4,5,6,1,2]), getDimM(simulator); whichIsTensorT = whichIsTensorT) 

	setTensorT!(simulator.lattice, permutedims(newTensorT,[5,6,1,2,3,4]))
	setTensorT!(simulator.lattice, permutedims(newTensorTtilde,[5,6,1,2,3,4]); tilde = true)
	setNormalizationfactor!(simulator, normalizationFactor)
end

function renormalizeY!{T}(simulator::Quantum2dSquareSimulator{T}; whichIsTensorT::Int = 1)
	tensorT1, tensorT2 = getTensorT(simulator, whichIsTensorT)
	newTensorT, newTensorTtilde, normalizationFactor = renormalize(permutedims(tensorT1,[5,6,1,2,3,4]), permutedims(tensorT2,[5,6,1,2,3,4]), getDimM(simulator); whichIsTensorT = whichIsTensorT) 

	setTensorT!(simulator.lattice, permutedims(newTensorT,[3,4,5,6,1,2]))
	setTensorT!(simulator.lattice, permutedims(newTensorTtilde,[3,4,5,6,1,2]); tilde = true)
	setNormalizationfactor!(simulator, normalizationFactor)
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
