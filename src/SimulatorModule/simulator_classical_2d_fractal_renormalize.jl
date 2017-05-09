#=
renormalize!
=#

function renormalize!{T}(lattice::Classical2dFractalLattice{T}, dimM::Int)
	tensorT, tensorTtilde = getTensorT(lattice)

	tensorT, tensorTtilde, legTensorY, caretTensorY = 
	constructHalf(tensorT, tensorTtilde, lattice, dimM, 2)

	tensorS, tensorStilde, legTensorX, caretTensorX = 
	constructHalf(tensorT, tensorTtilde, lattice, dimM, 1)

	updateLocalTensors!(tensorS, tensorStilde, legTensorX, legTensorY, caretTensorX, caretTensorY, lattice)
end

function updateLocalTensors!{T}(tensorS::Array{T,4}, tensorStilde::Array{T,4}, legTensorX::Array{T,2}, legTensorY::Array{T,2}, caretTensorX::Array{T,1}, caretTensorY::Array{T,1}, lattice::Classical2dFractalLattice{T})
 	@tensor begin
 		dumA[a,b,c,yp] := tensorS[a,b,c,d] * legTensorX[d,yp]
 		dummy1[a,xp,c,yp] := dumA[a,b,c,yp] * legTensorY[b,xp]
 		dummy2[x,xp,c,yp] := dummy1[a,xp,c,yp] * legTensorY[x,a]
 		newTensorT[x,xp,y,yp] := dummy2[x,xp,c,yp] * legTensorX[y,c]
 		newTensorPy[x,xp,yp] := dummy2[x,xp,c,yp] * caretTensorX[c]
 		dummy3[xp,c,yp] := dummy1[a,xp,c,yp] * caretTensorY[a]
 		newTensorPx[y,yp,xp] := dummy3[xp,c,yp] * legTensorX[y,c]
 		newTensorQ[xp,yp] := dummy3[xp,c,yp] * caretTensorX[c]
 
 		dumAt[a,b,c,yp] := tensorStilde[a,b,c,d] * legTensorX[d,yp]
 		dummy1t[a,xp,c,yp] := dumAt[a,b,c,yp] * legTensorY[b,xp]
 		dummy2t[x,xp,c,yp] := dummy1t[a,xp,c,yp] * legTensorY[x,a]
 		newTensorTtilde[x,xp,y,yp] := dummy2t[x,xp,c,yp] * legTensorX[y,c]
 	end
	setTensorT!(lattice, newTensorT)
	setTensorT!(lattice, newTensorTtilde; tilde = true)
	setTensorP!(lattice, 1, newTensorPx)
	setTensorP!(lattice, 2, newTensorPy)
	setTensorQ!(lattice, newTensorQ)
end

function constructHalf{T}(tensorT::Array{T,4}, tensorTtilde::Array{T,4}, lattice::Classical2dFractalLattice{T}, dimM::Int, XorY::Int; writefile = true, filename::AbstractString = "singularvalues.txt")
	tenmatM = getTensorM(tensorT)
	matrixMMd = tenmatM.matrix * transpose(tenmatM.matrix)
	Ul, lambdaVector, Uld = svd(matrixMMd)
	writefile && writeVector(lambdaVector, filename)
	trunUl = truncMatrixU(Ul,dimM)
	tensorUl = matU2tenU(trunUl)
	
	newTensorT = getNewTensorT(tensorT,tensorUl)
	newRotTensorT = rotateTensorT90(newTensorT)

	newTensorTtilde = getNewTensorT(tensorT,tensorUl,tensorTtilde)
	newRotTensorTtilde = rotateTensorT90(newTensorTtilde)

	tensorP = getTensorP(lattice, XorY)
	legTensor = getNewLegTensor(tensorP, tensorUl)
	caretTensor = getNewCaretTensor(getTensorQ(lattice), tensorUl, XorY)

	legextension = getLegextension(lattice)
	if legextension == 0
		legTensor = legTensor^getLegextension(lattice)
		caretTensor = ones(size(caretTensor))
	elseif legextension > 0
		extraleg = legTensor^(getLegextension(lattice) - 1)
		legTensor = legTensor * extraleg
		caretTensor = extraleg * caretTensor
	else
		error("legextension should be not negative integer")
	end

	return newRotTensorT, newRotTensorTtilde, legTensor, caretTensor
end

function getNewLegTensor{T}(tensorP::Array{T,3}, tensorU::Array{T,3})
	@tensor begin
		#####? maybe tensorU[x2,x1,i]
		dummy1[i,x2,s,x1p] := tensorU[x1,x2,i] * tensorP[x1,x1p,s]
		dummy2[i,x1p,x2p] := dummy1[i,x2,s,x1p] * tensorP[x2p,x2,s]
		legTensor[i,j] :=  dummy2[i,x1p,x2p] * tensorU[x1p,x2p,j]
	end
	return legTensor
end

function getNewCaretTensor{T}(tensorQ::Array{T,2}, tensorU::Array{T,3}, XorY::Int)
	if XorY == 1 # C[X]
		@tensor begin
			dummy[y1,y2] := tensorQ[s,y1] * tensorQ[s,y2]
			caretTensor[j] := dummy[y1,y2] * tensorU[y1,y2,j]
		end
	else # C[Y]
		@tensor begin
			dummy[x1,x2] := tensorQ[x1,s] * tensorQ[x2,s]
			caretTensor[j] := dummy[x1,x2] * tensorU[x1,x2,j]
		end
	end
	return caretTensor
end
