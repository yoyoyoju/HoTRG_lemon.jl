module LatticeModule
	using TensorOperations
	using TensorMatrices_lemon
	using HoTRG_lemon.SpinModule

	export 
		# lattice_info.jl
		LatticeInfo,
		getDimension,
		getGeometry,
		getCoarserate,
		getLegextension,
		getQuantumOrClassical,
		isClassical,
		isTwoDimension,
		isSquareLattice,
		isFractalLattice,
		testlatticeinfo,
		# lattice.jl
		Lattice,
		buildLattice,
			# <inherit from spinmodel>
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
		setTemperature!,
		setExternalfield!,
		setEnvParameters!,
		initialize!,
		getTensorT,
		getFactorW,
		getFactorWp,
		setTensorT!,
		# lattice_classical_2d_localtensor.jl
		makeTensorT,
		makeFactorWp,
		makeTensorQ,
		# lattice_classical.jl
		ClassicalLattice,
		buildClassicalLattice,
		# lattice_classical_2d.jl
		Classical2dLattice,
		getSpaceDimension,
		# lattice_classical_2d_square.jl
		Classical2dSquareLattice,
		testClassical2dSquareLattice,
		# lattice_classical_2d_fractal.jl
		Classical2dFractalLattice,
		testClassical2dFractalLattice,
		# lattice_quantum.jl
		QuantumLattice,
		buildQuantumLattice,
			# <inherit from QuantumSpinModel>
		getTrotterparameter,
		getTrotteriteration,
		getTrotterlayers,
		getBeta,
		setTrotterparameter!,
		setTrotterIteration!,
		# lattice_quantum_2d.jl
		Quantum2dLattice,
		# lattice_quantum_2d_square.jl
		Quantum2dSquareLattice,
		testQuantum2dSquareLattice,
		# lattice_classical_3d.jl
		Classical3dLattice,
		# lattice_classical_3d_square.jl
		Classical3dSquareLattice,
		testClassical3dSquareLattice,
		# lattice_quantum_2d_fractal.jl
		Quantum2dFractalLattice,
		testQuantum2dFractalLattice,
		# lattice_fractal.jl
		FractalLattice,
		getTensorP,
		getTensorQ,
		getLegextension,
		getHausdorffDim,
		getFractalDim,
		setTensorP!,
		setTensorQ!


	include("lattice_info.jl")
	include("lattice.jl")
	include("lattice_classical_2d_localtensor.jl")
	include("lattice_classical.jl")
	include("lattice_classical_2d.jl")
	include("lattice_classical_2d_square.jl")
	include("lattice_classical_2d_fractal.jl")
	include("lattice_quantum.jl")
	include("lattice_quantum_2d.jl")
	include("lattice_quantum_2d_square.jl")
	include("lattice_classical_3d.jl")
	include("lattice_classical_3d_square.jl")
	include("lattice_quantum_2d_fractal.jl")
	include("lattice_fractal.jl")
end

# inherit getSpaceDimension to the Simulator
#		getTensorP,
#		getTensorQ,
#		getLegextension,
#		getHausdorffDim,
#		getFractalDim,
#		setTensorP!,
#		setTensorQ!
