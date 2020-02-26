*!Based on the R-code sgpower
*!Works only on one interval at the moment
*!Not possible to plot the power function yet
*!Version 0.9 	: Initial Github Release
*!Version 0.91 	: Removed dependency on user-provided integrate-command. 
*!Version 0.91a	: Fixed some issues in the documentation. ->Not done yet
/* START HELP FILE
title[Power functions for Second-Generation P-Values]
desc[Compute power/type I error for Second-Generation P-Values approach.]
opt[true() the true value for the parameter of interest at which to calculate power. 
			Note that this is on the absolute scale of the parameter, and not the standard deviation or standard error scale.]
opt[nulllo() the lower bound of the indifference zone (null interval) upon which the second-generation {it:p}-value is based.]
opt[nullhi() the upper bound for the indifference zone (null interval) upon which the second-generation {it:p}-value is based.]
opt[inttype() class of interval estimate used for calculating the SGPV. Options are "confidence" for a (1-\alpha)100% confidence interval and "likelihood" for a 1/k likelihood support interval ("credible" not yet supported)]
opt[intlevel() level of interval estimate. If intervaltype is "confidence", the level is \alpha. 
				If "intervaltype" is "likelihood", the level is 1/k (not k).]
opt[stderr() standard error for the distribution of the estimator for the parameter of interest. 
			Note that this is the standard deviation for the estimator, not the standard deviation parameter for the data itself. 
			This will be a function of the sample size(s).]
opt[bonus display the additional diagnostics for error type I]
return[power0 probability of SGPV = 0 calculated assuming the parameter is equal to {cmd:true}. That is, {cmd:power.alt} = P(SGPV = 0 | \theta = } {cmd:true). ]
return[power1 probability of SGPV = 1 calculated assuming the parameter is equal to {cmd:true}. That is, {cmd:power.null} = P(SGPV = 1 | \theta = ) {cmd:true).]
return[powerinc probability of 0 < SGPV < 1 calculated assuming the parameter is equal to {cmd:true}. That is, {cmd:power.inc} = P(0 < SGPV < 1 | \theta = ) {cmd:true).]
return[minI is the minimum type I error over the range ({cmd:null.lo}, {cmd:null.hi}), which occurs at the midpoint of ({cmd:null.lo}, {cmd:null.hi}).]
return[maxI is the maximum type I error over the range ({cmd:null.lo}, {cmd:null.hi}), which occurs at the boundaries of the null hypothesis, {cmd:null.lo} and {cmd:null.hi}. ]
return[avgI is the average type I error (unweighted) over the range ({cmd:null.lo}, {cmd:null.hi}). If 0 is included in the null hypothesis region, then "type I error summaries" also contains at 0, the type I error calculated assuming the true parameter value \theta is equal to 0.]
example[
{stata sgpower,true(2) nulllo(-1) nullhi(1) stderr(1) inttype("confidence") intlevel(0.05)}
]
references[ Blume JD, D’Agostino McGowan L, Dupont WD, Greevy RA Jr. (2018). Second-generation {it:p}-values: Improved rigor, reproducibility, & transparency in statistical analyses. {it:PLoS ONE} 13(3): e0188299. {browse:https://doi.org/10.1371/journal.pone.0188299}

Blume JD, Greevy RA Jr., Welty VF, Smith JR, Dupont WD (2019). An Introduction to Second-generation {it:p}}-values. {it:The American Statistician}. In press. {browse:https://doi.org/10.1080/00031305.2018.1537893} ]

author[Sven-Kristjan Bormann]
institute[School of Economics and Business Administration, University of Tartu]
email[sven-kristjan@gmx.de]
seealso[ {help:fdrisk} {help:plotsgpv} {help:sgpvalue}  {help:sgpv}]
END HELP FILE*/

capture program drop sgpower
program define sgpower, rclass
version 14
syntax , true(real)  nulllo(real)  nullhi(real)  inttype(string)   intlevel(real) [stderr(real 1)  Bonus]

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
	local z = invnorm(1- `intlevel'/2)
}

if "`inttype'"=="likelihood"{
	local z = invnorm(1- 2*normal(-sqrt(2*log(1/`intlevel')))/2)
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
  
  *local pow0 normal(`nulllo'/`stderr' - `x'/`stderr' -`z') + normal(-`nullhi'/`stderr' + `x'/`stderr' - `z')
  local x (`nulllo'+`nullhi')/2
  local minI = normal(`nulllo'/`stderr' - `x'/`stderr' -`z') + normal(-`nullhi'/`stderr' + `x'/`stderr' - `z')
  local x `nulllo'
  local maxI = normal(`nulllo'/`stderr' - `x'/`stderr' -`z') + normal(-`nullhi'/`stderr' + `x'/`stderr' - `z')
  
  
  *Use Stata's internal numerical integration command 
  preserve
  quietly{ 
	  range x `nulllo' `nullhi' 1000 //Arbitrary number of integration points could be made dependent on the distance between upper and lower limit
	  gen y = normal(`nulllo'/`stderr' - x/`stderr' -`z') + normal(-`nullhi'/`stderr' + x/`stderr' - `z')
	  integ y x
	  local intres `r(integral)'
  }
  restore

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

return local power0  `power0'
return local power1  `power1'
return local powerinc  `powerinc'
return local minI  `minI'
return local maxI  `maxI'
return local avgI `avgI'

end
