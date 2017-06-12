"""
	setNorm!{T}(simulator::Quantum2dFractalSimulator{T}, norm::T, which::Int)
	setNorm!{T}(simulator::Quantum2dFractalSimulator{T}, norm::T, normname::AbstractString)
set the given normalization factor to the normalizationFactor Array
to the current iteration and given index information cell.

ref: `simulator_fractal.jl`
"""
function setNorm!{T}(simulator::Quantum2dFractalSimulator{T}, norm::T, which::Int)
	iteration = getCount(simulator)
	setNorm!(simulator, norm, which, iteration)
end

function setNorm!{T}(simulator::Quantum2dFractalSimulator{T}, norm::T, normname::AbstractString)
	setNorm!(simulator, norm, getIndexOf(simulator, normname))
end

