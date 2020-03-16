*!False discovery rates
*!Based on the R-code for fdisk.R
*!Version 1.00 : Initial submission to SSC, no changes compared to last Github release
*!Version 0.96 : Minor bugfixes; added all missing examples from the R-code to the help file and some more details to the help file.
*!Version 0.95 : Updated documentation, added more possibilities to abbreviate options, probablyF last Github release before submission to SSC 
*!Version 0.91 : Removed the dependency on the user-provided integrate-command -> Removed nomata option
*!Version 0.90 : Initial Github release
*!To-Do: Rewrite to use Mata whenever possible instead of workarounds in Stata -> Shorten the code and make it faster
*!		 Evaluate input of options directly with the expression parser `= XXX' to allow more flexible input -> somewhat done, but not available for all options
*!		 Rewrite input logic for nullspace and altspace to allow spaces in the input and make it easier to generate inputs in the dialog box


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
local intlevel = `intlevel' 

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
		qui `integrate' ,f(`powerx') l(`=min(`:word 1 of `nullspace'', `:word 2 of `nullspace'')') u(`=max(`:word 1 of `nullspace'', `:word 2 of `nullspace'')') 
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
        qui `integrate', f(`integrand') l(`=min(`:word 1 of `nullspace'', `:word 2 of `nullspace'')') u(`=max(`:word 1 of `nullspace'', `:word 2 of `nullspace'')') 
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
	 qui `integrate', f(`powerx') l(`=min(`:word 1 of `altspace'', `:word 2 of `altspace'')') u(`=max(`:word 1 of `altspace'', `:word 2 of `altspace'')') 
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
        qui `integrate', f(`integrand') l(`=min(`:word 1 of `altspace'', `:word 2 of `altspace'')') u(`=max(`:word 1 of `altspace'', `:word 2 of `altspace'')') 
      
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
	disp _n "The false discovery risk (fdr) is: " %9.0g `fdr'
  }
  if "`fcr'"!="" | !mi(real("`fcr'")){
	disp _n "The false confirmation rate (fcr) is: " %9.0g `fcr'
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
syntax , Lower(real) Upper(real) Function(string)
preserve
range x `lower' `upper' 1000
gen y  = `function'
integ y x
return local integral `r(integral)'
restore
 
end
