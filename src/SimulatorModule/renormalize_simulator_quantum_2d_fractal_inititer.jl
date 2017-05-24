function renormalizeTrotter!{T}(simulator::Quantum2dFractalInititerSimulator{T}, dimM::Int)
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


#---------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------
function renormalizeSpace!{T}(simulator::Quantum2dFractalInititerSimulator{T}, dimM::Int)
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
