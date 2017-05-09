spin_info.jl
spin_trotter.jl
spin_model.jl
spin_classical.jl
spin_quantum.jl
spin_classical_ising.jl
spin_classical_potts.jl
spin_classical_clock.jl
spin_quantum_ising.jl


functions from SpinInfo:
# spin_info.jl
	isZeroTemperature(spininfo) 
	isClassical(spininfo)
	getModelname(spininfo)
	getStates(spininfo)
	isSymmetricFactorization(spininfo)
	getTemperature(spininfo)
	getExternalfield(spininfo)
	getEnvParameters(spininfo)
	setTemperature!(spininfo, temperature)
	setExternalfield!(spininfo, externalfield)
	setEnvParameters!(spininfo, temperature, externalfield)
	testSpinInfo()

functions from TrotterInfo:
# spin_trotter.jl
	TrotterInfo,
	getTrotterparameter,
	getTrotteriteration,
	getTrotterlayers,
	getBeta,
	getTemperature,
	setTrotterparameter!,
	setTrotterIteration!,
	testTrotterInfo

functions from SpinModel:
# spin_model.jl
	buildSpinSystem(spininfo)
	buildSpinSystem(spininfo, TrotterInfo)
	getMeasureOperator
	getFactorW
	isPottsModel
	# <functions for Hamiltonian>
	getHamiltonian(spinmodel)
	# <test function>
	testSpinModel()
	# <inherit from spininfo>
	#--- one input (spininfo)
	isZeroTemperature
	isClassical
	getModelname
	getStates
	isSymmetricFactorization
	getTemperature
	getExternalfield(spininfo)
	getEnvParameters(spininfo)
	#--- two input (spininfo, T)
	setTemperature!(spininfo, temperature)
	setExternalfield!(spininfo, externalfield)
	#--- three input (spininfo, T1, T2)
	setEnvParameters!(spininfo, temperature, externalfield)

QunatumSpinModel's field:
	#---- SpinInfo
	qunatumOrClassical
	numberOfState
	factorization
	modelname
	temperature -> zero or finite
	externalfield
	#----
	#---- TrotterInfo
	trotterparameter -> tau
	trotteriteration ->
		trotterlayers as a functions
	#----
	#= to think about
	trotterinfo & spininfo compatable
	temperature and trotteriteration -> initiate!
	trotteriteration and the whole iteration <- coming from simulator 

	=#

	factorW
	factorWp

QunatumSpinModel's functions:
	getFactorWp
	# <inherit from trotterinfo>
	getTrotterparameter,
	getTrotteriteration,
	getTrotterlayers,
	getBeta,
	setTrotterparameter!,
	setTrotterIteration!,

	# <check info>
	checkInfo!(spininfo, trotterinfo)

QuantumIsingModel's functions:
	initialize!
	getFactorW
	getFactorWp
	getMeasureOperator
	getStates
	isSymmetricFactorization
	setTemperature!
	setEnvParameters!
	testQuantumIsingModel()
#----------------------------
#----------------------------
#----------------------------


ClassicalSpinModel's field:
	#---- SpinInfo
	qunatumOrClassical
	numberOfState
	factorization
	modelname
	temperature
	externalfield
	#----

	factorW

ClassicalSpinModel's functions:
	getBeta


	#----------------------------
	change the name of factorW and factorWp
	and according functions:
	spin_info.jl
	spin_model.jl
	spin_classical.jl
	spin_classical_ising.jl
	spin_classical_potts.jl
	spin_classical_clock.jl
	spin_trotter.jl
	spin_quantum.jl
	spin_quantum_ising.jl

	#=
		FUNCTIONS these are for spinmodel
		Hamiltonian::Array{T,2} # externalfield, numberOfState 
		BoltzmannWeight::Array{T,2} # temperature, hamiltonian
		factorW::Array{T,2} # temperature, externalfield, model
			# hamiltonian, temperature
	=#

