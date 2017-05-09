##### version 2 -> including the leg

#=
renormalize!
=#

function renormalize!{T}(lattice::Classical2dFractalLattice{T}, dimM::Int)
	tensorT, tensorTtilde = getTensorT(lattice)

	tensorS1, tensorS1tilde, tensorSc1 = 
	constructFirstHalf(tensorT, tensorTtilde, lattice, dimM, 2)

	constructSecondHalf(tensorS1, tensorS1tilde, lattice, dimM, 1, tensorSc1)
end

function calculateNextCoreTensor{T}(tensorT::Array{T,4}, tensorTtilde::Array{T,4}, dimM::Int; mirror = false)
	tenmatM = getTensorM(tensorT, mirror = mirror)
	matrixMMd = tenmatM.matrix * transpose(tenmatM.matrix)
	Ul, lambdaVector, Uld = svd(matrixMMd)
	trunUl = truncMatrixU(Ul,dimM)
	tensorUl = matU2tenU(trunUl)
	newTensorT = getNewTensorT(tensorT,tensorUl)
	newTensorTtilde = getNewTensorT(tensorT,tensorUl,tensorTtilde)
	return newTensorT, newTensorTtilde, tensorUl
end

function calculateScTensor{T}(tensorT::Array{T,4}, tensorCorner::Array{T,3}, tensorU::Array{T,3})
	@tensor begin
		dummy1[x1,x2,x1p,x2p,y] := tensorCorner[x1,x1p,s] * tensorT[x2p,x2,y,s]
		#####? maybe tensorU[x2,x1,i]
		dummy2[x,x1p,x2p,y] := tensorU[x1,x2,x] * dummy1[x1,x2,x1p,x2p,y]
		tensorSc[x,xp,y] := dummy2[x,x1p,x2p,y] * tensorU[x1p,x2p,xp]
	end
	return tensorSc
end

function calculateLegCaretTensor{T}(lattice::Classical2dFractalLattice{T}, XorY::Int, tensorU::Array{T,3})
	tensorP = getTensorP(lattice, XorY)
	legTensor = getNewLegTensor(tensorP, tensorU)
	caretTensor = getNewCaretTensor(getTensorQ(lattice), tensorU, XorY)

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
	return legTensor, caretTensor
end


function constructFirstHalf{T}(tensorT::Array{T,4}, tensorTtilde::Array{T,4}, lattice::Classical2dFractalLattice{T}, dimM::Int, XorY::Int)
	newTensorT, newTensorTtilde, tensorU = calculateNextCoreTensor(tensorT, tensorTtilde, dimM)
	legTensor, caretTensor = calculateLegCaretTensor(lattice, XorY, tensorU)

	@tensor begin # put legs to one side
		tensorS[x,xp,y,yp] := # legTensor * newTensorT
		  legTensor[x,i] * newTensorT[i,xp,y,yp]
		tensorStilde[x,xp,y,yp] := # legTensor * newTensorTtilde
		  legTensor[x,i] * newTensorTtilde[i,xp,y,yp]
	  	tensorSc[y,yp,xp] := # caretTensor * newTensorT
			caretTensor[j] * newTensorT[j,xp,y,yp]
	end

	newRotTensorS = rotateTensorT90(tensorS)
	newRotTensorStilde = rotateTensorT90(tensorStilde)

	return newRotTensorS, newRotTensorStilde, tensorSc 
end

function constructSecondHalf{T}(tensorT::Array{T,4}, tensorTtilde::Array{T,4}, lattice::Classical2dFractalLattice{T}, dimM::Int, XorY::Int, tensorCorner::Array{T,3})
	newTensorS, newTensorStilde, tensorU = calculateNextCoreTensor(tensorT, tensorTtilde, dimM, mirror = true)
	legTensor, caretTensor = calculateLegCaretTensor(lattice, XorY, tensorU)
	tensorSc = calculateScTensor(tensorT, tensorCorner, tensorU) # x, xp, y

	@tensor begin
		dummy1[x,xp,y,yp] := legTensor[x,i] * newTensorS[i,xp,y,yp] # legTensor * newTensorS
		newTensorT[x,xp,y,yp] := dummy1[x,j,y,yp] * legTensor[j,xp] # legTensor * newTensorS * legTensor = dummy1 * legTensor
		newTensorPy[y,yp,x] := dummy1[x,j,y,yp] * caretTensor[j] # legTensor * newTensorS * caretTensor = dummy1 * caretTensor
		dummy2[x,xp,yp] := legTensor[x,i] * tensorSc[i,xp,yp] # legTensor * ...
		newTensorPx[y,yp,s] := dummy2[y,j,s] * legTensor[j,yp]# legTensor * ... * leg
		newTensorQ[x,y] := dummy2[y,j,x] * caretTensor[j] # leg * ... * caret
		# tensorTtilde
		dummy1tilde[x,xp,y,yp] := legTensor[x,i] * newTensorStilde[i,xp,y,yp]
		newTensorTtilde[x,xp,y,yp] := dummy1tilde[x,j,y,yp] * legTensor[j,xp] # legTensor * newTensorS * legTensor = dummy1 * legTensor
	end

	newRotTensorT = rotateTensorT90(newTensorT)
	newRotTensorTtilde = rotateTensorT90(newTensorTtilde)

	setTensorT!(lattice, newRotTensorT)
	setTensorT!(lattice, newRotTensorTtilde; tilde = true)
	setTensorP!(lattice, 1, newTensorPx)
	setTensorP!(lattice, 2, newTensorPy)
	setTensorQ!(lattice, newTensorQ)

	return newRotTensorT, newRotTensorTtilde
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
