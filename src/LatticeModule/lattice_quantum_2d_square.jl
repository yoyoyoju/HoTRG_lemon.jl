import SpinModule: 
	initialize!

type Quantum2dSquareLattice{T} <: Quantum2dLattice{T}
	spinmodel::QuantumSpinModel{T}

	tensorT::Array{T,6}
	tensorTtilde::Array{T,6}
	function Quantum2dSquareLattice{T}(qmodel::QuantumSpinModel{T})
		this = new{T}()
 		this.spinmodel = qmodel
 		initialize!(this)
 		return this
 	end
end

Quantum2dSquareLattice{T}(qmodel::QuantumSpinModel{T}) = Quantum2dSquareLattice{T}(qmodel)

#---
# initialize functions for constructor
function initialize!{T}(lattice::Quantum2dSquareLattice{T})
	lattice.tensorT = initializeTensorT2dQ(lattice.spinmodel)
	lattice.tensorTtilde = initializeTensorT2dQ(lattice.spinmodel; tilde = true)
end

#---
# functions
function getCoarserate(lattice::Quantum2dSquareLattice)
	return 2
end

function getCoarserate(lattice::Quantum2dSquareLattice, whichAxis::AbstractString)
	if whichAxis == "z"
		return 2
	else
		return 2
	end
end

#---
# functions for test
function testQuantum2dSquareLattice()
	spinmodel = testQuantumIsingModel()
	return buildLattice("quantum_2d_square", spinmodel)
end
