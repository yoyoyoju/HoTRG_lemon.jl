function renormalize{T}(tensorT1::Array{T,6}, tensorT2::Array{T,6}, dimM::Int; whichIsTensorT::Int = 1)
	if whichIsTensorT ==1
		tensorT = tensorT1
		tensorTtilde = tensorT2
	else
		tensorT = tensorT2
		tensorTtilde = tensorT1
	end
	tensorU = getTensorU(tensorT, dimM)
	tensorV = getTensorV(tensorT, dimM)
	newTensorT = getNewTensorT_2dQ(tensorT, tensorT, tensorU, tensorV)
	normalizationFactor = maximum(newTensorT)
	newTensorTtilde = getNewTensorT_2dQ(tensorT1, tensorT2, tensorU, tensorV)
	newTensorTtilde = newTensorTtilde./ normalizationFactor
	newTensorT = newTensorT./ normalizationFactor
	return newTensorT, newTensorTtilde, normalizationFactor
end

function getNewTensorT_2dQ{T}(tensorT1::Array{T,6}, tensorT2::Array{T,6}, tensorU::Array{T,3}, tensorV::Array{T,3})
	@tensor begin
		d1[x2,x,x1p,y1,y1p,z,i] := tensorT1[x1,x1p,y1,y1p,z,i] * tensorU[x1,x2,x]
		d2[x2,x,x2p,xp,y1,y1p,z,i] := d1[x2,x,x1p,y1,y1p,z,i] * tensorU[x1p,x2p,xp]
		d3[x,xp,y1,y1p,y2,y2p,z,zp] := d2[x2,x,x2p,xp,y1,y1p,z,i] * tensorT2[x2,x2p,y2,y2p,i,zp]
		d4[x,xp,y,y1p,y2p,z,zp] := d3[x,xp,y1,y1p,y2,y2p,z,zp] * tensorV[y1,y2,y]
		newTensorT[x,xp,y,yp,z,zp] := d4[x,xp,y,y1p,y2p,z,zp] * tensorV[y1p,y2p,yp]
	end
	return newTensorT
end

function getTensorU{T}(tensorT::Array{T,6}, dimM::Int)
	tenmatMMd = getTenmatMMd(tensorT)
	Ul, lambdaVector, Uld = svd(tenmatMMd.matrix)
	trunUl = truncMatrixU(Ul,dimM)
	tensorU = matU2tenU(trunUl)
	return tensorU
end

function getTensorV{T}(tensorT::Array{T,6}, dimM::Int)
	tensorV = getTensorU(permutedims(tensorT,[3,4,1,2,5,6]), dimM)
	return tensorV
end

function getTenmatMMd{T}(tensorT::Array{T,6})
	@tensor begin
		dummy1[x1,a1,i,j] := tensorT[x1,x1p,y1,y1p,z,i] *
			tensorT[a1,x1p,y1,y1p,z,j]
		dummy2[x2,a2,i,j] := tensorT[x2,x2p,y2,y2p,i,zp] *
			tensorT[a2,x2p,y2,y2p,j,zp]
		tensorMMd[x1,x2,a1,a2] := dummy1[x1,a1,i,j] *
			dummy2[x2,a2,i,j]
	end
	tenmatMMd = tensor2tenmat(tensorMMd,[1,2],[3,4])
	return tenmatMMd
end
