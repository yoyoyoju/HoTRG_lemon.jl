#=
		countUp!(simulator) # space count
		######
		renormalizeSpace!(simulator.lattice, getDimM(simulator))
		normalizeTensor!(simulator)
		updateCoefficients!(simulator)

		countUp!(simulator, "trotter") # trotter count
		######
		renormalizeTrotter!()
		normalizeTensor!(simulator)
		updateCoefficients!(simulator,"trotter")
=#

#=
renormalize!
=#

###### let's make a note for this
function renormalizeSpace!{T}(lattice::Quantum2dFractalLattice{T}, dimM::Int)
	tensorT, tensorTtilde = getTensorT(lattice)
	tensorPx = getTensorP(lattice,1)
	tensorQ = getTensorQ(lattice)

	##### please refactor afterwards
	tensorUy = getTensorUy(tensorT, dimM, "x")
	tensorUz = getTensorUz(tensorT, dimM, "x")
	tensorCore1 = getTensorCore(tensorT, tensorT, tensorUy, tensorUz)
	tensorCore1tilde = getTensorCore(tensorT, tensorTtilde, tensorUy, tensorUz)

	legProjectorZ = getLegProjectorZ(tensorPx, dimM)
	tensorLegY = constructLegY(tensorPx, tensorUy, legProjectorZ)
	###### optional(later) extend leg
	caretProjectorZ = getCaretProjectorZ(tensorQ, dimM)
	tensorCaretY = constructCaretY(tensorQ, tensorUy, caretProjectorZ)

	tensorS1, tensorS1tilde, tensorSc1
	 # tensorS1 = tensorLegY * tensorCore1
		 # MMd =getMMd (tensorLegY, tensorCore1)
		 # U = getProjector( MMd)
		 # construct (tensorLegY, U, tensorCore1)
	 # tensorS1tilde = tensorLegY * tensorCore1tilde
	 	# construct (tensorLegY, U, tensorCore1tilde)

	 # tensorSc1 = tensorCaretY * tensorCore1
	 ## input: tensorLegY, tensorCaretY, tensorCore1, tensorCore1tilde
	 ## output: tensorS1, tensorS1tilde, tensorSc1
	 ## just the thing is, the z axis indices should be renormalized...
		 # getMMd
		 # getprojector
		 # construct
	 ## I should use the same projector for S1 tilde and S1 ...



	##### next
	# rotate
	# do the similar
	# but for the tensorCore
	# MMd should be mirrored
	# turn on the mirror option



	



	tensorS1, tensorS1tilde, tensorSc1 = 
	constructFirstHalf(tensorT, tensorTtilde, lattice, dimM, 2)

	constructSecondHalf(tensorS1, tensorS1tilde, lattice, dimM, 1, tensorSc1)
end

function renormalizeTrotter!{T}(lattice::Quantum2dFractalLattice{T}, dimM::Int)
###### maybe I can re-use the renormalize from 
# simulator_quantum_2d_square_renormalize.jl
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

function calculateLegCaretTensor{T}(lattice::Quantum2dFractalLattice{T}, XorY::Int, tensorU::Array{T,3})
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


function constructFirstHalf{T}(tensorT::Array{T,4}, tensorTtilde::Array{T,4}, lattice::Quantum2dFractalLattice{T}, dimM::Int, XorY::Int)
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

function constructSecondHalf{T}(tensorT::Array{T,4}, tensorTtilde::Array{T,4}, lattice::Quantum2dFractalLattice{T}, dimM::Int, XorY::Int, tensorCorner::Array{T,3})
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

#---
#

#---
# get functions for
# caret
function getCaretProjectorZ{T}(tensorQ::Array{T,4}, dimM::Int)
	tenmatMMd = getTenmatMMd_caret(tensorQ)
	caretProjectorZ = getProjectorFromMMd(tenmatMMd.matrix)
	return caretProjectorZ
end

function getTenmatMMd_caret{T}(tensorQ::Array{T,4})
	@tensor begin
		dummy1[z1,a1,s,t] :=
		tensorQ[s,y1,z1,z1p] *
		tensorQ[t,y1,a1,z1p]
		dummy2[z2,a2,s,t] :=
		tensorQ[s,y2,z2,z2p] *
		tensorQ[t,y2,a2,z2p]
		tenmatMMd[z1,z2,a1,a2] :=
		dummy1[z1,a1,s,t] *
		dummy2[z2,a2,s,t]
	end
	tenmatMMd =tensor2tenmat(tensorMMd,[1,2],[3,4])
	return tenmatMMd
end

function constructCaretY{T}(tensorQ::Array{T,4}, tensorUy::Array{T,3}, caretProjectorZ::Array{T,3})
	@tensor begin
		dummy1[s,y1,z1p,z2,z] :=
		 tensorQ[s,y1,z1,z1p] *
		 caretProjectorZ[z1,z2,z]
		dummy2[s,y2,z2,z1p,zp] :=
		 tensorQ[s,y2,z2,z2p] *
		 caretProjectorZ[z1p,z2p,zp]
		dummy3[y1,y2,z,zp] :=
		 dummy1[s,y1,z1p,z2,z] *
		 dummy2[s,y2,z2,z1p,zp]
		tensorCaretY[y,z,zp] :=
		 dummy3[y1,y2,z,zp] *
		 tensorUy[y1,y2,y]
	end
	return tensorCaretY
end

#---
# get functions for
# leg
function getLegProjectorZ{T}(tensorPx::Array{T,5}, dimM::Int)
	tenmatMMd = getTenmatMMd_leg(tensorPx)
	legProjectorZ = getProjectorFromMMd(tenmatMMd.matrix)
	return legProjectorZ
end
	
function getTenmatMMd_leg{T}(tensorPx::Array{T,5})
	@tensor begin
		dummy1[z1,a1,s,t] :=
		tensorPx[y1,y1p,s,z1,z1p] *
		tensorPx[y1,y1p,t,a1,z1p]
		dummy2[z2,a2,s,t] :=
		tensorPx[y2p,y2,s,z2,z2p] *
		tensorPx[y2p,y2,t,a2,z2p]
		tenmatMMd[z1,z2,a1,a2] :=
		dummy1[z1,a1,s,t] *
		dummy2[z2,a2,s,t]
	end
	tenmatMMd =tensor2tenmat(tensorMMd,[1,2],[3,4])
	return tenmatMMd
end

function getProjectorFromMMd{T}(matrix::Array{T,2})
	tensorU, lambdaVector, tensorUd = svd(matrix)
	truncatedU = truncMatrixU(tensorU,dimM)
	tensorU = matU2tenU(truncatedU)
	return tensorU
end

function constructLegY{T}(tensorPx::Array{T,5}, tensorUy::Array{T,3}, legProjectorZ::Array{T,3})
	@tensor begin
		dummy1[y1p,s,z1,z1p,y2,y] :=
		tensorPx[y1p,y1p,s,z1,z1p] *
		tensorUy[y1,y2,y]
		dummy2[y2,s,z2,z2p,y1p,yp] :=
		tensorPx[y2p,y2,s,z2,z2p] *
		tensorUy[y1p,y2p,yp]
		dummy3[z1,z1p,y,z2,z2p,yp] :=
		dummy1[y1p,s,z1,z1p,y2,y] *
		dummy2[y2,s,z2,z2p,y1p,yp]
		dummy4[z1p,y,z2p,yp] :=
		dummy3[z1,z1p,y,z2,z2p,yp] *
		legProjectorZ[z1,z2,z]
		tensorLegY[y,yp,z,zp] :=
		dummy4[z1p,y,z2p,yp] *
		legProjectorZ[z1p,z2p,zp]
	end
	return tensorLegY
end

#---
# get functions from
# simulator_quantum_2d_square_renormalize.jl
# permuted for different axis
function getTensorUy{T}(tensorT::Array{T,6}, dimM::Int, axis::AbstractString)
	if axis == "x"
		tensorUy = getTensorU(permutedims(tensorT,[3,4,5,6,1,2]),dimM)
	end
	return tensorUy
end

function getTensorUz{T}(tensorT::Array{T,6}, dimM::Int, axis::AbstractString)
	if axis == "x"
		tensorUz = getTensorV(permutedims(tensorT,[3,4,5,6,1,2]),dimM)
	end
	return tensorUz
end

function getTensorCore{T}(tensorT1::Array{T,6}, tensorT2::Array{T,6}, tensorUy::Array{T,3}, tensorUz::Array{T,3})
	newTensorT = getNewTensorT_2dQ(permutedims(tensorT1,[3,4,5,6,1,2]),permutedims(tensorT2,[3,4,5,6,1,2]), tensorUy, tensorUz)
	return permutedims(newTensorT, [5,6,1,2,3,4])
end
