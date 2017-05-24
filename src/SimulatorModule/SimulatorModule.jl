"""
	SimulatorModule
Simulator for lattice.  

# modifying _move this when finished_
* simulator_quantum_2d_fractal_initialiteration.jl  
  for adding additional iterations for the trotter layer
  * getSingularValues

# Type list
* Simulator,
* ClassicalSimulator,
* Classical2dSimulator,
* Classical3dSimulator,
* Classical2dSquareSimulator,
* QuantumSimulator,
* Quantum2dSimulator,
* Quantum2dSquareSimulator,
* Classical3dSquareSimulator,
* FractalSimulator,
* Classical2dFractalSimulator,
* Quantum2dFractalSimulator,
* Quantum2dFractalInititerSimulator <- working

# Method list
* buildSimulator, #
* getDimM,
* getExpectationValue,
* getFreeEnergy,
* getWholeiteration,
* getNormalizationfactors,
* getData4Energy,
* getCount,
* getNumberOfSites,
* countUp!,
* countDown!,
* isDone,
* setNormalizationfactor!,
* normalizeTensor,
* writeVector,
* isZeroTemperature,
* isClassical,
* getModelname,
* getStates,
* isSymmetricFactorization,
* isPottsModel,
* getHamiltonian,
* getTemperature,
* getExternalfield,
* getEnvParameters,
* getCoareserate,
* getTensorT,
* getTensorW,
* getMeasureOperator,
* setTemperature!,
* setExternalfield!,
* setTensorT!,
* setEnvParameters!,
* initializeCount!,
* getFirstTerm,
* renormalize!,
* getTrotterCount,
* getSpaceCount,
* getTrotterparameter,
* getTrotteriteration,
* getTrotterlayers,
* getBeta, # changed to use trottercount
* setTrotterparameter!,
* setTrotterIteration!,
* renormalize,
* getNewTensorT_2dQ,
* getTensorU,
* getTensorV,
* getTenmatMMd,
* renormalizeX!,
* renormalizeZ!,
* renormalizeY!,
* truncMatrixU,
* matU2tenU,
* simulatorTemperature,
* simulatorQuantum,
* getHausdorffDim,
* getFractalDim,
* getLegextension,
* getTensorP,
* getTensorQ,
* getCoefficient,
* setTensorP!,
* setTensorQ!,
* normalizeTensor!,
* setNorm!,
* constructHalf,
* updateLocalTensors!,
* debug_updateLocalTensors!,
* getNewLegTensor,
* getNewCaretTensor,
* # working_simulator_q2f_re.jl
* renormalizeSpace!,
* renormalizeTrotter!,
* getTensorUy,
* # new version of
* # simulator_quantum_2d_square.jl
* updateCoefficient!,
* setCoefficient!,
* getCoefficient,
* # for debug:
* calculateCoreTensors
* getInititeration(simulator::Quantum2dFractalinititerSimulator)



# Test list
* testClassical2dSquareSimulator,
* testQuantum2dSquareSimulator,
* testSimulateTemp,
* testClassical3dSquareSimulator,
* testClassical2dFractalSimulator,
* testQuantum2dFractalSimulator,
"""
module SimulatorModule
	using HoTRG_lemon.LatticeModule
	using HoTRG_lemon.SpinModule
	using TensorOperations
	using TensorMatrices_lemon

	export 
		# simulator.jl
		Simulator,
		buildSimulator, #
		getDimM,
		getExpectationValue,
		getFreeEnergy,
		getWholeiteration,
		getNormalizationfactors,
		getData4Energy,
		getCount,
		getNumberOfSites,
		countUp!,
		countDown!,
		isDone,
		setNormalizationfactor!,
		normalizeTensor,
		writeVector,
			# <inherit from lattice>
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
		getCoareserate,
		getTensorT,
		getTensorW,
		getMeasureOperator,
		setTemperature!,
		setExternalfield!,
		setTensorT!,
		setEnvParameters!,
		# simulator_classical.jl
		ClassicalSimulator,
		Classical2dSimulator,
		Classical3dSimulator,
		initializeCount!,
		getFirstTerm,
		# simulator_classical_2d_square.jl
		Classical2dSquareSimulator,
		testClassical2dSquareSimulator,
		# simulator_classical_2d_square_renormalize.jl
		renormalize!,
		# simulator_quantum.jl
		QuantumSimulator,
		Quantum2dSimulator,
		getTrotterCount,
		getSpaceCount,
			# <inherit from QuantumLattice>
		getTrotterparameter,
		getTrotteriteration,
		getTrotterlayers,
		getBeta, # changed to use trottercount
		setTrotterparameter!,
		setTrotterIteration!,
		# simulator_quantum_2d_square.jl
		Quantum2dSquareSimulator,
		testQuantum2dSquareSimulator,
		# simulator_quantum_2d_square_renormalize.jl
		renormalize,
		##### to debug
		getNewTensorT_2dQ,
		getTensorU,
		getTensorV,
		getTenmatMMd,
		renormalizeX!,
		renormalizeZ!,
		renormalizeY!,
		truncMatrixU,
		matU2tenU,
		# simulator_temperature.jl
		simulatorTemperature,
		testSimulateTemp,
		# simulator_quantum_data.jl
		simulatorQuantum,
		# simulator_classical_3d_square.jl
		Classical3dSquareSimulator,
		testClassical3dSquareSimulator,
		# simulator_fractal.jl
		FractalSimulator,
			# inherit from FractalLattice
		getHausdorffDim,
		getFractalDim,
		getLegextension,
		getTensorP,
		getTensorQ,
		getCoefficient,
		setTensorP!,
		setTensorQ!,
		normalizeTensor!,
		setNorm!,
		# simulator_classical_2d_fractal.jl
		Classical2dFractalSimulator,
		testClassical2dFractalSimulator,
		# for debugging
		constructHalf,
		updateLocalTensors!,
		debug_updateLocalTensors!,
		getNewLegTensor,
		getNewCaretTensor,
		# working_simulator_q2f.jl
		Quantum2dFractalSimulator,
		testQuantum2dFractalSimulator,
		# working_simulator_q2f_re.jl
		renormalizeSpace!,
		renormalizeTrotter!,
		getTensorUy,
		# new version of
		# simulator_quantum_2d_square.jl
		updateCoefficient!,
		setCoefficient!,
		getCoefficient,
		# for debug:
		calculateCoreTensors,
		# simulator_quantum_2d_fractal_inititer.jl
		Quantum2dFractalInititerSimulator,
		getInititeration








	include("simulator.jl")
	include("simulator_classical.jl")
	include("simulator_classical_2d_square.jl")
	include("simulator_classical_2d_square_renormalize.jl")
	include("simulator_quantum.jl")
#	 include("simulator_quantum_2d_square.jl")
#	 include("simulator_quantum_2d_square_renormalize.jl")
	 include("ori_simulator_quantum_2d_square.jl")
	 include("ori_simulator_quantum_2d_square_renormalize.jl")
	include("working_simulator_q2f.jl")
	include("working_simulator_q2f_re.jl")
	include("simulator_classical_temperature.jl")
	include("simulator_quantum_data.jl")
	include("simulator_classical_3d_square.jl")
	include("simulator_classical_3d_square_renormalize.jl")
	include("simulator_classical_2d_fractal_2.jl")
	include("simulator_classical_2d_fractal_renormalize_2.jl")
	include("simulator_quantum_2d_fractal_inititer.jl")
	include("renormalize_simulator_quantum_2d_fractal_inititer.jl")
	include("simulator_fractal.jl")

end
