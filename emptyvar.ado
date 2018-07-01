*! version 0.7 27.07.2017
*! Changelog: 
*!07.06.2018 Added option specifiy additional condition
*! 06.01.2018 - Added option to specify missing values
*! Shows and drops variables which contain only missing values
capture program drop emptyvar
program define emptyvar, rclass
	version 11
	gettoken subcmd 0 : 0, parse(" ,")
	if "`subcmd'"==""{
		disp as error "{err} subcommand show or drop required"
		disp "Command usage: emptyvar show|drop"
		exit 198
	}
	syntax [varlist], [CONDition(string)]
	if "`varlist'"==""{
		quietly ds
		local varlist `r(varlist)'
	}
	if "`condition'"!=""{
		local cond `condition'
		local condition2 if `condition'
		local condition "& `condition'"
		local condtext  " for `cond'"
	}
	local emptyvar //Collect the empty variables for later usuage
	if "`subcmd'"=="show"{
		foreach var of local varlist{
			capture confirm numeric variable `var'
			if _rc==0{
				quietly count if `var'!=. `condition'
				}
			else{
				quietly count if `var'!="" `condition'
			}
			if r(N)==0{
			disp "Variable `var' contains no observations`condtext'."
			local emptyvar `emptyvar' `var'
			}
		}
	}	
	if "`subcmd'"=="drop"{
		foreach var of local varlist{
			capture confirm numeric variable `var'
			if _rc==0{
				quietly count if `var'!=. `condition'
				}
			else{
				quietly count if `var'!="" `condition'
			}
			if r(N)==0{
				disp "Variable `var' contains no observations`condtext'."
				disp "Variable `var' will be dropped`condtext'."
				drop `var'  `condition2'
				local droppedvar `droppedvar' `var'
				}
			}
		}
	
	return local emptyvar = "`emptyvar'"
	return local droppedvar = "`droppedvar'"
	return local condition = "`condition'"
end
