import HoTRG_lemon.SpinModule:
		initialize!,
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
		getMeasureOperator,
		getFactorW,
		getFactorWp,
		setTemperature!,
		setExternalfield!,
		setEnvParameters!

abstract Lattice{T}

#---
# buildFunction
function buildLattice(latticeinfo::LatticeInfo, spinmodel::SpinModel)
	if isClassical(latticeinfo) != isClassical(spinmodel)
		error("info does not match")
	end
	if isClassical(latticeinfo)
		return buildClassicalLattice(latticeinfo,spinmodel)
	else
		return buildQuantumLattice(latticeinfo,spinmodel)
	end
end

function buildLattice(latticecode::AbstractString, spinmodel::SpinModel)
	latticeinfo = LatticeInfo(latticecode)
	return buildLattice(latticeinfo, spinmodel)
end

#---
# functions

#---
# inherit methods lattice.spinmodel
single_args_non_preserving = [
							:isZeroTemperature,
							:isClassical,
							:isSymmetricFactorization,
							:isPottsModel,
							:getModelname,
							:getStates,
							:getHamiltonian,
							:getTemperature,
							:getExternalfield,
							:getEnvParameters,
							:getFactorW,
							:getFactorWp,
							:getMeasureOperator
							]

for f in single_args_non_preserving
	eval(quote

		function $(f)(lattice::Lattice)
		  return $(f)(lattice.spinmodel)
		end

	end)
end

set_functions = [
				:setTemperature!,
				:setExternalfield!,
				]

for f in set_functions
	eval(quote

		  function $(f){T}(lattice::Lattice{T}, parameter::T)
		  $(f)(lattice.spinmodel, parameter)
			initialize!(lattice)
		end

	end)
end

function setEnvParameters!{T}(lattice::Lattice, temp::T, externalfield::T)
	setEnvParameters!(lattice.spinmodel, temp, externalfield)
	initialize!(lattice)
end


#---
# functions for Lattice
function initialize!{T}(lattice::Lattice{T})
	println("specify lattice!: return random tensor")
	lattice.tensorT = rand(2,2,2,2)
	lattice.tensorTtilde = rand(2,2,2,2)
end

function getTensorT(lattice::Lattice)
	return lattice.tensorT, lattice.tensorTtilde
end

function getTensorT(lattice::Lattice, whichIsTensorT::Int)
	tensorT, tensorTtilde = getTensorT(lattice)
	if whichIsTensorT == 1
		return tensorT, tensorTtilde
	else
		return tensorTtilde, tensorT
	end
end

function setTensorT!(lattice::Lattice, tensorT::Array; tilde = false)
	if tilde
		lattice.tensorTtilde = tensorT
	else
		lattice.tensorT = tensorT
	end
end



