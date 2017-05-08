"""
	SpinModule

Store informations about the spin model.  
"""
module SpinModule

export 
## spin_info.jl
SpinInfo,
isZeroTemperature, 
isClassical,
getModelname,
getStates,
isSymmetricFactorization,
getTemperature,
getExternalfield,
getEnvParameters,
setTemperature!,
setExternalfield!,
setEnvParameters!,
testSpinInfo,
## spin_trotter.jl
TrotterInfo,
getTrotterparameter,
getTrotteriteration,
getTrotterlayers,
getBeta,
setTrotterparameter!,
setTrotterIteration!,
iteration2layer,
testTrotterInfo



include("spin_info.jl")
include("spin_trotter.jl")

end
