type PottsModel{T} <: ClassicalSpinModel{T}
	spininfo::SpinInfo{T}
	factorW::Array{T,2}

	function PottsModel{T}(spininfo::SpinInfo{T})
		this = new{T}()
		this.spininfo = checkSpininfoForPotts(spininfo)
		initialize!(this)
		return this
	end
end

PottsModel{T}(spininfo::SpinInfo{T}) = PottsModel{T}(spininfo)
PottsModel() = testPottsModel()

#---
# functions for constructor
function checkSpininfoForPotts{T}(spininfo::SpinInfo{T})
	if spininfo.modelname != "potts"
		println("warning:spininfo.modelname does not match to the type.
		  the modelname is changed to 'potts'")
		spininfo.modelname = "potts"
	end
	return spininfo	
end

function initialize!{T}(pottsmodel::PottsModel{T})
	if isSymmetricFactorization(pottsmodel)
		factorW = initializePottsFactorWsym(pottsmodel::PottsModel)
	else
		factorW = initializeFactorWasym(pottsmodel::PottsModel)
	end
	pottsmodel.factorW = factorW
end

function initializePottsFactorWsym{T}(pottsmodel::PottsModel{T})
	temp, externalfield = getEnvParameters(pottsmodel)
	numberOfState = getStates(pottsmodel)
	sigmah = 1
	revTemp = one(T)/temp	# this is K
	etoK = exp(revTemp)		# e to the K
	eKbar = etoK + sqrt( (etoK + numberOfState - one(T)) * (etoK - one(T)) )
	eGamma = getExpGamma(revTemp, externalfield)
	denominatorTerm = sqrt( numberOfState -2.0 + 2.0 * eKbar )
	factorW = ones(T, numberOfState, numberOfState)
	for sigma = 1:numberOfState, s = 1:numberOfState
		if sigma == s
			factorW[sigma, s] *= eKbar
		end
		if sigma == sigmah
			factorW[sigma, s] *= eGamma
		end
	end
	factorW = factorW ./ denominatorTerm
	return factorW
end

function getHamiltonian{T}(pottsmodel::PottsModel{T})
	externalfield = getExternalfield(pottsmodel)
	numberOfState = getStates(pottsmodel)
	sigmah = 1
	hamiltonian = zeros(T, numberOfState, numberOfState)
	for sigmai = 1:numberOfState, sigmaj = 1:numberOfState
		addterm = zero(T)
		if sigmai == sigmah
			addterm += externalfield / 4.0
		end
		if sigmaj == sigmah
			addterm += externalfield / 4.0
		end
		if sigmai == sigmaj
			addterm += one(T)
		end
		hamiltonian[sigmai, sigmaj] += addterm
	end
	return -hamiltonian
end

function getMeasureOperator{T}(spinmodel::PottsModel{T})
	measurementOperator = zeros(getStates(spinmodel))
	measurementOperator[1] = one(T)
	return measurementOperator
end

#---
# functions for PottsModel
function isPottsModel(pottsmodel::PottsModel)
	return true
end

#---
# test to make a example SpinModel
function testPottsModel(numberOfState::Int = 2)
	modelcode = "classical_potts_" * dec(numberOfState)
	factorization = "sym"
	externalfield = 1.0e-13
	temperature = 1.5
	spininfo = SpinInfo(modelcode, factorization, externalfield, temperature)
	testModel = buildSpinSystem(spininfo)
	return testModel
end
