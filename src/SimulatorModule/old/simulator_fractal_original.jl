import HoTRG_lemon.LatticeModule:
	getHausdorffDim,
	getFractalDim,
	getLegextension,
	getTensorP,
	getTensorQ,
	setTensorP!,
	setTensorQ!

FractalSimulator = Union{Classical2dFractalSimulator,Quantum2dFractalSimulator}

#
##### update the SimulatorModule
function setNorm!{T}(simulator::FractalSimulator{T}, norm::T, which::Int, iteration::Int)
	simulator.normalizationFactor[iteration, which] = norm
end

function getNorm{T}(simulator::FractalSimulator{T}, which::Int, iteration::Int)
	return simulator.normalizationFactor[iteration, which]
end

function setCoefficient!{T}(simulator::FractalSimulator{T}, coefficient::T, which::Int, iteration::Int)
	simulator.coefficients[iteration, which] = coefficient
end

function getCoefficient{T}(simulator::FractalSimulator{T}, which::Int, iteration::Int)
	if which == 0
		coef = simulator.coefficients[iteration,:]
	else 
		coef = simulator.coefficients[iteration, which]
	end
	return coef
end


# inherit from FractalLattice
single_args = [
			   :getHausdorffDim,
			   :getFractalDim,
			   :getLegextension,
			   :getTensorQ
			   ]

for f in single_args
	eval(quote

	  function $(f)(simulator::FractalSimulator)
	  return $(f)(simulator.lattice)
		end

	end)
end

getTensors = [
			 :getTensorP
			 ]

for f in getTensors
	eval(quote

	  function $(f)(simulator::FractalSimulator, which::Int = 0)
		  return $(f)(simulator.lattice, which)
	  end

	 end)
end

setTensors = [
			  :setTensorP!
			  ]
for f in setTensors
	eval(quote
	  
	  function $(f)(simulator::FractalSimulator, which::Int, tensor::Array)
	  return $(f)(simulator.lattice, which, tensor)
	  end

	 end)
end

setTensors2 = [
			  :setTensorQ!
			 ]
for f in setTensors2
	eval(quote
	  
	  function $(f)(simulator::FractalSimulator, tensor::Array)
	  return $(f)(simulator.lattice, tensor)
	  end

	 end)
end
