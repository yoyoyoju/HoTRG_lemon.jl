"""
	HoTRG_lemon

Parent module for:  
	SpinModule  
	LatticeModule  
	SimulatorModule  
"""
module HoTRG_lemon

using TensorOperations
using TensorMatrices_lemon

include("./SpinModule/SpinModule.jl")
include("./LatticeModule/LatticeModule.jl")
# include("./SimulatorModule/SimulatorModule.jl")

end # module
