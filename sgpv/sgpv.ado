*! A wrapper program for calculating the Second-Generation P-Values and their associated diagnosis
*!Version 0.98a: Displays now the full name of a variable in case of multi equation commands. Shortened the displayed result and added a format option -> get s overriden by the same named option of matlistopt(); Do not calculate any more results for coefficients in r(table) with missing p-value -> previously only checked for missing standard error which is sometimes not enough, e.g. in case of heckman estimation. 
*!Version 0.98 : Added a subcommand to install the dialog boxes to the User's menubar. Fixed an incorrect references to the leukemia example in the help file.
*!Version 0.97 : Further sanity checks of the input to avoid conflict between different options, added possibility to install dialog box into the User menubar.
*!Version 0.96 : Added an example how to calculate all statistics for the leukemia dataset; minor fixes in the documentation of all commands and better handling of the matrix option.
*!Version 0.95 : Fixed minor mistakes in the documentation, added more information about SGPVs and more example use cases; minor bugfixes; changed the way the results are presented
*!Version 0.90 : Initial Github release

/*
To-Do(Things that I wish to implement at some point or that I think that might be interesting to have: 
	- Make error messages more descriptive and give hints how resolve the problems.
	- display the equation for multi equation commands e.g. sqreg, ivreg, heckman, etc. (done in general, but not tested for all scenarios)
	- make the output look like it got returned by "ereturn display", especially the p-values are too detailed at the moment, using matlist options does not work as matlist changes the format of all colums and not just the numbers in the colums. 
	- allow more flexible parsing of coefficient names -> make it easier to select coefficients for the same variable across different equations
	- support for more commands which do not report their results in a matrix named "r(table)".
	- Make results exportable or change the command to an e-class command to allow processing in commands like esttab or estpost from Ben Jann 
	- Make matrix parsing more flexible and rely on the names of the rows for identifiying the necessary numbers; allow calculations for more than one stored estimate
	- Return more infos
	- Allow plotting of the resulting SGPVs against the normal p-values directly after the calculations
	- Calculate automatically a null interval based on the statistical properties of the dependent variable of an estimation to encourage the usage of interval null-hypotheses.
	- change the help file generation from makehlp to markdoc for more control over the layout of the help files -> currently requires a lot of manual tuning to get desired results.
	- improve the speed of fdrisk.ado -> probably the integration part takes too long.
	- add an immidiate version of sgpvalue similar like ttesti-command; allow two sample t-test equivalent -> currently the required numbers need be calculated or extracted from these commands.
*/

capture program drop sgpv
program define sgpv, rclass
version 12.0
*Parse the initial input 
capture  _on_colon_parse `0'


*Check if anything to calculate is given
if _rc & "`e(cmd)'"=="" & (!ustrregexm(`"`0'"',"matrix\(\w+\)") & !ustrregexm(`"`0'"',"m\(\w+\)") ) & (!ustrregexm(`"`0'"',"estimate\(\w+\)") & !ustrregexm(`"`0'"',"e\(\w+\)") ) & !ustrregexm(`"`0'"',"menuInstall") { // If the command was not prefixed and no previous estimation exists. -> There should be a more elegant solution to this problem
	disp as error "No last estimate or matrix, saved estimate for calculating SGPV found."
	disp as error "No subcommand found either."
	disp as error "Make sure that the matrix option is correctly specified as 'matrix(matrixname)' or 'm(matrixname)' . "
	disp as error "Make sure that the estimate option is correctly specified as 'estimate(stored estimate name)' or 'e(stored estimate name)' . "
	disp as error "The only currently available subcommand is 'menuInstall'."
	exit 198
}


if !_rc{
	local cmd `"`s(after)'"'
	local 0 `"`s(before)'"' 
} 

**Define here options
syntax [anything(name=subcmd)] [, Quietly  Estimate(name)  Matrix(name) MATListopt(string asis) COEFficient(string) NOBonus(string) nulllo(real 0) nullhi(real 0)  ALTWeights(string) ALTSpace(string asis) NULLSpace(string asis) NULLWeights(string) INTLevel(string) INTType(string) pi0(real 0.5) perm debug  /*Display additional messages: undocumented*/ FORmat(str) /*Undocumented setting to change the numerical accuracy of the displayed results*/] 

***Parsing of subcommands -> Might be added as a new feature to use only one command for SGPV calculation
/* Potential subcommands: value, power, fdrisk, plot
if "`subcmd'"!=""{
	if !inlist("`anything'","value","power","fdrisk","plot" ) stop "Unknown subcommand `anything'. Allowed subcommands are value, power, fdrisk and plot."
	local 0_new `0'
	gettoken 
	ParseSubcmd `subcmd', 
	
}
*/
if "`subcmd'"=="menuInstall"{
	menuInstall , `perm'
	exit
}




***Option parsing
if ("`cmd'"!="" & "`e(cmd)'"!="" ) & ("`estimate'"!="" & "`matrix'"!=""){
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
			stop "The matrix `matrix' does not have the required format. See the {help sgpv##matrix_opt:help file} for the required format and make sure that the rows of the matrix are labelled correctly."
			}
			local inputmatrix `matrix'
	  }
	}

	**Process fdrisk options
	if `nulllo' ==. stop "No missing value for option 'nulllo' allowed. One-sided intervals are not yet supported."
	if `nullhi' ==. stop "No missing value for option 'nullhi' allowed. One-sided intervals are not yet supported."
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
	if !(`pi0'>0 & `pi0'<1){
		stop "Values for pi0 need to lie within the exclusive 0 - 1 interval. A prior probability outside of this interval is not sensible. The default value assumes that both hypotheses are equally likely."
	}
	
	
**Parse nobonus option
if !inlist("`nobonus'","deltagap","fdrisk","all","none",""){
	stop `"nobonus option incorrectly specified. It takes only values `"none"', `"deltagap"', `"fdrisk"' or `"all"'. "'
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
	 if !mi(`:disp `input'[2,`i']') /*<. */& !mi(`:disp `input'[4,`i']')/*<.*/ { // Check here if the standard error or the p-value is missing and treat is as indication for a variable to omit.
		local esthi `esthi' `:disp `input'[6,`i']'
		local estlo `estlo' `:disp `input'[5,`i']'
		mat `pval' =(nullmat(`pval')\\`input'[4,`i'])
		mat `input_new' = (nullmat(`input_new'), `input'[1..6,`i']) //Get new input matrix with only the elements for which results will be calculated

	 }
 }
  local rownames : colfullnames `input_new' //Save the variable names for later display

 
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
		qui fdrisk, nullhi(`nullhi') nulllo(`nulllo') stderr(`=`input_new'[2,`i']') inttype(`inttype') intlevel(`intlevel') nullspace(`nullspace') nullweights(`nullweights') altspace(`=`input_new'[5,`i']' `=`input_new'[6,`i']') altweights(`altweights') sgpval(`=`comp'[`i',1]') pi0(`pi0')  // Not sure yet if these are the best default values -> will need to implement possibilities to set these options
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

*Change the format of the displayed matrix
Format_Display `comp', format(`format')
 matlist r(display_mat) , title("Comparison of ordinary P-Values and Second Generation P-Values") rowtitle(Variables) `matlistopt'

*matlist `comp' , title("Comparison of ordinary P-Values and Second Generation P-Values") rowtitle(Variables) `matlistopt'
return add
*Return results
return matrix comparison =  `comp'

end

*Re-format the input matrix and return a new matrix to circumvent the limitations set by matlist -> using the cspec and rspec options of matlist requires more code to get these options automatically correct -> for now probably not worth the effort.
program define Format_Display, rclass
syntax name(name=matrix) [, format(string)]
	if `"`format'"'==""{
		local format %5.4f
		} 
	else {
			capture local junk : display `format' 1
			if _rc {
					dis as err "invalid %format `format'"
					exit 120
			}
		}
tempname display_mat
local display_mat_coln : colfullnames `matrix'
local display_mat_rown : rowfullnames `matrix'
mat `display_mat'=J(`=rowsof(`matrix')',`=colsof(`matrix')',.)
forvalues i=1/`=rowsof(`matrix')'{
	forvalues j=1/`=colsof(`matrix')'{
		mat `display_mat'[`i',`j']= `: display `format' `matrix'[`i',`j']'
	}

}
mat colnames `display_mat' = `display_mat_coln'
mat rownames `display_mat' = `display_mat_rown'

return matrix display_mat = `display_mat' 

end

*Simulate the behaviour of the R-function with the same name 
program define stop
 args text 
 disp as error `"`text'"'
 exit 198
end

*Make the dialog boxes accessible from the User-menu -> not called yet
program define menuInstall
 syntax [, perm *] 
 if "`perm'"=="perm"{
		capture findfile profile.do
		if _rc{
			local replace replace
			disp "profile.do not found."
			disp "profile.do will be created in the current folder."
			local profile profile.do
		}
		else{
			local replace append
			local profile `"`r(fn)'"'
			disp "Append your existing profile.do"
		}
	 
	 tempname fh
	 file open `fh' using `profile' , write text `replace'
	 
	 file write `fh' `"  window menu append item "stUserStatistics" "SGPV (Main Command) (&sgpv)" "db sgpv" "' _n
	 file write `fh' `"  window menu append item "stUserStatistics" "SGPV Value Calculations (&sgpvalue)" "db sgpvalue" "' _n
	 file write `fh' `"  window menu append item "stUserStatistics" "SGPV Power Calculations (&sgpower)" "db sgpower" "' _n
	 file write `fh' `"  window menu append item "stUserStatistics" "SGPV False Confirmation/Discovery Risk (&fdrisk)" "db fdrisk" "' _n
	 file write `fh' `"  window menu append item "stUserStatistics" "SGPV Plot Interval Estimates (&plotsgpv)" "db plotsgpv" "' _n
	 file write `fh' `" window menu refresh "' _n
	 file close `fh'

 
 }
	window menu clear // Assuming that no one else installs dialog boxes into the menubar. If this assumption is wrong then the code will be changed.
	window menu append submenu "stUserStatistics"  "SGPV"
	window menu append item "SGPV" "SGPV (Main command) (&sgpv)" "db sgpv" 
	window menu append item "SGPV" "SGPV Value Calculations (sgp&value)" "db sgpvalue"
	window menu append item "SGPV" "SGPV Power Calculations (sg&power)" "db sgpower" 
	window menu append item "SGPV" "False Confirmation/Discovery Risk (&fdrisk)" "db fdrisk" 
	window menu append item "SGPV" "SGPV Plot Interval Estimates (p&lotsgpv)" "db plotsgpv"

	window menu refresh
	
end
