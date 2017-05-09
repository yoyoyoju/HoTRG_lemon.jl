#=
QuantumIsingModel
initialize!
getMeasureOperator
getStates

=#

type QuantumIsingModel{T} <:QuantumSpinModel{T}
	spininfo::SpinInfo{T}
	trotterinfo::TrotterInfo{T}

	factorW::Array{T,2}
	factorWp::Array{T,2}

	function QuantumIsingModel{T}(spininfo::SpinInfo{T}, trotterinfo::TrotterInfo{T})
		this = new{T}()
		this.spininfo = spininfo
		this.trotterinfo = trotterinfo
		initialize!(this)
	return this
	end
end

QuantumIsingModel{T}(spininfo::SpinInfo{T}, trotterinfo::TrotterInfo{T}) = 
QuantumIsingModel{T}(spininfo, trotterinfo)

#---
# functions for constructor
function initialize!{T}(qising::QuantumIsingModel{T})
	checkInfo!(qising.spininfo, qising.trotterinfo)
	factorW = getFactorW(qising)
	factorWp = getFactorWp(qising)
	qising.factorW = factorW
	qising.factorWp = factorWp
end

function getFactorW{T}(qising::QuantumIsingModel{T})
	tau = getTrotterparameter(qising)
	coshterm = sqrt(cosh(tau))
	sinhterm = sqrt(sinh(tau))
	return factorW = [coshterm sinhterm; coshterm -sinhterm]
end

function getFactorWp{T}(qising::QuantumIsingModel{T})
	tau = getTrotterparameter(qising)
	h = getExternalfield(qising)
	expterm = exp(tau * h / 2.0)
	factorWp = [expterm one(T)/expterm; expterm -one(T)/expterm]./sqrt(2.0)
	return factorWp
end

#---
# functions for IsingModel
function getMeasureOperator{T}(qising::QuantumIsingModel{T})
	return [-one(T), one(T)]
end

function getStates(qising::QuantumIsingModel)
	return 2
end

function isSymmetricFactorization(qising::QuantumIsingModel)
	return false
end


# set functions
function setTemperature!{T}(qising::QuantumIsingModel{T}, temperature::T)
	if !isZeroTemperature(temperature)
		iteration = -log(2.0, getTrotterparameter(qising) * temperature)
		iteration = try 
			Int(iteration)
			setTrotterIteration!(qising.trotterinfo, iteration)
		catch
			error("cannot set the temperature")
		end
	end
	setTemperature!(qising.spininfo, temperature)
	initialize!(qising)
end

function setEnvParameters!{T}(qising::QuantumIsingModel{T}, temperature::T, externalfield::T)
	setExternalfield!(qising, externalfield)
	setTemperature!(qising,temperature)
end

#---
# test to make a example SpinModel
function testQuantumIsingModel()
	externalfield = 1.0e-13
	temperature = 0.0
	spininfo = SpinInfo("quantum_ising_2","asym",externalfield,temperature)
	trotterparameter = 0.01
	trotteriteration = 100
	trotterinfo = TrotterInfo(trotterparameter, trotteriteration)
	testModel = QuantumIsingModel(spininfo, trotterinfo)
	return testModel
end
