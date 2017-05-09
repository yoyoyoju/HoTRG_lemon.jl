type IsingModel{T} <: ClassicalSpinModel{T}
	spininfo::SpinInfo{T}
	factorW::Array{T,2}

	function IsingModel{T}(spininfo::SpinInfo{T})
		this = new{T}()
		this.spininfo = checkSpininfoForIsing(spininfo)
		initialize!(this)
		return this
	end
end

IsingModel{T}(spininfo::SpinInfo{T}) = IsingModel{T}(spininfo)
IsingModel() = testIsingModel()

#---
# functions for constructor
function checkSpininfoForIsing{T}(spininfo::SpinInfo{T})
	if spininfo.modelname != "ising"
		println("warning:spininfo.modelname does not match to the type.
		  the modelname is changed to 'ising'")
		spininfo.modelname = "ising"
	end
	if getStates(spininfo) != 2
		println("warning: ising model can only have 2 states.
			the numberOfStates is changed to 2")
		spininfo.numberOfState = 2
	end
	return spininfo	
end

function initialize!{T}(isingmodel::IsingModel{T})
	if isSymmetricFactorization(isingmodel)
		factorW = initializeIsingFactorWsym(getEnvParameters(isingmodel))
	else
		factorW = initializeIsingFactorWasym(getEnvParameters(isingmodel))
	end
	isingmodel.factorW = factorW
end

function initializeIsingFactorWsym{T}(temp::T, externalfield::T)
	revTemp = one(T)/temp
	expKbar = sqrt(exp(2.0*revTemp)+sqrt(exp(4.0*revTemp)-1.0))
	expterm = getExpGamma(revTemp, externalfield)
	factorW = [expterm*expKbar expterm/expKbar; 1.0/(expterm*expKbar) expKbar/expterm] ./ sqrt(2.0*exp(revTemp))
	return factorW
end

function initializeIsingFactorWasym{T}(temp::T, externalfield::T)
	revTemp = one(T)/temp
	coshterm = sqrt(cosh(revTemp))
	sinhterm = sqrt(sinh(revTemp))
	expterm = getExpGamma(revTemp, externalfield)
	return factorW = [coshterm*expterm sinhterm*expterm; coshterm/expterm -sinhterm/expterm]
end

initializeIsingFactorWsym{T}(envparameter::Tuple{Vararg{T,2}}) = 
	initializeIsingFactorWsym(envparameter[1], envparameter[2])
initializeIsingFactorWasym{T}(envparameter::Tuple{Vararg{T,2}}) =
	initializeIsingFactorWasym(envparameter[1], envparameter[2])

#---
# functions for IsingModel
function getMeasureOperator{T}(spinmodel::IsingModel{T})
	return [-one(T), one(T)]
end

#---
# test to make a example SpinModel
function testIsingModel()
	modelcode = "classical_ising_2"
	factorization = "sym"
	externalfield = 1.0e-13
	temperature = 1.5
	spininfo = SpinInfo(modelcode, factorization, externalfield, temperature)
	testModel = buildSpinSystem(spininfo)
	return testModel
end
