#= trotterinfo to build quantumspinsystem
	TrotterInfo(trotterparameter, trotteriteration)
	getTrotterparameter(trotterinfo::TrotterInfo)
	getTrotteriteration(trotterinfo::TrotterInfo)
	getTrotterlayers(trotterinfo::TrotterInfo)
	getBeta(trotterinfo::TrotterInfo)
	getTemperature(trotterinfo::TrotterInfo)
	setTrotterparameter!{T}(trotterinfo::TrotterInfo, trotterparameter::T)
	setTrotterIteration!(trotterinfo::TrotterInfo, trotteriteration::Int)
	---
	iteration2layer(iteration::Int)
=#
type TrotterInfo{T}
	trotterparameter::T
	trotteriteration::Int
end

#--- 
function iteration2layer(iteration::Int)
	return ldexp(1.0, iteration)
end

#--- get functions
function getTrotterparameter(trotterinfo::TrotterInfo)
	return trotterinfo.trotterparameter
end

function getTrotteriteration(trotterinfo::TrotterInfo)
	return trotterinfo.trotteriteration
end

function getTrotterlayers(trotterinfo::TrotterInfo)
	return iteration2layer(getTrotteriteration(trotterinfo))
end

function getBeta(trotterinfo::TrotterInfo)
	return getTrotterlayers(trotterinfo) * getTrotterparameter(trotterinfo)
end

function getTemperature{T}(trotterinfo::TrotterInfo{T})
	return one(T) / getBeta(trotterinfo)
end

function setTrotterparameter!{T}(trotterinfo::TrotterInfo, trotterparameter::T)
	trotterinfo.trotterparameter = trotterparameter
end

function setTrotterIteration!(trotterinfo::TrotterInfo, trotteriteration::Int)
	trotterinfo.trotteriteration = trotteriteration
end

function testTrotterInfo()
	trotterparameter = 0.01
	trotteriteration = 10
	trotter = TrotterInfo(trotterparameter, trotteriteration)
	println(getTrotterlayers(trotter))
	println(getBeta(trotter))
	println(getTemperature(trotter))
end
