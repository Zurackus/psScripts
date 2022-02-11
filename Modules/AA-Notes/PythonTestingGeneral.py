#Python Testing General
import os 
  
# Get the current working   
# directory (CWD)   
cwd = os.getcwd()   
print("Current Directory:", cwd) 
  
# Get the directory of  
# script 
script = os.path.realpath(__file__) 
print("SCript path:", script) 

print(os.getenv('LOCALAPPDATA'))

print(os.path.join(os.getenv('LOCALAPPDATA'), "WorkFiles"))