*!False discovery rates
*!Based on the R-code for fdisk.R
*!Version 0.9  : Initial Github release
*!Version 0.91 : Removed the dependency on the user-provided integrate-command -> Removed nomata option
*!Version 0.95 : Updated documentation, last Github release before submission to SSC 
*!To-Do: Rewrite to use Mata whenever possible instead of workarounds in Stata -> Shorten the code
*!		 Evaluate input of options directly with the expression parser `= XXX' to allow more flexible input -> somewhat done, but not available for all options
/* START HELP FILE
title[False Discovery or Confirmation Risk for Second-Generation p-values]
desc[This command computes the false discovery risk (sometimes called the "empirical bayes FDR") for a second-generation {it:p}-value of 0, or the false confirmation risk for a second-generation {it:p}-value of 1. 
This command should be used mostly for single calculations. 
For calculations after estimation commands use the {help sgpv} command. 

The false discovery risk is defined as: 	P(H_0|p_δ=0) = (1 + P(p_δ = 0| H_1)/P(p_δ=0|H_0) * r)^(-1)
The false confirmation risk is defined as: 	P(H_1|p_δ=1) = (1 + P(p_δ = 1| H_0)/P(p_δ=1|H_1) * 1/r )^(-1)
with r = P(H_1)/P(H_0) being the prior probability.		

]
opt[sgpval the observed second-generation {it:p}-value.]
opt[nulllo() the lower bound of the indifference zone (null interval) upon which the second-generation {it:p}-value was based.]
opt[nullhi() the upper bound for the indifference zone (null interval) upon which the second-generation {it:p}-value was based.]
opt[stderr() standard error of the point estimate.]
opt[inttype() class of interval estimate used.]
opt[intlevel() level of interval estimate. If inttype is "confidence", the level is α. If "inttype" is "likelihood", the level is 1/k (not k).]
opt[nullweights() probability distribution for the null parameter space. Options are currently "Point", "Uniform", and "TruncNormal".]
opt[nullspace() support of the null probability distribution.]
opt[altweights() probability distribution for the alternative parameter space. Options are currently "Point", "Uniform", and "TruncNormal".]
opt[altspace() support for the alternative probability distribution.]
opt[pi0() prior probability of the null hypothesis. Default is 0.5.]
opt2[sgpval the observed second-generation {it:p}-value. Default is 0, which gives the false discovery risk. Setting it to 1 gives the false confirmation risk.]
opt2[nullspace() support of the null probability distribution. If "nullweights" is "Point", then "nullspace" is a scalar. If "nullweights" is "Uniform", then "nullspace" are two numbers separated by a space.]
opt2[inttype() class of interval estimate used. This determines the functional form of the power function. Options are "confidence" for a (1-α)100% confidence interval and "likelihood" for a 1/k likelihood support interval ("credible" not yet supported).]
opt2[altspace() support for the alternative probability distribution. If "altweights" is "Point", then "altspace" is a scalar. If "altweights" is "Uniform" or "TruncNormal", then "altspace" are two numbers separated by a space.]

example[
{bf:false discovery risk with 95% confidence level}

 fdrisk, sgpval(0)  nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)  nullweights("Uniform")  nullspace(log(1/1.1) log(1.1)) altweights("Uniform")  altspace(2-1*invnorm(1-0.05/2)*0.8 2+1*invnorm(1-0.05/2)*0.8) inttype("confidence") intlevel(0.05)

]
return[fdr false discovery risk]
return[fcr false confirmation risk ]
references[ Blume JD, D’Agostino McGowan L, Dupont WD, Greevy RA Jr. (2018). Second-generation {it:p}-values: Improved rigor, reproducibility, & transparency in statistical analyses. {it:PLoS ONE} 13(3): e0188299. 
{browse "https://doi.org/10.1371/journal.pone.0188299"}

Blume JD, Greevy RA Jr., Welty VF, Smith JR, Dupont WD (2019). An Introduction to Second-generation {it:p}-values. {it:The American Statistician}. In press. {browse "https://doi.org/10.1080/00031305.2018.1537893"} ]
author[Sven-Kristjan Bormann]
institute[School of Economics and Business Administration, University of Tartu]
email[sven-kristjan@gmx.de]

seealso[ {help plotsgpv} {help sgpvalue} {help sgpower} {help sgpv}  ]
END HELP FILE */


capture program drop fdrisk

program define fdrisk, rclass
version 12.0
syntax, nullhi(string) nulllo(string) STDerr(real) INTType(string) INTLevel(string) ///
		NULLSpace(string) NULLWeights(string) ALTSpace(string) ALTWeights(string) ///
		[SGPVal(integer 0) pi0(real 0.5)]
*Syntax parsing
local integrate nomataInt

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
		disp as error "For a point indifference zone, specification of a different 'nullspace' is not permitted; 'nullspace' set to be " round(`nulllo', 0.01)
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
			stop " 'nullspace' must contain only one value when using a point null probability distribution, e.g. 'nullspace(0)'."
			
		} 
		local powerxnullint : subinstr local powerx "x" "`nullspace'", all
		local PsgpvH0 = `powerxnullint' 
      }
	 * P.sgpv.H0 averaged: check `null.space` input
	 if inlist("`nullweights'","Uniform","GBeta","TruncNormal"){
		if `:word count `nullspace''<2{
			stop "nullspace must not be a point to use averaging methods. Set nullweights(`"Point"') instead."
			
		}
		if `:word count `nullspace''==2{
			if max(`:word 1 of `nullspace'', `:word 2 of `nullspace'')>`nullhi' | min(`:word 1 of `nullspace'', `:word 2 of `nullspace'')<`nulllo'{
				disp as error "null space must be inside originally specified null hypothesis; at least one null space bound has been truncated."
				
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

     
	  if !real("`truncNormmu'") | !real("`truncNormsd'") stop "'trunNorm.mu' and 'truncNorm.sd' must be numeric."

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


*Shortcut to the Stata integration command, same syntax as the user-provided integrate-command.
program define nomataInt, rclass
syntax , Lower(real) Upper(real) Function(string) [Vectorise]
preserve
range x `lower' `upper' 1000
gen y  = `function'
integ y x
return local integral `r(integral)'
restore
 
end
