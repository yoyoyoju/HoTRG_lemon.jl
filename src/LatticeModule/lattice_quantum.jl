import HoTRG_lemon.SpinModule:
	getTrotterparameter,
	getTrotteriteration,
	getTrotterlayers,
	getBeta,
	setTrotterparameter!,
	setTrotterIteration!

abstract QuantumLattice{T} <: Lattice{T}

function buildQuantumLattice(latticeinfo::LatticeInfo, spinmodel::SpinModel)
	if isClassical(spinmodel)
		error("wrong lattice")
	end
	if isTwoDimension(latticeinfo) & isSquareLattice(latticeinfo)
		return Quantum2dSquareLattice(spinmodel)
	elseif isTwoDimension(latticeinfo) & isFractalLattice(latticeinfo)
		return Quantum2dFractalLattice(spinmodel)
	else 
		error("wrong latticeinfo")
	end
end

#---
# functions inherit from QuantumSpinModel
get_functions = [
				:getTrotterparameter,
				:getTrotteriteration,
				:getTrotterlayers,
				:getBeta
				]
for f in get_functions
	eval(quote
	  function $(f){T}(lattice::QuantumLattice{T})
	  	$(f)(lattice.spinmodel)
		end
	end)
end

set_functions = [
				:setTrotterparameter!,
				:setTrotterIteration!
				]

for f in set_functions
	eval(quote

		  function $(f){T}(lattice::QuantumLattice{T}, parameter)
		  $(f)(lattice.spinmodel, parameter)
			initialize!(lattice)
		end

	end)
end

