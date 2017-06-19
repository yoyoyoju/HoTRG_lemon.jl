import HoTRG_lemon.LatticeModule:
		isZeroTemperature,
		isClassical,
		getModelname,
		getStates,
		isSymmetricFactorization,
		isPottsModel,
		getHamiltonian,
		getTemperature,
		getExternalfield,
		getEnvParameters,
		getTensorT,
		getFactorW,
		getCoarserate,
		getMeasureOperator,
		setTemperature!,
		setExternalfield!,
		setTensorT!,
		setEnvParameters!

#=
Simulator
getExpectationValue
getFreeEnergy(simulator)
getDimM(simulator)
getWholeiteration(simulator)
setNormalizationfactor!(simulator, normalizationfactor)
getNormalizationfactors(simulator)
=#

abstract Simulator{T}

#---
# build simulator according to the type of the lattice
"""
	buildSimulator

Build Simulator from `Lattice`.

# arguments
* `lattice`: 
  * `Classical2dSquareLattice` with  `dimM`, `wholeiteration`
  * `Classical2dFractalLattice` with `dimM`, `wholeiteration`
  * `Classicl3dSquareLattice` with `dimM`, `wholeiteration`
  * `Quantum2dSquareLattice` with `dimM`
  * `Quantum2dFractalLattice` with `dimM`
* `dimM::Int`: the maximum tensor size
* `wholeiteration::Int`: For `ClassicalLattice`. How many times to  iterate.  
For `QuantumLattice`, it is determined by `trotteriteration`.
"""
function buildSimulator{T}(lattice::Classical2dSquareLattice{T}, dimM::Int, wholeiteration::Int)
	return Classical2dSquareSimulator{T}(lattice, dimM, wholeiteration)
end

function buildSimulator{T}(lattice::Classical2dFractalLattice{T}, dimM::Int, wholeiteration::Int)
	return Classical2dFractalSimulator{T}(lattice, dimM, wholeiteration)
end

function buildSimulator{T}(lattice::Classical3dSquareLattice{T}, dimM::Int, wholeiteration::Int)
	return Classical3dSquareSimulator{T}(lattice, dimM, wholeiteration)
end

function buildSimulator{T}(lattice::Quantum2dSquareLattice{T}, dimM::Int)
	return Quantum2dSquareSimulator{T}(lattice, dimM)
end

function buildSimulator{T}(lattice::Quantum2dFractalLattice{T}, dimM::Int)
	return Quantum2dFractalSimulator{T}(lattice, dimM, 0)
end

function buildSimulator{T}(lattice::Quantum2dFractalLattice{T}, dimM::Int, inititeration::Int)
	return Quantum2dFractalSimulator{T}(lattice, dimM, inititeration)
end
#---
# functions for the expectation values
function getExpectationValue(simulator::Simulator)
	tensorT, impurityTensorTtilde = getTensorT(simulator)
	expectationvalue = traceTensorTPeriodic(impurityTensorTtilde) / traceTensorTPeriodic(tensorT)
	# println("traceT is \t", traceTensorTPeriodic(impurityTensorTtilde))
	# println("tractTt is\t",traceTensorTPeriodic(tensorT))
	# println("exp value\t", expectationvalue)
	return expectationvalue
end

##### ------- under this to be modified
#---
# functions inside of simulator

function getFreeEnergy(simulator::Simulator)
	
	freeenergy = - getFirstTerm(simulator) *(
										  termFromNormFactor(simulator) +
					 termCorrection(simulator)
					)
	return freeenergy
end

function termCorrection(simulator::Simulator)
	tensorT = getTensorT(simulator)[1]
	termcorrection = log(traceTensorTPeriodic(tensorT))/getNumberOfSites(simulator)
	return termcorrection
end

function termFromNormFactor(simulator::Simulator)
	termNorm = 0.0
	data4energy = getData4Energy(simulator)
	for i in 1:getCount(simulator)
		termNorm += data4energy[i]
	end
	return termNorm
end

#---
# functions for simulator
function getDimM(simulator::Simulator)
	return simulator.dimM
end

function getWholeiteration(simulator::Simulator)
	return simulator.wholeiteration
end

function getNormalizationfactors(simulator::Simulator)
	return simulator.normalizationFactor
end

function getData4Energy(simulator::Simulator)
	return simulator.data4energy
end

function getCount(simulator::Simulator)
	return simulator.countiteration
end

function getNumberOfSites(simulator::Simulator)
	a = getCoarserate(simulator)
	b = 2
	n = getSpaceCount(simulator)
	l = getTrotterCount(simulator)
	return exp(n*log(a) + l*log(b))
end

function countUp!(simulator::Simulator)
	simulator.countiteration = simulator.countiteration + 1
end

function countDown!(simulator::Simulator)
	simulator.countiteration = simulator.countiteration - 1
end

function isDone(simulator::Simulator)
	if getCount(simulator) >= getWholeiteration(simulator)
		return true
	else
		return false
	end
end

function setNormalizationfactor!{T}(simulator::Simulator{T}, normalizationfactor::T)
	iteration = getCount(simulator)
	simulator.normalizationFactor[iteration] = normalizationfactor
	dummy = log(normalizationfactor)/getNumberOfSites(simulator)
	simulator.data4energy[iteration] = dummy
end

#---
# functions for local tensors

function normalizeTensor(tensorT::Array; smallnumber = 1.0e-12)
	normalizationfactor = maximum(abs(tensorT))
	normalizationfactor = normalizationfactor <= smallnumber ? 1.0 : normalizationfactor
	normalizedTensorT = tensorT ./ normalizationfactor
	return normalizedTensorT, normalizationfactor
end

function traceTensorTPeriodic{T}(tensorT::Array{T,4})
	# trace tensorT(x,xp,y,yp) with periodic boundary condition
	xDimension = size(tensorT,1) == size(tensorT,2) ? size(tensorT,1) : error("size does not match")
	size(tensorT,3) == size(tensorT,4) ? yDimension = size(tensorT,3) : error("size does not match")
	tracetensor = 0.0
	for i = 1:xDimension, j = 1:yDimension
		tracetensor += tensorT[i,i,j,j]
	end
	return tracetensor
end

function traceTensorTPeriodic{T}(tensorT::Array{T,6})
	# trace tensorT(x,xp,y,yp,z,zp) with periodic boundary condition
	xDimension = size(tensorT,1) == size(tensorT,2) ? size(tensorT,1) : error("size does not match")
	size(tensorT,3) == size(tensorT,4) ? yDimension = size(tensorT,3) : error("size does not match")
	size(tensorT,5) == size(tensorT,6) ? zDimension = size(tensorT,5) : error("size does not match")
	tracetensor = 0.0
	for i = 1:xDimension, j = 1:yDimension, k = 1:zDimension
		tracetensor += tensorT[i,i,j,j,k,k]
	end
	return tracetensor
end

function rotateTensorT90{T}(tensorT::Array{T,4})
	# rotate 90 degrees tensorT to the clockwise 
	# tenT[x,xp,y,yp] -> tenT[yp,y,x,xp]
	rotatedTensorT = permutedims(tensorT,[4,3,1,2])
	return rotatedTensorT
end



#---
# functions inheritted from lattice type
single_args_non_preserving = [
							:isZeroTemperature,
							:isClassical,
							:getModelname,
							:getStates,
							:getCoarserate,
							:isSymmetricFactorization,
							:isPottsModel,
							:getHamiltonian,
							:getTemperature,
							:getExternalfield,
							:getEnvParameters,
							:getTensorT,
							:getFactorW,
							:getMeasureOperator
							]

for f in single_args_non_preserving
	eval(quote

	  function $(f)(simulator::Simulator)
	  return $(f)(simulator.lattice)
		end

	end)
end

function getTensorT(simulator::Simulator, whichIsTensorT::Int)
	return getTensorT(simulator.lattice, whichIsTensorT)
end

set_functions = [
				:setTemperature!,
				:setExternalfield!
				]

for f in set_functions
	eval(quote

	  function $(f){T}(simulator::Simulator{T}, parameter::T)
		  $(f)(simulator.lattice, parameter)
		end

	end)
end

function setEnvParameters!{T}(simulator::Simulator{T}, temp::T, exf::T)
	setEnvParameters!(simulator.lattice, temp, exf)
end

function setTensorT!(simulator::Simulator, tensorT::Array; tilde = false)
	setTensorT!(simulator.lattice, tensorT; tilde = tilde)
end

function writeVector{T}(vector::Array{T,1}, filename::AbstractString = "data.txt")
	open(filename, "w") do f
		for i = 1:size(vector,1)
			write(f, "$(vector[i]) \n")
		end
	end
end
