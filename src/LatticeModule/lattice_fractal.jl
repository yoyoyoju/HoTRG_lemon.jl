FractalLattice = Union{Classical2dFractalLattice,Quantum2dFractalLattice}

function getTensorP(lattice::FractalLattice, which::Int = 0)
	if which == 0
		return lattice.tensorP
	else
		return lattice.tensorP[which]
	end
end

function getTensorQ(lattice::FractalLattice)
	return lattice.tensorQ
end

function setTensorP!(lattice::FractalLattice, which::Int, tensorP::Array)
	lattice.tensorP[which] = tensorP
end

function setTensorQ!(lattice::FractalLattice, tensorQ::Array) 
	lattice.tensorQ = tensorQ
end

function getLegextension(lattice::FractalLattice)
	return lattice.legextension
end

function getHausdorffDim(lattice::FractalLattice)
	L = getLegextension(lattice)
	d = log(4.0+8.0*L)/log(2.0+2.0*L)
	# d = log(convert(T,4+8*L))/log(convert(T,2+2*L))
	return d
end

function getFractalDim(lattice::FractalLattice)
	L = getLegextension(lattice)
	d = 1.0 + log(2.0)/log(2.0+2.0*L)
	return d
end

