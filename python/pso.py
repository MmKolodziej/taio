__author__ = 'Alek'

from pyswarm import pso

from dfa_test_func import *

no_states = 2.1
no_symbols = 3
lb = []
ub = []
for i in range(no_symbols*int(round(no_states+1))):
    lb.append(0)
    ub.append(no_states)


xopt, fopt = pso(dfa_pso_func, lb, ub, maxiter=300)
print xopt, fopt

rounded_xopt = []
for x in xopt:
    rounded_xopt.append(int(round(x)))

print rounded_xopt
