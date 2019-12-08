# stata-tools
A collection of Stata scripts and dialog boxes
These scripts are developed as a side effect of my analyses using Stata. The help files and dialog boxes are part of my learning how to write Stata programs.
A list with the content of each program is below.
Not all programs are not yet available via the SSC, but will be in the future.

# Programs
* checkdim - Checks if a variable has observations for all categories of another variable. This tool is mainly used to check if a variable has values for all time periods e.g. years.
* emptyvar - Finds variables containing no values and drops them.
* expandIhlp - Integrates .ihlp files into normal help files to allow repeated usage of text without the need to ship the .ihlp-file(s) itself. This is mainly a convience tool other programmers.
* getperc - Returns the relative frequency of categorical variable for further processing. 
* multif - Constructs multiple if-restrictions. It allows to apply the same if-restriction(s) to different variables for the same command.
   Mainly delevoped and used for the *count* command, but it works for other scenarios as well 
* num2base26 - An interface to the *numbase26()* function of Mata. Converts a number to a letter. 
  Useful when creating Excel tables in Stata
  
# Installation
  To install the programs, just download them and the corresponding help file and dialog box to your local ado folder.
  Or run __net install <programname>, from(https://github.com/skbormann/stata-tools) replace__
