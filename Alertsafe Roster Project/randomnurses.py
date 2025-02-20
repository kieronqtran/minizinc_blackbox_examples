NrInstances=20
import random
for i in range(0,NrInstances):
              NurseBio = []
              for j in range(0,30):
                            seed = random.randint(1,100)
                            if seed<=64:
                                          NurseBio.append(1)
                            elif seed<=72:
                                          NurseBio.append(2)
                            elif seed<=80:
                                          NurseBio.append(3)
                            elif seed<=88:
                                          NurseBio.append(4)
                            elif seed<=89:
                                          NurseBio.append(5)
                            elif seed<=90:
                                          NurseBio.append(6)
                            elif seed<=98:
                                          NurseBio.append(7)
                            elif seed<=99:
                                          NurseBio.append(8)
                            else:
                                          NurseBio.append(9)
              NurseBio.sort()
              print(NurseBio,",")
