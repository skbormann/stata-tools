*! Based on the R-code for the sgpvalue function from the sgpv-package from https://github.com/weltybiostat/sgpv
*!Cannot deal yet properly with infinite values
*!Still missing: Some Input error checks
*!To-do: At some point rewrite the code to use Mata for a more compact code 
*!To-do: Allow matrices as input for esthi and estlo -> cannot input these values in a local macro due to the length limit of macros -> need processing of references to matrix colums or rows -> allow variables as inputs 
*!Version 0.9: Initial release to Github 
*!Version 0.95: Added support for using variables as inputs for options esthi() and estlo(); Added Mata function for SGPV calculations in case c(matsize) is smaller than the input vectors; Added alternative approach to use variables for the calculations instead if variables are the input -> Mata is relatively slow compared to using only variables for calculations.
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
opt[nomata Don't use Mata for calculating the SGPVs if esthi() and estlo() are variables as inputs or if c(matsize) is smaller than these options.]
opt[replace replace existing variables in case the nomata-option was used.]
opt[nodeltagap disable the display of the delta gap. Mainly used inside of {cmd:sgpv}, since delta-gaps are less useful to most users of p-values.  ]
opt2[esthi() A numeric vector of upper bounds of interval estimates. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:estlo}. Multiple upper bounds can be entered. They must be separated by spaces. Typically the upper bound of a confidence interval can be used.
A variable contained the upper bound can be also used.
]
opt2[infcorrection() A small scalar to denote a positive but infinitesimally small SGPV. Default is 1e-5. SGPVs that are infinitesimally close to 1 are assigned 1-infcorrection. This option can only be invoked when one of the intervals has infinite length.]
opt2[nomata Deactive the usage of Mata for calculating the SGPVs with large matrices or variables. The Mata function depends on the external {cmd:moremata} package by Ben Jann. The package will be installed if it does not exist. If this option is set, an approach based on variables is used. Using variables instead of Mata is considerably faster, but new variables containing the results are created. If you don't want to create new variables and time is not an issue then don't set this option. Stata might become unresponsive when using Mata.]

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
syntax [anything], esthi(string) estlo(string) nullhi(string) nulllo(string)  [noWARNings infcorrection(real 1e-5) nodeltagap save nomata noshow replace] // Allow string intervals for one-sided tests -> requires later parsing of the options -> Save option -> Saves the results as variables if matrix is too large for further processing

*Parse the input 
*Check that the inputs are variables -> For the moment only allowed if both esthi and estlo are variables
	if `:word count `esthi''==1{
		capture confirm numeric variable `esthi'
		if !_rc{
			local var_esthi 1
		}
	}

	if `:word count `estlo''==1{
		capture confirm numeric variable `estlo'
		if !_rc{
			local var_estlo 1
		}
	}
	
	if "`var_esthi'" == "1" & "`var_estlo'" =="1"{
		local varsfound 1
	}
	else if "`var_esthi'"!="`var_estlo'" {
		disp as error "Either `esthi' or `estlo' is not a numeric variable. Both options need to be numeric variables if you want to use variables as inputs."
		exit 198
	}
	else if "`var_esthi'"=="" & "`var_estlo'"==""{
		local varsfound 0
	}


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

	if `varsfound'{
		local estint =_N
	}
	else{
		local estint : word count `esthi'
	}

*Check if estint is larger than the current matsize
if `estint'>=c(matsize){ //Assuming here that this condition is only true if variables used as inputs -> The maximum length of the esthi() and estlo() should not be as large as c(matsize)
	*Add here alternative based on variables if inputs are variables
	if "`mata'"=="nomata"{
		local nulllo = real(trim("`nulllo'"))
		local nullhi = real(trim("`nullhi'"))
		sgpv_var ,esthi(`esthi') estlo(`estlo') nulllo(`nulllo') nullhi(`nullhi') `replace'
	}
	else if "`mata'"==""{
		*Check for existence of moremata package and installed it if needed
		capture findfile moremata.hlp
		if _rc{
			disp "Install required mata libraries"
			qui ssc install moremata, replace
		}
		mata: sgpv("`estlo' `esthi'", "results", `nulllo', `nullhi') // ONly one null interval allowed
		*The same return as before but this time for the Mata -> not the best solution yet.
		mat colnames results = "New_PValues" "Delta_Gap"
		if "`deltagap'"=="nodeltagap"{
		mat results=results[1...,1]
		} 
		if "`show'"!="noshow" matlist results ,names(columns) title(Second Generation P-Values)
		return matrix results = results
	}
}
else{	// Run if rows less than matsize
	tempname results 
	mat `results' = J(`estint',2,0)
	mat colnames `results' = "New_P-Values" "Delta_Gap"

	***Iterate over all intervalls to implement a parallel max and min function as in R-code
	forvalues i=1/`estint'{
		*Reset some macros
		local est_len
		local est_lenvar
		*Parse interval -> Not the best names yet
		local null_lo = `: word `i' of `nulllo''
			isValid `null_lo'
			isInfinite `null_lo'
			local null_lo = `r(infinite)'
		
		local null_hi = `: word `i' of `nullhi''
			isValid `null_hi'
			isInfinite `null_hi'
			local null_hi = `r(infinite)'
		*Only required if no variables as input
		if `varsfound'==0{
		local est_lo = `: word `i' of `estlo''	
			isValid `est_lo'
			isInfinite `est_lo'
			local est_lo = `r(infinite)'

		local est_hi = `: word `i' of `esthi''
			isValid `est_hi'
			isInfinite `est_hi'
			local est_hi =`r(infinite)'
		}
		else{
			local est_lo = `estlo'[`i']
			local est_hi = `esthi'[`i']
		}
		*Compute Interval Lengths -> Not sure how to deal with infinite lengths
		/*if !`varsfound'{
			local est_len = `est_hi' - `est_lo'
		}
		else{
			local est_len = `est_hi'[`i'] - `est_lo'[`i']
		}*/
		local est_len = `est_hi' - `est_lo'
		local null_len = `null_hi' -`null_lo'
		
		*Warnings
		*local warn = `estlo'!=.| `estlo'!=. | `null_lo'!=. | `null_hi'!=. // na.any = (any(is.na(est.lo))|any(is.na(est.hi))|any(is.na(null.lo))|any(is.na(null.hi)))
			if "`warnings'"!="nowarnings"{
			if (`est_len'<0  ) & `null_len'<0 & `varsfound'==0 {
				disp as error "The `i'th interval length is negative."
			}
			*if isinfinite(abs(`est_len'))+abs(`null_len'){ disp as error "The `i' th interval has infinite length"} // Not sure how to implement the is.infinite function from R
			
			if (`est_len'==0 | `null_len'==0 ) & `varsfound'==0 {
				disp as error "The `i'th interval has zero length"
			}
		
		}
		
		*SGPV computation--------------------------------------------------
		*Esthi and estlo are vectors
		
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
}
	
 
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

*Use new variables to store and calculate the SGPVs
program define sgpv_var, rclass
 syntax ,esthi(varname) estlo(varname) nullhi(string) nulllo(string) [replace]
 if "`replace'"!=""{
	capture drop pdelta dg
 }
 else{
	capture confirm variable pdelta dg
		if !_rc{
			disp as error "Specifiy the replace option: variables pdelta and dg already exist."
			exit 198
		}
 }
 
 tempvar estlen nulllen overlap bottom null_hi null_lo gap delta gapmax gapmin overlapmin overlapmax
 quietly{
		gen	`null_hi' = real("`nullhi'")
		gen `null_lo' =real("`nulllo'")			
 		gen `estlen' = `esthi' - `estlo'
		gen `nulllen' = `null_hi' -`null_lo'
		egen `overlapmin' = rowmin(`esthi' `null_hi') 
		egen `overlapmax' =rowmax(`estlo' `null_lo')
		gen `overlap' = `overlapmin' - `overlapmax'
		replace `overlap' = max(`overlap',0)
		gen `bottom' =	min(2*`nulllen',`estlen')
		gen pdelta = `overlap'/`bottom'
		
		replace pdelta =0 if `overlap'==0 
		replace pdelta = 1 if (`estlen'==0 & `nulllen'>=0 & `estlo'>=`null_lo' & `esthi'<=`null_hi')
		replace pdelta = 0.5 if (`estlen'>0 & `nulllen'==0 & `estlo'<=`null_lo' & `esthi'>=`null_hi')
		replace pdelta =. if (`estlo'>`esthi' | `null_lo'>`null_hi')
		/* Calculate delta gap*/
		egen 	`gapmax' = rowmax(`estlo' `null_lo') 
		egen	`gapmin' = rowmin(`null_hi' `esthi')
		gen 	`gap' = `gapmax' - `gapmin'
		 
		 gen `delta' = `nulllen'/2
		 replace `delta' = 1 if `nulllen'==0
		 gen dg = .
		 replace dg = `gap'/`delta'  if (pdelta==0 & pdelta!=.)

		*Label variables
		label variable pdelta "SGPV"
		label variable dg "Delta Gap"
		}
 
 exit 
end

***Mata function(s)
mata:
void function sgpv(string varlist, string sgpvmat, real scalar nulllo, real scalar nullhi, | string save ){ 
/*Allow only one null interval for now*/
/*Calculate the SGPVs and Delta Gaps if the desired matrix size is too large for Stata
Still rather slow for the leukemia example dataset with more than 7000 p-values to calculate
*/
	real matrix Sgpv
	//real matrix Data
	
	V = st_varindex(tokens(varlist))
    //Data = J(1,1,0)
    //st_view(Data,.,V) // First column should be the lower bound and the second column the upper bound -> not sure how to check that
	//Data=st_data(.,V) //Try alternative st_data to save time?
	Sgpv = J(st_nobs(),2,.)	// Change rows(Data) st_nobs()
	null_len = J(st_nobs(),1,nullhi - nulllo) 
	 
		est_lo =st_data(.,V[1]) 
		est_hi=st_data(.,V[2])
		est_len = est_hi - est_lo
		nulllo=J(st_nobs(),1,nulllo)
		nullhi=J(st_nobs(),1,nullhi)
		upper_bound =(est_hi, nullhi)
		lower_bound =(est_lo, nulllo)
		overlap =  rowmin(upper_bound)-rowmax(lower_bound)
		overlap = mm_cond(overlap:>0, overlap , 0 )
		 bottom =mm_cond(2:*null_len:>est_len, est_len , 2:*null_len)
		 pdelta = overlap:/bottom
		 	/* Overwrite NA and NaN due to bottom = Inf*/
		 pdelta =mm_cond(overlap:==0,0,pdelta)
		
		/* Interval estimate is a point (overlap=zero) but can be in null or equal null pt*/
		pdelta =mm_cond(est_len:==0, mm_cond(null_len:>=0,mm_cond(est_lo:>nulllo,mm_cond(est_hi:<=nullhi, 1,pdelta),pdelta),pdelta),pdelta)

		/* Null interval is a point (overlap=zero) but is in interval estimate*/
		pdelta = mm_cond(est_len:>0, mm_cond(null_len:==0,mm_cond(est_lo:<=nulllo,mm_cond(est_hi:>=nullhi, 0.5,pdelta),pdelta),pdelta),pdelta)
		/* Return Missing value for nonsense intervals*/
		pdelta = mm_cond(est_lo:>est_hi,.,mm_cond(nulllo:>nullhi,.,pdelta))
		/*if (est_lo>est_hi | nulllo>nullhi){
			pdelta = .			
		}*/
		 
		/* Calculate delta gap*/
		gap = rowmax(lower_bound)-rowmin(upper_bound)
		// gap = (est_lo> nulllo ? est_lo : nulllo ) - (nullhi> est_hi ? est_hi  : nullhi) // max(`est_lo', `null_lo') - min(`null_hi', `est_hi')
		 delta = null_len:/2
		 delta = mm_cond(null_len:==0,1,delta)
		/*disp "Iteration i: Gap gap Delta delta"*/
		dg = mm_cond(pdelta:==0, mm_cond(pdelta:!=., gap:/delta,.),.)
		/*Write results*/
		 Sgpv[.,1] = pdelta
		 Sgpv[.,2] = dg
	
	
	st_matrix(sgpvmat,Sgpv)
}
end
