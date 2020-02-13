*! Based on the R-code for the sgpvalue function from the sgpv-package from https://github.com/weltybiostat/sgpv
*!Cannot deal yet properly with infinite values
*!Still missing: Some Input error checks
*!To-do: At some point rewrite the code to use Mata for a more compact code 
*!Version :0.9
/*START HELP FILE
title[Second-Generation p-values]
desc[This function computes the second-generation {it:p}-value (SGPV) and its associated delta gaps, as introduced in Blume et al. (2018).
This command and its companions commands ({cmd:sgpower}, {cmd:fdrisk}) are based on the R-code for the sgpv-package from {browse "https://github.com/weltybiostat/sgpv"}
]
opt[esthi() A numeric vector of upper bounds of interval estimates. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:estlo}. Multiple upper bounds can be entered. They must be separated by spaces. Typically the upper bound of a confidence interval can be used.]
opt[estlo() A numeric vector of lower bounds of interval estimates. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:estlo}. Multiple lower bounds can be entered. They must be separated by spaces. Typically the lower bound of a confidence interval can be used.]
opt[nullhi() A numeric vector of upper bounds of null intervals. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:nulllo}.]
opt[nulllo() A numeric vector of lower bounds of null intervals. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:nullhi}.]
opt[nowarnings Disable showing the warnings for problematic intervals.]
opt2[infcorrection() A small scalar to denote a positive but infinitesimally small SGPV. Default is 1e-5. SGPVs that are infinitesimally close to 1 are assigned 1-infcorrection. This option can only be invoked when one of the intervals has infinite length.]
opt[nodeltagap disable the display of the delta gap. Mainly used inside of {cmd:sgpv}, since delta-gaps are less useful to most users of p-values.  ]
example[The examples are based on the original documentation for the R-code, but are modified to resemble more closely the usual Stata convention.

 {bf:Simple example for three estimated log odds ratios but the same null interval}{p_end}
 
		 local lb log(1.05) log(1.3) log(0.97)
		
		 local ub log(1.8) log(1.8) log(1.02)
		
		 sgpvalue , estlo(`lb') esthi(`ub') nulllo(log(1/1.1)) nullhi(log(1.1))
		
	{bf: A simple more Stata-like example with a point null hypothesis}{p_end}
	
		{stata sysuse auto, clear}
		{stata regress price mpg}
		{stata mat table = r(table)}  //Copy the regression results into a new matrix for the next calculations
		
		The numbers for the options could be also copied by hand, we use here directly the matrix.
		
		 sgpvalue, esthi(table[6,1]) estlo(table[5,1]) nullhi(0) nulllo(0) 
]
return[results matrix with the results]
references[ Blume JD, D’Agostino McGowan L, Dupont WD, Greevy RA Jr. (2018). Second-generation {it:p}-values: Improved rigor, reproducibility, & transparency in statistical analyses. \emph{PLoS ONE} 13(3): e0188299. https://doi.org/10.1371/journal.pone.0188299

Blume JD, Greevy RA Jr., Welty VF, Smith JR, Dupont WD (2019). An Introduction to Second-generation {it:p}}-values. {it:The American Statistician}. In press. https://doi.org/10.1080/00031305.2018.1537893 ]
author[Sven-Kristjan Bormann ]
institute[School of Economics and Business Administration, University of Tartu]
email[sven-kristjan@gmx.de]

seealso[{help:sgpower} {help:fdrisk} {help:sgpv}]
END HELP FILE*/
capture program drop sgpvalue
program define sgpvalue, rclass
version 14 
syntax [anything], esthi(string) estlo(string) nullhi(string) nulllo(string)  [noWARNings infcorrection(real 1e-5) nodeltagap] // Allow string intervals for one-sided tests -> requires later parsing of the options

*Parse the input 

*Potential Errors
if `:word count `nullhi'' != `: word count `nulllo''{
	disp as error " `"nullhi"' and `"nulllo"' are of different length "
	exit 198
}

if `:word count `esthi'' != `: word count `estlo''{
	disp as error " `"esthi"' and `"estlo"' are of different length. "
	exit 198
}

  if `:word count `nulllo''==1 {
   local nulllo = "`nulllo' " * `: word count `estlo''  
   local nullhi = "`nullhi' " * `: word count `esthi'' 
  }


local estint : word count `esthi'
tempname results 
mat `results' = J(`estint',2,0)
mat colnames `results' = "New_P-Values" "Delta_Gap"

***Iterate over all intervalls to implement a parallel max and min function as in R-code
forvalues i=1/`estint'{
	*Parse interval -> Not the best names yet
	local null_lo = `: word `i' of `nulllo''
		isValid `null_lo'
		isInfinite `null_lo'
		local null_lo = `r(infinite)'
	
	local null_hi = `: word `i' of `nullhi''
		isValid `null_hi'
		isInfinite `null_hi'
		local null_hi = `r(infinite)'

	local est_lo = `: word `i' of `estlo''	
		isValid `est_lo'
		isInfinite `est_lo'
		local est_lo = `r(infinite)'

	local est_hi = `: word `i' of `esthi''
		isValid `est_hi'
		isInfinite `est_hi'
		local est_hi =`r(infinite)'
	
	*Compute Interval Lengths -> Not sure how to deal with infinite lengths
	local est_len = `est_hi' - `est_lo'
	local null_len = `null_hi' -`null_lo'
	
	*Warnings
	*local warn = `estlo'!=.| `estlo'!=. | `null_lo'!=. | `null_hi'!=. // na.any = (any(is.na(est.lo))|any(is.na(est.hi))|any(is.na(null.lo))|any(is.na(null.hi)))
		if "`warnings'"!="nowarnings"{
		if `est_len'<0 & `null_len'<0 {
			disp as error "The `i'th interval length is negative."
		}
		*if isinfinite(abs(`est_len'))+abs(`null_len'){ disp as error "The `i' th interval has infinite length"} // Not sure how to implement the is.infinite function from R
		
		if `est_len'==0 | `null_len'==0{
			disp as error "The `i'th interval has zero length"
		}
	
	}
	
	*SGPV computation

	local overlap = min(`est_hi',`null_hi') - max(`est_lo',`null_lo')
	local overlap = max(`overlap',0)
	local bottom =	min(2*`null_len',`est_len')
	local pdelta = `overlap'/`bottom'
	
	*disp "Iteration `i': Overlap `overlap' Bottom `bottom' Pdelta `pdelta'"
	
	***** Zero-length & Infinite-length intervals **** 
	*These checks will be implemented once I figured out how to deal with infinites

	** Overwrite NA and NaN due to bottom = Inf
	if `overlap'==0 {
		local pdelta 0
	}
	
	/** Overlap finite & non-zero but bottom = Inf
	if `overlap'!=0 
	p.delta[overlap!=0&is.finite(overlap)&is.infinite(bottom)] <- inf.correction
*/
	** Interval estimate is a point (overlap=zero) but can be in null or equal null pt
	*p.delta[est.len==0&null.len>=0&est.lo>=null.lo&est.hi<=null.hi] <- 1
	if `est_len'==0 & `null_len'>=0 & `est_lo'>=`null_lo' & `est_hi'<=`null_hi' {
		local pdelta 1
	}
/*
	** One-sided intervals with overlap; overlap == Inf & bottom==Inf
	p.delta[is.infinite(overlap)&is.infinite(bottom)&((est.hi<=null.hi)|(est.lo>=null.lo))] <- 1
	p.delta[is.infinite(overlap)&is.infinite(bottom)&((est.hi>null.hi)|(est.lo<null.lo))] <- 1-inf.correction

	** Interval estimate is entire real line and null interval is NOT entire real line
	p.delta[est.lo==-Inf&est.hi==Inf] <- 1/2

	** Null interval is entire real line
	p.delta[null.lo==-Inf&null.hi==Inf] <- NA
	*/
	** Null interval is a point (overlap=zero) but is in interval estimate
	*p.delta[est.len>0&null.len==0&est.lo<=null.lo&est.hi>=null.hi] <- 1/2
	if `est_len'>0 & `null_len'==0 & `est_lo'<=`null_lo' & `est_hi'>=`null_hi' {
		local pdelta 0.5
	}

	
	** Return Missing value for nonsense intervals

	if `est_lo'>`est_hi' | `null_lo'>`null_hi'{
		local pdelta .
		if "`warnings'"!="nowarnings" disp as error "The `i'th interval limits are likely reversed."
	}
	
	
	** Calculate delta gap

	local gap = max(`est_lo', `null_lo') - min(`null_hi', `est_hi')
	local delta = `null_len'/2
	* Report unscaled delta gap if null has infinite length
  	*delta[null.len==Inf] = 1
	if `null_len' ==0{
		local delta 1
	}
	*disp "Iteration `i': Gap `gap' Delta `delta'"
	if `pdelta'==0 & `pdelta'!=.{
		local dg = `gap'/`delta' 
	}
	else{
		local dg .
	}
	*Write results
	mat `results'[`i',1] = `pdelta'
	mat `results'[`i',2] = `dg'
	
}
	*Process nodelta-option
	if "`deltagap'"=="nodeltagap"{
		mat `results'=`results'[1...,1]
	} 
	matlist `results' ,names(columns) title(Second Generation P-Values)
	return matrix results = `results' 
 
end 




program define isValid
args valid
if "`valid'"!="+Inf" & "`valid'"!="-Inf" & real("`valid'")==.{
	disp as error "`valid'  is not a number nor -Inf or +Inf"
	exit 198
		}
		
end

program define isInfinite, rclass
args infinite
	if `"`infinite'"'=="+Inf"{
		return local infinite = c(maxdouble)
	}
	else if `"`infinite'"'=="-Inf"{
		return local infinite = - c(maxdouble)
	}
	else{
		return local infinite = `infinite'
	}

end




 
 
