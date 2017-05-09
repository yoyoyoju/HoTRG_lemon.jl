function simulatorTemperature{T}(temperaturerange::LinSpace{T}, simulator::Simulator{T}; verbose = true, writefile = true, filename= "Data.txt")
	NumberOfTemperatures = Int(temperaturerange.len)
	freeenergies = Array{T}(NumberOfTemperatures)
	magnetizations = Array{T}(NumberOfTemperatures)
	
	writefile && open(filename, "w") do f; write(f, "temperature \t free energy \t magnetization \n")
		for i = 1:NumberOfTemperatures
			freeenergies[i], magnetizations[i] = simulator(temperaturerange[i]) 
			writefile && write(f, "$(temperaturerange[i])\t $(freeenergies[i]) \t $(magnetizations[i]) \n")
			verbose && @printf "temperature is %f, free energy is %f, magnetization is %f \n" temperaturerange[i] freeenergies[i] magnetizations[i]
		end
	end
	return freeenergies, magnetizations
end


function testSimulateTemp()
	test = testClassical2dSquareSimulator()
	temperaturerange = linspace(1.0,3.0,100)
	simulatorTemperature(temperaturerange, test)
end
