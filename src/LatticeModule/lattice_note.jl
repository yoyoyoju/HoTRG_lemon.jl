

lattice_info.jl
	fields:
		quantumOrClassical
		dimension
		geometry
		coarserate
	functions:
		getDimension
		getGeometry
		getCoarserate
		getQuantumOrClassical
		isClassical
		isTwoDimension
		isSquareLattice
		testlatticeinfo

lattice.jl
	fields:
		spinmodel
		tensorT
		tensorTtilde

	functions:
		getTensorT
		setTensorT!

		buildLattice
		# <inherit from spinmodel>
		isZeroTemperature
		isClassical
		getModelname
		getStates
		isSymmetricFactorization
		isPottsModel
		getHamiltonian
		getTemperature
		getExternalfield
		getEnvParameters
		-
		setTemperature!
		setExternalfield!
		setEnvParameters!


lattice_quantum.jl
	functions:
		buildQuantumLattice
		# <inherit from spinmodel(from TrotterInfo)>
		getTrotterparameter
		getTrotteriteration
		getTrotterlayers
		getBeta
		-
		setTrotterparameter!
		setTrotterIteration!
lattice_quantum_2d.jl
lattice_quantum_2d_square.jl
	getCoareserate -> 2

lattice_classical.jl
	functions:
		buildClassicalLattice
lattice_classical_2d.jl
lattice_classical_2d_square.jl
	functions:
		initialize!
		getCoareserate -> 2
		testClassical2dSquareLattice
lattice_classical_3d.jl
lattice_classical_3d_square.jl

---------------------------------
# fractal lattice... -> let's see the paper,,

introduce type union fractal lattice 
	IntOrString = Union{Int, AbstractString}


lattice_fractal.jl
	fractal lattices fields:
		spinmodel
		legextension::Int
		tensorT
		tensorTtilde
		tensorP::Array{Array{T,4},1}
		tensorQ
	fractal lattice functions:
		getTensorP - done
		getTensorQ - done
		getLegextension - done 
		getHaudorffDim =  done
		getFractalDim (from the legextension) - done
		getCoarserate #####
		setTensorP - done
		setTensorQ - done

	

lattice_classical_2d_fractal.jl
	need to have the information about how many legs are there
	need to store all the tensorP (with all the space directions) and tensorQ
	get and set tensorP's and tensorQ ( so, maybe tensorP should be array??)
	then I wonder what can I do about the memory? should I allocate?
	getCoarserate
	need to think about coarserate..
	it is when the countUp happens how many sites go to the next...



----
lattice_2d_localtensor.jl
	-> get T, P, Q
lattice_3d_localtensor.jl



#---------------
the change from spin*
tensorW -> factorW
tensorP -> factorWp (the matrix P for 2d quantum spins...)
and the correspondings.

lattice.jl
lattice_info.jl
lattice_classical.jl
lattice_classical_2d.jl
lattice_classical_2d_fractal.jl
lattice_classical_2d_square.jl
lattice_classical_3d.jl
lattice_classical_3d_square.jl
lattice_2d_localtensor.jl
lattice_fractal.jl
lattice_quantum.jl
lattice_quantum_2d.jl
lattice_quantum_2d_square.jl
LatticeModule.jl
