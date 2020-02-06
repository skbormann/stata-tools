*! A wrapper program for calculating the Second-Generation P-Values and their associated diagnosis
*!To-Do: Add parsing of stored estimations, selection of specific coefficients, support for more commands
/*START HELP FILE
title[]
desc[]
opt[quietly suppress the output of the estimation command]
opt[nullho() change the upper limit of the null-hypothesis intervall. The default is 0.]
opt[nullli() change the lower limit of the null-hypothesis intervall. The default is 0.]
opt[matlistopt() change the options of the displayed matrix. The same options as for {cmd:matlist} can be used.]
example[]

END HELP FILE*/

capture program drop sgpv
program define sgpv, rclass
version 14
 tempname input  sgpv pval comp rest

capture  _on_colon_parse `0'
if _rc & "`e(cmd)'"=="" { // If the command was not prefixed and no previous estimation exists.
	disp as error "No command or matrix for calculating SGPV provided."
	exit 198
} 
/*
if _rc & "`e(cmd)'"!=""{
	local options `0'
}*/
if !_rc{
	local cmd `s(after)'
	local 0 `s(before)' // Copy  everything before the colon into the '0' macro for options/syntax parsing
} 

**Define here options
syntax [, Quietly nulllo(real 0) nullhi(real 0) Matrix(name) ESTImate(name) MATListopt(string)]

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

*Arbitrary matrix useful?
/*
capture confirm matrix `matrix'
if _rc{
	disp as error "Matrix `matrix' does not exist"
	exit 198
}
*/

*Assuming that any estimation command will report a matrix named "r(table)" and a macro named "e(cmd)"
if "`cmd'"!=""{
 `quietly'	`cmd'
}
else if "`e(cmd)'"!=""{ // Replay previous estimation
 `quietly'	`e(cmd)'
}
 
 
 disp "Start calculating SGPV"
 *Create input vectors
 capture confirm matrix r(table) //Check if required matrix was returned by estimation command
 if _rc{
	disp as error "`e(cmd)' did not return required matrix r(table)."
	exit 198
 }
 
 mat `input' = r(table)
 return add
 local coln =colsof(`input')
 *local esthi
 *local estlo
 local rownames : colnames `input'
* Hard coded values for the rows from which necessary numbers are extracted
*The rows could be addressed by name, but then at least Stata 14 returns a matrix
* which requires additional steps to come to the same results as with hardcoded row numbers.
 forvalues i=1/`coln'{
	 if `:disp `input'[2,`i']'!=.{
		local esthi `esthi' `:disp `input'[6,`i']'
		local estlo `estlo' `:disp `input'[5,`i']'
		mat `pval' =(nullmat(`pval')\\`input'[4,`i'])
		*local rownames `rownames' `:coln `input'
	 }
	 else{ //Remove rownames for not included variables
	 mat `rest'=`input'[1...,`i']
	 local nocoln : colnames `rest'
	 local rownames : subinstr local rownames "`nocoln'" ""
	 }
 }
qui sgpvalue, esthi(`esthi') estlo(`estlo') nullhi(`nullhi') nulllo(`nulllo') nowarnings

mat `comp'=r(results)
return add
mat colnames `pval' = "Old_P-Values"


mat `comp'= `pval',`comp'
 mat rownames `comp' = `rownames'

matlist `comp' , title(Comparison Second Generation P-Values) rowtitle(Variables) `matlistopt'
return add
return matrix  comparison =  `comp'
return local options  `options'
return local nullhi `nullhi'
return local nulllo `nulllo'


end
