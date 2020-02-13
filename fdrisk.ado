*!False discovery rates
*!Based on the R-code for fdisk.R
*!Version 0.9
*!To-Do: Rewrite to use Mata whenever possible instead of workarounds in Stata -> Shorten the code
*! Evaluate input of options directly with the expression parser `= XXX' to allow more flexible input -> somewhat done, but not available for all options
/*START HELP FILE
title[False Discovery Risk for Second-Generation p-values]
desc[This command computes the false discovery risk (sometimes called the "empirical bayes FDR") for a second-generation {it:p}-value of 0, or the false confirmation risk for a second-generation {it:p}-value of 1. This command should be used for single calculations. For calculations for or after estimation commands use the {cmd:sgpv} command. ]
opt[sgpval The observed second-generation {it:p}-value. Default is 0, which gives the false discovery risk. Setting it to 1 gives the false confirmation risk]
opt[nulllo() The lower bound of the indifference zone (null interval) upon which the second-generation {it:p}-value was based.]
opt[nullhi() The upper bound for the indifference zone (null interval) upon which the second-generation {it:p}-value was based.]
opt[stderr() Standard error of the point estimate.]
opt[inttype() Class of interval estimate used. This determines the functional form of the power function. Options are "confidence" for a (1-\alpha)100% confidence interval and "likelihood" for a 1/k likelihood support interval ("credible" not yet supported).]
opt[intlevel() Level of interval estimate. If inttype is "confidence", the level is \alpha. If "inttype" is "likelihood", the level is 1/k (not k).]
opt[nullweights() Probability distribution for the null parameter space. Options are currently "Point", "Uniform", and "TruncNormal".]
opt[nullspace() Support of the null probability distribution. If "nullweights" is "Point", then "nullspace" is a scalar. If "nullweights" is "Uniform", then "nullspace" is a vector of length two.]
opt[altweights() Probability distribution for the alternative parameter space. Options are currently "Point", "Uniform", and "TruncNormal".]
opt[altspace() Support for the alternative probability distribution. If "altweights" is "Point", then "altspace" is a scalar. If "altweights" is "Uniform" or "TruncNormal", then "altspace" is a vector of length two.]
opt[pi0() Prior probability of the null hypothesis. Default is 0.5.]
opt[nomata deactivates the usage of an additional user-provided command for numerical integration. The numerical integration is required to calculate the false discovery/confirmation risks. Instead the numerical integration Stata command is used.  ]

example[
{bf:false discovery risk with 95% confidence level}

fdrisk, sgpval(0)  nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)  nullweights("Uniform")  nullspace(log(1/1.1) log(1.1)) altweights("Uniform")  altspace(2-1*invnorm(1-0.05/2)*0.8 2+1*invnorm(1-0.05/2)*0.8) inttype("confidence") intlevel(0.05)

]
return[fdr False discovery risk]
return[fcr False confirmation risk ]
references[ Blume JD, D’Agostino McGowan L, Dupont WD, Greevy RA Jr. (2018). Second-generation {it:p}-values: Improved rigor, reproducibility, & transparency in statistical analyses. \emph{PLoS ONE} 13(3): e0188299. https://doi.org/10.1371/journal.pone.0188299

Blume JD, Greevy RA Jr., Welty VF, Smith JR, Dupont WD (2019). An Introduction to Second-generation {it:p}}-values. {it:The American Statistician}. In press. https://doi.org/10.1080/00031305.2018.1537893 ]
author[Sven-Kristjan Bormann ]
institute[School of Economics and Business Administration, University of Tartu]
email[sven-kristjan@gmx.de]

seealo[ {help:sgpvalue} {help:sgpower} {help:sgpv}  ]
END HELP FILE */


capture program drop fdrisk

program define fdrisk, rclass
version 14
syntax, nullhi(string) nulllo(string) STDerr(real) INTType(string) INTLevel(string) ///
		NULLSpace(string) NULLWeights(string) ALTSpace(string) ALTWeights(string) ///
		[sgpval(integer 0) pi0(real 0.5) nomata]
*Syntax parsing
if "`mata'"!="nomata"{ //Check if necessary command is installed
	capture which integrate
	qui if _rc ssc install integrate, replace
	local integrate integrate
}
else local integrate nomataInt

if !inlist(`sgpval',0,1){
	stop "Only values 0 and 1 allowed for the option 'sgpval'"
	
}

if !inlist("`inttype'", "confidence","likelihood"){
	stop "Parameter intervaltype must be one of the following: confidence or likelihood "
	
}

if !inlist("`nullweights'", "Point", "Uniform", "TruncNormal"){
	stop "Parameter nullweights must be one of the following: Point, Uniform or TruncNormal"
}

if !inlist("`altweights'", "Point", "Uniform", "TruncNormal"){
	stop "Parameter altweights must be one of the following: Point, Uniform or TruncNormal"
}


*Code taken from sgpower.ado -> in R-code things are handled directly by the sgpower() function. This would be only possible in Mata in the same way.
if "`inttype'"=="confidence"{
	local z = invnorm(1- `intlevel'/2)
}

if "`inttype'"=="likelihood"{
	local z = invnorm(1- 2*normal(-sqrt(2*log(1/`intlevel')))/2)
}

*Evaluate inputs to allow more flexible specifications of intervals, null & alt spaces; no further checks yet for non-sensical input
local nullhi = `nullhi'
local nulllo = `nulllo'
if `: word count `nullspace''==1 local nullspace = `nullspace'
if `: word count `nullspace''==2{
	local nullspace1  `: word 1 of `nullspace''
	local nullspace1 = `nullspace1'
	local nullspace2  `: word 2 of `nullspace''
	local nullspace2 = `nullspace2'
	local nullspace `nullspace1' `nullspace2'
} 

if `: word count `altspace''==1 local altspace = `altspace'
if `: word count `altspace''==2{
	local altspace1  `: word 1 of `altspace''
	local altspace1 = `altspace1'
	local altspace2  `: word 2 of `altspace''
	local altspace2 = `altspace2'
	local altspace `altspace1' `altspace2'
} 

local intlevel = `intlevel'


*Power functions
	if `sgpval'==0{
		local powerx normal(`nulllo'/`stderr' - x/`stderr' -`z') + normal(-`nullhi'/`stderr' + x/`stderr' - `z')
		
	}
	if `sgpval'==1{
		if (`nullhi'-`nulllo')>= 2*`z'*`stderr' {
		local powerx normal(`nullhi'/`stderr' - x/`stderr' - `z') - normal(`nulllo'/`stderr' - x/`stderr' + `z')
		
		}
		if (`nullhi'-`nulllo') < 2*`z'*`stderr'{
		local powerx = 0 
		}
	}
    if(`nulllo' == `nullhi')  {
      if "`nulllo'" != "`nullspace'"{
		disp as error "for a point indifference zone, specification of a different 'nullspace' not permitted; 'nullspace' set to be " round(`nulllo', 0.01)
	  } 
	  local powerxnull : subinstr local powerx "x" "`nulllo'", all // Need substitution to emulate the parameter passing of R-functions only possible in Mata but in Stata -> Could be reworked by switching over to Mata
      local PsgpvH0 = `powerxnull'
	} 


*** calculate P.sgpv.H0

    * point null
	   * * interval null
     if(`nulllo' != `nullhi')  {

     * * P.sgpv.H0 @ point (=type I error at null.space)
      if("`nullweights'" == "Point")  {
        if(`:word count `nullspace''!=1){
			stop "null space must be a vector of length 1 when using a point null probability distribution"
			
		} 
		local powerxnullint : subinstr local powerx "x" "`nullspace'", all
		local PsgpvH0 = `powerxnullint' 
      }
	 * P.sgpv.H0 averaged: check `null.space` input
	 if inlist("`nullweights'","Uniform","GBeta","TruncNormal"){
		if `:word count `nullspace''<2{
			stop "null space must not be a point to use averaging methods"
			
		}
		if `:word count `nullspace''==2{
			if max(`:word 1 of `nullspace'', `:word 2 of `nullspace'')>`nullhi' | min(`:word 1 of `nullspace'', `:word 2 of `nullspace'')<`nulllo'{
				disp as error "null space must be inside originally specified null hypothesis; at least one null space bound has been truncated"
				
				if max(`:word 1 of `nullspace'', `:word 2 of `nullspace'')>`nullhi'{
					local nullspace `=min(`:word 1 of `nullspace'', `:word 2 of `nullspace'')' `nullhi'
				}  
				if min(`:word 1 of `nullspace'', `:word 2 of `nullspace'')<`nulllo'{
					local nullspace `nulllo' `=max(`:word 1 of `nullspace'', `:word 2 of `nullspace'')' 
			
				}
				
			}
		}
	 }
 * P.sgpv.H0 averaged uniformly
      if("`nullweights'" == "Uniform") {
		qui `integrate' ,f(`powerx') l(`=min(`:word 1 of `nullspace'', `:word 2 of `nullspace'')') u(`=max(`:word 1 of `nullspace'', `:word 2 of `nullspace'')') v
		*local integrand `r(integral)'
        local PsgpvH0 = 1/(`=max(`:word 1 of `nullspace'', `:word 2 of `nullspace'')' - `=min(`:word 1 of `nullspace'', `:word 2 of `nullspace'')') * `r(integral)' 
      }

      *P.sgpv.H0 averaged using generalized beta as weighting distribution function
      if("`nullweights'" == "GBeta") {
        disp as error "placeholder for future implementation of Generalized Beta null probability distribution"

        local PsgpvH0 .
      }
	       *P.sgpv.H0 averaged using truncated normal as weighting distribution function
      if("`nullweights'" == "TruncNormal") {

        * default: mean of Normal distr at midpoint of null.space // I assume that nullspace can have only two elements: upper and lower bound
        local truncNormmu = (`:word 1 of `nullspace'' + `:word 2 of `nullspace'')/2
        * default: std. dev of Normal distr same as assumed for estimator
        local truncNormsd  `stderr'

        local integrand `powerx' * ( normalden(x, `truncNormmu', `truncNormsd') * (normal((`=max(`:word 1 of `nullspace'', `:word 2 of `nullspace'')' - `truncNormmu')/`truncNormsd') - normal((`=min(`:word 1 of `nullspace'', `:word 2 of `nullspace'')'- `truncNormmu')/ `truncNormsd'))^(-1) ) 
        qui `integrate', f(`integrand') l(`=min(`:word 1 of `nullspace'', `:word 2 of `nullspace'')') u(`=max(`:word 1 of `nullspace'', `:word 2 of `nullspace'')') v
        local PsgpvH0 `r(integral)'

      }
	 } 
	 *Next next to translate
	 *** calculate P.sgpv.H1

    * P.sgpv.H1 @ point
    if("`altweights'" == "Point")  {
      if(`:word count `altspace''!=1){
	    stop "alt space must be a vector of length 1 when using a point alternative probability distribution"
		
	  }
	  
      if inrange(`altspace',`nulllo',`nullhi') {
		stop "alternative space must be outside of the originally specified indifference zone"
	  
	  } 
	  local powerxaltpoint : subinstr local powerx "x" "`altspace'", all
      local PsgpvH1 = `powerxaltpoint' 
    }

    * P.sgpv.H1 averaged: check ``altspace'` input
    if inlist("`altweights'" ,"Uniform", "GBeta", "TruncNormal") {
      if( `:word count `altspace''<2)  stop "alt space must not be a point to use averaging methods"
      if `:word count `altspace''==2  {
        if(`=min(`:word 1 of `altspace'', `:word 2 of `altspace'')' > `nulllo') & (`=max(`:word 1 of `altspace'', `:word 2 of `altspace'')'< `nullhi') stop "alternative space can not be contained inside indifference zone; 'nullspace' and `'altspace' might be flipped"
        if ((`:word 1 of `altspace'' >`nulllo'| `:word 2 of `altspace''> `nulllo' ) & (`:word 1 of `altspace'' < `nullhi'| `:word 2 of `altspace'' < `nullhi'))  stop "alternative space can not intersect indifference zone" //Not sure if translated correctly
      }
    }

    * P.sgpv.H1 averaged uniformly
    if("`altweights'" == "Uniform") {
	 qui `integrate', f(`powerx') l(`=min(`:word 1 of `altspace'', `:word 2 of `altspace'')') u(`=max(`:word 1 of `altspace'', `:word 2 of `altspace'')') v
      local PsgpvH1 = 1/(`=max(`:word 1 of `altspace'', `:word 2 of `altspace'')' - `=min(`:word 1 of `altspace'', `:word 2 of `altspace'')') * `r(integral)'
    }

    * P.sgpv.H1 averaged using generalized beta as weighting distribution function
    if("`altweights'" == "GBeta") {
      disp as error "placeholder for future implementation of Generalized Beta null probability distribution"
      local PsgpvH1 .
    }

    * P.sgpv.H1 averaged using truncated normal as weighting distribution function
    if("`altweights'" == "TruncNormal") {

      * default: mean of Normal distr at midpoint of `altspace'
      local truncNormmu = (`:word 1 of `altspace'' + `:word 2 of `altspace'')/2
      * default: std. dev of Normal distr same as assumed for estimator
      local truncNormsd = `stderr'

      *if(any(is.na(c(truncNorm.mu, truncNorm.sd)))) stop('error: 'trunNorm.mu' and 'truncNorm.sd' must be NULL or numeric; may not be NA') // Not sure how to check that
	  if !real("`truncNormmu'") | !real("`truncNormsd'") stop "'trunNorm.mu' and 'truncNorm.sd' must be numeric"

        local integrand `powerx' * ( normalden(x, `truncNormmu', `truncNormsd') * (normal((`=max(`:word 1 of `altspace'', `:word 2 of `altspace'')' - `truncNormmu')/`truncNormsd') - normal((`=min(`:word 1 of `altspace'', `:word 2 of `altspace'')'- `truncNormmu')/ `truncNormsd'))^(-1) ) 
        qui `integrate', f(`integrand') l(`=min(`:word 1 of `altspace'', `:word 2 of `altspace'')') u(`=max(`:word 1 of `altspace'', `:word 2 of `altspace'')') v
      
      local PsgpvH1 = `r(integral)'

    }
	
 * Calculate FDR or FCR
  if(`sgpval' == 0){
	local fdr = (1 + `PsgpvH1' / `PsgpvH0' *  (1-`pi0') / `pi0'     ) ^ (-1) 
	}
  if(`sgpval' == 1){
  local fcr = (1 + `PsgpvH0' / `PsgpvH1' *  `pi0'     / (1-`pi0') ) ^ (-1)
  }
  
  if "`fdr'"!="" | !mi(real("`fdr'")){
	disp "False discovery risk is: `fdr'"
  }
  if "`fcr'"!="" | !mi(real("`fcr'")){
	disp "False confirmation rate is: `fcr'"
  }

  return local fdr  `fdr'
  return local fcr  `fcr'  	
end

*Simulate the behaviour of the R-function with the same name 
program define stop
 args text 
 disp as error `"`text'"'
 exit 198
end


*In case no Mata integration is requested 
program define nomataInt, rclass
syntax , Lower(real) Upper(real) Function(string) [Vectorise]
preserve
range x `lower' `upper' 1000
gen y  = `function'
integ y x
return local integral `r(integral)'
restore
 
end
