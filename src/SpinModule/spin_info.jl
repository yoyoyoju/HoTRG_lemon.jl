#= modelcode = "quantum_ising_2" so on...
SpinInfo(modelcode, factorization, externalfield, temperature)
isZeroTemperature(spininfo) 
isClassical(spininfo)
getModelname(spininfo)
getStates(spininfo)
isSymmetricFactorization(spininfo)
getTemperature(spininfo)
getExternalfield(spininfo)
getEnvParameters(spininfo)
setTemperature!(spininfo, temperature)
setExternalfield!(spininfo, externalfield)
setEnvParameters!(spininfo, temperature, externalfield)
testSpinInfo()
=#

"""
	SpinInfo{T}(modelcode::AbstractString, factorization::AbstractString, externalfield::T, temperature::T)

Store informations about the spin model.  

# Arguments

* `modelcode::AbstractString`: `[quantum,classical]_[modelname]_[numberOfState]`  
* `factorization::AbstractString`: `sym` or `asym` (default: `asym`)  
* `temperature::T`: (default: one(T))  
* `externalfield::T`: (default: one(T))  

# Examples

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

```jldoctest spininfo
modelcode = "quantum_ising"
factorization = "sym"
externalfield = 2.0
temperature = 1.5
spininfo = HoTRG_lemon.SpinModule.SpinInfo(modelcode, factorization, externalfield, temperature)

# output

HoTRG_lemon.SpinModule.SpinInfo{Float64}("quantum","ising",2,"sym",1.5,2.0)
```

"""
type SpinInfo{T}
	quantumOrClassical::AbstractString
	modelname::AbstractString
	numberOfState::Int
	factorization::AbstractString

	temperature::T
	externalfield::T

	function SpinInfo{T}(modelcode::AbstractString, factorization::AbstractString, externalfield::T, temperature::T)
		this = new{T}()
		this.quantumOrClassical, this.modelname, this.numberOfState = getInfoFromModelcode(modelcode)
		this.factorization = checkFactorization(factorization)
		this.externalfield = externalfield
		this.temperature = temperature
		return this
	end

end

SpinInfo{T}(modelcode::AbstractString, factorization::AbstractString, externalfield::T, temperature::T) =
	SpinInfo{T}(modelcode, factorization, externalfield, temperature)
SpinInfo{T}(modelcode::AbstractString, factorization::AbstractString, externalfield::T) =
	SpinInfo{T}(modelcode, factorization, externalfield, one(T))
SpinInfo{T}(modelcode::AbstractString, externalfield::T, temperature::T) =
	SpinInfo{T}(modelcode, "asym", externalfield, temperature)
SpinInfo{T}(modelcode::AbstractString, externalfield::T) =
	SpinInfo{T}(modelcode, "asym", externalfield, one(T))
SpinInfo(modelcode::AbstractString, factorization::AbstractString) =
	SpinInfo{Float64}(modelcode, factorization, one(Float64), one(Float64))
SpinInfo(modelcode::AbstractString) =
	SpinInfo{Float64}(modelcode, "asym", one(Float64), one(Float64))

#---
# checking for initialize SpinInfo type

function getInfoFromModelcode(modelcode::AbstractString)
	model = split(modelcode,"_")
	quantumOrClassical = checkQuantumOrClassical(model[1])
	modelname = lowercase(model[2])
	numberOfState = try
			parse(Int, model[3])
		catch
			2
		end
	return quantumOrClassical, modelname, numberOfState
end

function checkFactorization(factorization::AbstractString)
	factorization = lowercase(factorization)
	if !(factorization in ("sym", "asym"))
		println("warning: factorization should be either 'sym' or 'asym'. now factorization set to be 'asym'.")
		factorization = "asym"
	end
	return factorization
end

function checkQuantumOrClassical(QOC::AbstractString)
	QOC = lowercase(QOC)
	if !(QOC in ("quantum","classical"))
		error("should be quantum or classical")
	end
	return QOC
end

#---
# functions for SpinInfo type

"""
	getModelname(spininfo)

Return the model name.  

```jldoctest spininfo
julia> HoTRG_lemon.SpinModule.getModelname(spininfo)
"ising"
```
"""
function getModelname(spininfo::SpinInfo)
	return spininfo.modelname
end

"""
	isClassical(spininfo)

Return true when the spin is classical, false for quantum.  

```jldoctest spininfo
julia> HoTRG_lemon.SpinModule.isClassical(spininfo)
false
```
"""
function isClassical(spininfo::SpinInfo)
	if spininfo.quantumOrClassical == "classical"
		return true
	else
		return false
	end
end

"""
	getStates(spininfo)

Return the number of states.   

```jldoctest spininfo
julia> HoTRG_lemon.SpinModule.getStates(spininfo)
2
```
"""
function getStates(spininfo::SpinInfo)
	return spininfo.numberOfState
end

"""
	isSymmetricFactorization(spininfo)

Return `true` for symmetric factorization  

```jldoctest spininfo
julia> HoTRG_lemon.SpinModule.isSymmetricFactorization(spininfo)
true
```
"""
function isSymmetricFactorization(spininfo::SpinInfo)
	if spininfo.factorization == "sym"
		return true
	else
		return false
	end
end

"""
	getTemperature(spininfo)

Return the temperature of the spin system.  

```jldoctest spininfo
julia> HoTRG_lemon.SpinModule.getTemperature(spininfo)
1.5
```
"""
function getTemperature(spininfo::SpinInfo)
	return spininfo.temperature
end

function isZeroTemperatuer{T}(temperature::T)
	if temperature == zero(T)
		return true
	else
		return false
	end
end

"""
	isZeroTemperature(spininfo::SpinInfo)

Return true when  the system is at the Zero Temperature.  

```jldoctest spininfo
julia> HoTRG_lemon.SpinModule.isZeroTemperature(spininfo)
false
```
"""
function isZeroTemperature{T}(spininfo::SpinInfo{T})
	return isZeroTemperatuer(getTemperature(spininfo))
end

"""
	getExternalfield(spininfo)

Return external field.  

```jldoctest spininfo
julia> HoTRG_lemon.SpinModule.getExternalfield(spininfo)
2.0
```
"""
function getExternalfield(spininfo::SpinInfo)
	return spininfo.externalfield
end

"""
	getEnvParameters(spininfo)

Return temperature and external field.  

```jldoctest spininfo
julia> HoTRG_lemon.SpinModule.getEnvParameters(spininfo)
(1.5,2.0)
```
"""
function getEnvParameters(spininfo::SpinInfo)
	return spininfo.temperature, spininfo.externalfield
end

"""
	setTemperature!(spininfo, temperature)

Set temperature for spininfo to the input temperature.  

```jldoctest spininfo
julia> HoTRG_lemon.SpinModule.setTemperature!(spininfo, 3.0);

julia> HoTRG_lemon.SpinModule.getTemperature(spininfo)
3.0
```
"""
function setTemperature!{T}(spininfo::SpinInfo{T}, temperature::T)
	spininfo.temperature = temperature
end

"""
	setExternalfield!(spininfo, externalfield)

Set spininfo's external field  into the input.  

```jldoctest spininfo
julia> HoTRG_lemon.SpinModule.setExternalfield!(spininfo, 4.0);

julia> HoTRG_lemon.SpinModule.getExternalfield(spininfo)
4.0
```
"""
function setExternalfield!{T}(spininfo::SpinInfo{T}, externalfield::T)
	spininfo.externalfield = externalfield
end

"""
	setEnvParameters!(spininfo, temperature, externalfield)

Set spininfo's temperature and external field.  

```jldoctest spininfo
julia> HoTRG_lemon.SpinModule.setEnvParameters!(spininfo, 1.2, 3.4);

julia> HoTRG_lemon.SpinModule.getEnvParameters(spininfo)
(1.2,3.4)
```
"""
function setEnvParameters!{T}(spininfo::SpinInfo{T}, temperature::T, externalfield::T)
	spininfo.temperature = temperature
	spininfo.externalfield = externalfield
end

#---
# test to make a example SpinInfo instatce

"""
	testSpinInfo()

Test SpinInfo for quantum ising model.  

`testSpininfo()`
"""
function testSpinInfo()
	modelcode = "quantum_ising"
	factorization = "sym"
	externalfield = 2.0
	temperature = 1.5
	spininfo = SpinInfo(modelcode, factorization, externalfield, temperature)
	return spininfo
end


