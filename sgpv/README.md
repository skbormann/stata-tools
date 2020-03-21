# SGPV
## Description
Second Generation P-Values (SGPV) based on the R-code by  Jeffrey D. Blume and Valerie F. Welty available [here](https://github.com/weltybiostat/sgpv)

## Changelog
The changelog is taken from the ado-files.

### General
General remarks if updates come in larger "packages".
* 21.03.2020: 
  * Added a dialog box for the sgpv-command. Instructions how to add the dialogs to the menubar can be found inside the sgpv.dlg file. 
  * The dialog boxes can be also added now by running __sgpv menuInstall__ or permanently added by running __sgpv menuInstall, perm__
  * Restructured all help files to allow a better understanding which options are mandatory and which are optional.
  * Restructured and improved the layout of all dialog boxes.
  * Added more examples for the original R-code to the help-files.

* 16.03.2020: 
  * Added more examples for the original R-code to the help-files.
  * Added dialog boxes for all commands except for the sgpv-command. Instructions how to add the dialogs to the menubar can be found inside the respective **command**.dlg file.

### fdrisk
* Version 0.97 : Added another input check for the pi0 option. Options altspace and nullspace deal now with spaces, but require their arguments now in "" if spaces are to be used with formulas.
* Version 0.96 : Minor bugfixes; added all missing examples from the R-code to the help file and some more details
* Version 0.95 : Updated documentation, added more possibilities to abbreviate options, probably last Github release before submission to SSC 
* Version 0.91 : Removed the dependency on the user-provided integrate-command -> Removed nomata option
* Version 0.90 : Initial Github release

### plotsgpv
* Version 0.98a: 
  * The option xshow() has now the same effect as in the R-code -> it sets correctly the limit of the x-axis.
  *	Changed the default behaviour of the nullpt-option to be the same as in the R-code. 
  * Now a line is only drawn if set, before it was to 0 as a default and always drawn.	
  *	Changed the default behaviour of xtitle() option -> now a default title is shown if not set.
  * Added do-file to make running the example in the help-file easier.
* Version 0.98 : 
  * Fixed nolegend-option -> disables now the legend as expected; minor updates to the help file and additional abbreviations for options
  * Fixed nullcol-option -> now parses correctly color names and sets the color correctly, previous only the default color was used
  * Fixed intcol-option -> now parses correctly color names and  RGB-values
* Changed behaviour of intcol-option -> now three separate color options for easier providing custom colors, the change is necessary to make it possible (easier) to set the colors in the dialog box 
* Version 0.91 : Changed the handling of additional plotting options to avoid hard to understand error messages of the twoway-command. Corrected minor errors in the documentation
* Version 0.90 : Initial Github release

### sgpower
* Version 0.92	: Fixed some issues in the documentation, changed the renamed the returned results to be the same as in the original R-code.
* Version 0.91a	: Fixed some issues in the documentation.
* Version 0.91 	: Removed dependency on user-provided integrate-command. 
* Version 0.90 	: Initial Github Release

### sgpv
* Version 0.98 : Added a subcommand to install the dialog boxes to the User's menubar. Fixed an incorrect references to the leukemia example in the help file.
* Version 0.97 : Further sanity checks of the input to avoid conflict between different options, added possibility to install dialog box into the User menubar.
* Version 0.96 : Added an example how to calculate all statistics for the leukemia dataset; minor fixes in the documentation of all commands and better handling of the matrix option.
* Version 0.95 : Fixed minor mistakes in the documentation, added more information about SGPVs and more example use cases; minor bugfixes; changed the way the results are presented
* Version 0.90 : Initial Github release

### sgpvalue
* Version 0.98a: 
	* Fixed an incorrect comparison -> now the correct version of the SGPV algorithm should be chosen if c(matsize) is smaller than the input matrix; added more examples from the original R-code to the help-file.
	* Fixed a bug with the nodeltagap-option.
	* Added more examples from the R-code (as a do-file).
* Version 0.98 : Implement initial handling of infinite values (one sided intervals) -> not 100% correct yet -> treatment of missing values in variables is questionable and might need further thought and changes
* Version 0.95a: Fixed some issues in the documentation.
* Version 0.95 : 
  * Added support for using variables as inputs for options esthi() and estlo(); Added Mata function for SGPV calculations in case c(matsize) is smaller than the input vectors; 
  * Added alternative approach to use variables for the calculations instead if variables are the input -> Mata is relatively slow compared to using only variables for calculations.
* Version 0.9  : Initial release to Github 

## To-Do-List and Limitations
A collection of things that I want to do at some point + some limitations of the current versions of the commands

### fdrisk
*   Rewrite to use Mata whenever possible instead of workarounds in Stata -> Shorten the code and make it faster
* 	Evaluate input of options directly with the expression parser `= XXX' to allow more flexible input -> somewhat done, but not available for all options
* 	Rewrite input logic for nullspace and altspace to allow spaces in the input and make it easier to generate inputs in the dialog box

### plotsgpv


### sgpower
* Works only on one interval and one true value at the moment; 
* The standard error has to be a number and cannot be an expression like in the R-code
* Not possible to plot directly the power function yet, an example how to plot the power function is located in the file sgpower_plot_example.do
* The displayed results could be labeled better and explain more but for now they are the same as in the original R-code.

### sgpv
* support for more commands which do not report their results in a matrix named "r(table)".
* Make results exportable or change the command to an e-class command to allow processing in commands like esttab or estpost from Ben Jann 
* Make matrix parsing more flexible and rely on the names of the rows for identifiying the necessary numbers; allow calculations for more than one stored estimate
* Return more infos
* Allow plotting of the resulting SGPVs against the normal p-values directly after the calculations
* Calculate automatically a null interval based on the statistical properties of the dependent variable of an estimation to encourage the usage of interval null-hypotheses.
* change the help file generation from makehlp to markdoc for more control over the layout of the help files -> currently requires a lot of manual tuning to get desired results.
* improve the speed of fdrisk.ado -> probably the integration part takes too long.
* add an imediate version of sgpvalue similar like ttesti-command; allow two sample t-test equivalent 

### sgpvalue
* At some point rewrite the code to use only Mata for a more compact code -> currently three different versions of the same algorithm are used. 
* Some input error checks are still missing



