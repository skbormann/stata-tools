*! Version 0.5 03.10.2017: Check if variable(s) exist(s) for all values of another variable
* Displayed output tends to be overloaded, same for returned value
capture program drop checkdim
program define checkdim, rclass

	version 9.0
	syntax [anything] [if], DIMension(varname) [NOshow]
	local varlist `"`anything'"'
	if "`varlist'" ==""{ 
	 qui ds
	 local varlist `r(varlist)'
	}
	qui levelsof `dimension'
	local levels = r(levels)
	local mislevel
	foreach var of local varlist{
		foreach level of local levels{
			qui count if !missing(`var') & `dimension'==`level'
			if r(N)==0{
				local mislevel `mislevel' `level'
			}
		}
		if "`mislevel'"!=""{
		local varmiss "`varmiss' `var': `mislevel'"
		
		}
		if "`noshow'"==""{
			if "`mislevel'"!=""{
				disp "Variable `var' misses data for values `mislevel' of `dimension'"
			}
			else{
				disp "Variable `var' contains data for all levels of `dimension'"
			}
		}
		
	}	
	return local misslevel = "`mislevel'"
	return local varmiss = "`varmiss'"
end
