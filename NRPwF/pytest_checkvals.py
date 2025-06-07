from minizinc import *
from datetime import timedelta
import sys
import time
import numpy as np #Import numpy to get python format on matlab-output
import random

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
# nBioInstances = range(17,20)#[2,3,4,5,6,7,8,9,10,11,12,13,14] # example - range(3) or [0, 1, 2, 3]
nBioInstances = [17]
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
    allavgplotfile= open("allavgplot.txt","a")
    allavgplotfile.write("\n"+str(nBioInstance)+"\t")
    allavgplotfile.close()

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
    rosterinit = Model("./model__STUB_initialSol.mzn")
    # Find the MiniZinc solver configuration for Gurobi
    gurobi = Solver.lookup("gurobi")
    # gurobi = Solver.lookup("gecode")
    # Create an Instance of the roster model for Gurobi
    instance = Instance(gurobi, rosterinit)
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
    result = instance.solve()                                   #INITIAL SOLUTION FOUND HERE: BASE MODEL + "./model__STUB_initialSol.mzn"

    print(result.status)
    #################Get scores from initial sol
##    rostereval = Model("./EvaluateScore.mzn")
##    rostereval["nShift_WS_DATA_2D"]=result["nShift"]
##    evalinst = Instance(99,rostereval)
##    evalresults = evalinst.solve()
##    print(evalresults["score"])
##
    #print(result["nShift"])
    #print(result["score"])
    
    


    ListOfSols=[]
    ListOfSols=[result["nShift"]]
    ListOfApproxScores=[[[0]*nDays]*nNurses]
    
    if result.status.has_solution():                            #PHASE 2: BASE MODEL + "./model__STUB_phase2.mzn"
        stats = result.status
        # stats['status'] = str(result.status)
        print('Initial solution found obj approx. ', result.objective,'.\nStarting phase 2......')

        # Inputs and Model Extensions
        #extFatigue = extFatigue_LNS
        extShiftWork = extShiftWork_LNS
        applyMinWorkTime = applyMinWorkTime_LNS

        #print('---Change of Parameters: ', outputString , '---')
        f.write('---Change of Parameters: ' + outputString + '---\n')
        f.close()

        # for output purposes
        worstApproxScoresproxScores = []
        
        f = open(fileID+"solution.txt", "a")
        f.write('Initial SATISFY solution found.\nStarting phase 2......')
        print('--------------------------Objective: global minmax--------------------------')
        print('Runtime per LNS iteration: ',LNSminutes,' mins', LNSseconds, 'secs')
        
        write_2d_array_to_file("nShift",fileID+"solution.txt","a",result["nShift"],0,nNurseBioType)
        result_nShift = result["nShift"]
        result_score = []
        NurseID = 1
        DayID = 1
        
        WorstVals=10000;
        worseDays=[*range(nNurses)];
        
        SwitchNeighborhood=0;
        
        testWNURSES=set();#
        randNURSES=set();
        testWDAYS=set();

        plotfile= open("plot.txt","w")
        plotfile.write("Iteration\t Fatigue\n")
        plotfile.close()
        avgplotfile= open("avgplot.txt","w")
        avgplotfile.write("Iteration\t Fatigue\n")
        avgplotfile.close()
        #allavgplotfile= open("allavgplot.txt","a")
        #allavgplotfile.write("Iteration\t Fatigue\n")
        #allavgplotfile.close()
        
        # Load rostering model with score from file
        for iter in range(nLNS+1):
            f = open(fileID+"solution.txt", "a")

            if backendLNS == "gurobi":
                rosterimp = Model("./model__STUB__MIP_phase2.mzn")
            else:        
                rosterimp = Model("./model__STUB_phase2.mzn")
            # Set Chuffed parameter needed for LNS
            if backendLNS == "chuffed":
                params = { 'fzn-flags': '--restart constant'}
            else:
                params = { 'fzn-flags': '-restart constant'}
            # Find the MiniZinc solver configuration for Chuffed
            solverLNS = Solver.lookup(backendLNS)
            # Create an Instance of the rostering model with score for Chuffed
            instimp = Instance(solverLNS,rosterimp)
            
            if iter > int(nLNS-20) and iter:# <= int(nLNS-2):#WHEN SOME ITERATIONS REMAIN, MAKE CHANGES IN PARAMETERS
                if iter == int(nLNS-20)+1:
                    print('--------------------------Objective: avg. individual minmax--------------------------')
                    print('Runtime per LNS iteration: ',LNSminutes,' mins', LNSseconds, 'secs')
                fObjMinimiseSum=1
                 
                extShiftWork = extShiftWork_LNS_Mid
                LNSminutes=LNSminutes_Mid#Set runtime for new neighbourhood
                LNSseconds=LNSseconds_Mid
                worseDays=[]
                for n in range(0,nNurses):
                    HighestFatigue=max(resultimp["score"][n])           #Find individual worst fatigues
                    #IndWorstVals.append(HighestFatigue)
                    worseDays.append(resultimp["score"][n].index(HighestFatigue))
                
            else:
                 fObjMinimiseSum= 0 #Begin by minimizing worst case to get starting point.

            instimp["fObjMinimiseSum"]=fObjMinimiseSum
            instimp["Iteration"]=iter
            
            f.write('\nRuntime: ' + str(LNSminutes) + ' mins' + str(LNSseconds) + 'secs')
            #f.close()
            #sys.stdout.flush()

            #instimp["maxObj"] = int(WorstVals) #Set hard constraint on maximum fatigue
            # Assign warm start solution
            instimp["nShift_WS_DATA_2D"] = result_nShift
            instimp["nScore_DATA_2D"] = result_score
            instimp["prevObj"]=WorstVals
            # Assign inputs
            sys.stdout.flush()
            #instance["maxObj"] = maxObj
            instimp["nNurses"] = nNurses
            instimp["nDays"] = nDays
            # Assign model extensions
            #instimp["extFatigue"] = extFatigue
            instimp["extShiftWork"] = extShiftWork
            instimp["applyMinWorkTime"] = applyMinWorkTime
            # Bio Types
            instimp["nNurseBioType"] = nNurseBioType
            instimp["nDiff"] = nDiff
            instimp["worseDays"]=worseDays;
            
            instimp["SwitchNeighborhood"]=SwitchNeighborhood;
            instimp["testWNURSES"]=testWNURSES;
            instimp["randNURSES"]=randNURSES;

            
            instimp["nurID1"] = int(NurseID)
            instimp["d1"] = int(DayID)
          
            print(fObjMinimiseSum,SwitchNeighborhood)
            print(testWNURSES,randNURSES)
            
            # Run solver
            if backendLNS == "gurobi":
                resultimp = instimp.solve(timeout=timedelta(minutes=LNSminutes,seconds=LNSseconds))
            else:
                resultimp = instimp.solve(timeout=timedelta(minutes=LNSminutes,seconds=LNSseconds),free_search=True, **params)
            print(resultimp.status)
            if resultimp.status.has_solution():
                result_nShift = resultimp["nShift"]
                result_score = resultimp["score"]
            else:
                print('Cannot apply the pattern, continuing to the next iteration...',NurseID,',',DayID)
                f.write('Cannot apply the pattern, continuing to the next iteration...'+str(NurseID)+','+str(DayID))
                continue
                      
            
            #Get val highest values
            SolsDv = np.array(resultimp["score"])
            #print('AvgScore: '+str(AvgScore))
            #print('Average: '+str(Average))
            val=1 #Set val to some number
            SolsDv_1D=SolsDv.flatten() #1D for finding max vals        
            ind=np.argpartition(SolsDv_1D, -val)[-val:] #get ind values
            WorstValIndices=ind[np.argsort(SolsDv_1D[ind])] #Get indies in 1D for worst v values
            WorstVals=int(SolsDv_1D[WorstValIndices]) #Get val worst values
            #WorstValList.append(WorstVals) #Add to list of worst vals
            #Find all occurances of worst score
            #print(WorstVals)
            indexlist=list_duplicates_of(list(SolsDv_1D), WorstVals)
            #print(indexlist)
            testWNURSES=set();
            randNURSES=set();
            testWDAYS=set();

            for n in range(0,nNurses):
                for d in range(0,nDays):
                    if(SolsDv[n][d]==WorstVals):
                        testWNURSES.add(int(n+1))
                        testWDAYS.add(int(d+1))
                        for i in range(0,nDiff):
                            if DayID-(i+1)>=1:
                                testWDAYS.add(int(DayID-(i+1)))

            #for n in range(0,nNurses):
            #    if(SolsDv[n][d]==BestVals):
                    

            while len(randNURSES)<5:#+5*SwitchObj:
                randomNurse=random.randint(0,nNurses-1)
                if ((not randomNurse in randNURSES) and (not randomNurse in testWNURSES)):
                                        randNURSES.add(randomNurse)

            NurseID, DayID = np.unravel_index(WorstValIndices, SolsDv.shape) #Get indices in 2D
            NurseID=NurseID+1#Convert to 1-indexing in minizinc
            DayID=DayID+1#Convert to 1-indexing in minizinc


            #print(NurseID,nurID2,nurID3,nurID4,nurID5,nurID6,nurID7,nurID8,nurID9,nurID10)
            #print(DayID,d2,d3)
            #print(fObjMinimiseSum,SwitchNeighborhood)
            #print(testWNURSES)
            #print(testWDAYS)
            print("Nurses w/ max fatigue score ",testWNURSES)
            #testWNURSES={}
            if len(testWNURSES) > 5:
                SwitchNeighborhood=1
                saveset=testWNURSES
                testWNURSES=set(random.sample(sorted(testWNURSES),5))
            else:
                SwitchNeighborhood=0
            #    testWNURSES.add(random.sample(testWNURSES,5))
            
            ## input
            #fObjMinimiseSum = 0# use random.randint(0, 1) to toggle between two objective minimisation modes: 0 - minimize the maximum score in the entire roster, 1 - minimise sum of maximum score of each nurses
            
            FirstSol=result.objective;
            BestSol=resultimp.objective;
            
            IndWorstVals=[]
            plotfile= open("plot.txt","a")
            avgplotfile= open("avgplot.txt","a")
            for n in range(0,nNurses):
                #worseDays=[]
                HighestFatigue=max(resultimp["score"][n])           #Find individual worst fatigues
                IndWorstVals.append(HighestFatigue)
                plotfile.write(str(iter)+"\t"+str(HighestFatigue*0.01)+"\n")
            plotfile.close()

            avgplotfile.write(str(iter)+"\t"+str(sum(IndWorstVals)/len(IndWorstVals)*0.01)+"\n")
            avgplotfile.close()

            end = time.time()
            outputStats = "Iteration "+str(iter)+ "\t Avg ind max fatigue: "+str(round(sum(IndWorstVals)/nNurses))+"\t Max fatigue: "+str(WorstVals)+' ['+str(NurseID)+','+str(DayID)+'],\t Obj.func.: '+str(BestSol)+"\t Time: "+str(round(end - start))#, Approx avg: '+str(AvgScore) 
            
            print(outputStats)
            print(len(ListOfSols))
            print(len(ListOfApproxScores))
            sys.stdout.flush()
            
            
            # Write to file
            allavgplotfile= open("allavgplot.txt","a")
            allavgplotfile.write(str((sum(IndWorstVals)*0.01/nNurses))+"\t")
            allavgplotfile.close()
            
            f.write('\n'+outputStats)
            f.close()
            write_2d_array_to_file("nShift",fileID+"solution.txt","a",resultimp["nShift"],0,nNurseBioType)
            worstApproxScores = write_2d_array_to_file("score",fileID+"solution.txt","a",resultimp["score"],1,nNurseBioType)
            if not resultimp["nShift"] == ListOfSols[-1]:
                ListOfSols.append(resultimp["nShift"])
                ListOfApproxScores.append(resultimp["score"])

            #print(ListOfSols)
            
            
    else:
        print(result.status,"\nNo Initial Solution Found. Terminating...")

    
    if fEvalSol==1: #Get FRE-values of best solutions based on approximation
        ListOfEvalSols=[] #List all the solutions we perfrom FRE on
        ListOfEvalResults=[] #List all FRE scores
        ListOfEvalSolsDvMax=[]#List of all SolsDvMax
        ApproxErr=[0]*nNurses #List the error of FRE-approx for all sols
        DayOfSolsDvMax=[0]*nNurses #List the days the errors occur

        """Evaluate current solution"""                 
    
        #evalplotfile= open("evalplot.txt","w")
        #evalplotfile.write("Iteration\t Fatigue\n")
        #evalplotfile.close()

        #Import matlab to python
        import matlab.engine
        eng=matlab.engine.start_matlab()

        

        
        for listiter in [len(ListOfSols)-1]:#reversed(range(len(ListOfSols)-3,len(ListOfSols))):
            print('-------------------Full roster evaluation of solution ',listiter,'------------------------------')
            ApproxScores=ListOfApproxScores[listiter]#The approx-scores we want to compare real scores with
            


            

            Sols=np.zeros((nNurses,nDays)) #Will be filled with daily Dv vals


            #Use solution found previously
            #FirstSols=result["nShift"]
            #Sols=resultimp["nShift"]
            Sols=ListOfSols[listiter]
            
            SolsDv=np.zeros((nNurses,nDays)) #Will be filled with daily Dv vals
            SolsDvMax=np.zeros(nNurses) #Will be filled with daily Dv vals

            
            
            write_to_file (fileID+"solution.txt","a","FRE Evaluation of Solution found by LNS\n--------")
            # Store FRE worse score of each roster evaluated
            for n in range(0,nNurses):
                #Roster=FirstSols[n,:].tolist()
                #Run FRE of Roster, get only Dv output
                _,Dv,_,_,_,_,_ = eng.evalnumberedpattern(Sols[n],0,9999,9999,9999,9999,9999,0,NurseBioAll[nBioInstance][n],nargout=7)
                Dv=np.array(Dv._data)*100 #Conversion to list, get integer values like in minizinc
                Dv=Dv[0:2400*nDays] #Ignore last time increment to get 2400 each day
                # Dv=Dv.reshape(-1,2400) #Reshape to facilitate getting daily max
                Dv=np.max(Dv,axis=1) #Get daily max values
                SolsDv[n,:]=Dv #Store in SolsDv
                SolsDvMax[n]=np.max(Dv) #Individual maximum fatigue values, store in SolsDvMax
                DayOfSolsDvMax[n]=list(SolsDv[n,:]).index(SolsDvMax[n])
                ApproxErr[n]=SolsDvMax[n]-ApproxScores[n][DayOfSolsDvMax[n]]
                
                #print("Nurse ",n,"Dv:\t",Dv)
                #print("DvMax[n]\t",SolsDvMax[n])
                #AvgIndWorstValsFRE.append(
            #    write_to_file (fileID+"solution.txt","a",str(int(round(np.max(Dv)))))
                write_to_file("FRE_Scores.txt","a",str(NurseBioAll[nBioInstance][n]))
                write_1d_array_to_file("FRE_Scores.txt","a",Sols[n])
                write_to_file("FRE_Scores.txt","a",str(np.max(Dv)))

            #Get ind max values
            AvgIndWorstValsFRE=(sum(SolsDvMax)/nNurses)

            #Get val highest values
            val=1 #Set val to some number
            SolsDv_1D=SolsDv.flatten() #1D for finding max vals
            worstind=np.argpartition(SolsDv_1D, -1)[-1:] #get the worst value's ind
            TheWorstValIndex=worstind[np.argsort(SolsDv_1D[worstind])] #Get index in 1D for worst value
            TheWorstVal=SolsDv_1D[worstind] #get worst value

            ind=np.argpartition(SolsDv_1D, -val)[-val:] #get ind values
            WorstValIndices=ind[np.argsort(SolsDv_1D[ind])] #Get indies in 1D for worst v values

            
            WorstVals=int(SolsDv_1D[WorstValIndices]) #Get val worst values

            
            ListOfEvalSols.append(Sols)
            ListOfEvalResults.append(AvgIndWorstValsFRE)
            ListOfEvalSolsDvMax.append(SolsDvMax)

            
            
            #NurseID, DayID = np.unravel_index(WorstValIndices, SolsDv.shape) #Get indices of worst val in 2D

            #NurseID, DayID = np.unravel_index(ApproxErr.argmax(),ApproxErr.shape) # Get indices of worst approx in 2D

            NurseID=ApproxErr.index(max(ApproxErr))
            DayID=DayOfSolsDvMax[NurseID]
            
            NurseID=NurseID+1#Convert to 1-indexing in minizinc
            DayID=DayID+1#Convert to 1-indexing in minizinc

            end = time.time()
            outputStats = "\t Avg ind max fatigue: "+str(round(AvgIndWorstValsFRE))+"\t Max fatigue: "+str(WorstVals)+' ['+str(NurseID)+','+str(DayID)+'],\t\t Time: '+str(round(end - start))

            print('FRE:\t '+outputStats)
            print('Worst approx: ',max(ApproxErr),'\t Nurse: ',NurseID, '\t Day ',DayID)
            #print(WorstVals) #Just to check values
            #print(NurseID) #Just to check values
            #print(DayID) #Just to check values
            sys.stdout.flush()

            #write_2d_array_to_file("nShift",fileID+"solution.txt","a",resultimp["nShift"],0,nNurseBioType)
            FREScores = write_2d_array_to_file("FRE-scores",fileID+"solution.txt","a",SolsDv,1,nNurseBioType)

            #Formulate diff of FRE and RHE comparing Dv and ApproxScores
            #Find each nurse's worst score = SolsDvMax[n]
            #Find the same nurse's approx score on that same day

            


            
            """Perform improvement procedure"""                     #POST PROCESSING: PHASE 3

            NrIt=10
            
            if fPostProcess==1 and max(ApproxErr)>=10:
                
                it=0
                while it<NrIt:
                    """Here we use LNS to improve existing solution"""
                    if resultimp.status.has_solution():
                        stats = resultimp.stats
                        stats['status'] = str(resultimp.status)
                        it==it+1
                        print('Performing post-processing...(', it, ')...')
                        #print('Runtime: ',LNSminutes,' mins', LNSseconds, 'secs')
                        sys.stdout.flush()
                        # Load rostering model with score from file
                        rosterimp = Model("./model__STUB_phase3.mzn")
                        # Set Chuffed parameter needed for LNS
                        if backendLNS == "chuffed":
                            params = { 'fzn-flags': '--restart constant'}
                        else:
                            params = { 'fzn-flags': '-restart constant'}
                        # Find the MiniZinc solver configuration for Chuffed
                        solverLNS = Solver.lookup(backendLNS)
                        # Create an Instance of the rostering model with score for Chuffed
                        instimp = Instance(solverLNS,rosterimp)
                        # Assign warm start solution
                        instimp["nShift_WS_DATA_2D"] = resultimp["nShift"]
                        instimp["NurseID"] = set([NurseID])#set(NurseID)
                        instimp["DayID"] = set([DayID])#set(DayID)
                        # Assign inputs
                        instimp["fObjMinimiseSum"] = 0
                        #instance["maxObj"] = maxObj
                        instimp["nNurses"] = nNurses
                        instimp["nDays"] = nDays
                        # Assign model extensions
                        #instimp["extFatigue"] = extFatigue
                        instimp["extShiftWork"] = extShiftWork
                        instimp["applyMinWorkTime"] = applyMinWorkTime
                        # Bio Types
                        instimp["nNurseBioType"] = nNurseBioType
                        # Run solver
                        resultimp = instimp.solve(timeout=timedelta(minutes=LNSminutes,seconds=LNSseconds),free_search=True, **params)#Solve here
                        
                        #Use solution found previously
                        if resultimp.status.has_solution():
                            Sols=resultimp["nShift"]
                            ApproxScores=resultimp["score"]
                            SolsDv=np.zeros((nNurses,nDays)) #Will be filled with daily Dv vals
                            
                            write_to_file (fileID+"solution.txt","a","-----Post-processing iteration"+str(it)+"-----")

                            #for s in range(0,nSols):
                            for n in range(0,nNurses):
                                #Roster=Sols[n,:].tolist()
                                #Run FRE of Roster, get only Dv output
                                _,Dv,_,_,_,_,_ = eng.evalnumberedpattern(Sols[n],0,9999,9999,9999,9999,9999,0,NurseBioAll[nBioInstance][n],nargout=7)
                                Dv=np.array(Dv._data)*100 #Conversion to list, get integer values like in minizinc
                                Dv=Dv[0:2400*nDays] #Ignore last time increment to get 2400 each day
                                Dv=Dv.reshape(-1,2400) #Reshape to facilitate getting daily max
                                Dv=np.max(Dv,axis=1) #Get daily max values
                                SolsDv[n,:]=Dv #Store in SolsDv
                                SolsDvMax[n]=np.max(Dv) #Individual maximum fatigue values, store in SolsDvMax
                                DayOfSolsDvMax[n]=list(SolsDv[n,:]).index(SolsDvMax[n])
                                ApproxErr[n]=SolsDvMax[n]-ApproxScores[n][DayOfSolsDvMax[n]]

                                #write_to_file (fileID+"solution.txt","a",str(int(round(np.max(Dv)))))
                            #write_to_file (fileID+"solution.txt","a","--------")
               

        #plotfile= open("plot.txt","w")
        #plotfile.write("Iteration\t Fatigue\n")
        #plotfile.close()                            #print(SolsDv) #Just to check values. Looks right.

                            #Get val highest values
                            SolsDv_1D=SolsDv.flatten() #1D for finding max vals
                            worstind=np.argpartition(SolsDv_1D, -1)[-1:] #get the worst value's ind
                            TheWorstValIndex=worstind[np.argsort(SolsDv_1D[worstind])] #Get index in 1D for worst value
                            TheWorstVal=SolsDv_1D[worstind] #get worst value

                            ind=np.argpartition(SolsDv_1D, -val)[-val:] #get ind values
                            WorstValIndices=ind[np.argsort(SolsDv_1D[ind])] #Get indies in 1D for worst v values
                            WorstVals=int(SolsDv_1D[WorstValIndices]) #Get val worst values
                            #NurseID, DayID = np.unravel_index(WorstValIndices, SolsDv.shape) #Get indices in 2D


                            NurseID=ApproxErr.index(max(ApproxErr))
                            DayID=DayOfSolsDvMax[NurseID]
                            NurseID=NurseID+1#Convert to 1-indexing in minizinc
                            DayID=DayID+1#Convert to 1-indexing in minizinc

                            #print("Worst values according to the FRE")
                            #print(WorstVals) #Just to check values
                            #print(NurseID) #Just to check values
                            #print(DayID) #Just to check values
                            #sys.stdout.flush()
                            #Get ind max values
                            AvgIndWorstValsFRE=(sum(SolsDvMax)/nNurses)

                            ListOfEvalSols.append(Sols)
                            ListOfEvalResults.append(AvgIndWorstValsFRE)
                            ListOfEvalSolsDvMax.append(SolsDvMax)

                            end = time.time()
                            outputStats = "\t Avg ind max fatigue: "+str(round(AvgIndWorstValsFRE))+"\t Max fatigue: "+str(WorstVals)+' ['+str(NurseID)+','+str(DayID)+'],\t\t Time: '+str(round(end - start))

                            print('FRE:\t '+outputStats)
                            print('Worst approx: ',max(ApproxErr),'\t Nurse: ',NurseID, '\t Day ',DayID)
                            

                            if(max(ApproxErr)>=10):
                                BestSol=WorstVals
                                end = time.time()
                                outputStats = "\t Avg ind max fatigue: "+str(round(AvgIndWorstValsFRE))+"\t Max fatigue: "+str(WorstVals)+' ['+str(NurseID)+','+str(DayID)+'],\t\t Time: '+str(round(end - start))
                                print('FRE:\t '+outputStats)

                                write_2d_array_to_file("nShift",fileID+"solution.txt","a",resultimp["nShift"],0,nNurseBioType)
                                worstApproxScores = write_2d_array_to_file("score",fileID+"solution.txt","a",resultimp["score"],1,nNurseBioType)
                                FREScores = write_2d_array_to_file("FRE-scores",fileID+"solution.txt","a",SolsDv,1,nNurseBioType)
                                
                            else:
                                it=NrIt
                                print('Error of approx insignificant, post-processing successful.')
                            sys.stdout.flush()

                            #if(BestSol<=maxObj):
                            #    it=10
                            #    print('Post-processing successful.')
                        else:
                            print('minizinc.status: ',resultimp.status)
                            it=NrIt
                              
                    else:
                        print("No Solution Found. Terminating...",it)
                        it=NrIt

            elif fPostProcess==1 and max(ApproxErr)<10:
                print('Error of approx insignificant, post-processing not performed.')

        FinalVal=min(ListOfEvalResults)
        FinalValListIndex=ListOfEvalResults.index(FinalVal)

        avgplotfile= open("avgplot.txt","a")
        avgplotfile.write(str(nLNS+1)+"\t"+str(FinalVal*0.01)+"\n")
        avgplotfile.close()

        plotfile= open("plot.txt","a")
        for n in range(0,nNurses):
            plotfile.write(str(nLNS+1)+"\t"+str(ListOfEvalSolsDvMax[FinalValListIndex][n]*0.01)+"\n")
        plotfile.close()

        allavgplotfile= open("allavgplot.txt","a")
        allavgplotfile.write(str(FinalVal*0.01))
        allavgplotfile.close()
    
        print(int(FinalVal))
        print(ListOfEvalSols[ListOfEvalResults.index(FinalVal)])
        #f=open("allruns.txt","a")
        #f.write(fileID)
        #f.write(outputStats)
        #f.close()
    
        ## End time
        end = time.time()
        print("Time: "+str(end - start))
        f = open(fileID+"solution.txt", "a")
        f.write('\n Time: ' + str(end - start) + '\n============\n\n')
        f.close()

    
