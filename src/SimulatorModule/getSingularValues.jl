# to do the initialiteration
"""
let's think what I need
* well, maybe I can use to get the singular values
* maybe I can get the relative entopy by the singular values
* do the initial iteration on the trotter direction
* do I need to do it on the spatial direction too?
"""

"""
	getSingularValues
Return the singular values

----
notes:  
maybe it should be done in the way, take the tensorT 
and get the singular values
(when a simulator is passed) any simulator??
	1. get the tensorT
	2. pass it to a function.

the unit to get the singular values when a tensor is passed.
	1. form MM+ : this depends on the which type of the simulator...
		can I deal with it?
	2. do the svd
	3. the middle vector.

or it could be done from on the way..
I mean anyway in the process they get some singular values.. so.
But I guess it should be like 'printSingularValues'... 
Besides, when should I do? well, the first answer would be
when I form the Core tensor.
But, no, forget it, it goes down too deep...

Maybe I can recycle some functions I created before..
in the case of Quantum2dFractal: calculateCoreTensors(tensorT, tensorTtilde, dimM)
Actually more properly: getTensorUy(dimM, "x", tensorT, mirror=mirror)
	that's true that it depends on the direction... well, well, well

	calculateCoreTensors <- add arg getsvd
	getTensorUy
	getTensorUz
	getProgectorFromMMd: return tensorU, lambdaVector - DONE
"""
function getSingularValues(simulator::Simulator)

end

function getSingularValues{T}(tensorT::Array{T,N})
end



