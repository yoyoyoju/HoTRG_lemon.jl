# use functions from simulator_quantum_2d_square_renormalize.jl :
#	 renormalize

function renormalizeZ!{T}(simulator::Classical3dSquareSimulator{T}; whichIsTensorT::Int = 1)
	tensorT1, tensorT2 = getTensorT(simulator, whichIsTensorT)
	newTensorT, newTensorTtilde, normalizationFactor = renormalize(tensorT1, tensorT2, getDimM(simulator); whichIsTensorT = whichIsTensorT) 

	setTensorT!(simulator.lattice, newTensorT)
	setTensorT!(simulator.lattice, newTensorTtilde; tilde = true)
	setNormalizationfactor!(simulator, normalizationFactor)
end

function renormalizeX!{T}(simulator::Classical3dSquareSimulator{T}; whichIsTensorT::Int = 1)
	tensorT1, tensorT2 = getTensorT(simulator, whichIsTensorT)
	newTensorT, newTensorTtilde, normalizationFactor = renormalize(permutedims(tensorT1,[3,4,5,6,1,2]), permutedims(tensorT2,[3,4,5,6,1,2]), getDimM(simulator); whichIsTensorT = whichIsTensorT) 

	setTensorT!(simulator.lattice, permutedims(newTensorT,[5,6,1,2,3,4]))
	setTensorT!(simulator.lattice, permutedims(newTensorTtilde,[5,6,1,2,3,4]); tilde = true)
	setNormalizationfactor!(simulator, normalizationFactor)
end

function renormalizeY!{T}(simulator::Classical3dSquareSimulator{T}; whichIsTensorT::Int = 1)
	tensorT1, tensorT2 = getTensorT(simulator, whichIsTensorT)
	newTensorT, newTensorTtilde, normalizationFactor = renormalize(permutedims(tensorT1,[5,6,1,2,3,4]), permutedims(tensorT2,[5,6,1,2,3,4]), getDimM(simulator); whichIsTensorT = whichIsTensorT) 

	setTensorT!(simulator.lattice, permutedims(newTensorT,[3,4,5,6,1,2]))
	setTensorT!(simulator.lattice, permutedims(newTensorTtilde,[3,4,5,6,1,2]); tilde = true)
	setNormalizationfactor!(simulator, normalizationFactor)
end
