workspace()
using HoTRG_lemon.SimulatorModule
using HoTRG_lemon.SpinModule
using HoTRG_lemon.LatticeModule
using TensorOperations
using TensorMatrices_lemon

dimM = 5
trotterparameter = 0.01
trotteriteration = 40

isinginfo = SpinInfo("quantum_ising_2",1.0e-13,0.0)
trotterinfo = TrotterInfo(trotterparameter, trotteriteration)
ising = QuantumIsingModel(isinginfo, trotterinfo)
lattice = buildLattice("quantum_2d_fractal", ising)
# simulator = buildSimulator(lattice,dimM)
simulator = Quantum2dFractalInititerSimulator(lattice, dimM, 0)
#simulator = buildSimulator(lattice,dimM)

fieldrange = linspace(0.1,3.5,10)
simulatorQuantum(fieldrange, simulator; filename = "datai0.txt")
println("fractal---------------")
# simulatorQuantum(fieldrange, simulator0; filename = "data0.txt")
#tensorT = getTensorT(simulator)[1]
#tenmatMMd = getTenmatMMd(tensorT)
#Ul, lambdaVector, Uld = svd(tenmatMMd.matrix)
#trunUl = truncMatrixU(Ul,dimM)
#tensorU = matU2tenU(trunUl)
