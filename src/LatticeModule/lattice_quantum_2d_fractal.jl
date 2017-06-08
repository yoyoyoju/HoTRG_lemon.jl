import HoTRG_lemon.SpinModule:
	initialize!

"""
	Quantum2dFractalLattice

# arguments

* `spinmodel::QuantumSpinModel`
* `legextension::Int`  
  default value is one. set zero for the normal square lattice.
"""
type Quantum2dFractalLattice{T} <: Quantum2dLattice{T}
	spinmodel::QuantumSpinModel{T}
	legextension::Int
	tensorT::Array{T,6} # ; x,xp,y,yp,z,zp
	tensorTtilde::Array{T,6}
	tensorP::Array{Array{T,5},1}# leg tensor; x,xp,s,z,zp
	tensorQ::Array{T,4} # corner tensor; x,y,z,zp
	function Quantum2dFractalLattice{T}(spinmodel::QuantumSpinModel{T}, legextension::Int)
		this = new{T}()
 		this.spinmodel = spinmodel
		this.legextension = legextension
 		initialize!(this)
 		return this
 	end
end

Quantum2dFractalLattice{T}(spinmodel::QuantumSpinModel{T}, legextension::Int) = 
Quantum2dFractalLattice{T}(spinmodel, legextension)
Quantum2dFractalLattice{T}(spinmodel::QuantumSpinModel{T}) = 
Quantum2dFractalLattice{T}(spinmodel, 1)

#---
# initialize functions for constructor
"""
	initialize(lattice::Quantum2dFractalLattice)
initialize and set tensorT, tensorTtilde, tensorP and tensorQ.  
"""
function initialize!{T}(lattice::Quantum2dFractalLattice{T})
	lattice.tensorT = initializeTensorT2dQ(lattice.spinmodel)
	lattice.tensorTtilde = initializeTensorT2dQ(lattice.spinmodel; tilde = true)
	tensorP = initializeTensorP_q2d(lattice)
	lattice.tensorP = fill(tensorP, getSpaceDimension(lattice))
	tensorQ = initializeTensorQ_q2d(lattice)
	setTensorQ!(lattice, tensorQ)
end

function initializeTensorP_q2d{T}(lattice::Quantum2dFractalLattice{T})
	factorW = getFactorW(lattice)								  
	factorWp = getFactorWp(lattice)
	leng = size(factorW,1)==size(factorW,2) ? size(factorW,1) : throw(DomainError())
	tensorPx = zeros(T,leng,leng,leng,leng,leng) #; y yp s z zp
	for a = 1:leng, l = 1:leng, r = 1:leng, f=1:leng, u=1:leng, v=1:leng
		tensorPx[l,r,f,u,v] += 
		factorW[a,l] * factorW[a,r] * factorW[a,f] * 
		factorWp[a,u] * factorWp[a,v]
	end
	return tensorPx
end

function initializeTensorQ_q2d{T}(lattice::Quantum2dFractalLattice{T})
	factorW = getFactorW(lattice)								  
	factorWp = getFactorWp(lattice)
	leng = size(factorW,1)==size(factorW,2) ? size(factorW,1) : throw(DomainError())
	tensorQ = zeros(T,leng,leng,leng,leng) #; x y z zp
	for a = 1:leng, x = 1:leng, y = 1:leng, z = 1:leng, zp = 1:leng
		tensorQ[x,y,z,zp] +=
		factorW[a,x] * factorW[a,y] *
		factorWp[a,z] * factorWp[a,zp]
	end
	return tensorQ
end

#---
# functions for Quantum2dFractalLattice
function getCoarserate(lattice::Quantum2dFractalLattice)
	##### maybe not right... or even I don't need this
	L = getLegextension(lattice)
	return 8*(L+1)
end

#---
# functions for test
function testQuantum2dFractalLattice()
	spinmodel = testQuantumIsingModel()
	latticecode = "quantum_2d_fractal_1"
	lattice = buildLattice(latticecode, spinmodel)
	return lattice
end
