abstract SpinModel{T}

#---
# building SpinModel from SpinInfo
##### include quantum spins
function buildSpinSystem{T}(spininfo::SpinInfo{T}, trotterinfo::TrotterInfo{T} = TrotterInfo(0.01,10))
	if isClassical(spininfo)
		if spininfo.modelname == "ising"
			return IsingModel(spininfo)
		elseif spininfo.modelname == "potts"
			return PottsModel(spininfo)
		elseif spininfo.modelname == "clock"
			return ClockModel(spininfo)
		else
			println("warning: no matching modelname")
			return SpinModel
		end
	else
		if spininfo.modelname == "ising"
			println("set trotterparameter 0.01, trotteriteration 10")
			return QuantumIsingModel(spininfo, trotterinfo) 
		else
			error("model name error")
		end
	end
end

#---
# functions for SpinModel
function getMeasureOperator{T}(spinmodel::SpinModel{T})
	println("SpinModel was used")
	return [-one(T), one(T)]
end

function getFactorW(spinmodel::SpinModel)
	return spinmodel.factorW
end

function isPottsModel(spinModel::SpinModel)
	return false
end

#---
# functions for SpinModel
# inherit from SpinInfo
single_args_non_preserving = [
							  :isZeroTemperature,
							  :isClassical,
							  :getModelname,
							  :getStates, 
							  :isSymmetricFactorization,
							  :getTemperature,
							  :getExternalfield,
							  :getEnvParameters
							 ]

for f in single_args_non_preserving
	eval(quote

		function $(f)(spinmodel::SpinModel)
			return $(f)(spinmodel.spininfo)
		end

	end)
end

set_single_parameter = [:setTemperature!,
						:setExternalfield!]
for f in set_single_parameter
	eval(quote
		
	  function $(f){T}(spinmodel::SpinModel{T}, parameter::T)
		 $(f)(spinmodel.spininfo, parameter)
		 initialize!(spinmodel)
	  end

	end)
end

function setEnvParameters!{T}(spinmodel::SpinModel{T}, temperature::T, externalfield::T)
	setEnvParameters!(spinmodel.spininfo, temperature, externalfield)
	initialize!(spinmodel)
end

#---
# functions to make factorW from Hamiltonian
function getHamiltonian{T}(spinmodel::SpinModel{T})
	println("return random hamiltonian")
	return rand(getStates(spinmodel), getStates(spinmodel))
end

function initializeFactorWasym{T}(spinmodel::SpinModel{T})
	hamiltonian = getHamiltonian(spinmodel)
	factorW = getFactorWfromHamiltonian(getTemperature(spinmodel), hamiltonian)
	return factorW 
end

function getFactorWfromHamiltonian{T}(temperature::T, hamiltonian::Array{T,2})
	numberOfState = size(hamiltonian,1)
	boltzmannWeight = getBoltzmannWeight(temperature, hamiltonian)
	D, P = eig(boltzmannWeight)
	factorW = zeros(T, numberOfState, numberOfState)
	for sigma = 1:numberOfState, s = 1:numberOfState
		factorW[sigma,s] = P[sigma,s] * sqrt(D[s])
	end
	return factorW
end

function getBoltzmannWeight{T}(temperature::T, hamiltonian::Array{T,2})
	BoltzmannWeight = exp( -hamiltonian ./temperature )
	return BoltzmannWeight
end

#---
# auxilary functions

function getExpGamma{T}(revTemp::T,externalfield::T)
	expterm = exp(revTemp*externalfield/4.0)
end

#---
# testFunction
function testSpinModel()
	return testIsingModel()
end
