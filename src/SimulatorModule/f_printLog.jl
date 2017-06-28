"""
	printLog(simulator::Quantum2dFractalSimulator; printlog="none")

# option `printtlog`:  

* "mag"
* "magmute" : calculate magnetization for every renorm steps without printing
* "logNorms"
* "maxT"

"""
function printLog(simulator::Quantum2dFractalSimulator; printlog="none")
	if printlog=="mag"
		magnetization = getExpectationValue(simulator)
		println(magnetization)
	elseif printlog=="magmute"
		magnetization = getExpectationValue(simulator)
	elseif printlog=="logNorms"
		printLogNorms(simulator)
	elseif printlog=="maxTensor"
		print(maximum(abs(simulator.lattice.tensorT)))
		print("\t")
		print(maximum(abs(getTensorP(simulator.lattice,1))))
		print("\t")
		print(maximum(abs(getTensorP(simulator.lattice,2))))
		print("\t")
		print(maximum(abs(simulator.lattice.tensorQ)))
		println()
	end
end


function printLogNorms(simulator::Quantum2dFractalSimulator)
	println(simulator.logNorms)
end

###========================
###========== under this I don't need
function printCoefficientsLabel(simulator::Quantum2dFractalSimulator)
	print("count", "\t")
	for i = 1:getLengthOfNormList(simulator)
		print(getListOfNormFactors(simulator)[i],"\t")
	end
	println()
end
	 
function printCoefficients(simulator::Quantum2dFractalSimulator)
	iteration = getWholeiteration(simulator) +2 -getCount(simulator)
	lengCoef = getLengthOfNormList(simulator)
	print(iteration, "\t")
	for i = 1:lengCoef
		@printf "%.5e\t" simulator.coefficients[iteration,i]
	end
	println()
end

function printNormalizationFactor(simulator::Quantum2dFractalSimulator)
	iteration = getCount(simulator)
	lengCoef = getLengthOfNormList(simulator)
	print(iteration, "\t")
	for i = 1:lengCoef
		@printf "%.5e\t" simulator.normalizationFactor[iteration,i]
	end
	println()
end
