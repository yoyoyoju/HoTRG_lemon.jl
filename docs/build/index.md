
<a id='HoTRG_lemon.jl-Documentation-1'></a>

# HoTRG_lemon.jl Documentation

- [HoTRG_lemon.jl Documentation](index.md#HoTRG_lemon.jl-Documentation-1)
    - [SubModule](index.md#SubModule-1)
    - [HoTRG_lemon.SpinModule](index.md#HoTRG_lemon.SpinModule-1)
    - [HoTRG_lemon.LatticeModule](index.md#HoTRG_lemon.LatticeModule-1)
    - [HoTRG_lemon.SimulaterModule](index.md#HoTRG_lemon.SimulaterModule-1)
    - [Index](index.md#Index-1)


<a id='SubModule-1'></a>

## SubModule

<a id='HoTRG_lemon.SpinModule' href='#HoTRG_lemon.SpinModule'>#</a>
**`HoTRG_lemon.SpinModule`** &mdash; *Module*.



```
SpinModule
```

Store informations about the spin model.  

**Type list**

  * SpinInfo
  * TrotterInfo for Quantum Spins
  * SpinModel
  * ClassicalSpinModel
  * IsingModel
  * PottsModel
  * ClockModel
  * QuantumSpinModel
  * QuantumIsingModel

**Method list**

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

**Test list**

  * testSpinInfo
  * testTrotterInfo
  * testSpinModel
  * testIsingModel
  * testPottsModel
  * testClockModel
  * testQuantumIsingModel


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SpinModule/SpinModule.jl#L1-L63' class='documenter-source'>source</a><br>

<a id='HoTRG_lemon.LatticeModule' href='#HoTRG_lemon.LatticeModule'>#</a>
**`HoTRG_lemon.LatticeModule`** &mdash; *Module*.



```
LatticeModule
```

Store information about the Lattice  

**Type list**

  * LatticeInfo
  * Latttice
  * ClassicalLattice,
  * Classical2dLattice,
  * Classical2dSquareLattice,
  * Classical2dFractalLattice,
  * QuantumLattice,
  * Quantum2dLattice,
  * Quantum2dSquareLattice,
  * Classical3dLattice,
  * Classical3dSquareLattice,
  * Quantum2dFractalLattice,
  * FractalLattice,

**Method list**

  * getDimension
  * getGeometry
  * getCoarserate
  * getLegextension
  * getQuantumOrClassical
  * isClassical,
  * isTwoDimension,
  * isSquareLattice,
  * isFractalLattice,
  * buildLattice,
  * initialize!,
  * isZeroTemperature,
  * isClassical,
  * getModelname,
  * getStates,
  * isSymmetricFactorization,
  * isPottsModel,
  * getHamiltonian,
  * getTemperature,
  * getExternalfield,
  * getEnvParameters,
  * setTemperature!,
  * setExternalfield!,
  * setEnvParameters!,
  * initialize!,
  * getTensorT,
  * getFactorW,
  * getFactorWp,
  * setTensorT!,
  * makeTensorT,
  * makeFactorWp,
  * makeTensorQ,
  * buildClassicalLattice,
  * getSpaceDimension,
  * buildQuantumLattice,
  * getTrotterparameter,
  * getTrotteriteration,
  * getTrotterlayers,
  * getBeta,
  * setTrotterparameter!,
  * setTrotterIteration!,
  * getTensorP,
  * getTensorQ,
  * getLegextension,
  * getHausdorffDim,
  * getFractalDim,
  * setTensorP!,
  * setTensorQ!

**Test list**

  * testlatticeinfo,
  * testClassical2dSquareLattice,
  * testClassical2dFractalLattice,
  * testQuantum2dSquareLattice,
  * testClassical3dSquareLattice,
  * testQuantum2dFractalLattice,


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./LatticeModule/LatticeModule.jl#L1-L82' class='documenter-source'>source</a><br>

<a id='HoTRG_lemon.SimulatorModule' href='#HoTRG_lemon.SimulatorModule'>#</a>
**`HoTRG_lemon.SimulatorModule`** &mdash; *Module*.



```
SimulatorModule
```

Simulator for lattice.  

**modifying _move this when finished_**

  * simulator_quantum_2d_fractal_initialiteration.jl   for adding additional iterations for the trotter layer

      * getSingularValues

**Type list**

  * Simulator,
  * ClassicalSimulator,
  * Classical2dSimulator,
  * Classical3dSimulator,
  * Classical2dSquareSimulator,
  * QuantumSimulator,
  * Quantum2dSimulator,
  * Quantum2dSquareSimulator,
  * Classical3dSquareSimulator,
  * FractalSimulator,
  * Classical2dFractalSimulator,
  * Quantum2dFractalSimulator,
  * Quantum2dFractalInititerSimulator <- working

**Method list**

  * buildSimulator, #
  * getDimM,
  * getExpectationValue,
  * getFreeEnergy,
  * getWholeiteration,
  * getNormalizationfactors,
  * getData4Energy,
  * getCount,
  * getNumberOfSites,
  * countUp!,
  * countDown!,
  * isDone,
  * setNormalizationfactor!,
  * normalizeTensor,
  * writeVector,
  * isZeroTemperature,
  * isClassical,
  * getModelname,
  * getStates,
  * isSymmetricFactorization,
  * isPottsModel,
  * getHamiltonian,
  * getTemperature,
  * getExternalfield,
  * getEnvParameters,
  * getCoareserate,
  * getTensorT,
  * getTensorW,
  * getMeasureOperator,
  * setTemperature!,
  * setExternalfield!,
  * setTensorT!,
  * setEnvParameters!,
  * initializeCount!,
  * getFirstTerm,
  * renormalize!,
  * getTrotterCount,
  * getSpaceCount,
  * getTrotterparameter,
  * getTrotteriteration,
  * getTrotterlayers,
  * getBeta, # changed to use trottercount
  * setTrotterparameter!,
  * setTrotterIteration!,
  * renormalize,
  * getNewTensorT_2dQ,
  * getTensorU,
  * getTensorV,
  * getTenmatMMd,
  * renormalizeX!,
  * renormalizeZ!,
  * renormalizeY!,
  * truncMatrixU,
  * matU2tenU,
  * simulatorTemperature,
  * simulatorQuantum,
  * getHausdorffDim,
  * getFractalDim,
  * getLegextension,
  * getTensorP,
  * getTensorQ,
  * getCoefficient,
  * setTensorP!,
  * setTensorQ!,
  * normalizeTensor!,
  * setNorm!,
  * constructHalf,
  * updateLocalTensors!,
  * debug_updateLocalTensors!,
  * getNewLegTensor,
  * getNewCaretTensor,
  * # working_simulator_q2f_re.jl
  * renormalizeSpace!,
  * renormalizeTrotter!,
  * getTensorUy,
  * # new version of
  * # simulator_quantum_2d_square.jl
  * updateCoefficient!,
  * setCoefficient!,
  * getCoefficient,
  * # for debug:
  * calculateCoreTensors
  * getInititeration(simulator::Quantum2dFractalinititerSimulator)

**Test list**

  * testClassical2dSquareSimulator,
  * testQuantum2dSquareSimulator,
  * testSimulateTemp,
  * testClassical3dSquareSimulator,
  * testClassical2dFractalSimulator,
  * testQuantum2dFractalSimulator,


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SimulatorModule/SimulatorModule.jl#L1-L119' class='documenter-source'>source</a><br>




---


<a id='HoTRG_lemon.SpinModule-1'></a>

## HoTRG_lemon.SpinModule


<a id='Types-1'></a>

### Types

<a id='HoTRG_lemon.SpinModule.SpinInfo' href='#HoTRG_lemon.SpinModule.SpinInfo'>#</a>
**`HoTRG_lemon.SpinModule.SpinInfo`** &mdash; *Type*.



```
SpinInfo{T}(modelcode::AbstractString, factorization::AbstractString, externalfield::T, temperature::T)
```

Store informations about the spin model.  

**Arguments**

  * `modelcode::AbstractString`: `[quantum,classical]_[modelname]_[numberOfState]`
  * `factorization::AbstractString`: `sym` or `asym` (default: `asym`)
  * `temperature::T`: (default: one(T))
  * `externalfield::T`: (default: one(T))

**Examples**

```julia
modelcode = "quantum_ising"
factorization = "sym"
externalfield = 2.0
temperature = 1.5
spininfo = HoTRG_lemon.SpinModule.SpinInfo(modelcode, factorization, externalfield, temperature)
spininfo = HoTRG_lemon.SpinModule.SpinInfo(modelcode, factorization, externalfield)
spininfo = HoTRG_lemon.SpinModule.SpinInfo(modelcode, externalfield, temperature)
spininfo = HoTRG_lemon.SpinModule.SpinInfo(modelcode, externalfield)
spininfo = HoTRG_lemon.SpinModule.SpinInfo(modelcode, factorization)
spininfo = HoTRG_lemon.SpinModule.SpinInfo(modelcode)
```

```julia
modelcode = "quantum_ising"
factorization = "sym"
externalfield = 2.0
temperature = 1.5
spininfo = HoTRG_lemon.SpinModule.SpinInfo(modelcode, factorization, externalfield, temperature)

# output

HoTRG_lemon.SpinModule.SpinInfo{Float64}("quantum","ising",2,"sym",1.5,2.0)
```


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SpinModule/spin_info.jl#L17-L56' class='documenter-source'>source</a><br>


<a id='Methods:-SpinModule-1'></a>

### Methods: SpinModule


  * Methods for SpinModule:

      * isZeroTemperature,
      * isClassical,
      * getModelname,
      * getStates,
      * isSymmetricFactorization,
      * getTemperature,
      * getExternalfield,
      * getEnvParameters,
      * setTemperature!,
      * setExternalfield!,
      * setEnvParameters!,
      * testSpinInfo,

<a id='HoTRG_lemon.SpinModule.isZeroTemperature' href='#HoTRG_lemon.SpinModule.isZeroTemperature'>#</a>
**`HoTRG_lemon.SpinModule.isZeroTemperature`** &mdash; *Function*.



```
isZeroTemperature(spininfo::SpinInfo)
```

Return true when  the system is at the Zero Temperature.  

```jlcon
julia> HoTRG_lemon.SpinModule.isZeroTemperature(spininfo)
false
```


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SpinModule/spin_info.jl#L211-L220' class='documenter-source'>source</a><br>

<a id='HoTRG_lemon.SpinModule.isClassical' href='#HoTRG_lemon.SpinModule.isClassical'>#</a>
**`HoTRG_lemon.SpinModule.isClassical`** &mdash; *Function*.



```
isClassical(spininfo)
```

Return true when the spin is classical, false for quantum.  

```jlcon
julia> HoTRG_lemon.SpinModule.isClassical(spininfo)
false
```


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SpinModule/spin_info.jl#L139-L148' class='documenter-source'>source</a><br>

<a id='HoTRG_lemon.SpinModule.getModelname' href='#HoTRG_lemon.SpinModule.getModelname'>#</a>
**`HoTRG_lemon.SpinModule.getModelname`** &mdash; *Function*.



```
getModelname(spininfo)
```

Return the model name.  

```jlcon
julia> HoTRG_lemon.SpinModule.getModelname(spininfo)
"ising"
```


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SpinModule/spin_info.jl#L125-L134' class='documenter-source'>source</a><br>

<a id='HoTRG_lemon.SpinModule.getStates' href='#HoTRG_lemon.SpinModule.getStates'>#</a>
**`HoTRG_lemon.SpinModule.getStates`** &mdash; *Function*.



```
getStates(spininfo)
```

Return the number of states.   

```jlcon
julia> HoTRG_lemon.SpinModule.getStates(spininfo)
2
```


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SpinModule/spin_info.jl#L157-L166' class='documenter-source'>source</a><br>

<a id='HoTRG_lemon.SpinModule.isSymmetricFactorization' href='#HoTRG_lemon.SpinModule.isSymmetricFactorization'>#</a>
**`HoTRG_lemon.SpinModule.isSymmetricFactorization`** &mdash; *Function*.



```
isSymmetricFactorization(spininfo)
```

Return `true` for symmetric factorization  

```jlcon
julia> HoTRG_lemon.SpinModule.isSymmetricFactorization(spininfo)
true
```


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SpinModule/spin_info.jl#L171-L180' class='documenter-source'>source</a><br>

<a id='HoTRG_lemon.SpinModule.getTemperature' href='#HoTRG_lemon.SpinModule.getTemperature'>#</a>
**`HoTRG_lemon.SpinModule.getTemperature`** &mdash; *Function*.



```
getTemperature(spininfo)
```

Return the temperature of the spin system.  

```jlcon
julia> HoTRG_lemon.SpinModule.getTemperature(spininfo)
1.5
```


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SpinModule/spin_info.jl#L189-L198' class='documenter-source'>source</a><br>

<a id='HoTRG_lemon.SpinModule.getExternalfield' href='#HoTRG_lemon.SpinModule.getExternalfield'>#</a>
**`HoTRG_lemon.SpinModule.getExternalfield`** &mdash; *Function*.



```
getExternalfield(spininfo)
```

Return external field.  

```jlcon
julia> HoTRG_lemon.SpinModule.getExternalfield(spininfo)
2.0
```


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SpinModule/spin_info.jl#L225-L234' class='documenter-source'>source</a><br>

<a id='HoTRG_lemon.SpinModule.getEnvParameters' href='#HoTRG_lemon.SpinModule.getEnvParameters'>#</a>
**`HoTRG_lemon.SpinModule.getEnvParameters`** &mdash; *Function*.



```
getEnvParameters(spininfo)
```

Return temperature and external field.  

```jlcon
julia> HoTRG_lemon.SpinModule.getEnvParameters(spininfo)
(1.5,2.0)
```


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SpinModule/spin_info.jl#L239-L248' class='documenter-source'>source</a><br>

<a id='HoTRG_lemon.SpinModule.setTemperature!' href='#HoTRG_lemon.SpinModule.setTemperature!'>#</a>
**`HoTRG_lemon.SpinModule.setTemperature!`** &mdash; *Function*.



```
setTemperature!(spininfo, temperature)
```

Set temperature for spininfo to the input temperature.  

```jlcon
julia> HoTRG_lemon.SpinModule.setTemperature!(spininfo, 3.0);

julia> HoTRG_lemon.SpinModule.getTemperature(spininfo)
3.0
```


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SpinModule/spin_info.jl#L253-L264' class='documenter-source'>source</a><br>

<a id='HoTRG_lemon.SpinModule.setExternalfield!' href='#HoTRG_lemon.SpinModule.setExternalfield!'>#</a>
**`HoTRG_lemon.SpinModule.setExternalfield!`** &mdash; *Function*.



```
setExternalfield!(spininfo, externalfield)
```

Set spininfo's external field  into the input.  

```jlcon
julia> HoTRG_lemon.SpinModule.setExternalfield!(spininfo, 4.0);

julia> HoTRG_lemon.SpinModule.getExternalfield(spininfo)
4.0
```


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SpinModule/spin_info.jl#L269-L280' class='documenter-source'>source</a><br>

<a id='HoTRG_lemon.SpinModule.setEnvParameters!' href='#HoTRG_lemon.SpinModule.setEnvParameters!'>#</a>
**`HoTRG_lemon.SpinModule.setEnvParameters!`** &mdash; *Function*.



```
setEnvParameters!(spininfo, temperature, externalfield)
```

Set spininfo's temperature and external field.  

```jlcon
julia> HoTRG_lemon.SpinModule.setEnvParameters!(spininfo, 1.2, 3.4);

julia> HoTRG_lemon.SpinModule.getEnvParameters(spininfo)
(1.2,3.4)
```


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SpinModule/spin_info.jl#L285-L296' class='documenter-source'>source</a><br>

<a id='HoTRG_lemon.SpinModule.testSpinInfo' href='#HoTRG_lemon.SpinModule.testSpinInfo'>#</a>
**`HoTRG_lemon.SpinModule.testSpinInfo`** &mdash; *Function*.



```
testSpinInfo()
```

Test SpinInfo for quantum ising model.  

`testSpininfo()`


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SpinModule/spin_info.jl#L305-L311' class='documenter-source'>source</a><br>


---


<a id='HoTRG_lemon.LatticeModule-1'></a>

## HoTRG_lemon.LatticeModule


<a id='Types-2'></a>

### Types

<a id='HoTRG_lemon.LatticeModule.Quantum2dFractalLattice' href='#HoTRG_lemon.LatticeModule.Quantum2dFractalLattice'>#</a>
**`HoTRG_lemon.LatticeModule.Quantum2dFractalLattice`** &mdash; *Type*.



```
Quantum2dFractalLattice
```

**arguments**

  * `spinmodel::QuantumSpinModel`
  * `legextension::Int`   default value is one. set zero for the normal square lattice.


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./LatticeModule/lattice_quantum_2d_fractal.jl#L4-L12' class='documenter-source'>source</a><br>


<a id='Methods:-1'></a>

### Methods:


---


<a id='HoTRG_lemon.SimulaterModule-1'></a>

## HoTRG_lemon.SimulaterModule


<a id='Types-3'></a>

### Types


<a id='Methods:-SimulatorModuel-1'></a>

### Methods: SimulatorModuel


  * Methods to build a Simulator:

      * `buildSimulator`

<a id='HoTRG_lemon.SimulatorModule.buildSimulator' href='#HoTRG_lemon.SimulatorModule.buildSimulator'>#</a>
**`HoTRG_lemon.SimulatorModule.buildSimulator`** &mdash; *Function*.



```
buildSimulator
```

Build Simulator from `Lattice`.

**arguments**

  * `lattice`: 

      * `Classical2dSquareLattice` with  `dimM`, `wholeiteration`
      * `Classical2dFractalLattice` with `dimM`, `wholeiteration`
      * `Classicl3dSquareLattice` with `dimM`, `wholeiteration`
      * `Quantum2dSquareLattice` with `dimM`
      * `Quantum2dFractalLattice` with `dimM`
  * `dimM::Int`: the maximum tensor size
  * `wholeiteration::Int`: For `ClassicalLattice`. How many times to  iterate.

For `QuantumLattice`, it is determined by `trotteriteration`.


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SimulatorModule/simulator.jl#L35-L50' class='documenter-source'>source</a><br>


  * Methods to run a simulator:

      * simulatorQuantum

<a id='HoTRG_lemon.SimulatorModule.simulatorQuantum' href='#HoTRG_lemon.SimulatorModule.simulatorQuantum'>#</a>
**`HoTRG_lemon.SimulatorModule.simulatorQuantum`** &mdash; *Function*.



```
simulatorQuantum{T}(fieldrange::LinSpace{T}, simulator::QuantumSimulator{T}; verbose = true, writefile = true, filename = "Data.txt")
```

Get the results from simulator quantum spin system.  

**arguments**

  * `fieldrange::LinSpace`: the range for the external field to be applied.
  * `simulator::QuantumSimulator`
  * `verbose = true`: print the results
  * `writefile = true`: write the  result data into a file
  * `filename = "Data.txt"`: name of the file for the results


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SimulatorModule/simulator_quantum_data.jl#L1-L13' class='documenter-source'>source</a><br>


```
simulatorQuantum{T}(externalfield::T, simulator::QuantumSimulator{T}; verbose = true, writefile = true, filename = "Data_.txt")
```

Simulate for some external field. Append onto "Data_.txt" file.


<a target='_blank' href='https://github.com/yoyoyoju/HoTRG_lemon.jl/tree/36d00ea8947c8ce43b5c897b34d1e43275131c71/src/./SimulatorModule/simulator_quantum_data.jl#L31-L35' class='documenter-source'>source</a><br>




<a id='Index-1'></a>

## Index

- [`HoTRG_lemon.LatticeModule`](index.md#HoTRG_lemon.LatticeModule)
- [`HoTRG_lemon.SimulatorModule`](index.md#HoTRG_lemon.SimulatorModule)
- [`HoTRG_lemon.SpinModule`](index.md#HoTRG_lemon.SpinModule)
- [`HoTRG_lemon.LatticeModule.Quantum2dFractalLattice`](index.md#HoTRG_lemon.LatticeModule.Quantum2dFractalLattice)
- [`HoTRG_lemon.SpinModule.SpinInfo`](index.md#HoTRG_lemon.SpinModule.SpinInfo)
- [`HoTRG_lemon.SimulatorModule.buildSimulator`](index.md#HoTRG_lemon.SimulatorModule.buildSimulator)
- [`HoTRG_lemon.SimulatorModule.simulatorQuantum`](index.md#HoTRG_lemon.SimulatorModule.simulatorQuantum)
- [`HoTRG_lemon.SpinModule.getEnvParameters`](index.md#HoTRG_lemon.SpinModule.getEnvParameters)
- [`HoTRG_lemon.SpinModule.getExternalfield`](index.md#HoTRG_lemon.SpinModule.getExternalfield)
- [`HoTRG_lemon.SpinModule.getModelname`](index.md#HoTRG_lemon.SpinModule.getModelname)
- [`HoTRG_lemon.SpinModule.getStates`](index.md#HoTRG_lemon.SpinModule.getStates)
- [`HoTRG_lemon.SpinModule.getTemperature`](index.md#HoTRG_lemon.SpinModule.getTemperature)
- [`HoTRG_lemon.SpinModule.isClassical`](index.md#HoTRG_lemon.SpinModule.isClassical)
- [`HoTRG_lemon.SpinModule.isSymmetricFactorization`](index.md#HoTRG_lemon.SpinModule.isSymmetricFactorization)
- [`HoTRG_lemon.SpinModule.isZeroTemperature`](index.md#HoTRG_lemon.SpinModule.isZeroTemperature)
- [`HoTRG_lemon.SpinModule.setEnvParameters!`](index.md#HoTRG_lemon.SpinModule.setEnvParameters!)
- [`HoTRG_lemon.SpinModule.setExternalfield!`](index.md#HoTRG_lemon.SpinModule.setExternalfield!)
- [`HoTRG_lemon.SpinModule.setTemperature!`](index.md#HoTRG_lemon.SpinModule.setTemperature!)
- [`HoTRG_lemon.SpinModule.testSpinInfo`](index.md#HoTRG_lemon.SpinModule.testSpinInfo)

