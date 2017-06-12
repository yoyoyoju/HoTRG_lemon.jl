"""
	printLog(simulator::Quantum2dFractalSimulator; printlog="none")

# option `printtlog`:  

* "none" : default - print nothing
* "coef"
* "norm"
* "label" : print the labels for coeficients
* "mag"
* "magmute" : calculate magnetization for every renorm steps without printing

"""
function printLog(simulator::Quantum2dFractalSimulator; printlog="none")
	if printlog=="coef" 
		printCoefficients(simulator)
	elseif printlog=="norm"
		printNormalizationFactor(simulator)
	elseif printlog=="label"
		printCoefficientsLabel(simulator)
	elseif printlog=="mag"
		magnetization = getExpectationValue(simulator)
		println(magnetization)
	elseif printlog=="magmute"
		magnetization = getExpectationValue(simulator)
	end
end

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
