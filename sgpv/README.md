# SGPV
## Description
Second Generation P-Values (SGPV) based on the R-code by  Jeffrey D. Blume and Valerie F. Welty available [here](https://github.com/weltybiostat/sgpv)

## Changelog
The changelog is taken from the ado-files and slightly modified.

### General
General remarks if updates come in larger "packages".
* 27.12.2020:
  * Made the syntax of most commands more Stata like and less R-like. Removed several options and replaced by them with default settings. The old syntax still works.
  * Certification scripts for each command are now available but not part of the package distribution. For now only the accuracy of the results is tested but later tests for input errors might be added.

* 17.05.2020:
  * Changed type of returned results from macro to scalar to be more inline with standard practises for the commands __fdrisk__ and __sgpower__
  * Various additional input checks for __sgpvalue__ and __sgpv__
  * _sgpv_ supports now new subcommands, so that __sgpv__ can be used instead of __fdrisk__, __sgpower__, __sgpvalue__ and __plotsgpv__. This is convenience feature to make __sgpv__ even more the central command of this package.
  * Coefficient selection in __sgpv_ works as promised in the dialog box
  * The behaviour of the _nobonus-option_ of __sgpv__ got changed to behave like a _bonus statistics-option_ 
  * Using the default point 0 null-hypothesis for __sgpv__ is now more openly discouraged to promote using an interval null-hypothesis instead.  

* 26.03.2020:
  * Submission of the commands to SSC
  * Minor corrections in all help files -> Correction of spelling mistakes, incorrect format, etc.

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
* Version 1.2  22.02.2022 : Depreciated the old syntax. The old syntax did not work as intended after the switch to the new syntax.
* Version 1.1  24.12.2020 : 
  * Option sgpval became one option 'fcr'. The default is to calculate the Fdr.
  * Option nullweights became option 'nulltruncnormal'. The former option nullweights("Point") is automatically selected if option nullspace contains only one element. If option nullspace contains two elements then the Uniform distribution is used as the default distribution. 
  * Option altweights became 'alttruncnormal'. The option altweights("Point") is automatically selected if option altspace contains only one element. If option altspace contains two elements then the Uniform distribution is used as the default distribution. 
  * Options inttype and intlevel became options level(#) and likelihood(#). If no option is set then the confidence interval with the default confidence interval level is used. 
* Version 1.04 09.11.2020 : Changed in the dialog the option sgpval (Set Fdr/Fcr) to display "Fdr" or "Fcr" instead of numerical values.
* Version 1.03 24.05.2020 : Added more input checks 
* Version 1.02 14.05.2020 : Changed type of returned results from macro to scalar to be more inline with standard practises
* Version 1.01 : Removed unused code for Generalized Beta distribution 
* Version 1.00 : Initial SSC release, no changes compared to the last Github version.
* Version 0.97a: Made error messages hopefully more understandable.
* Version 0.97 : 
  * Added another input check for the pi0 option. 
  * Options altspace and nullspace deal now with spaces, but require their arguments now in "" if spaces are to be used with formulas.
* Version 0.96 : Minor bugfixes; added all missing examples from the R-code to the help file and some more details
* Version 0.95 : Updated documentation, added more possibilities to abbreviate options, probably last Github release before submission to SSC 
* Version 0.91 : Removed the dependency on the user-provided integrate-command -> Removed nomata option
* Version 0.90 : Initial Github release

### plotsgpv
* Version 1.05 31.12.2021 : Fixed/improved handling of situations with low number of observations.
* Version 1.04 02.07.2020 : 
	* Fixed/improved the support for matrices as input for options "esthi" and "estlo".
	* Removed noshow-option because it was never needed. The results of the sgpv-calculations were never shown even without this option set. 
	* Fixed non working combinations of variables as inputs and the nomata-option.
	* Changed the legend slightly to be more in line with R-code.
* Version 1.03 18.06.2020 : Changed the order in the legend to match the order in the R-code.
* Version 1.02 05.06.2020 : nomata-option will now be set correctly if variables are used as inputs for estimated intervals.
* Version 1.01 29.03.2020 : Added code for the cornercase that the ordering is set "sgpv", no variables as inputs are used and the matrix size exceeds c(matsize) -> uses Ben Jann's mm_cond() function (necessary code is included to avoid having the moremata-package installed ) -> not tested the code yet due to lack of test cases 
* Version 1.00 : Initial SSC release, no changes compared to the last Github version.
* Version 0.98a: 
  * The option xshow() has now the same effect as in the R-code -> it sets correctly the limit of the x-axis.
  *	Changed the default behaviour of the nullpt-option to be the same as in the R-code. 
  * Now a line is only drawn if set, before it was set to 0 as the default and always drawn.	
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
* Version 1.05 24.12.2020 : Options "inttype" and "intlevel" were renamed to "level" and "likelihood". The old syntax still works.
* Version 1.02 10.07.2020 : Fixed a missing bonus statistic ('at 0') in the help-file and the code.
* Version 1.01 14.05.2020 : Changed type of returned results from macro to scalar to be more inline with standard practise
* Version 1.00  : Initial SSC release, no changes compared to the last Github version.
* Version 0.92	: Fixed some issues in the documentation, changed the renamed the returned results to be the same as in the original R-code.
* Version 0.91a	: Fixed some issues in the documentation.
* Version 0.91 	: Removed dependency on user-provided integrate-command. 
* Version 0.90 	: Initial Github Release

### sgpv
* Version 1.2.3 25.05.2022: Fixed a bug when running "sgpv menu, remove" under Linux.
* Version 1.2.2 20.05.2022: 
	* Fixed a bug which prevented the subcommands from running under some circumstances. 
	* Fixed a bug which did not remove all entries added by the command sgpv menu, permdialog from the profile.do. 
	* Added an explanation to the help file how to remove the entries manually if the remove option fails.
* Version 1.2.1 13.05.2022: 
	* Fixed a bug introduced by removing the support for the original R-syntax for fdrisk, so that the options fdrisk and all did not work anymore.   
	* Removed the code to support the original R-syntax for fdrisk. 
	* Removed the support for the already depreciated bonus option. 
	* Fixed a bug that the deltagap has always been calculated and displayed even if the deltagap-option or the all-option had not been set.
* Version 1.2c 14.02.2022: Fixed a bug when using the coefficient-option together with noconstant-option.  Support for Mata to calculate Fdrs has been removed, because it did not work as intended and offered no significant speed advantage.
* Version 1.2b 10.06.2021: Added option to use Mata to calculate the Fdrs; requires the moremata-package by Ben Jann.
* Version 1.2a 01.02.2021 : Fixed a bug with the level option. Fixed a bug with regards to leading whitespaces when prefixing sgpv.
* Version 1.2 27.12.2020 : 
  * Changed the name of the option permament to permdialog to clarify the meaning of the option. 
  * Fixed the format option in the Dialog box. 
  * Added a remove option for the menu subcommand to remove the entries in the profile.do created by the option permdialog.
  * Renamed the dialog tab "Display" to "Reporting". Moved the options from the dialog tab "Fdrisk" to dialog tab "Reporting". 
  * Depreciated the option bonus() and replaced it with the new options "deltagap", "fdrisk" and "all" which have the same effect as the previous bonus() option. This way is more in line with standard Stata praxis. The bonus option still works but is no longer supported.
  * Added a forgotten option to calculate the bonus statistics in the example file sgpv-leukemia-example.do and fixed the size of the final matrix. 
  * Removed the fdrisk-options "nullspace" and "nullweights" because they were redudant and added a new option "truncnormal" to request the truncated Normal distribution for the null and alternative space. 
  * Renamed the options "intlevel" and "inttype" to "level" and "likelihood". The level-option works like the same named option in other estimation command. It sets the level of the confidence interval. This option overwrites the level option of an estimation command. 
  * The likelihood-option is meant to be used together with the matrix-option. 
  * The previous inttype and intlevel options did not work as intended. 
  * The title for results matrix now shows the level and type which was used to calculate the SGPVs (, delta-gaps and Fdrs). 
  * Calculating SGPVs for stored estimations will only show the SGPV results and not the saved estimation results.
* Version 1.1a 08.07.2020 : Changed the subcommand "fdrisk" to "risk" to be in line with the Python code.
* Version 1.1  28.05.2020 : 
  * Added support for multiple null hypotheses. 
  * Added a noconstant-option to remove the constant from the list of coefficients. 
  * Fixed an error in the perm-option of the "sgpv menu"-subcommand.
  * Fixed a confusion in the help-file about the nulllo and nullhi options.
  *	Added an experimental, undocumented option to enter the null interval -> option "null" with syntax "(lower_bound1,upper_bound2) (lower2,upper2) ... " 
  * Should allow now to use expressions for options "nulllo" and "nullhi" without having to run the expression parser first.
  * Removed unused "altspace" option from the syntax, help file and dialog box -> "altspace" is automatically set with lower and upper bounds of confidence intervals -> fixed remarks related to default values for altspace and nullspace.
* Version 1.03a 17.05.2020 : 
  * Made the title of the displayed matrix adapt to the type of null-hypothesis
  * Fixed a wrong file name in the sgpv-leukemia-example.do -> should now load the dataset
  * Minor improvements and fixes in the example section of the help file:
    * Added more structure to the examples and easier nagivation 
    * Added a new example showing how to apply a different null-hypothesis for each coefficient
	* Added an example how to export results by using estout from Ben Jann
* Version 1.03 13.05.2020 : 
  * added better visible warnings against using the default point 0 null-hypothesis after the displayed results -> warnings can be disabled by an undocumented option 
  * added some more warnings in the description of the options
  * Fixed: the Fdr's are now displayed when using the bonus-option with the values "fdrisk" or "all"
* Version 1.02 03.05.2020 :
	* Changed name of option 'perm' to 'permanent' to be inline with Standard Stata names of options
	* Removed some inconsistencies between help file and command file (missing abbreviation of pi0-option, format-option was already documented).
	* Enforced and fixed the exclusivity of 'matrix', 'estimate' and prefix-command -> take precedence over replaying .
	* Shortened subcommand menuInstall to menu.
	* Added parsing of subcommands as a convenience feature.
	* Allow now more flexible parsing of coefficient names -> make it easier to select coefficients for the same variable across different equations -> only the coefficient name is now required not the equation name anymore -> implemented what is "promised" by the dialog box text 
	* changed the default behaviour of the bonus option from nobonus to bonus -> bonus statistics only shown when requested 
* Version 1.00 : Initial SSC release, no changes compared to the last Github version.
* Version 0.99 : Removed automatic calculation of Fcr -> setting the correct interval boundaries of option altspace() not possible automatically
* Version 0.98a: 
  *	Displays now the full name of a variable in case of multi equation commands. 
  * Shortened the displayed result and added a format option -> get s overriden by the same named option of matlistopt(); 
  * Do not calculate any more results for coefficients in r(table) with missing p-value -> previously only checked for missing standard error which is sometimes not enough, e.g. in case of heckman estimation.
* Version 0.98 : Added a subcommand to install the dialog boxes to the User's menubar. Fixed an incorrect references to the leukemia example in the help file.
* Version 0.97 : Further sanity checks of the input to avoid conflict between different options, added possibility to install dialog box into the User menubar.
* Version 0.96 : Added an example how to calculate all statistics for the leukemia dataset; minor fixes in the documentation of all commands and better handling of the matrix option.
* Version 0.95 : Fixed minor mistakes in the documentation, added more information about SGPVs and more example use cases; minor bugfixes; changed the way the results are presented.
* Version 0.90 : Initial Github release

### sgpvalue
* Version 1.07	15.05.2022: Handling of larger inputs and nomata-option should work now as intended. Previously, not all possible combinations of large inputs and nomata-option have been supported correctly.
*Version 1.06  13.02.2022: 
	* Fixed a bug when variables as input with only one null-hypothesis is used, but only a few observations exist. ///
	* Fixed a bug which prevented one of the examples from the help file to run.
* Version 1.05  01.11.2020: 
    * Fixed a bug in an input check which made it impossible to use missing values as input for one-sided intervals.
    * Fixed a bug which set delta incorrectly when calculating the deltagap for one-sided intervals. 
* Version 1.04  01.07.2020: 
	* Added/improved support matrices as inputs for options "esthi" and "estlo".
	* Noshow-option now works as expected.  
* Version 1.03a 23.06.2020: Removed unnecessary input checks
* Version 1.03 24.05.2020 : Added further input checks	
* Version 1.02 06.04.2020 : Added another check to prevent using more than one null interval with variables or large matrices as input estlo and esthi
* Version 1.01 28.03.2020 : Fixed the nodeltagap-option -> now it works in all scenarios, previously it was missing in the Mata version and ignored in the variable version of the SGPV algorithm.	
* Version 1.00 : Initial SSC release, no changes compared to the last Github version.
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
* 	Rewrite input logic for nullspace and altspace to allow spaces in the input and make it easier to generate inputs in the dialog box

### plotsgpv

### sgpower
* Works only on one interval and one true value at the moment. 
* The standard error has to be a number and cannot be an expression like in the R-code.
* Not possible to plot directly the power function yet, an example how to plot the power function is located in the file sgpower_plot_example.do
* The displayed results could be labeled better and explain more but for now they are the same as in the original R-code.

### sgpv
#### Internal changes (Mostly re-organising the code for shorter and easier maintained code):
* Shorten parts of the code by using the cond()-function instead if ... else if ... constructs.
* Write a certification script which checks all possible errors (help cscript)

#### External changes (Mostly more features):
* Consider dropping the default value for the null-hypothesis and require an explicit setting to the null-hypothesis
* Make error messages more descriptive and give hints how to resolve the problems. (somewhat done hopefully)
* support for more commands which do not report their results in a matrix named "r(table)".
* Make matrix parsing more flexible and rely on the names of the rows for identifiying the necessary numbers
* Return more infos which might be needed for further processing.
* Allow plotting of the resulting SGPVs against the normal p-values directly after the calculations -> use user-provided command plotmatrix instead?	
* Improve the speed of fdrisk.ado -> the integration part takes too long. -> switch over to Mata integration functions provided by moremata-package
* Add an immidiate version of sgpvalue similar like ttesti-command; allow two sample t-test equivalent -> currently the required numbers need be calculated or extracted from these commands.

### sgpvalue
* At some point rewrite the code to use only Mata for a more compact code -> currently three different versions of the same algorithm are used. 



