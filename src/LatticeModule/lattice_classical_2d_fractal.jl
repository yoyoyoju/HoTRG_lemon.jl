import HoTRG_lemon.SpinModule:
	initialize!

type Classical2dFractalLattice{T} <: Classical2dLattice{T}
	spinmodel::ClassicalSpinModel{T}
	legextension::Int
	tensorT::Array{T,4} # ; x,xp,y,yp
	tensorTtilde::Array{T,4}
	tensorP::Array{Array{T,3},1}# leg tensor; x,xp,s
	tensorQ::Array{T,2} # corner tensor; x,y
	function Classical2dFractalLattice{T}(spinmodel::ClassicalSpinModel{T}, legextension::Int)
		this = new{T}()
 		this.spinmodel = spinmodel
		this.legextension = legextension
 		initialize!(this)
 		return this
 	end
end

Classical2dFractalLattice{T}(spinmodel::ClassicalSpinModel{T}, legextension::Int) = 
Classical2dFractalLattice{T}(spinmodel, legextension)
Classical2dFractalLattice{T}(spinmodel::ClassicalSpinModel{T}) = 
Classical2dFractalLattice{T}(spinmodel, 1)

#---
# initialize functions for constructor
function initialize!{T}(lattice::Classical2dFractalLattice{T})
	lattice.tensorT = initializeTensorT2D_fractal(lattice.spinmodel)
	lattice.tensorTtilde = initializeTensorT2D_fractal(lattice.spinmodel; tilde = true)
	factorW = getFactorW(lattice)
	tensorP = makeTensorP(factorW)
	lattice.tensorP = fill(tensorP, getSpaceDimension(lattice))
	setTensorQ!(lattice, makeTensorQ(factorW))
end

function initializeTensorT2D_fractal{T}(spinmodel::ClassicalSpinModel{T}; tilde::Bool = false)
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
# functions for Classical2dFractalLattice
function getCoarserate(lattice::Classical2dFractalLattice)
	L = getLegextension(lattice)
	return 4*(L+1)
end

#---
# functions for test
#####
function testClassical2dFractalLattice()
	spinmodel = testIsingModel()
	latticecode = "classical_2d_fractal_1"
	lattice = buildLattice(latticecode, spinmodel)
	return lattice
end
