#Create latex table
#Import pandas
import pandas as pd
#Read from file
X=pd.read_csv('firstallavgplot.txt', sep='\t', header=None)
print(X)
