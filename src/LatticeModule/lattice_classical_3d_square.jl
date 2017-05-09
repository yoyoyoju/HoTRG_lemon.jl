import HoTRG_lemon.SpinModule:
	initialize!

type Classical3dSquareLattice{T} <: Classical3dLattice{T}
	spinmodel::ClassicalSpinModel{T}

	tensorT::Array{T,6}
	tensorTtilde::Array{T,6}
 	function Classical3dSquareLattice{T}(spinmodel::ClassicalSpinModel{T})
		this = new{T}()
 		this.spinmodel = spinmodel
 		initialize!(this)
 		return this
 	end
end

Classical3dSquareLattice{T}(spinmodel::ClassicalSpinModel{T}) = Classical3dSquareLattice{T}(spinmodel)

#---
# initialize functions for constructor
function initialize!{T}(lattice::Classical3dSquareLattice{T})
	lattice.tensorT = initializeTensorT3D(lattice.spinmodel)
	lattice.tensorTtilde = initializeTensorT3D(lattice.spinmodel; tilde = true)
end

function initializeTensorT3D{T}(spinmodel::ClassicalSpinModel{T}; tilde::Bool = false)
	if tilde
		measureOperator = getMeasureOperator(spinmodel)
	else
		measureOperator = ones(T,getStates(spinmodel))
	end
	tensorW = getFactorW(spinmodel)
	leng = size(tensorW,1)==size(tensorW,2) ? size(tensorW,1) : throw(DomainError())
	tensorT = zeros(T,leng,leng,leng,leng,leng,leng)
	for a = 1:leng, l = 1:leng, r = 1:leng, f=1:leng, b=1:leng, u=1:leng, v=1:leng
		tensorT[l,r,f,b,u,v] += measureOperator[a] *
		tensorW[a,l] * tensorW[a,r] * tensorW[a,f] * tensorW[a,b] *
		tensorW[a,u] * tensorW[a,v]
	end
	return tensorT
end

#---
# functions for Classical3dSquareLattice
function getCoarserate(lattice::Classical3dSquareLattice)
	return 2
end

#---
# functions for test
function testClassical3dSquareLattice()
	spinmodel = testIsingModel()
	return buildLattice("classical_3d_square", spinmodel)
end
