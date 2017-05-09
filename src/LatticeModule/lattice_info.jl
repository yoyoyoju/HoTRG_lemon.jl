import SpinModule: isClassical
#=
LatticeInfo(latticecode::AbstractString)
getDimension(latticeinfo::LatticeInfo)
getGeometry(latticeinfo::LatticeInfo)
getCoarserate(latticeinfo::LatticeInfo)
getQuantumOrClassical(latticeinfo::LatticeInfo)
isClassical(latticeinfo::LatticeInfo)
getDimension(latticeinfo::LatticeInfo, dimension::Int)
isTwoDimension(latticeinfo::LatticeInfo)
isSquareLattice(latticeinfo::LatticeInfo)
=#

type LatticeInfo
	quantumOrClassical::AbstractString
	dimension::Int
	geometry::AbstractString
	coarserate::Int
	legextension::Int

	function LatticeInfo(latticecode::AbstractString)
		this = new()
		initiateLattice!(latticecode, this)
		return this
	end
end

#---
# auxiliary function for constructor

function initiateLattice!(latticecode::AbstractString, latticeinfo::LatticeInfo)
	lattice = split(latticecode,"_")
	latticeinfo.quantumOrClassical = lowercase(lattice[1])
	latticeinfo.dimension = parse(Int,match(r"(?<dimension>\d+)d",lattice[2])[:dimension])
	latticeinfo.geometry = lowercase(lattice[3])
	if getGeometry(latticeinfo) == "square"
		latticeinfo.coarserate = 2
		latticeinfo.legextension = 0
	elseif getGeometry(latticeinfo) == "fractal"
		latticeinfo.legextension = 
			try
				parse(Int,lattice[4])
			catch
				1
			end
	end
	return latticeinfo
end

#---
# functions for latticeinfo
function getDimension(latticeinfo::LatticeInfo)
	return latticeinfo.dimension
end

function getGeometry(latticeinfo::LatticeInfo)
	return latticeinfo.geometry
end

function getLegextension(latticeinfo::LatticeInfo)
	return latticeinfo.legextension
end

function getCoarserate(latticeinfo::LatticeInfo)
	return latticeinfo.coarserate
end

function getQuantumOrClassical(latticeinfo::LatticeInfo)
	return latticeinfo.quantumOrClassical
end

function isClassical(latticeinfo::LatticeInfo)
	if getQuantumOrClassical(latticeinfo) == "classical"
		return true
	else
		return false
	end
end

function getDimension(latticeinfo::LatticeInfo, dimension::Int)
	if getDimension(latticeinfo) == dimension
		return true
	else
		return false
	end
end

function isTwoDimension(latticeinfo::LatticeInfo)
	return getDimension(latticeinfo, 2)
end

function isSquareLattice(latticeinfo::LatticeInfo)
	if getGeometry(latticeinfo) == "square"
		return true
	else
		return false
	end
end

function isFractalLattice(latticeinfo::LatticeInfo)
	if getGeometry(latticeinfo) == "fractal"
		return true
	else
		return false
	end
end
#---
# test function

function testlatticeinfo()
	latticecode = "quantum_2d_square"
	latticeinfo = LatticeInfo(latticecode)
	println(isTwoDimension(latticeinfo))
	println(isSquareLattice(latticeinfo))
	println(getDimension(latticeinfo,4))
end
