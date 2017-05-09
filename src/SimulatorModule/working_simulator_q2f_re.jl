function upsidedown{T}(tensor6::Array{T,6})
	upsidedowntensor = permutedims(tensor6, [1,2,3,4,6,5])
	return upsidedowntensor
end

function renormalizeTrotter!{T}(simulator::Quantum2dFractalSimulator{T}, dimM::Int)
	lattice = simulator.lattice
	tensorT, tensorTtilde = getTensorT(lattice)
 	tensorPx = getTensorP(lattice,1)
 	tensorPy = getTensorP(lattice,2)
 	tensorQ = getTensorQ(lattice)

 	if isodd(getTrotterCount(simulator))
 		whichisT = 1
		tensorT1 = tensorT
		tensorT2 = tensorTtilde
	else
 		whichisT = 2
		tensorT2 = tensorT
		tensorT1 = tensorTtilde
 	end

	nextTensorT, nextTensorTtilde, projectorUx, projectorUy = renormalizeTensorT_trotter(tensorT1, tensorT2, dimM , whichIsTensorT = whichisT)
	nextTensorTtilde = symmetrizeTensorTrotter(nextTensorTtilde)
 	nextTensorPy = renormalizeTensorPy_trotter(tensorPy, projectorUx, projectorUy, dimM)
 	nextTensorPx = renormalizeTensorPx_trotter(tensorPx, projectorUx, projectorUy, dimM)
 	nextTensorQ = renormalizeTensorQ_trotter(tensorQ, projectorUx, projectorUy, dimM)

	setTensorT!(lattice, nextTensorT)
	setTensorT!(lattice, nextTensorTtilde; tilde = true)
 	setTensorP!(lattice, 1, nextTensorPx)
 	setTensorP!(lattice, 2, nextTensorPy)
 	setTensorQ!(lattice, nextTensorQ)

end

function renormalizeTensorQ_trotter{T}(tensorQ::Array{T,4}, projectorUx::Array{T,3}, projectorUy::Array{T,3}, dimM::Int)
	@tensor begin
		dummy1[x1,z,i,y2,y] :=
		tensorQ[x1,y1,z,i] * projectorUy[y1,y2,y]
		dummy2[z,i,y2,y,x2,x] :=
		dummy1[x1,z,i,y2,y] * projectorUx[x1,x2,x]
		nextTensorQ[x,y,z,zp] :=
		dummy2[z,i,y2,y,x2,x] * tensorQ[x2,y2,i,zp]
	end
	return nextTensorQ
end

function renormalizeTensorPx_trotter{T}(tensorPx::Array{T,5}, projectorUx::Array{T,3}, projectorUy::Array{T,3}, dimM::Int)
	@tensor begin
		dummy1[y1p,s1,z,i,y2,y] :=
		tensorPx[y1,y1p,s1,z,i] * projectorUy[y1,y2,y]
		dummy2[y1p,s1,z,y,y2p,s2,zp] :=
		dummy1[y1p,s1,z,i,y2,y] * tensorPx[y2,y2p,s2,i,zp]
		dummy3[s1,z,y,s2,zp,yp] :=
		dummy2[y1p,s1,z,y,y2p,s2,zp] * projectorUy[y1p,y2p,yp]
		nextTensorPx[y,yp,s,z,zp] :=
		dummy3[s1,z,y,s2,zp,yp] * projectorUx[s1,s2,s]
	end
	return nextTensorPx
end

function renormalizeTensorPy_trotter{T}(tensorPy::Array{T,5}, projectorUx::Array{T,3}, projectorUy::Array{T,3}, dimM::Int)
	@tensor begin
		dummy1[x1,x1p,z,i,s2,s] :=
		tensorPy[x1,x1p,s1,z,i] * projectorUy[s1,s2,s]
 		dummy2[x1,x1p,z,s,x2,x2p,zp] :=
 		dummy1[x1,x1p,z,i,s2,s] * tensorPy[x2,x2p,s2,i,zp]
 		dummy3[x1p,z,s,x2p,zp,x] :=
 		dummy2[x1,x1p,z,s,x2,x2p,zp] * projectorUx[x1,x2,x]
 		nextTensorPy[x,xp,s,z,zp] :=
 		dummy3[x1p,z,s,x2p,zp,x] * projectorUx[x1p,x2p,xp]
 	end
 	return nextTensorPy
end

function renormalizeTensorT_trotter{T}(tensorT1::Array{T,6}, tensorT2::Array{T,6}, dimM::Int ; whichIsTensorT::Int = 1)
	 if whichIsTensorT == 1
		tensorT = tensorT1
		tensorTtilde = tensorT2
	 else
		tensorT = tensorT2
		tensorTtilde = tensorT1
	 end
	tensorU = getTensorU(tensorT, dimM)
	tensorV = getTensorV(tensorT, dimM)
	newTensorT = getNewTensorT_2dQ(tensorT, tensorT, tensorU, tensorV)
	newTensorTtilde = getNewTensorT_2dQ(tensorT1, tensorT2, tensorU, tensorV)
	return newTensorT, newTensorTtilde, tensorU, tensorV
end

#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------
function renormalizeSpace!{T}(simulator::Quantum2dFractalSimulator{T}, dimM::Int)
	lattice = simulator.lattice
	tensorT, tensorTtilde = getTensorT(lattice)
	# println(traceTensorTPeriodic(tensorTtilde), " over ", traceTensorTPeriodic(tensorT)) ###debug
	tensorPx = getTensorP(lattice,1)
	tensorQ = getTensorQ(lattice)

	tensorCore, tensorCoretilde, tensorUy =
	calculateCoreTensors(tensorT, tensorTtilde, dimM)
	tensorCore, normC = normalizeTensor(tensorCore)
	tensorCoretilde = tensorCoretilde ./ normC
	setNorm!(simulator, normC, getIndexOf(simulator, "c"))
  
	tensorLeg = calculateLegTensor(tensorPx, tensorUy, dimM)
	tensorLeg, normLy = normalizeAndSetNorm!(simulator, tensorLeg, "ly")
  		###### optional(later) extend leg
	tensorCaret = calculateCaretTensor(tensorQ, tensorUy, dimM)
	tensorCaret, normEy = normalizeAndSetNorm!(simulator, tensorCaret, "ey")
  
	tensorLegCore, tensorLegCoretilde = calculateTensorLegCore(tensorLeg, tensorCore, tensorCoretilde, dimM)
	tensorLegCore, normLc = normalizeAndSetNorm!(simulator, tensorLegCore, "lc")
	tensorCaretCore = calculateTensorCaretCore(tensorCaret, tensorCore, dimM)
	tensorCaretCore, normEc = normalizeAndSetNorm!(simulator, tensorCaretCore, "ec")
  
	tensorTau = rotateTensorS_xy(tensorLegCore)
	tensorTautilde = rotateTensorS_xy(tensorLegCoretilde)

 	# do the similar things
	# second stage
	# P = getTensorP(lattice,2) 
	# Tau -> Core, tensorU
	# P, Q, tensorU -> leg, caret
	
	tensorP = getTensorP(lattice,2)
	tensorCore, tensorCoretilde, tensorUy =
	calculateCoreTensors(tensorTau, tensorTautilde, dimM, mirror = true)
	tensorCore, normLccl = normalizeAndSetNorm!(simulator, tensorCore, "lccl")
	tensorCoretilde = tensorCoretilde ./ normLccl
	tensorLeg = calculateLegTensor(tensorP, tensorUy, dimM)
	tensorLeg, normLx = normalizeAndSetNorm!(simulator, tensorLeg, "lx")
  		###### optional(later) extend leg
	tensorCaret = calculateCaretTensor(permutedims(tensorQ, [2,1,3,4]), tensorUy, dimM)
	tensorCaret, normEx = normalizeAndSetNorm!(simulator, tensorCaret, "ex")

	# calculateNextPQ:
	# input:	CaretCore, LegCore, leg, caret, tensorUy, dimM
	# output:	nextTensorPx, nextTensorQ
	## CareCore, LegCore from the prev stage
	## CaretCore, LegCore, leg, caret -> Py, Q
	##### 137,153 #noleg#
		# 1. tensorPi0: CaretCore + CoreLeg = eccl
		tensorPi0 = calculateWallCore(tensorCaretCore, mirrorTensorS(tensorLegCore), tensorUy, dimM)
		tensorPi0, normEccl = normalizeAndSetNorm!(simulator, tensorPi0, "eccl")
		# 2. tensorPi1: leg + tensorPi0 = eccll
			# tensorPi1 = calculatePi1(tensorPi0, leg, dimM)
			tensorPi1 = calculateLegWall(tensorLeg, tensorPi0, dimM)
		tensorPi1, normEccll = normalizeAndSetNorm!(simulator, tensorPi1, "eccll")
		# 3. nextTensorPy: tensorPi1 + leg = ecclll
			nextTensorPy = calculateWallLeg(tensorPi1, tensorLeg, dimM)
			nextTensorPy, normPy = normalizeAndSetNorm!(simulator, nextTensorPy, "py")
		# 4. nextTensorQ:  tensorPi1 + caret = ecclle
			nextTensorQ = calculateWallCaret(tensorPi1, tensorCaret, dimM)
			nextTensorQ, normQ = normalizeAndSetNorm!(simulator, nextTensorQ, "q")
	# Core, leg -> LegCore ( attach leg to y index)
	# Core = lccl, leg -> LegCore = lccll
	tensorLegCore, tensorLegCoretilde = calculateTensorLegCore(tensorLeg, tensorCore, tensorCoretilde, dimM)
	tensorLegCore, normLccll = normalizeAndSetNorm!(simulator, tensorLegCore, "lccll")
	tensorLegCoretilde = tensorLegCoretilde ./ normLccll
		## LegCore, leg (attach leg to the yp index) -> rotate -> T
		## LegCore = lccll + leg = lcclll = next tensorT
		tensorT, tensorTtilde = calculateTensorCoreLeg(tensorLegCore, tensorLegCoretilde, tensorLeg, dimM)
		tensorT, normT = normalizeAndSetNorm!(simulator, tensorT, "t")
		tensorTtilde = tensorTtilde ./ normT
		nextTensorT = rotateTensorS_xy(tensorT)
		nextTensorTtilde = rotateTensorS_xy(tensorTtilde)
		# symmetrize tensorTtilde
		nextTensorTtilde = symmetrizeTensorSpatial(nextTensorTtilde) 
		## LegCore, caret -> Px (lccll + caret = nextTensorPx = lcclle)
		nextTensorPx = calculateTensorCoreCaret(tensorLegCore, tensorCaret, dimM)
		nextTensorPx, normPx = normalizeAndSetNorm!(simulator, nextTensorPx, "px")

		setTensorT!(lattice, nextTensorT)
		setTensorT!(lattice, nextTensorTtilde; tilde = true)
		setTensorP!(lattice, 1, nextTensorPx)
	setTensorP!(lattice, 2, nextTensorPy)
	setTensorQ!(lattice, nextTensorQ)


# 	# with mirror
# 	tensorPx = getTensorP(lattice,2)
# 	tensorUy = getTensorUy(dimM, "x", rotatedTensorS1, mirror = true)
# 	tensorUz = getTensorUz(dimM, "x", rotatedTensorS1, mirror = true)
# 	tensorCore2 = getTensorCore(rotatedTensorS1, mirrorTensorS(rotatedTensorS1), tensorUy, tensorUz)
# 	tensorCore2tilde = getTensorCore(rotatedTensorS1tilde, mirrorTensorS(rotatedTensorS1tilde), tensorUy, tensorUz)
# 
#  	legProjectorZ = getLegProjectorZ(tensorPx, dimM)
#  	tensorLegY = constructLegY(tensorPx, tensorUy, legProjectorZ)
#  		###### optional(later) extend leg
#  	caretProjectorZ = getCaretProjectorZ(tensorQ, dimM)
#  	tensorCaretY = constructCaretY(tensorQ, tensorUy, caretProjectorZ)
# 
#  	tensorSProjectorZ = getSProjectorZ(tensorLegY, tensorCore2, dimM)
#  	tensorS2 = constructTensorS(tensorLegY, tensorSProjectorZ, tensorCore2)
#  	tensorS2tilde = constructTensorS(tensorLegY, tensorSProjectorZ, tensorCore2tilde)
# 
# 	# 1. T: S2 + leg
# 	# 2. Ttilde: S2tilde + leg
# 		# 
# 	# 3. Py: S2 + caret
# 
	# from CaretCore, LegCore, newLeg, newCaret
	# -> Py, Q
	# do it without rotating anything
	# 1. 	CaretCore + CoreLeg
# 	# 1. ScS1: Sc + mirror(S1)
# 	# 2. ScS1Leg: ScS1 + leg
# 	# 3. Px: ScS1Leg + leg
# 	# 4. Q: ScS1Leg + caret
# 
# 	# rotate
# 	# store them
# 	# T, Ttilde
# 	# Px, Py
# 	# Q
# 
# 	# from S and Sc
# 	###### from here
# 	# attach one more leg or caret
# 	# to make next tensor T

end

#---
# rotation on x,y plane

function rotateTensorS_xy{T}(tensorS::Array{T,6})
	return permutedims(tensorS,[3,4,2,1,5,6])
end

function mirrorTensorS{T}(tensorS::Array{T,6})
	return permutedims(tensorS,[2,1,3,4,5,6])
end

# symmetrizeTensorSpatial
function symmetrizeTensorSpatial{T}(tensor6::Array{T,6})
	rotated90Tensor = rotateTensorS_xy(tensor6)
	rotated180Tensor = rotateTensorS_xy(rotated90Tensor)
	rotated270Tensor = rotateTensorS_xy(rotated180Tensor)
	symmetrizedTensor = (tensor6 + rotated90Tensor + rotated180Tensor + rotated270Tensor) ./ 4.0
	return symmetrizedTensor
end

function symmetrizeTensorTrotter{T}(tensor6::Array{T,6})
	upsidedowntensor = upsidedown(tensor6)
	symmetrizedTensor = (tensor6 + upsidedowntensor) ./ 2.0
	return symmetrizedTensor
end

#----------------------------------------------------------------------
#----------------------------------------------------------------------
# functions mainly for the second part
#---
# functions for
# WallCaret
function calculateWallCaret{T}(tensorWall::Array{T,5}, tensorCaret::Array{T,3}, dimM::Int)
	projectorWallCaret = getWallCaretProjectorZ(tensorWall, tensorCaret, dimM)
	tensorWallCaret = constructTensorWallCaret(tensorWall, projectorWallCaret, tensorCaret)
	return tensorWallCaret
end

function getWallCaretProjectorZ{T}(tensorWall::Array{T,5}, tensorCaret::Array{T,3}, dimM::Int)
	tenmatMMd = getTenmatMMd_WallCaret(tensorWall, tensorCaret)
	projectorWallCaret = getProjectorFromMMd(tenmatMMd, dimM)
	return projectorWallCaret
end

function getTenmatMMd_WallCaret{T}(tensorWall::Array{T,5}, tensorCaret::Array{T,3})
	@tensor begin
		dummy1[i,z1,j,a1] := tensorWall[x,i,s,z1,z1p] * tensorWall[x,j,s,a1,z1p]
		dummy2[i,z2,j,a2] := tensorCaret[i,z2,z2p] * tensorCaret[j,a2,z2p]
		tensorMMd[z1,z2,a1,a2] := dummy1[i,z1,j,a1] * dummy2[i,z2,j,a2]
	end
	tenmatMMd =tensor2tenmat(tensorMMd,[1,2],[3,4])
	return tenmatMMd
end

function constructTensorWallCaret{T}(tensorWall::Array{T,5}, projectorWallCaret::Array{T,3}, tensorCaret::Array{T,3})
	@tensor begin
		dummy1[i,z2p,z1,z] :=
		tensorCaret[i,z2,z2p] * projectorWallCaret[z1,z2,z]
		dummy2[i,z1,z,z1p,zp] :=
		dummy1[i,z2p,z1,z] * projectorWallCaret[z1p,z2p,zp]
		tensorWallCaret[x,y,z,zp] :=
		dummy2[i,z1,z,z1p,zp] * tensorWall[x,i,y,z1,z1p]
	end
	return tensorWallCaret
end

#---
# functions for
# WallLeg
function calculateWallLeg{T}(tensorWall::Array{T,5}, tensorLeg::Array{T,4}, dimM::Int)
	tensorWallLeg = calculateLegWall(permutedims(tensorLeg,[2,1,3,4]), permutedims(tensorWall,[2,1,3,4,5]), dimM)
	return tensorWallLeg
end

#---
# functions for
# LegWall

function calculateLegWall{T}(tensorLeg::Array{T,4}, tensorWall::Array{T,5}, dimM::Int)
	projectorLegWall = getLegWallProjectorZ(tensorLeg, tensorWall, dimM)
	tensorLegWall = constructTensorLegWall(tensorLeg, projectorLegWall, tensorWall)
	return tensorLegWall
end

function getLegWallProjectorZ{T}(tensorLeg::Array{T,4}, tensorWall::Array{T,5}, dimM::Int)
	tenmatMMd = getTenmatMMd_LegWall(tensorLeg, tensorWall)
	projectorLegWall = getProjectorFromMMd(tenmatMMd, dimM)
	return projectorLegWall
end

function getTenmatMMd_LegWall{T}(tensorLeg::Array{T,4}, tensorWall::Array{T,5})
	@tensor begin
		dummy1[i,j,z1,a1] := tensorLeg[x,i,z1,z1p] * tensorLeg[x,j,a1,z1p]
		dummy2[i,z2,j,a2] := tensorWall[i,xp,s,z2,z2p] * tensorWall[j,xp,s,a2,z2p]
		tensorMMd[z1,z2,a1,a2] := dummy1[i,j,z1,a1] * dummy2[i,z2,j,a2]
	end
	tenmatMMd =tensor2tenmat(tensorMMd,[1,2],[3,4])
	return tenmatMMd
end

function constructTensorLegWall{T}(tensorLeg::Array{T,4}, projectorLegWall::Array{T,3}, tensorWall::Array{T,5})
	@tensor begin
		dummy1[x,i,z1p,z2,z] :=
		tensorLeg[x,i,z1,z1p] * projectorLegWall[z1,z2,z]
		dummy2[x,i,z2,z,z2p,zp] :=
		dummy1[x,i,z1p,z2,z] * projectorLegWall[z1p,z2p,zp]
		tensorLegWall[x,xp,s,z,zp] :=
		dummy2[x,i,z2,z,z2p,zp] * tensorWall[i,xp,s,z2,z2p]
	end
	return tensorLegWall
end

#---
# functions for
# WallCore

function calculateWallCore{T}(tensorWall::Array{T,5}, tensorCore::Array{T,6}, tensorUx::Array{T,3}, dimM::Int)
		projectorWallCore = getWallCoreProjectorZ(tensorWall, tensorCore, dimM)
		tensorWallCore = constructTensorWallCore(tensorWall, tensorUx, projectorWallCore, tensorCore)
		return tensorWallCore
end

function getWallCoreProjectorZ{T}(tensorWall::Array{T,5}, tensorCore::Array{T,6}, dimM::Int)
	tenmatMMd = getTenmatMMd_WallCore(tensorWall, tensorCore)
	projectorWallCore = getProjectorFromMMd(tenmatMMd, dimM)
	return projectorWallCore
end

function getTenmatMMd_WallCore{T}(tensorWall::Array{T,5}, tensorCore::Array{T,6})
	@tensor begin
		dummy1[i,z1,j,a1] :=
		tensorWall[x1,x1p,i,z1,z1p] * tensorWall[x1,x1p,j,a1,z1p]
		dummy2[i,z2,j,a2] :=
		tensorCore[x2,x2p,i,y,z2,z2p] * tensorCore[x2,x2p,j,y,a2,z2p]
		tensorMMd[z1,z2,a1,a2] :=
		dummy1[i,z1,j,a1] * dummy2[i,z2,j,a2]
	end
	tenmatMMd =tensor2tenmat(tensorMMd,[1,2],[3,4])
	return tenmatMMd
end

function constructTensorWallCore{T}(tensorWall::Array{T,5}, tensorUx::Array{T,3}, projectorWallCore::Array{T,3}, tensorCore::Array{T,6})
	@tensor begin
		dummy1[x1,x1p,i,z1p,z2,z] := 
		tensorWall[x1,x1p,i,z1,z1p] * projectorWallCore[z1,z2,z]
		dummy2[x1,x1p,i,z2,z,z2p,zp] :=
		dummy1[x1,x1p,i,z1p,z2,z] * projectorWallCore[z1p,z2p,zp]
		dummy3[x1,x1p,z,zp,x2,x2p,s] :=
		dummy2[x1,x1p,i,z2,z,z2p,zp] * tensorCore[x2,x2p,i,s,z2,z2p]
		dummy4[x1p,z,zp,x2p,s,x] :=
		dummy3[x1,x1p,z,zp,x2,x2p,s] * tensorUx[x1,x2,x]
		tensorWallCore[x,xp,s,z,zp] :=
		dummy4[x1p,z,zp,x2p,s,x] * tensorUx[x1p,x2p,xp]
	end
	return tensorWallCore
end

#----------------------------------------------------------------------
# functions mainly for the first part

#---
# calculate
# CoreCaret (attach Caret to yp index)
function calculateTensorCoreCaret{T}(tensorCore::Array{T,6}, tensorCaret::Array{T,3}, dimM::Int)
	tensorCoreCaret = calculateTensorCaretCore(tensorCaret, permutedims(tensorCore,[1,2,4,3,5,6]), dimM)
	return tensorCoreCaret
end

#---
# get functions for
# CaretCore (attach Caret to y index)

function calculateTensorCaretCore{T}(tensorCaret::Array{T,3}, tensorCore::Array{T,6}, dimM::Int)
  	tensorScProjectorZ = getScProjectorZ(tensorCaret, tensorCore, dimM)
  	tensorSc = constructTensorSc(tensorCaret, tensorScProjectorZ, tensorCore)
	return tensorSc
end

function getScProjectorZ{T}(tensorCaretY::Array{T,3}, tensorCore::Array{T,6}, dimM)
	tenmatMMd = getTenmatMMd_caretCore(tensorCaretY, tensorCore)
	tensorScProjectorZ = getProjectorFromMMd(tenmatMMd, dimM)
	return tensorScProjectorZ
end

function getTenmatMMd_caretCore{T}(tensorCaretY::Array{T,3}, tensorCore::Array{T,6})
	@tensor begin
		dummy1[i,z2,j,a2] :=
		tensorCore[x,xp,i,yp,z2,z2p] *
		tensorCore[x,xp,j,yp,a2,z2p]
		dummy2[z1,z1p,z2,j,a2] :=
		dummy1[i,z2,j,a2] *
		tensorCaretY[i,z1,z1p]
		tensorMMd[z1,z2,a1,a2] :=
		dummy2[z1,z1p,z2,j,a2] *
		tensorCaretY[j,a1,z1p]
	end
	tenmatMMd =tensor2tenmat(tensorMMd,[1,2],[3,4])
	return tenmatMMd
end

function constructTensorSc{T}(tensorCaretY::Array{T,3}, tensorScProjectorZ::Array{T,3}, tensorCore::Array{T,6})
	@tensor begin
		dummy1[x,xp,i,s,z2p,z1,z] :=
		tensorCore[x,xp,i,s,z2,z2p] *
		tensorScProjectorZ[z1,z2,z]
		dummy2[x,xp,s,z2p,z,z1p] :=
		dummy1[x,xp,i,s,z2p,z1,z] *
		tensorCaretY[i,z1,z1p]
		tensorSc[x,xp,s,z,zp] :=
		dummy2[x,xp,s,z2p,z,z1p] *
		tensorScProjectorZ[z1p,z2p,zp]
	end
	return tensorSc
end

#---
# calculate
# CoreLeg ( attach leg to the yp index )

function calculateTensorCoreLeg{T}(tensorCore::Array{T,6}, tensorCoretilde::Array{T,6}, tensorLeg::Array{T,4}, dimM::Int)
	tensorS, tensorStilde = calculateTensorLegCore(permutedims(tensorLeg,[2,1,3,4]), permutedims(tensorCore,[1,2,4,3,5,6]), permutedims(tensorCoretilde,[1,2,4,3,5,6]), dimM)
	return permutedims(tensorS,[1,2,4,3,5,6]), permutedims(tensorStilde,[1,2,4,3,5,6])
end

#---
# get functions for
# LegCore

function calculateTensorLegCore{T}(tensorLeg::Array{T,4}, tensorCore::Array{T,6}, tensorCoretilde::Array{T,6}, dimM::Int)
	# attach leg to the y index
  	tensorSProjectorZ = getSProjectorZ(tensorLeg, tensorCore, dimM)
  	tensorS = constructTensorS(tensorLeg, tensorSProjectorZ, tensorCore)
  	tensorStilde = constructTensorS(tensorLeg, tensorSProjectorZ, tensorCoretilde)
	return tensorS, tensorStilde
end

function getSProjectorZ{T}(tensorLegY::Array{T,4}, tensorCore::Array{T,6}, dimM::Int)
	tenmatMMd = getTenmatMMd_legCore(tensorLegY, tensorCore)
	tensorSProjectorZ = getProjectorFromMMd(tenmatMMd, dimM)
	return tensorSProjectorZ
end

function getTenmatMMd_legCore{T}(tensorLegY::Array{T,4}, tensorCore::Array{T,6})
	@tensor begin
		dummy1[j,z2,k,a2] :=
		tensorCore[x,xp,j,yp,z2,z2p] *
		tensorCore[x,xp,k,yp,a2,z2p]
		dummy2[j,z1,k,a1] :=
		tensorLegY[y,j,z1,z1p] *
		tensorLegY[y,k,a1,z1p]
		tensorMMd[z1,z2,a1,a2] :=
		dummy1[j,z2,k,a2] *
		dummy2[j,z1,k,a1]
	end
	tenmatMMd =tensor2tenmat(tensorMMd,[1,2],[3,4])
	return tenmatMMd
end

function constructTensorS{T}(tensorLegY::Array{T,4}, tensorSProjectZ::Array{T,3}, tensorCore::Array{T,6})
	@tensor begin
		dummy1[x,xp,j,yp,z2p,z1,z] :=
		tensorCore[x,xp,j,yp,z2,z2p] *
		tensorSProjectZ[z1,z2,z]
		dummy2[x,xp,yp,z2p,z,y,z1p] :=
		dummy1[x,xp,j,yp,z2p,z1,z] *
		tensorLegY[y,j,z1,z1p]
		tensorS[x,xp,y,yp,z,zp] :=
		dummy2[x,xp,yp,z2p,z,y,z1p] *
		tensorSProjectZ[z1p,z2p,zp]
	end
	return tensorS
end

#---
# get functions for
# caret

function calculateCaretTensor{T}(tensorQ::Array{T,4}, tensorUy::Array{T,3}, dimM::Int)
  	caretProjectorZ = getCaretProjectorZ(tensorQ, dimM)
	tensorCaretY = constructCaretY(tensorQ, tensorUy, caretProjectorZ)
	return tensorCaretY
end

function getCaretProjectorZ{T}(tensorQ::Array{T,4}, dimM::Int)
	tenmatMMd = getTenmatMMd_caret(tensorQ)
	caretProjectorZ = getProjectorFromMMd(tenmatMMd, dimM)
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
		tensorMMd[z1,z2,a1,a2] :=
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

######

function calculateLegTensor{T}(tensorPx::Array{T,5}, tensorUy::Array{T,3}, dimM::Int)
  	legProjectorZ = getLegProjectorZ(tensorPx, dimM)
  	tensorLegY = constructLegY(tensorPx, tensorUy, legProjectorZ)
	return tensorLegY
end

function getLegProjectorZ{T}(tensorPx::Array{T,5}, dimM::Int)
	tenmatMMd = getTenmatMMd_leg(tensorPx)
	legProjectorZ = getProjectorFromMMd(tenmatMMd, dimM)
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
		tensorMMd[z1,z2,a1,a2] :=
		dummy1[z1,a1,s,t] *
		dummy2[z2,a2,s,t]
	end
	tenmatMMd =tensor2tenmat(tensorMMd,[1,2],[3,4])
	return tenmatMMd
end

function constructLegY{T}(tensorPx::Array{T,5}, tensorUy::Array{T,3}, legProjectorZ::Array{T,3})
	@tensor begin
		dummy1[y1p,s,z1,z1p,y2,y] :=
		tensorPx[y1,y1p,s,z1,z1p] *
		tensorUy[y1,y2,y]
		dummy2[y2,s,z2,z2p,y1p,yp] :=
		tensorPx[y2p,y2,s,z2,z2p] *
		tensorUy[y1p,y2p,yp]
		dummy3[z1,z1p,y,z2,z2p,yp] :=
		dummy1[y1p,s,z1,z1p,y2,y] *
		dummy2[y2,s,z2,z2p,y1p,yp]
		dummy4[z1p,y,z2p,yp,z] :=
		dummy3[z1,z1p,y,z2,z2p,yp] *
		legProjectorZ[z1,z2,z]
		tensorLegY[y,yp,z,zp] :=
		dummy4[z1p,y,z2p,yp,z] *
		legProjectorZ[z1p,z2p,zp]
	end
	return tensorLegY
end


#---
# functions for Core Tensor

function calculateCoreTensors{T}(tensorT::Array{T,6}, tensorTtilde::Array{T,6}, dimM::Int; mirror::Bool = false)
 	tensorUy = getTensorUy(dimM, "x", tensorT, mirror = mirror)
 	tensorUz = getTensorUz(dimM, "x", tensorT, mirror = mirror)
	if mirror
		tensorT2 = mirrorTensorS(tensorT)
		tensorT2tilde = mirrorTensorS(tensorTtilde)
	else
		tensorT2 = tensorT
		tensorT2tilde = tensorTtilde
	end
  	tensorCore = getTensorCore(tensorT, tensorT2, tensorUy, tensorUz)
  	tensorCoretilde = getTensorCore(tensorT, tensorT2tilde, tensorUy, tensorUz)
	return tensorCore, tensorCoretilde, tensorUy
end

function getTensorUy{T}(dimM::Int, axis::AbstractString, tensorT::Array{T,6}; mirror::Bool = false)
	if axis == "x"
		if mirror
			tenmatMMd = getTenmatMMd_CoreCore(tensorT, mirrorTensorS(tensorT))
		else
			tenmatMMd = getTenmatMMd_CoreCore(tensorT)
		end
		tensorUy = getProjectorFromMMd(tenmatMMd, dimM)
		return tensorUy
	end
end

function getTensorUz{T}(dimM::Int, axis::AbstractString, tensorT::Array{T,6}; mirror::Bool = false)
	tensorUz = getTensorUy(dimM, axis, permutedims(tensorT,[1,2,5,6,4,3]), mirror = mirror)
	return tensorUz
end

function getTenmatMMd_CoreCore{T}(tensorT::Array{T,6}, tensorT2::Array{T,6} = tensorT)
	@tensor begin
		dummy1[i,y1,j,a1] :=
		tensorT[x,i,y1,y1p,z1,z1p] *
		tensorT[x,j,a1,y1p,z1,z1p]
		dummy2[i,y2,j,a2] :=
		tensorT2[i,xp,y2,y2p,z2,z2p] *
		tensorT2[j,xp,a2,y2p,z2,z2p]
		tensorMMd[y1,y2,a1,a2] :=
		dummy1[i,y1,j,a1] *
		dummy2[i,y2,j,a2]
	end
	tenmatMMd = tensor2tenmat(tensorMMd,[1,2],[3,4])
	return tenmatMMd
end

function getTensorCore{T}(tensorT1::Array{T,6}, tensorT2::Array{T,6}, tensorUy::Array{T,3}, tensorUz::Array{T,3})
	newTensorT = getNewTensorT_2dQ(permutedims(tensorT1,[3,4,5,6,1,2]),permutedims(tensorT2,[3,4,5,6,1,2]), tensorUy, tensorUz)
	# from:	 simulator_quantum_2d_square_renormalize.jl
	return permutedims(newTensorT, [5,6,1,2,3,4])
end

#---
# functions to creat projector
function getProjectorFromMMd{T}(matrix::Array{T,2},dimM::Int)
	tensorU, lambdaVector, tensorUd = svd(matrix)
	truncatedU = truncMatrixU(tensorU,dimM)
	tensorU = matU2tenU(truncatedU)
	return tensorU
end

function getProjectorFromMMd{T}(tenmatMMd::Tenmat{T}, dimM::Int)
	projectorMatrix = getMatrix(tenmatMMd)
	indicesTuple = tensorSize(tenmatMMd)[1:2]
	tensorU, lambdaVector, tensorUd = svd(projectorMatrix)
	truncatedU = truncMatrixU(tensorU,dimM)
	tensorU = matU2tenU_asym(truncatedU, indicesTuple)
	return tensorU
end

function matU2tenU_asym(matrixU::Matrix, indicesTuple::Tuple{Int,Int})
	sizeTuple = (indicesTuple[1], indicesTuple[2], size(matrixU,2))
	tenmatU = Tenmat(matrixU,[1,2],[3],sizeTuple)
	tensorU = tenmat2tensor(tenmatU)
	return tensorU
end
