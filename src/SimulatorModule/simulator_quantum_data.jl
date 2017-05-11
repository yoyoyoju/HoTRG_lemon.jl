"""
	simulatorQuantum{T}(fieldrange::LinSpace{T}, simulator::QuantumSimulator{T}; verbose = true, writefile = true, filename = "Data.txt")

Get the results from simulator quantum spin system.  

# arguments
* `fieldrange::LinSpace`: the range for the external field to be applied.  
* `simulator::QuantumSimulator`  

* `verbose = true`: print the results  
* `writefile = true`: write the  result data into a file  
* `filename = "Data.txt"`: name of the file for the results   
"""
function simulatorQuantum{T}(fieldrange::LinSpace{T}, simulator::QuantumSimulator{T}; verbose = true, writefile = true, filename = "Data.txt")
	numberofh = Int(fieldrange.len)
	energies = Array{T}(numberofh)
	Mzs = Array{T}(numberofh)


	writefile && open(filename, "w") do f; write(f, "field \t ground_energy \t magnetization_z \n")
		for i = 1:numberofh
			setExternalfield!(simulator, fieldrange[i])
			energies[i], Mzs[i] = simulator()
			writefile && write(f, "$(fieldrange[i])\t $(energies[i]) \t $(Mzs[i]) \n")
			verbose && @printf "applied field is %f, ground state energy is %f, magnetization z is %f \n" fieldrange[i] energies[i] Mzs[i]
		end
	end
	return energies, Mzs
end

"""
	simulatorQuantum{T}(externalfield::T, simulator::QuantumSimulator{T}; verbose = true, writefile = true, filename = "Data_.txt")

Simulate for some external field. Append onto "Data_.txt" file.
"""
function simulatorQuantum{T}(externalfield::T, simulator::QuantumSimulator{T}; verbose = true, writefile = true, filename = "Data_.txt")
	setExternalfield!(simulator, externalfield)
	energie, Mz = simulator()

	if (writefile & !isfile(filename))
		open(filename, "w") do f
			write(f, "field \t ground_energy \t magnetization_z \n") 
			write(f, "$(externalfield)\t $(energie) \t $(Mz) \n")
		end
	elseif (writefile & isfile(filename))
		open(filename, "a") do f
			write(f, "$(externalfield)\t $(energie) \t $(Mz) \n")
		end
	end

	verbose && @printf "applied field is %f, ground state energy is %f, magnetization z is %f \n" externalfield energie Mz
end
