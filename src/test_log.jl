workspace()
using HoTRG_lemon.SimulatorModule
using HoTRG_lemon.SpinModule
using HoTRG_lemon.LatticeModule
using TensorOperations
using TensorMatrices_lemon

dimM = 5
inititer = 1
trotterparameter = 0.01
trotteriteration = 40

isinginfo = SpinInfo("quantum_ising_2",1.0e-13,0.0)
trotterinfo = TrotterInfo(trotterparameter, trotteriteration)
ising = QuantumIsingModel(isinginfo, trotterinfo)
lattice = buildLattice("quantum_2d_fractal", ising)
simulator = buildSimulator(lattice,dimM, inititer)

# print("Input Float for external field: ")
# fieldrange = parse(Float64, readline())
fieldrange = 3.0
# simulatorQuantum(fieldrange, simulator; filename = "log.txt")
simulator(printlog="maxTensor")
