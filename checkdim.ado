*! Version 0.5 03.10.2017: Check if variable(s) exist(s) for all values of another variable
*! Version 1.0 19.08.2019: Changed display of results. Allows now to save the results as variables.
/* START HELP FILE
title[Check if variable(s) exist(s) for all values of another variable]
desc[ {cmd:checkdim} allows you to check if a variable or multiple variables has/have missing values for all values of another variable/dimension. The results are saved in temporary variables which can be made permanent.  The results can be replayed if the {opt keep} has been specified in the first run of the command. To replay the results, just type {cmd:checkdim} without the dimension and any variables.  It is possible to filter the output by using the {opt showcondition()} option. Variables can also be dropped based on the results by using the options {opt drop} and {opt dropcondition()} together. ]
opt[dimension() the variable for which all values are checked. Currently only one dimension possible but extension to more variables in one go possible. ]
opt[noshow do not show the results]
opt[drop drop if  the drop condition is met. The default drop condition is to drop variables which having missing values for all levels of a dimension. ]
opt[dropcondition() the condition for which variable(s) should be dropped other than the default condition (dropping if missing values for all levels of a dimension).  ]
opt[showcondition() the condition for which variables should be shown.]
opt[sort sort the results in descending order.]
opt[keep keep the generated variables]
opt[keepname() the stub for the generated variables. The default stub is "mis".]
opt[replace replace existing variables which contain the results.]
opt[drop drop if  the drop condition is met. The default drop condition is to drop variables which having missing values for all levels of a dimension when only the drop option is set.]

example[ Generate an artificial example  dataset ]
return[dropvar list of dropped variables]
return[dropcondition the condition under which variables are dropped.]
return[showcondition the condition for which variables should be shown.]
return[keepname the stub for the generated variables]
author[Sven-Kristjan Bormann ]
institute[School of Economics and Business Administration, University of Tartu]
email[sven-kristjan@gmx.de]
END HELP FILE */
capture program drop checkdim
program define checkdim, rclass

	version 9.0
		if replay(){
			check_replay `0'
			exit
	}
	
	syntax [varlist] [if][in], DIMension(varname) [NOshow drop DROPCONDition(string) SHOWCONDition(string) sort keep KEEPName(string) replace]
	
	*Parse syntax
	if "`keepname'"==""{
	local keepname mis
	}
	else{
	local keepname = abbrev("`keepname'",27) // Just in case somebody wants to use a really long stub...
	}	
	
	if "`keep'"!="" check_keep, `replace' keepname(`keepname') // Check if variables could be kept

	*Remove potentially earlier created variables
	local misvarlist `keepname'var `keepname'level `keepname'count
	local varlist : list varlist - misvarlist
	
	marksample touse, novarlist strok
	 quietly count if `touse' 
     if r(N) == 0 error 2000 


	qui levelsof `dimension'
	local levels = r(levels)
	local levelnum : word count `levels'
	*Set up temporary variables to save and tabulate the results
	tempvar misvar mislevel miscount 
	quietly{
	 gen str32 `misvar' =""
	 gen str`=length("`levels'")' `mislevel'=""
	 gen byte `miscount' = .
	 label var `misvar' "Variables with missing values for `dimension'"
	 label var `mislevel' "Missing levels of `dimension'"
	 label var `miscount' "# of missing levels of `dimension'"
	}
	*Set up macros for recording missing levels 
	local misvarcount 0
	foreach var of local varlist{
		local mlevel
		foreach level of local levels{
			qui count if !missing(`var') & `dimension'==`level' & `touse'
			if r(N)==0{
				local mlevel `mlevel' `level'
				}
		}		
		if "`mlevel'"!=""{
			local mlevelcount : word count `mlevel'
			local ++misvarcount
			qui replace `misvar'="`var'" in `misvarcount'
			qui replace `mislevel'="`mlevel'" in `misvarcount'
			qui replace `miscount' = `mlevelcount' in `misvarcount'
			}	
	}	


	*Stop the command if no missing values were found	
	if `misvarcount'==0{
		disp as res "No missing values for variables `varlist'  for dimension `dimension' "
		exit
	} 
*---------------------------------------------------------------------------------------------------------------------
*This code is only reached if missing values were found.	
			*Display options
		if  "`show'"!="noshow" {
			check_mistable ,misvar(`misvar') mislevel(`mislevel') miscount(`miscount') showcondition(`showcondition') `sort'
		}
		
			*Drop variables based on missing levels
		if "`drop'"!=""{
			if "`dropcondition'"==""{
			local dropcondition "==`levelnum'" //Set default value for dropping, drop if a variable misses for all levels of a dimension
			} 
			if `miscount'`dropcondition'{
				capture drop `var'
				if !_rc disp "Variable `var' dropped under the condition that observations for `miscount'`dropcondition' are missing for dimension `dimension'.  "
				local dropvar `dropvar' `var'
			}		
		}
	
		*Keep generated variables for later analysis
		if "`keep'"!="" {  
				qui clonevar `keepname'var = `misvar'
				qui clonevar `keepname'level = `mislevel'
				qui clonevar `keepname'count = `miscount'
				qui compress
				}
			
		return local dropvar = "`dropvar'"
		return local dropcondition = "`dropcondition'"
		return local showcondition = "`showcondition'"
		return local keepname = "`keepname'"
		
end

program define check_mistable
*Custom table instead of using list, because list does not display labels of temporary variables.
syntax , [misvar(varname) mislevel(varname) miscount(varname) showcondition(string) sort]
*args misvar mislevel miscount showcondition sort
if "`misvar'"=="" | "`mislevel'"=="" | "`miscount'"==""{
	disp as error "No variables to display found!"
	disp as error "If you have used  -checkdim- without a variable list to replay the results, then specify the correct prefix for the variables to display with the -keepname()- option."
	exit 198
}
local oldsortorder : sortedby

if "`sort'"=="sort"{
				gsort -`miscount'
			}
else{
	gsort -`misvar' // Get a  working sort order for the replay function and following tabulation
}



*Not the best naming scheme for locals yet...
qui levelsof `misvar' ,local(misvarlevels) clean
local varcount : word count `misvarlevels'
qui levelsof `mislevel' ,local(mislevels)
local w1 0
local w2 0
*Find the maximum width of the columns
forvalues l=1/`varcount'{
	local w1 = max(`w1', length("`: word `l' of `misvarlevels''"))
	local w2 = max(`w2', length("`: word `l' of `mislevels''"))
}
*Define the table to display the results

*Define alternative width if total width exceeds linesize
if c(linesize)<`=length("`w1'")+length("`w2'")+8'{
	local w2 = c(linesize) - `w1' - 8
}

tempname mistab  
.`mistab' = ._tab.new, col(3) lmargin(0)
.`mistab'.width `w1'| `w2' 8
.`mistab'.titlefmt %`w1's %~`=`w2''s .
.`mistab'.sep, top
.`mistab'.titles "Variable" "Missing levels" "#"
.`mistab'.sep
.`mistab'.strfmt %`w1's %`w2's .

*Build the table
forvalues i=1/`varcount'{
	if !missing(`miscount'[`i']){
	*Check if the row length exceeds linesize, if so split text simulate a line wrap
		if `w2'>`= length("`mislevel'[`i']")'{
			.`mistab'.row `"`=`misvar'[`i']'"' `"`=`mislevel'[`i']'"' `=`miscount'[`i']'
		}
		else{
			local mlpart1 = substr("`=`mislevel'[`i']'",1,`w2')
			local mlpart2 = substr("`=`mislevel'[`i']'",`=`w2'+1',.)
			local mlpart1count : word count `mlpart1'
			local mlpartlastword : word `=`mlpart1count'' of `mlpart1'
			local mlpart1: list mlpart1 - mlpartlastword
			local mlpart2 = "`mlpartlastword'" + "`mlpart2'"
			if length("`mlpart2'")<=`w2'{
				.`mistab'.row `"`=`misvar'[`i']'"' `"`mlpart1'"' `=`miscount'[`i']'
				.`mistab'.row `" "' `"`mlpart2'"' `" "' 
			}
			*Add more rows if needed and split up the text		
			else{
				local addrow = ceil(length("`mislevel'[`i']")/`w2')
				forvalues j=3/`addrow'{
					local mlpart`j' = substr("`mlpart`=`j'-1''",1,`w2')
					local mlpart`=`j'+1' = substr("`mlpart`=`j'-1''",`=`w2'+1',.)
					local mlpart`j'count : word count `mlpart`j''
					local mlpartlastword : word `=`mlpart`j'count'' of `mlpart`j''
					local mlpart`j': list mlpart`j' - mlpartlastword
					local mlpart`=`j'+1' = "`mlpartlastword'" + "`mlpart`j''"
					.`mistab'.row `" "' `"`mlpart`j''"' `" "' 
				}
			} 

		}
	}
}
.`mistab'.sep, bottom
if "`sort'"=="sort" cap sort `oldsortorder' 

end

program define check_keep, rclass
syntax , keepname(string) [replace] 

if "`replace'"!="" capture drop `keepname'var `keepname'level `keepname'count
capture confirm new variable `keepname'var `keepname'level `keepname'count
if _rc{
	 disp as error "-replace- option must be specified if variables already exist."
	 disp as error "or change the variable stub with the -keepname(stub)- option."
	 exit 198			 
}
return local keepchecked = 1

end


program define check_replay
if strmatch("`0'","*dim*"){
				disp as error "Option -dimension- cannot be used when replaying results."
				exit 198
			}
		
		syntax [, sort SHOWCONDition(string) KEEPName(string) ] 
			if "`keepname'"=="" local keepname mis 
			if "`showcondition'"==""{
				local showcondition  "!mi(`keepname'count)"
			} 
			else{
				local showcondition `showcondition' & !mi(`keepname'count)
			}
			if "`sort'"!=""{
				local oldsortorder :sortedby
				gsort -`keepname'count
			}
			
			cap confirm variable `keepname'var `keepname'level `keepname'count
			if !_rc{
			disp as error "No variables to display found!"
			disp as error "If you have used  -checkdim- without a variable list to replay the results, then specify the correct prefix for the variables to display with the -keepname()- option."
			exit 198
			}
			*Use list instead of check_mistable to keep "check_mistable" rather simple
			list `keepname'var `keepname'level `keepname'count if !mi(`keepname'count) & `showcondition', noobs table compress sep(0) linesize(`=c(linesize)')
			*check_mistable ,misvar(`keepname'var) mislevel(`keepname'level) miscount(`keepname'count) showcondition(`showcondition') `sort'
			if "`sort'"!="" cap sort `oldsortorder'
end
