"""
	normalizeAndSetNorm!

# arguments:

* simulator: comparable for  
  * `Quantum2dFractalSimulator`
  * `Quantum2dFractalinititerSimulator`
* tensor::Array
* normname
"""
function normalizeAndSetNorm!{T}(simulator::Quantum2dFractalSimulator{T}, tensor::Array, normname::AbstractString)
	normedTensor, normalizationFactor = normalizeTensor(tensor)
	setNorm!(simulator, normalizationFactor, normname)
	return normedTensor, normalizationFactor
end

function normalizeAndSetNorm!{T}(simulator::Quantum2dFractalInititerSimulator{T}, tensor::Array, normname::AbstractString)
	normedTensor, normalizationFactor = normalizeTensor(tensor)
	setNorm!(simulator, normalizationFactor, normname)
	return normedTensor, normalizationFactor
end

