abstract ClassicalSpinModel{T} <: SpinModel{T}

function getBeta{T}(classicalspinmodel::ClassicalSpinModel{T})
	return one(T)/getTemperature(classicalspinmodel)
end
