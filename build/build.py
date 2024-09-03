import os

with open('env.config', 'r') as file:
    line = file.readline().strip()  # Read the first line and remove any trailing whitespace/newline

key, value = line.split(',', 1)
value = value.strip('"')  

# Run vivado in tcl mode and pass the Vivado script
os.system(value + " -mode tcl")