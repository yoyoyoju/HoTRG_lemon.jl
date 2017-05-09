import HoTRG_lemon.SpinModule:
	initialize!

type Classical2dSquareLattice{T} <: Classical2dLattice{T}
	spinmodel::ClassicalSpinModel{T}

	tensorT::Array{T,4}
	tensorTtilde::Array{T,4}
 	function Classical2dSquareLattice{T}(spinmodel::ClassicalSpinModel{T})
		this = new{T}()
 		this.spinmodel = spinmodel
 		initialize!(this)
 		return this
 	end
end

Classical2dSquareLattice{T}(spinmodel::ClassicalSpinModel{T}) = Classical2dSquareLattice{T}(spinmodel)

#---
# initialize functions for constructor
function initialize!{T}(lattice::Classical2dSquareLattice{T})
	lattice.tensorT = initializeTensorT2D(lattice.spinmodel)
	lattice.tensorTtilde = initializeTensorT2D(lattice.spinmodel; tilde = true)
end

function initializeTensorT2D{T}(spinmodel::ClassicalSpinModel{T}; tilde::Bool = false)
	if tilde
		measureOperator = getMeasureOperator(spinmodel)
	else
		measureOperator = ones(T,getStates(spinmodel))
	end
	factorW = getFactorW(spinmodel)
	tensorT = makeTensorT(factorW, measureOperator)
	return tensorT
end

#---
# functions for Classical2dSquareLattice
function getCoarserate(lattice::Classical2dSquareLattice)
	return 2
end

#---
# functions for test
function testClassical2dSquareLattice()
	spinmodel = testIsingModel()
	return buildLattice("classical_2d_square", spinmodel)
end
