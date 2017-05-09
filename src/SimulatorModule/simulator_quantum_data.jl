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
