*!Based on the R-code sgpower
*!Works only on one interval at the moment
*!Not possible to plot the power function yet
/* START HELP FILE
title[Power functions for Second-Generation p-values]
desc[]
opt2[true() The true value for the parameter of interest at which to calculate power. 
			Note that this is on the absolute scale of the parameter, and not the standard deviation or standard error scale.]
opt2[nulllo() The lower bound of the indifference zone (null interval) upon which the second-generation {it:p}-value is based.]
opt2[nullhi() The upper bound for the indifference zone (null interval) upon which the second-generation {it:p}-value is based.]
opt2[inttype() Class of interval estimate used for calculating the SGPV. Options are "confidence" for a (1-\alpha)100% confidence interval and "likelihood" for a 1/k likelihood support interval ("credible" not yet supported)]
opt2[intlevel() Level of interval estimate. If intervaltype is "confidence", the level is \alpha. 
				If "intervaltype" is "likelihood", the level is 1/k (not k).]
opt2[stderr() Standard error for the distribution of the estimator for the parameter of interest. 
			Note that this is the standard deviation for the estimator, not the standard deviation parameter for the data itself. 
			This will be a function of the sample size(s).]
opt[bonus Display the additional diagnostics for error type I]
opt[mata Use the user-provided command "integrate" for faster calculating the bonus diagnostics]
return[]
example[]
references[]
END HELP FILE*/

capture program drop sgpower
program define sgpower, rclass
version 10
syntax , true(real)  nulllo(real)  nullhi(real)  inttype(string)   intlevel(real) [stderr(real 1)  Bonus  Mata]

*Input checking: Not all checks yet,; no length checks yet 
if !inlist("`inttype'", "confidence","likelihood"){
	disp as err "Parameter intervaltype must be one of the following: confidence or likelihood "
	exit 198
}
	
/*if real("`intlevel'")==.{
	disp as err "Option 'intervallevel' does not contain a valid number."
	exit 198
}
else{
	local intervallevel = real("`intlevel'")
}
*/

if "`inttype'"=="confidence"{
	local z = invnorm(1- `intervallevel'/2)
}

if "`inttype'"=="likelihood"{
	local z = invnorm(1- 2*normal(-sqrt(2*log(1/`intervallevel')))/2)
}

**P(SGPV=0 | true ) (see Blume et al. (2018) eq.(S4) for CI/LSI)
local power0 = normal(`nulllo'/`stderr' - `true'/`stderr' -`z') + normal(-`nullhi'/`stderr' + `true'/`stderr' - `z')

**P(SGPV=1 | true ) (see Blume et al. (2018) eq.(S7) for CI/LSI)
* -> only for symmetric null hypothesis
if (`nullhi'-`nulllo')>= 2*`z'*`stderr' {
	local power1 = normal(`nullhi'/`stderr' - `true'/`stderr' - `z') - normal(`nulllo'/`stderr' - `true'/`stderr' + `z')
}
if (`nullhi'-`nulllo') < 2*`z'*`stderr'{
	local power1 = 0
}

 ** P(0<SGPV<1 | true)   (see Blume et al. (2018) eq.(S8, S9) for CI/LSI)
  * -> only for symmetric null hypothesis
if (`nullhi'-`nulllo')<= 2*`z'*`stderr' {
	local powerinc = 1 - normal(`nulllo'/`stderr' - `true'/`stderr' -`z') - normal(-`nullhi'/`stderr' + `true'/`stderr' - `z')
}

if (`nullhi'-`nulllo') > 2*`z'*`stderr'{
	local powerinc = 1 - (normal(`nulllo'/`stderr' - `true'/`stderr' -`z')  + normal(-`nullhi'/`stderr' + `true'/`stderr' - `z')) - (normal(`nullhi'/`stderr' - `z') - normal(`nulllo'/`stderr' - `true'/`stderr' + `z'))
}

*check
 * if(any(round(power.0+power.inc+power.1,7) != 1)) warning(paste0('error: power.0+power.inc+power.1 != 1 for indices ', paste(which(round(power.0+power.inc+power.1,7) != 1), collapse=', ')))

if round(`power0'+ `powerinc'+`power1',0.0000001)!=1{
disp as error "power.0+power.inc+power.1 != 1 for indices "

}



**Returned values
disp "Power.Alt: " round(`power0',0.0001) _skip(10)  "Power.inc: " round(`powerinc',0.0001) _skip(20) "Power.Null: " round(`power1',0.0001) 

if "`bonus'"!=""{
**bonus type I error summaries
*Uncorrect numbers
/*  pow0 = function(x) pnorm(null.lo/std.err - x/std.err - Z) + pnorm(-null.hi/std.err + x/std.err - Z)

  minI = pow0((null.lo+null.hi)/2)
  maxI = pow0(null.lo)
  avgI = 1/(null.hi-null.lo)*integrate(f=pow0, lower=null.lo, upper=null.hi)$value

  typeI = c('min'=minI, 'max'=maxI, 'mean'=avgI)
  if(null.lo<=0 & 0<=null.hi) {
    typeI = c('at 0'=pow0(0), 'min'=minI, 'max'=maxI, 'mean'=avgI)
  }
  */
  
  *local pow0 normal(`nulllo'/`stderr' - `x'/`stderr' -`z') + normal(-`nullhi'/`stderr' + `x'/`stderr' - `z')
  local x (`nulllo'+`nullhi')/2
  local minI = normal(`nulllo'/`stderr' - `x'/`stderr' -`z') + normal(-`nullhi'/`stderr' + `x'/`stderr' - `z')
  local x `nulllo'
  local maxI = normal(`nulllo'/`stderr' - `x'/`stderr' -`z') + normal(-`nullhi'/`stderr' + `x'/`stderr' - `z')
  
  
  *Alternative approach using user-provided integrate command
  if "`mata'"!=""{
  local power normal(`nulllo'/`stderr' - x/`stderr' -`z') + normal(-`nullhi'/`stderr' + x/`stderr' - `z') 
  capture which integrate
  if _rc qui ssc install install, replace
  integrate, f() l(`nulllo') u(`nullhi') vectorise
  local integral `r(integral)'
  }
  else{
  *
  *Use Stata's internal numerical integration command -> requires a new dataset
  preserve
  quietly{ 
  range x `nulllo' `nullhi' 1000 //Arbitrary number of integration points could be made dependent on the distance between upper and lower limit
  gen y = normal(`nulllo'/`stderr' - x/`stderr' -`z') + normal(-`nullhi'/`stderr' + x/`stderr' - `z')
  integ y x
  local intres `r(integral)'
  }
  restore
  }
  local avgI = 1/(`nullhi'-`nulllo')*`intres'
  local pow00 = normal(`nulllo'/`stderr' - 0/`stderr' -`z') + normal(-`nullhi'/`stderr' + 0/`stderr' - `z')
  disp "type I error summaries"
  if `nulllo>0' & `nullhi'>0{
  disp "Min: " round(`minI',0.000001) _skip(10) "Max: " round(`maxI',0.000001) _skip(10) "Mean :" round(`avgI',0.000001)
  }
  else if `nulllo'<=0 & `nullhi'<=0 {
	  disp "at 0: " round(`pow00',0.000001) _skip(10) "Min: " round(`minI',0.000001) _skip(10) "Max: " round(`maxI',0.000001) _skip(10) "Mean :" round(`avgI',0.000001)

  }
}

return scalar power0 `power0'
return scalar power1 `power1'
return scalar powerinc `powerinc'
return scalar minI `minI'
return scalar maxI `maxI'
return scalar avgI `avgI'

end
