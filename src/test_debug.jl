workspace()
using HoTRG_lemon.SimulatorModule
using HoTRG_lemon.SpinModule
using HoTRG_lemon.LatticeModule
using TensorOperations
using TensorMatrices_lemon

dimM = 5
trotterparameter = 0.01
trotteriteration = 10

isinginfo = SpinInfo("quantum_ising_2",1.0e-13,0.0)
trotterinfo = TrotterInfo(trotterparameter, trotteriteration)
ising = QuantumIsingModel(isinginfo, trotterinfo)
lattice = buildLattice("quantum_2d_fractal", ising)
simulator = buildSimulator(lattice,dimM)

# sqLattice = buildLattice("quantum_2d_square", ising)
# sqSimulator = buildSimulator(sqLattice,dimM)

# println(simulator())
# println(sqSimulator())

# fieldrange = linspace(0.1, 3.5, 10)
fieldrange = 3.5
simulatorQuantum(fieldrange, simulator; filename = "log_coef.txt")
 # simulatorQuantum(fieldrange, sqSimulator; filename = "q2s_m6_t30_ori_m7.txt")
#tensorT = getTensorT(simulator)[1]
#tenmatMMd = getTenmatMMd(tensorT)
#Ul, lambdaVector, Uld = svd(tenmatMMd.matrix)
#trunUl = truncMatrixU(Ul,dimM)
#tensorU = matU2tenU(trunUl)
