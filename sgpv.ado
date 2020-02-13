*! A wrapper program for calculating the Second-Generation P-Values and their associated diagnosis
*!Version: 0.9
*!To-Do: support for more commands
*!To-Do: Make results exportable or change command to e-class command to allow processing in commands like esttab from Ben Jaan 
*!To-Do: Make matrix parsing more flexible and rely on the names of the rows for identifiying the necessary numbers
/*START HELP FILE
title[A wrapper command for calculating the Second-Generation P-Values and their associated diagnosis.  ]
desc[{cmd:sgpv} allows the calculation of the Second-Generation P-Values (SGPV) developed by Blume et.al.(2018,2019) for and after commonly used estimation commands. The false discovery/confirmation risks (fdr/fcr) can be also reported. The SGPVs are reported alongside the usually reported p-values. 
An ordinary user should use this command and not other commands on which {cmd:sgpv} is based upon. {cmd:sgpv} uses sensible default values for calculating the SGPVs and the accompaning fdr/fcr, which can be changed.  
This wrapper command runs the commands translated into Stata which are based on the original R-code from for the sgpv-package from {browse "https://github.com/weltybiostat/sgpv"} ]
opt[quietly suppress the output of the estimation command]
opt[nulllo() change the upper limit of the null-hypothesis intervall.]
opt[nullhi() change the lower limit of the null-hypothesis intervall.]
opt[estimate() takes the name of a previously stored estimation.]
opt[matrix() takes the name of matrix as input for the calculation.]
opt[coefficient() allows the selection of the coefficients for which the SGPVs and other statistics are calculated. The selected coefficients need to have the same names as displayed in the estimation output.]
opt[matlistopt() change the options of the displayed matrix. The same options as for {helpb matlist:matlist} can be used.]
opt[inttype() Class of interval estimate used. This determines the functional form of the power function. Options are "confidence" for a (1-\alpha)100% confidence interval and "likelihood" for a 1/k likelihood support interval.]
opt[intlevel() Level of interval estimate.]
opt[nullweights() Probability distribution for the null parameter space.]
opt[nullspace() Support of the null probability distribution.]
opt[altweights() Probability distribution for the alternative parameter space. Options are currently "Uniform", and "TruncNormal".]
opt[altspace() Support for the alternative probability distribution.  If "altweights" is  is "Uniform" or "TruncNormal", then "altspace" is a two numbers separated by a space.]
opt[pi0() Prior probability of the null hypothesis. Default is 0.5.]
opt[nomata deactivates the usage of an additional user-provided command for numerical integration. ]
opt[nobonus() deactive the display and calculation of bonus statistics like delta gaps and fdr/fcr. Possible values are "deltagap", "fdrisk", "all".]

opt2[nulllo() change the upper limit of the null-hypothesis intervall. The default is 0.]
opt2[nullhi() change the lower limit of the null-hypothesis intervall. The default is 0.]
opt2[matrix() takes the name of matrix as input for the calculation. The matrix must follow the structure of the r(table) matrix returned after commonly used estimation commands due to the hardcoded row numbers used for identifiying the necessary numbers. Meaning that the parameter estimate has to be in the 1st row, the standard errors need to be in the 2nd row, the p-values in 4th row, the lower bound in the 5th and the upper bound in the 6th row.]
opt2[nullweights() Probability distribution for the null parameter space. Options are currently "Point", "Uniform", and "TruncNormal". The default is "Point".]
opt2[nullspace() Support of the null probability distribution. If "nullweights" is "Point", then "nullspace" is a single number. If "nullweights" is "Uniform" or "TruncNormal", then "nullspace" is a two numbers separated by a space.]
opt2[intlevel() Level of interval estimate. If inttype is "confidence", the level is \alpha. If "inttype" is "likelihood", the level is 1/k (not k).]
opt2[inttype() Class of interval estimate used. This determines the functional form of the power function. Options are "confidence" for a (1-\alpha)100% confidence interval and "likelihood" for a 1/k likelihood support interval. The default is "confidence".]
opt2[nomata deactivates the usage of an additional user-provided command for numerical integration. The numerical integration is required to calculate the false discovery/confirmation risks. Instead the numerical integration Stata command is used.  ]
example[ 	
{stata sysuse auto, clear}

Usage of {cmd:spgv} as a prefix-command{p_end}
{stata sgpv: regress price mpg weight foreign} 

{stata regress price mpg weight foreign}

Save estimation for later usage {p_end}
{stata estimate store pricereg} 

The same result but this time after the last estimation.{p_end}
{stata sgpv} 

{stata qreg price mpg weight foreign}

{stata estimates store priceqreg}

Calculate SPGVs for the stored estimation and only the foreign coefficient{p_end}
{stata sgpv, estimate(pricereg) coeffient("foreign")} 

]
return[comparison a matrix containing the displayed results]



references[ Blume JD, D’Agostino McGowan L, Dupont WD, Greevy RA Jr. (2018). Second-generation {it:p}-values: Improved rigor, reproducibility, & transparency in statistical analyses. \emph{PLoS ONE} 13(3): e0188299. https://doi.org/10.1371/journal.pone.0188299

Blume JD, Greevy RA Jr., Welty VF, Smith JR, Dupont WD (2019). An Introduction to Second-generation {it:p}}-values. {it:The American Statistician}. In press. https://doi.org/10.1080/00031305.2018.1537893 ]

author[Sven-Kristjan Bormann ]
institute[School of Economics and Business Administration, University of Tartu]
email[sven-kristjan@gmx.de]

seealo[ {help:sgpvalue} {help:sgpower} {help:fdrisk}  ]

END HELP FILE*/

capture program drop sgpv
program define sgpv, rclass
version 14

*Parse the initial input -> Not captured yet the case that sgpv is called
capture  _on_colon_parse `0'
if _rc & "`e(cmd)'"=="" { // If the command was not prefixed and no previous estimation exists.
	disp as error "No command or matrix for calculating SGPV provided."
	exit 198
} 

if !_rc{
	local cmd `s(after)'
	local 0 `s(before)' 
} 

**Define here options
syntax [, Quietly nulllo(real 0) nullhi(real 0) ESTImate(name) MATListopt(string) Matrix(name)  altweights(string) altspace(string) nullspace(string) nullweights(string) INTLevel(string) INTType(string) pi0(real 0.5) COEFficient(string) nomata nobonus(string)] 

***Option parsing
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
			if "`:word 1 of `matrown''"!="b" | "`:word 2 of `matrown''" =="se"| "`:word 4 of `matrown''" =="pvalue" |"`:word 5 of `matrown''" =="lb" | "`:word 6 of `matrown''" =="ub"{
			stop "The matrix `matrix' does not have the required format. See the help file for the required format and make sure that the rows of the matrix are labelled correctly."
			}
			local inputmatrix `matrix'
	  }
	}

	**Process fdrisk options
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
	if "`nullweights'"!="" & {
		local nullweights `nullweights'
	}
	else if  "`nullweights'"!="" | "`nullspace'"=="`nulllo'"{
		local nullweights "Point"
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
 *local esthi
 *local estlo
 *local rownames : colnames `input'
* Hard coded values for the rows from which necessary numbers are extracted
*The rows could be addressed by name, but then at least Stata 14 returns a matrix
* which requires additional steps to come to the same results as with hardcoded row numbers. Unless some one complains
 forvalues i=1/`coln'{
	 if `:disp `input'[2,`i']'!=.{
		local esthi `esthi' `:disp `input'[6,`i']'
		local estlo `estlo' `:disp `input'[5,`i']'
		mat `pval' =(nullmat(`pval')\\`input'[4,`i'])
		mat `input_new' = (nullmat(`input_new'), `input'[1..6,`i']) //Get new input matrix with only the elements for which results will be calculated
		*local rownames `rownames' `:coln `input'
	 }
	/* else{ //Remove rownames for not included variables
	 mat `rest'=`input'[1...,`i']
	 local nocoln : colnames `rest'
	 local rownames : subinstr local rownames "`nocoln'" ""
	 }*/
 }
  local rownames : colnames `input_new'

 
qui sgpvalue, esthi(`esthi') estlo(`estlo') nullhi(`nullhi') nulllo(`nulllo') nowarnings `nodeltagap'

mat `comp'=r(results)
return add
mat colnames `pval' = "Old_P-Values"

if "`nofdrisk'"==""{
*False discovery risks / False confirmation risks -> Need further checks to ensure that the necessary options exist when calling without further arguments
	mat `fdrisk' = J(`:word count `rownames'',1,.)
	mat colnames  `fdrisk' = Fdr/Fcr
	forvalues i=1/`:word count `rownames''{
	*tempname fdriskcalc
	if inlist(`=`comp'[`i',1]',0,1){
		qui fdrisk, nullhi(`nullhi') nulllo(`nulllo') stderr(`=`input_new'[2,`i']') inttype(`inttype') intlevel(`intlevel') nullspace(`nullspace') nullweights(`nullweights') altspace(`=`input_new'[5,`i']' `=`input_new'[6,`i']') altweights("Uniform") sgpval(`=`comp'[`i',1]') pi0(`pi0') `nomata' // Not sure yet if these are the best default values -> will need to implement possibilities to set these options
		if "`r(fdr)'"!= "" mat `fdrisk'[`i',1] = `r(fdr)'
		if "`r(fcr)'"!= "" mat `fdrisk'[`i',1] = `r(fcr)'
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

matlist `comp' , title(Comparison Second Generation P-Values) rowtitle(Variables) `matlistopt'
return add
return matrix  comparison =  `comp'



end

*Simulate the behaviour of the R-function with the same name 
program define stop
 args text 
 disp as error `"`text'"'
 exit 198
end
