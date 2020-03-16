*! A wrapper program for calculating the Second-Generation P-Values and their associated diagnosis
*!Version 1.00 : Initial SSC release, no changes compared to the last Github version.
*!Version 0.97 : Further sanity checks of the input to avoid conflict between different options, added possibility to install dialog box into the User menubar.
*!Version 0.96 : Added an example how to calculate all statistics for the leukemia dataset; minor fixes in the documentation of all commands and better handling of the matrix option.
*!Version 0.95 : Fixed minor mistakes in the documentation, added more information about SGPVs and more example use cases; minor bugfixes; changed the way the results are presented
*!Version 0.90 : Initial Github release

/*
To-Do(Things that I wish to implement at some point or that I think that might be interesting to have: 
	- support for more commands which do not report their results in a matrix named "r(table)".
	- Make results exportable or change the command to an e-class command to allow processing in commands like esttab or estpost from Ben Jann 
	- Make matrix parsing more flexible and rely on the names of the rows for identifiying the necessary numbers; allow calculations for more than one stored estimate
	- Return more infos
	- Allow plotting of the resulting SGPVs against the normal p-values directly after the calculations
	- Calculate automatically a null interval based on the statistical properties of the dependent variable of an estimation to encourage the usage of interval null-hypotheses.
	- change the help file generation from makehlp to markdoc for more control over the layout of the help files -> currently requires a lot of manual tuning to get desired results.
	- improve the speed of fdrisk.ado -> probably the integration part takes too long.
	- add an imediate version of sgpvalue similar like ttesti-command; allow two sample t-test equivalent 
*/

capture program drop sgpv
program define sgpv, rclass
version 12.0
*Parse the initial input 
capture  _on_colon_parse `0'


*Check if anything to calculate is given
if _rc & "`e(cmd)'"=="" & (!ustrregexm(`"`0'"',"matrix\(\w+\)") & !ustrregexm(`"`0'"',"m\(\w+\)") ) & (!ustrregexm(`"`0'"',"estimate\(\w+\)") & !ustrregexm(`"`0'"',"e\(\w+\)") ) { // If the command was not prefixed and no previous estimation exists. -> There should be a more elegant solution to this problem
	disp as error "No last estimate or matrix or saved estimate for calculating SGPV found." 
	disp as error "Make sure that the matrix option is correctly specified as 'matrix(matrixname)' or 'm(matrixname)' . "
	disp as error "Make sure that the estimate option is correctly specified as 'estimate(stored estimate name)' or 'm(stored estimate name)' . "
	exit 198
}


if !_rc{
	local cmd `"`s(after)'"'
	local 0 `"`s(before)'"' 
} 

**Define here options
syntax [anything(name=subcmd)] [, Quietly  Estimate(name)  Matrix(name) MATListopt(string asis) COEFficient(string) NOBonus(string) nulllo(real 0) nullhi(real 0)  ALTWeights(string) ALTSpace(string) NULLSpace(string) NULLWeights(string) INTLevel(string) INTType(string) pi0(real 0.5)  debug /*Display additional messages: undocumented*/] 

***Parsing of subcommands -> Might be added as a new feature to use only one command for SGPV calculation
/* Potential subcommands: value, power, fdrisk, plot
if "`subcmd'"!=""{
	if !inlist("`anything'","value","power","fdrisk","plot" ) stop "Unknown subcommand `anything'. Allowed subcommands are value, power, fdrisk and plot."
	local 0_new `0'
	gettoken 
	ParseSubcmd `subcmd', 
	
}

if ustrregexm(`"`0'"',"menuInstall"){
	gettoken menu 0:0
	menuInstall `0'
}

*/


***Option parsing
if ("`cmd'"!="" | "`e(cmd)'"!="" ) & ("`estimate'"!="" | "`matrix'"!=""){
	stop "Options 'matrix' and 'estimate' cannot be used in combination with replaying an existing estimation or a new estimation."
} 

if "`estimate'"!="" & "`matrix'"!=""{
	stop "Setting both options 'estimate' and 'matrix' is not allowed."
} 

	*Saved Estimation
	if "`estimate'"!=""{
		qui estimates dir
		if regexm("`r(names)'","`estimate'"){
		qui estimates restore `estimate'
		}
		else{
			disp as error "No saved estimation result with the name `estimate' found."
			exit 198
		}
	}


	*Arbitrary matrix 
	if "`matrix'"!=""{
		capture confirm matrix `matrix'
		if _rc{
			disp as error "Matrix `matrix' does not exist."
			exit 198
		}
		else{ 
		  //Initial check if rows are correctly named as a crude check that the rows contain the expected numbers
		   local matrown : rownames `matrix'
			if "`:word 1 of `matrown''"!="b" | "`:word 2 of `matrown''"!="se" | "`:word 4 of `matrown''"!="pvalue" | "`:word 5 of `matrown''"!="ll" | "`:word 6 of `matrown''" !="ul"{
			stop "The matrix `matrix' does not have the required format. See the help file for the required format and make sure that the rows of the matrix are labelled correctly."
			}
			local inputmatrix `matrix'
	  }
	}

	**Process fdrisk options
	if `nulllo' ==. stop "No missing value for option 'nulllo' allowed. One-sided intervals not yet supported."
	if `nullhi' ==. stop "No missing value for option 'nullhi' allowed. One-sided intervals not yet supported."
	*Nullspace option
	if "`nullspace'"!=""{
		local nullspace `nullspace'
	}
	else if `nullhi'!= `nulllo'{
		local nullspace `nulllo' `nullhi'
	}
	else if `nullhi'== `nulllo'{
		local nullspace `nulllo'
	}
	*Intlevel
	if "`intlevel'"!=""{
		local intlevel `intlevel'
	}
	else{
		local intlevel 0.05
	}
	
	*Inttype
	if "`inttype'"!="" & inlist("`inttype'", "confidence","likelihood"){
		local inttype `inttype'
	}
	else if "`inttype'"!="" & !inlist("`inttype'", "confidence","likelihood"){
		stop "Parameter intervaltype must be one of the following: confidence or likelihood "
	}
	else{
		local inttype "confidence"
	}

	*Nullweights
	if "`nullweights'"!=""  {
		local nullweights `nullweights'
	}
	else if  "`nullweights'"=="" & "`nullspace'"=="`nulllo'"{
		local nullweights "Point"
	}
	else if "`nullweights'"=="" & `:word count `nullspace''==2{ //Assuming that Uniform is good default nullweights for a nullspace with two values -> TruncNormal will be chosen only if explicitly set.
		local nullweights "Uniform" 
	} 
	
	*Altweights
	if "`altweights'"!="" & inlist("`altweights'", "Uniform", "TruncNormal"){
		local altweights `altweights'
	}
	else{
		local altweights "Uniform"
	}
	
	*Pi0
	if !(`pi0'>0 & 1>`pi0'){
		stop "Values for pi0 need to lie within the exclusive 0 - 1 interval. A prior probability of 0 or 1 is not sensible."
	}
	
	
**Parse nobonus option
if !inlist("`nobonus'","deltagap","fdrisk","all",""){
	stop `"nobonus option incorrectly specified. It takes only values `"deltagap"', `"fdrisk"' or `"all"'. "'
}
if "`nobonus'"=="deltagap"{
	local nodeltagap nodeltagap
	}
	
if "`nobonus'"=="fdrisk"{
	local nofdrisk nofdrisk
}

if "`nobonus'"=="all"{
	local nofdrisk nofdrisk
	local nodeltagap nodeltagap
}

*Assuming that any estimation command will report a matrix named "r(table)" and a macro named "e(cmd)"
if "`cmd'"!=""{
 `quietly'	`cmd'
}
else if "`e(cmd)'"!=""{ // Replay previous estimation
 `quietly'	`e(cmd)'
}
 
 
 
* disp "Start calculating SGPV"
 *Create input vectors
  tempname input  input_new sgpv pval comp rest fdrisk coef_mat
 
 *Set the required input matrix
 if "`matrix'"==""{
  capture confirm matrix r(table) //Check if required matrix was returned by estimation command
	 if _rc{
		disp as error "`e(cmd)' did not return required matrix r(table)."
		exit 198
	 }
	local inputmatrix r(table)
 }
 
 ***Input processing
 mat `input' = `inputmatrix'
 return add // save existing returned results 
 
 *Add here code for coefficient selection
 if "`coefficient'"!=""{
	local coefnumb : word count `coefficient'
	forvalues i=1/`coefnumb'{
		capture mat `coef_mat' = (nullmat(`coef_mat'), `input'[1...,"`: word `i' of `coefficient''"])
		if _rc{
			stop "Coefficient `:word `i' of `coefficient'' not found or incorrectly written."
		}
	}
	mat `input'=`coef_mat'
 }
 
 local coln =colsof(`input')

* Hard coded values for the rows from which necessary numbers are extracted
*The rows could be addressed by name, but then at least Stata 14 returns a matrix
* which requires additional steps to come to the same results as with hardcoded row numbers. Unless some one complains, I won't change this restriction.
*The macros for esthi and estlo could be become too large, will fix/rewrite the logic if needed 
*Removing not estimated coefficients from the input matrix
 forvalues i=1/`coln'{
	 if `:disp `input'[2,`i']'!=.{ // Check here if the standard error is missing and treat is as indication for a variable to omit.
		local esthi `esthi' `:disp `input'[6,`i']'
		local estlo `estlo' `:disp `input'[5,`i']'
		mat `pval' =(nullmat(`pval')\\`input'[4,`i'])
		mat `input_new' = (nullmat(`input_new'), `input'[1..6,`i']) //Get new input matrix with only the elements for which results will be calculated

	 }
 }
  local rownames : colnames `input_new' //Save the variable names for later display

 
qui sgpvalue, esthi(`esthi') estlo(`estlo') nullhi(`nullhi') nulllo(`nulllo') nowarnings `nodeltagap' 
if "`debug'"=="debug" disp "Finished SGPV calculations. Starting now bonus Fdr/Fcr calculations."


mat `comp'=r(results)
return add
*mat colnames `pval' = "Old_P-Values"
 mat colnames `pval' = "P-Value"


if "`nofdrisk'"==""{
*False discovery risks / False confirmation risks -> Need further checks to ensure that the necessary options exist when calling without further arguments
	mat `fdrisk' = J(`:word count `rownames'',1,.)
	*mat colnames  `fdrisk' = Fdr/Fcr
	*Test alternative layout and presentation of results
	*if "`altlabel'"=="altlabel"{
		mat `fdrisk' = J(`:word count `rownames'',2,.)
		mat colnames  `fdrisk' = Fdr  Fcr
	*}
	forvalues i=1/`:word count `rownames''{
	if inlist(`=`comp'[`i',1]',0,1){
		qui fdrisk, nullhi(`nullhi') nulllo(`nulllo') stderr(`=`input_new'[2,`i']') inttype(`inttype') intlevel(`intlevel') nullspace(`nullspace') nullweights(`nullweights') altspace(`=`input_new'[5,`i']' `=`input_new'[6,`i']') altweights("Uniform") sgpval(`=`comp'[`i',1]') pi0(`pi0')  // Not sure yet if these are the best default values -> will need to implement possibilities to set these options
		if "`r(fdr)'"!= "" mat `fdrisk'[`i',1] = `r(fdr)'
		if "`r(fcr)'"!= "" mat `fdrisk'[`i',2] = `r(fcr)'
				
		}
	}
}

*Final matrix composition before displaying results
if "`nofdrisk'"!="nofdrisk"{
	mat `comp'= `pval',`comp' , `fdrisk'
}
else{
	mat `comp'= `pval',`comp'
}
 mat rownames `comp' = `rownames'

matlist `comp' , title("Comparison of ordinary P-Values and Second Generation P-Values") rowtitle(Variables) `matlistopt'
return add
*Return results
return matrix comparison =  `comp'

end

*Simulate the behaviour of the R-function with the same name 
program define stop
 args text 
 disp as error `"`text'"'
 exit 198
end

*Make the dialog boxes accessible from the User-menu
program define menuInstall
 args perm 
 if "`perm'"=="perm"{
	 capture findfile profile.do
	 if _rc{
		disp as error "File profile.do not found." 
		disp as error "To make the dialog boxes permanently available in your menu bar, please create a profile.do file in your home directory."
		disp as error "You can create this file by running: " {stata }
		exit 
	 }
	 tempname fh
	 file open `fh' using profile.do , read write append
	 
	 file write `fh' `"  window menu append item "stUserStatistics" "SGPV (Main command) (&sgpv)" "db sgpv" "' _n
	 file write `fh' `"  window menu append item "stUserStatistics" "SGPV Value Calculations (&sgpvalue)" "db sgpvalue" "' _n
	 file write `fh' `"  window menu append item "stUserStatistics" "SGPV Power Calculations (&sgpower)" "db sgpower" "' _n
	 file write `fh' `"  window menu append item "stUserStatistics" "SGPV False Confirmation/Discovery Risk (&fdrisk)" "db fdrisk" "' _n
	 file write `fh' `"  window menu append item "stUserStatistics" "SGPV Plot Interval Estimates (&plotsgpv)" "db plotsgpv" "' _n
	 file write `fh' `" window menu refresh "' _n
	 file close `fh'

 
 }
	window menu append item "stUserStatistics" "SGPV (Main command) (&sgpv)" "db sgpv" 
	window menu append item "stUserStatistics" "SGPV Value Calculations (&sgpvalue)" "db sgpvalue"
	window menu append item "stUserStatistics" "SGPV Power Calculations (&sgpower)" "db sgpower" 
	window menu append item "stUserStatistics" "SGPV False Confirmation/Discovery Risk (&fdrisk)" "db fdrisk" 
	window menu append item "stUserStatistics" "SGPV Plot Interval Estimates (&plotsgpv)" "db plotsgpv"

	window menu refresh
 
end
