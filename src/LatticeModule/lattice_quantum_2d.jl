abstract Quantum2dLattice{T} <: QuantumLattice{T}

function getSpaceDimension(lattice::Quantum2dLattice)
	return 2
end

function initializeTensorT2dQ{T}(spinmodel::QuantumSpinModel{T}; tilde::Bool = false)
	if tilde
		measureOperator = getMeasureOperator(spinmodel)
	else
		measureOperator = ones(T,getStates(spinmodel))
	end
	factorW = getFactorW(spinmodel)
	factorWp = getFactorWp(spinmodel)
	leng = size(factorW,1)==size(factorW,2) ? size(factorW,1) : throw(DomainError())
	tensorT = zeros(T,leng,leng,leng,leng,leng,leng)
	for a = 1:leng, l = 1:leng, r = 1:leng, f=1:leng, b=1:leng, u=1:leng, v=1:leng
		tensorT[l,r,f,b,u,v] += measureOperator[a] *
		factorW[a,l] * factorW[a,r] * factorW[a,f] * factorW[a,b] *
		factorWp[a,u] * factorWp[a,v]
	end
	return tensorT
end

