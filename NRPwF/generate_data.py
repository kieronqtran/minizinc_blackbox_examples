from minizinc import *
from datetime import timedelta
import sys
import time
import numpy as np #Import numpy to get python format on matlab-output
import random
import os
from datetime import timedelta

def write_to_file(file, mode, string):
    f = open(file, mode)
    f.write('\n'+string)
    f.close()

def write_1d_array_to_file(file, mode, array_1d):
    f = open(file, mode)
    f.write('\n')
    for i in array_1d:
        f.write(str(i)+',')
    f.close()
 
def write_2d_array_to_file(caption, file, mode, array_2d, printMax, BioTypes):
    f = open(file, mode)
    f.write('\n' + caption + '\n')
    idx = 0
    maxVals = []
    for i in array_2d:
        idx += 1
        if printMax:
            maxVal = 0
            for j in i:
                if maxVal < j:
                    maxVal = j

            try:
                maxVals.append(maxVal)
            except:
                maxVals = maxVal
            maxValCount = 0
            for j in i:
                if maxVal == j:
                    maxValCount += 1
            f.write('Nurse ' + str(idx) + ',\t BioType ' + str(BioTypes[idx-1]) +  ', \t Worst score: ' + str(maxVal)+ ', \t #times: ' +str(maxValCount)+':\n' + str(i) +'\n')
        else:
            nD = 0
            nE = 0
            nN = 0
            nO = 0
            for j in i:
                if j == 0:
                    nO += 1
                elif j == 1:
                    nD += 1
                elif j == 2:
                    nE += 1
                else:
                    nN += 1
            f.write('Nurse ' + str(idx) + ',\t BioType ' + str(BioTypes[idx-1]) + ':\t Off:' + str(nO) + ',\t Day:' + str(nD) + ',\t Eve' + str(nE) + ',\t Night' + str(nN) + ':\n' + str(i) +'\n')
    f.close()
    #print(maxVals)
    return maxVals

def list_duplicates_of(seq,item):
    start_at = -1
    locs = []
    while True:
        try:
            loc = seq.index(item,start_at+1)
        except ValueError:
            break
        else:
            locs.append(loc)
            start_at = loc
    return locs



#### =============== INPUT  ===============####
#### ======================================####
## Run settings
#Minimize worst case =0, Minimize average=1
fObjMinimiseSum=0
# Evaluate solution
fEvalSol = 1
# Post processing
fPostProcess = 0
# Inputs
#nNursesInit = [30] # example - [30,27]
nDays=42
# Bio instance
nBioInstances = range(17,20)#[2,3,4,5,6,7,8,9,10,11,12,13,14] # example - range(3) or [0, 1, 2, 3]
# Set bio types of nurses
NurseBioAll = [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 4, 4, 7, 7, 7] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 3, 4, 4, 4, 4, 4, 7, 7, 7, 7, 7] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 4, 7, 9, 9] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3, 4, 4, 4, 4, 4, 6, 7, 7, 7, 8, 8, 9] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3, 4, 4, 4, 4, 4, 6, 7, 7, 7, 9] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 5, 7, 9] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 3, 3, 7, 7, 7, 7, 8, 9] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 5, 5, 8] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 4, 4, 5, 6, 7] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 3, 4, 4, 4, 4, 6, 9] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 4, 4, 7, 7, 7] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 3, 4, 4, 4, 4, 4, 7, 7, 7, 7, 7] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 4, 7, 9, 9] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3, 4, 4, 4, 4, 4, 6, 7, 7, 7, 8, 8, 9] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3, 4, 4, 4, 4, 4, 6, 7, 7, 7, 9] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 5, 7, 9] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 3, 3, 7, 7, 7, 7, 8, 9] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 5, 5, 8] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 4, 4, 5, 6, 7] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 3, 4, 4, 4, 4, 6, 9] ,#20
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 7, 7, 8, 9] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 4, 4, 5, 7, 7, 8] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3, 3, 4, 7, 7] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 7, 7, 7, 9] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3, 3, 4, 4, 4, 7, 9] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 4, 4, 4, 7, 7, 7, 7, 7, 7] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 4, 4, 5, 7, 7, 7] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 4, 4, 4, 7, 7] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 4, 4, 7, 7, 7] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 7] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 4, 4, 7, 7, 7,7] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 4, 4, 4, 4, 4, 4, 7, 7, 8] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 7, 7] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 5, 6, 6, 7, 7, 7, 7] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 6, 7, 9] ,
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 7, 7, 9] ,
                #[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 4, 4, 4, 4, 6, 7, 7, 8] ,
                #[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 3, 3, 3, 3, 4, 5, 6] ,
                #[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 4, 7, 7, 8] ,
                #[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3, 3, 4, 4, 4] ,
                #[1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 1, 1],
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
                [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
                [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4],
                [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
                [6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6],
                [7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7],
                [8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8],
                [9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9],
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7],
                [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8],
                [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9],
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
                [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6],
                [7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9],
                [1, 1, 2, 1, 4, 2, 2, 3, 3, 6, 1, 7, 4, 1, 1, 1, 2, 7, 3, 1, 1, 3, 1, 1, 4, 1, 7, 2, 1, 1],
                #[4, 1, 1, 1, 7, 4, 7, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 5, 1, 4, 1, 4, 1, 7, 1, 1, 1, 1, 1],
                #[2, 1, 1, 1, 1, 1, 1, 3, 4, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 8, 3, 1, 1, 1, 8, 9],
                #[1, 2, 3, 4, 5, 6, 7, 8, 9, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8],
                ]

## Initial run parameters
# Model Extensions
#extFatigue_INIT = 0
extShiftWork_INIT = 1
applyMinWorkTime_INIT = 1

## LNS related parameters
# No of LNS iterations
nLNS = 50
# run time
LNSseconds_Strt = 0
LNSminutes_Strt = 1
# solver
backendLNS = "chuffed"
# Model extension
#extFatigue_LNS = 1
extShiftWork_LNS = 1
applyMinWorkTime_LNS = 1

# option to change the shift work rule on/off half way through
LNSseconds_Mid = 0
LNSminutes_Mid = 1
extShiftWork_LNS_Mid = 1

#### ======================================####
#### ======================================####

LNSseconds=LNSseconds_Strt
LNSminutes=LNSminutes_Strt;

allavgplotfile= open("allavgplot.txt","w")
allavgplotfile.write("Instance\t")
for it in range(nLNS+2):
    allavgplotfile.write("Iteration"+str(it)+"\t")
allavgplotfile.close()

for nBioInstance in nBioInstances:#Find the nurse's biotype (depends on instance)
    # allavgplotfile= open("allavgplot.txt","a")
    # allavgplotfile.write("\n"+str(nBioInstance)+"\t")
    # allavgplotfile.close()

    nNurses=len(NurseBioAll[nBioInstance])
    # Clear solution file
    fileID="Biocase="+str(nBioInstance)+"Days="+str(nDays)+"_"
    write_to_file(fileID+"solution.txt","w","")
    ## Start timing
    start = time.time()
    
    nNurseBioType = NurseBioAll[nBioInstance]#Create list of the Biotypes for each Nurse in the instance
   
    # Model Extensions
    #extFatigue = extFatigue_INIT
    extShiftWork = extShiftWork_INIT
    applyMinWorkTime = applyMinWorkTime_INIT
    
    #nNbhType = 1 # 1-Random, 2 - Worst fatigue, 3 - Combo
    nDiff = 0 # recommended 0, but possible 1..3

    outputString = 'nNurses ' + str(nNurses) + ', nDays ' + str(nDays) + ', nBioInstance ' + str(nBioInstance) +', LNStimes (mins) ' + str(LNSminutes)+', '+str(LNSminutes_Mid)+', '#+', extFatigue ' + str(extFatigue) + ', extShiftWork, ' + str(extShiftWork) + ', applyMinWorkTime, ' + str(applyMinWorkTime)

    print('\n\n\n ===Parameters: ', outputString, '===')
    sys.stdout.flush()

    # Write stats and solution to file
    f = open(fileID+"solution.txt", "a")
    f.write('===Parameters: ' + outputString + '===\n')

    # Load score-free rostering model from file
    rosterinit = Model("./model__STUB_BASE.mzn")
    # Find the MiniZinc solver configuration for Gurobi
    # solver = Solver.lookup("gurobi")
    solver = Solver.lookup("gecode")
    # solver = Solver.lookup("chuffed")
    # Create an Instance of the roster model for Gurobi
    instance = Instance(solver, rosterinit)
    # Assign inputs
    #instance["FatigueConstr"] = FatigueConstr
    instance["nNurses"] = nNurses
    instance["nDays"] = nDays

    # Assign model extensions
    #instance["extFatigue"] = extFatigue
    instance["extShiftWork"] = extShiftWork
    instance["applyMinWorkTime"] = applyMinWorkTime
    # Bio Types
    instance["nNurseBioType"] = nNurseBioType
    print(instance._data)
    result = instance.solve(timeout=timedelta(minutes=10), all_solutions=True, intermediate_solutions=True)                                   #INITIAL SOLUTION FOUND HERE: BASE MODEL + "./model__STUB_initialSol.mzn"
    print(result.status)
