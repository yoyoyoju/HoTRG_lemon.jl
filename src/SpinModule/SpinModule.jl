"""
	SpinModule

Store informations about the spin model.  

# Type list

* SpinInfo 
* TrotterInfo for Quantum Spins 
* SpinModel
* ClassicalSpinModel
* IsingModel
* PottsModel
* ClockModel
* QuantumSpinModel
* QuantumIsingModel

# Method list

* Methods for SpinInfo:
  * isZeroTemperature
  * isClassical
  * getmodelname
  * getStates
  * isSymmetricFactorization
  * getTemperature
  * getExternalfield
  * getEnvParameters
  * setTemperature!
  * setExternalfield!
  * setEnvParameters!
* Methods for TrotterInfo
  * getTrotterparameter
  * getTrotteriteration
  * getTrotterlayers
  * getBeta
  * setTrotterparameter!
  * setTrotteriteration!
  * iteration2layer
* Methods for SpinModel
  * buildSpinSystem
  * getMeasureOperator
  * getFactorW
  * isPottsModel
  * getHamiltonian
* Methods for IsingModel
  * initialize!
* Methods for QuantumSpinModel
  * checkInfo!
* Methods for QuantumIsingModel
  * getFactorWp


# Test list

* testSpinInfo
* testTrotterInfo
* testSpinModel
* testIsingModel
* testPottsModel
* testClockModel
* testQuantumIsingModel
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
testTrotterInfo,
	## spin_model.jl
SpinModel,
buildSpinSystem,
getMeasureOperator,
getFactorW,
isPottsModel,
getHamiltonian,
testSpinModel,
	## spin_classical.jl
ClassicalSpinModel,
getBeta,
	## spin_classical_ising.jl
IsingModel,
initialize!,
testIsingModel,
	## spin_classical_potts.jl
PottsModel,
testPottsModel,
	## spin_classical_clock.jl
ClockModel,
testClockModel,
	## spin_quantum.jl
QuantumSpinModel,
checkInfo!,
	## spin_quantum_ising.jl
QuantumIsingModel,
getFactorWp,
testQuantumIsingModel



include("spin_info.jl")
include("spin_trotter.jl")
include("spin_model.jl")
include("spin_classical.jl")
include("spin_classical_ising.jl")
include("spin_classical_potts.jl")
include("spin_classical_clock.jl")
include("spin_quantum.jl")
include("spin_quantum_ising.jl")

end
