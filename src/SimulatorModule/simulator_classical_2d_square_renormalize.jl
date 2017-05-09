#=
renormalize!

getTensorM
truncMatrixU
matU2tenU
getNewTensorT
retateTensorT90
normalize
=#

function renormalize!{T}(lattice::Classical2dSquareLattice{T}, dimM::Int)
	tensorT, impurityTensorTtilde = getTensorT(lattice)

	tenmatM = getTensorM(tensorT)
	matrixMMd = tenmatM.matrix * transpose(tenmatM.matrix)
	Ul, lambdaVector, Uld = svd(matrixMMd)
	trunUl = truncMatrixU(Ul,dimM)
	tensorUl = matU2tenU(trunUl)
	
	# contract tensors to get the bigger tensorT
	newTensorT = getNewTensorT(tensorT,tensorUl)

	# rotate tensorT 90 degrees to the clockwise
	newRotTensorT = rotateTensorT90(newTensorT)
	
	# normalize tensorT
	newRotNormTensorT, normalizationFactor = normalize(newRotTensorT)

	### similar thing to do to tensorTtilde
	newTensorTtilde = getNewTensorT(tensorT,tensorUl,impurityTensorTtilde)
	newRotTensorTtilde = rotateTensorT90(newTensorTtilde)
	newRotNormTensorTtilde = newRotTensorTtilde ./normalizationFactor

	setTensorT!(lattice, newRotNormTensorT)
	setTensorT!(lattice, newRotNormTensorTtilde; tilde = true)
	return normalizationFactor
end

function getTensorM{T}(tensorT::Array{T,4} ; returntenmat = true, mirror = false)
	if mirror == false
		@tensor begin
			tensorM[x1,x2,x1p,x2p,y,yp] := tensorT[x1,x1p,y,j] * tensorT[x2,x2p,j,yp]
		end
	else
		@tensor begin
			tensorM[x1,x2p,x1p,x2,y,yp] := tensorT[x1,x1p,y,j] * tensorT[x2,x2p,yp,j]
		end
	end
	returntenmat ? answer = tensor2tenmat(tensorM,[1,2],[3,4,5,6]) : answer = tensorM
	return answer
end

function truncMatrixU(matrixU::Matrix, dimM::Int)
	# truncate the column dimension of matrix U to the dimM
	if size(matrixU,2) > dimM
		matrixU = Array(view(matrixU,:,1:dimM))
	end
	return matrixU
end

function matU2tenU(matrixU::Matrix)
	size1 = Int(sqrt(size(matrixU,1)))
	tenmatU = Tenmat(matrixU,[1,2],[3],(size1,size1,size(matrixU,2)))
	tensorU = tenmat2tensor(tenmatU)
	return tensorU
end

function getNewTensorT{T}(tensorT::Array{T,4},tensorU::Array{T,3}, tensorTtilde::Array{T,4}= tensorT; mirror = false)
	# contract U,T,T,U tensors to make new tensorT
	# according to the Fig.1.(b)
	# the third input tensorTtilde is for impurity tensor
	# 	without the third input, it uses tensorT twice
	if mirror == false
		@tensor begin
			UT[x2,x,x1p,y,i] := tensorU[x1,x2,x] * tensorTtilde[x1,x1p,y,i]
			UTT[x,x1p,y,x2p,yp] := UT[x2,x,x1p,y,i] * tensorT[x2,x2p,i,yp]
			newTensorT[x,xp,y,yp] := UTT[x,x1p,y,x2p,yp] * tensorU[x1p,x2p,xp]
		end
	else
		@tensor begin
			UT[x2,x,x1p,y,i] := tensorU[x1,x2,x] * tensorTtilde[x1,x1p,y,i]
			UTT[x,x1p,y,x2p,yp] := UT[x2,x,x1p,y,i] * tensorT[x2,x2p,yp,i]
			newTensorT[x,xp,y,yp] := UTT[x,x1p,y,x2p,yp] * tensorU[x1p,x2p,xp]
		end
	end
	return newTensorT
end


