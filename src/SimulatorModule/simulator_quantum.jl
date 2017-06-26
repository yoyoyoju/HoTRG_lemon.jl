import HoTRG_lemon.LatticeModule:
	getTrotterparameter,
	getTrotteriteration,
	getTrotterlayers,
	getBeta,
	setTrotterparameter!,
	setTrotterIteration!
	

"""
	QuantumSimulator

Under `Simulator`


# methods:

* `getTrotterparameter(QuantumSimulator)` - get tau  
* `getTrotteriteration(QS)`
* `getTrotterlayers(QS)`

"""
abstract QuantumSimulator{T} <: Simulator{T}
abstract Quantum2dSimulator{T} <: QuantumSimulator{T}

#---
# functions for QuantumSimulator
function initializeCount!(simulator::QuantumSimulator)
	simulator.countiteration = 0
	simulator.trottercount = 0
end

function getTrotterCount(simulator::QuantumSimulator)
	return simulator.trottercount
end

function getSpaceCount(simulator::QuantumSimulator)
	return getCount(simulator) - getTrotterCount(simulator)
end

function countUp!(simulator::QuantumSimulator, whichone::AbstractString)
	countUp!(simulator)
	if whichone == "trotter"
		simulator.trottercount = simulator.trottercount + 1
	end
end

function countDown!(simulator::QuantumSimulator, whichone::AbstractString)
	countDown!(simulator)
	if whichone == "trotter"
		simulator.trottercount = simulator.trottercount - 1
	end
end

function getBeta(simulator::QuantumSimulator)
	return iteration2layer(getTrotteriteration(simulator)) * getTrotterparameter(simulator)
end

function getFirstTerm{T}(simulator::QuantumSimulator{T})
	return one(T)/getTrotterparameter(simulator)
end

#---
# inherit from QuantumSpinModel
single_args_non_preserving = [
							:getTrotterparameter,
							:getTrotteriteration,
							:getTrotterlayers
							]

for f in single_args_non_preserving
	eval(quote

	  function $(f)(simulator::QuantumSimulator)
	  return $(f)(simulator.lattice)
		end

	end)
end
							
set_functions = [
				:setTrotterparameter!,
				:setTrotterIteration!
				]

for f in set_functions
	eval(quote

		  function $(f){T}(simulator::QuantumSimulator{T}, parameter)
		  $(f)(simulator.lattice, parameter)
		end

	end)
end

