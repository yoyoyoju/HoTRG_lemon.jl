# HoTRG_lemon.jl Documentation

```@contents
```

## SubModule

```@docs
HoTRG_lemon.SpinModule
```
* add:
  * HoTRG_lemon.LatticeModule  
  * HoTRG_lemon.SimulatorModule  

```@meta
DocTestSetup = quote
	using HoTRG_lemon
end
```

--------------

## HoTRG_lemon.SpinModule

### Types

```@docs
HoTRG_lemon.SpinModule.SpinInfo
```

### Methos: SpinModule

* Methos for SpinModule:
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

```@docs
HoTRG_lemon.SpinModule.isZeroTemperature
HoTRG_lemon.SpinModule.isClassical
HoTRG_lemon.SpinModule.getModelname
HoTRG_lemon.SpinModule.getStates
HoTRG_lemon.SpinModule.isSymmetricFactorization
HoTRG_lemon.SpinModule.getTemperature
HoTRG_lemon.SpinModule.getExternalfield
HoTRG_lemon.SpinModule.getEnvParameters
HoTRG_lemon.SpinModule.setTemperature!
HoTRG_lemon.SpinModule.setExternalfield!
HoTRG_lemon.SpinModule.setEnvParameters!
HoTRG_lemon.SpinModule.testSpinInfo
```

```@meta
DocTestSetup = nothing
```

--------------

## HoTRG_lemon.LatticeModule

--------------

## HoTRG_lemon.SimulaterModule

### Types


### Methos: SimulatorModuel

* Methods to build a Simulator:
  * `buildSimulator`

```@docs
HoTRG_lemon.SimulatorModule.buildSimulator
```

* Methods to run a simulator:
  * simulatorQuantum

```@docs
HoTRG_lemon.SimulatorModule.simulatorQuantum
```

## Index

```@index
```
