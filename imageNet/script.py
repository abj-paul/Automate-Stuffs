import os
import sys
import subprocess


from os import listdir
from os.path import isfile, join
mypath = sys.argv[1]
only_directory = [f for f in listdir(mypath)]

# Printing PWD to fix the variable "pwd" manually
test = subprocess.Popen(["pwd"], stdout=subprocess.PIPE)
output = test.communicate()[0]
print("pwd="+str(output))
pwd = "/home/abhijit/temp/experimentation/imageNet"+"/" # MUST EDIT THIS VARIABLE TO THE OUTPUT THAT COMES from pwd


# moving the files
for dir in only_directory:
    if isfile(dir)==False:
        files_in_dir = [f for f in listdir(pwd+dir+"/images/")]

        for file in files_in_dir:
            command = "cp"
            from_dir = pwd+dir+"/images/"+file
            to_dir = pwd+dir+"/"
            test = subprocess.Popen([command,from_dir, to_dir], stdout=subprocess.PIPE)
            output = test.communicate()[0]
 #       print(command+" "+from_dir+" "+to_dir)
