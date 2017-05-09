#=
getFactorWp
getTrotterParameter
getTrotterIteration
getTrotterlayers
getBeta
setTrotterparameter!
setTrotterIteration
checkInfo!

getFactorW
getMeasureOperator
isZeroTemperature
getTemperature
getExternalfield
getEnvParameters
=#

abstract QuantumSpinModel{T} <: SpinModel{T}

function getFactorWp{T}(qspin::QuantumSpinModel{T})
	return qspin.factorWp
end

# functions for check trotterinfo and spininfo
function checkInfo!{T}(spininfo::SpinInfo{T}, trotterinfo::TrotterInfo{T})
	if !isZeroTemperature(spininfo)
		temp = getTemperature(trotterinfo)
		if getTemperature(spininfo) != temp
			setTemperature!(spininfo, temp)
			@printf "adjust temperature in spininfo to %f" temp
		end
	end
end

# inherit from trotterinfo
single_args_non_preserving = [
							  :getTrotterparameter,
							  :getTrotteriteration,
							  :getTrotterlayers,
							  :getBeta
							 ]

for f in single_args_non_preserving
	eval(quote

		function $(f)(quantumspinmodel::QuantumSpinModel)
			return $(f)(quantumspinmodel.trotterinfo)
		end

	end)
end

set_single_parameter = [:setTrotterparameter!,
						:setTrotterIteration!]
for f in set_single_parameter
	eval(quote
		
	  function $(f){T}(quantumspinmodel::QuantumSpinModel{T}, parameter)
		 $(f)(quantumspinmodel.trotterinfo, parameter)
		 initialize!(quantumspinmodel)
	  end

	end)
end

