type ClockModel{T} <: ClassicalSpinModel{T}
	spininfo::SpinInfo{T}
	factorW::Array{T,2}

	function ClockModel{T}(spininfo::SpinInfo{T})
		this = new{T}()
		this.spininfo = checkSpininfoForClock(spininfo)
		initialize!(this)
		return this
	end
end

ClockModel{T}(spininfo::SpinInfo{T}) = ClockModel{T}(spininfo)
ClockModel() = testClockModel()

#---
# functions for constructor
function checkSpininfoForClock{T}(spininfo::SpinInfo{T})
	if spininfo.modelname != "clock"
		println("warning:spininfo.modelname does not match to the type.
		  the modelname is changed to 'clock'")
		spininfo.modelname = "clock"
	end
	if isSymmetricFactorization == "sym"
		println("only 'asym'metric factorization for clock model.
		  change factorization to 'asym'.")
		spininfo.factorization = "asym"
	end
	return spininfo	
end

function initialize!{T}(clockmodel::ClockModel{T})
	factorW = initializeFactorWasym(clockmodel::ClockModel)
	clockmodel.factorW = factorW
end

function getHamiltonian{T}(clockmodel::ClockModel{T})
	numberOfState = getStates(clockmodel)
	externalfield = getExternalfield(clockmodel)
	sigmah = 1
	Hamiltonian = zeros(T,numberOfState, numberOfState)
	for i = 1:numberOfState, j = 1:numberOfState
		Hamiltonian[i,j] += sigmaTerm(i,j,numberOfState,T) + externalfield * (sigmaTerm(i,sigmah,numberOfState,T) + sigmaTerm(j,sigmah,numberOfState,T))/4.0
	end
	return -Hamiltonian
end
function getAngle(n::Int, numberOfState::Int, T::DataType = Float64)
	return (2.0 * pi * (convert(T,(n-1))))/convert(T,numberOfState)		
end
function sigmaTerm(i::Int, j::Int, numberOfState::Int, T::DataType = Float64)
	return cos(getAngle(i,numberOfState,T) - getAngle(j,numberOfState,T))	
end

function getMeasureOperator{T}(spinmodel::ClockModel{T})
	NOS = getStates(spinmodel)
	measurementOperator = Array{T}(NOS)
	for i = 1:NOS
		measurementOperator[i] = sigmaTerm(i,1,NOS,T)
	end
	return measurementOperator
end

#---
# test to make a example SpinModel
function testClockModel(numberOfState::Int = 2)
	modelcode = "classical_clock_" * dec(numberOfState)
	factorization = "sym"
	externalfield = 1.0e-13
	temperature = 1.5
	spininfo = SpinInfo(modelcode, factorization, externalfield, temperature)
	testModel = buildSpinSystem(spininfo)
	return testModel
end
