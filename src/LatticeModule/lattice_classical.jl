abstract ClassicalLattice{T} <: Lattice{T}

function buildClassicalLattice(latticeinfo::LatticeInfo, spinmodel::SpinModel)
	if isTwoDimension(latticeinfo) & isSquareLattice(latticeinfo)
		return Classical2dSquareLattice(spinmodel)
	elseif isTwoDimension(latticeinfo) & isFractalLattice(latticeinfo)
		return Classical2dFractalLattice(spinmodel, getLegextension(latticeinfo))
	elseif getDimension(latticeinfo,3) & isSquareLattice(latticeinfo)
		return Classical3dSquareLattice(spinmodel)
	else
		error("wrong latticeinfo")
	end
end
