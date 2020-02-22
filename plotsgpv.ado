*!Plot interval estimates according to Second-Generation p-value rankings
*!Based on the R-code for plotsgpv.R
*!Version 0.9
*! Removed setting of plot limits -> not really needed in Stata compared to R
/*START HELP FILE
title[Plotting Second-Generation P-Values]
desc[Plot the second-generation {it:p}-value (SGPV), as introduced in Blume et al. (2018), for user supplied interval estimates (support intervals, confidence intervals, credible intervals, etc.) according to its associated second-generation {it:p}-value ranking.
This command and its companions commands  ({cmd:sgpvalue}, {cmd:sgpower}, {cmd:fdrisk}) are based on the R-code for the sgpv-package from {browse "https://github.com/weltybiostat/sgpv"}
]
opt[esthi() A numeric vector of upper bounds of interval estimates. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:estlo}. Multiple upper bounds can be entered. They must be separated by spaces. Typically the upper bound of a confidence interval can be used.]
opt[estlo() A numeric vector of lower bounds of interval estimates. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:estlo}. Multiple lower bounds can be entered. They must be separated by spaces. Typically the lower bound of a confidence interval can be used.]
opt[nullhi() A numeric vector of upper bounds of null intervals. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:nulllo}.]
opt[nulllo() A numeric vector of lower bounds of null intervals. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:nullhi}.]
opt[setorder() A variable giving the desired order along the x-axis. If {bf:setorder} is set to {bf:"sgpv"}, the second-generation {it:p}-value ranking is used. If {bf:setorder} is empty, the original input ordering is used.]
opt[nomata Don't use Mata for calculating the SGPVs if esthi() and estlo() are variables as inputs or if c(matsize) is smaller than these options.]
opt[replace replace existing variables in case the nomata-option was used.]
opt[noshow do not show the outcome of the calculations. Useful for larger calculations.]
opt[xshow() A scalar representing the maximum ranking on the x-axis that is displayed. Default is to display all intervals.]
opt[nullcol() Coloring of the null interval (indifference zone). Default is the R-colour Hawkes Blue]
opt[intcol() Coloring of the intervals according to SGPV ranking. Default are the R-colours ("cornflowerblue","firebrick3","darkslateblue")} for SGPVs of {it:0}, in {it:(0,1)}, and {it:1} respectively.]

opt[noplotx_axis Deactive showing the x-axis.]
opt[noploty_axis Deactive showing the y-axis.]
opt[nullpt() A scalar representing a point null hypothesis. Default is 0. If set, the function will draw a horizontal dashed red line at this location.]
opt[nooutlinezone Deactive drawing a slim white outline around the null zone. Helpful visual aid when plotting many intervals. Default is on.]
opt[title() Title of the plot.]
opt[xtitle() Label of the x-axis label.]
opt[ytitle() Label of the y-axis.]
opt[nolegend Deactive plotting the legend.]
opt[* Any additional options for the plotting go here. See {help:twoway} for more information about the possible options. Options set here {bf:do not} override the values set in other options before.]

opt2[esthi() A numeric vector of upper bounds of interval estimates. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:estlo}. Multiple upper bounds can be entered. They must be separated by spaces. Typically the upper bound of a confidence interval can be used.
A variable contained the upper bound can be also used.
]

opt2[estlo() A numeric vector of lower bounds of interval estimates. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:estlo}. Multiple lower bounds can be entered. They must be separated by spaces. Typically the lower bound of a confidence interval can be used.
A variable contained the lower bound can be also used.
]
opt2[nullcol() Coloring of the null interval (indifference zone). Default is the R-colour Hawkes Blue. You can see the colour before plotting via 
{stata palette color 208 216 232 }
]
opt2[intcol() Coloring of the intervals according to SGPV ranking. Default are the R-colours ("cornflowerblue","firebrick3","darkslateblue")} for SGPVs of {it:0}, in {it:(0,1)}, and {it:1} respectively. You can see the colour before plotting via: 
{stata palette color 100 149 237 } // cornflowerblue
{stata palette color 205 38 38 } // firebrick3
{stata palette color 72 61 139 } // darkslateblue
]


opt2[nomata Deactive the usage of Mata for calculating the SGPVs with large matrices or variables. If this option is set, an approach based on variables is used. Using variables instead of Mata is considerably faster, but new variables containing the results are created. If you don't want to create new variables and time is not an issue then don't set this option. Stata might become unresponsive when using Mata.]

example[
{stata sysuse leukstats} // Load the example dataset provided with this command

{stata plotsgpv, esthi(ci_hi) estlo(ci_lo) nulllo(-0.3) nullhi(0.3) nomata replace noshow setorder(p_value) title("Leukemia Example") xtitle("Classical p-value ranking") ytitle("Fold Change (base 10)") ylabel(`=log10(1/1000)' "1/1000" `=log10(1/100)' "1/100" `=log10(1/10)' "1/10" `=log10(1/2)' "1/2" `=log10(2)' "2" `=log10(10)' "10" `=log10(100)' "100" `=log10(1000)'  "1000") } //Replicate the example plot from the R-code

]

references[ Blume JD, D’Agostino McGowan L, Dupont WD, Greevy RA Jr. (2018). Second-generation {it:p}-values: Improved rigor, reproducibility, & transparency in statistical analyses. \emph{PLoS ONE} 13(3): e0188299. https://doi.org/10.1371/journal.pone.0188299

Blume JD, Greevy RA Jr., Welty VF, Smith JR, Dupont WD (2019). An Introduction to Second-generation {it:p}}-values. {it:The American Statistician}. In press. https://doi.org/10.1080/00031305.2018.1537893 ]
author[Sven-Kristjan Bormann ]
institute[School of Economics and Business Administration, University of Tartu]
email[sven-kristjan@gmx.de]

seealo[ {help:fdrisk} {help:sgpvalue} {help:sgpower} {help:sgpv}  ]

END HELP FILE */
program define plotsgpv, rclass
syntax [if] [in] , esthi(string) estlo(string) nullhi(string) nulllo(string) /// 
[setorder(string) xshow(string) nullcol(string)		intcol(string)	 /// 
	 noploty_axis noplotx_axis	nullpt(real 0.0) nooutlinezone title(string) /// 
	xtitle(string) ytitle(string) nolegend nomata noshow replace * ]  


***Some default values :Color settings -> translated R-colors into RGB for Stata -> Not sure how to install the colours in Stata for easier referencing.
local cornflowerblue 100 149 237
local firebrick3 205 38 38
local darkslateblue 72 61 139
local intcoldefault cornflowerblue firebrick3 darkslateblue 
local nullcoldefault 208 216 232
***Input parsing
*Need additional checks and conversions of matrix names  to work with the example in the R-code
if `:word count `nullhi'' != `: word count `nulllo''{
	disp as error " `"nullhi"' and `"nulllo"' are of different length "
	exit 198
}

if `:word count `esthi'' != `: word count `estlo''{
	disp as error " `"esthi"' and `"estlo"' are of different length. "
	exit 198
}

if `:word count `nullhi'' !=  1 |`: word count `nulllo'' !=1{
	disp as error " null.lo and null.hi must be scalars "
	exit 198
}
***Further input parsing
*Not sure how to parse matrices as input for esthi and estlo

if `:word count `esthi''==1{
	capture confirm numeric variable `esthi' `estlo'
	if !_rc{
		local varsfound 1
	}
	else{
		local varsfound 0
	}

}
*Set order of results -> Default behaviour: No ordering if nothing set
if "`setorder'"!="" & "`setorder'"!="sgpv"{
	capture confirm variable `setorder'
	if _rc{
		disp as error "No variables found in option 'setorder'. Only variable names or `"sgpv"' are allowed values. "
		exit 198
	}
	else local setorder_var `setorder' // Indicate that variable for sorting got found -> currently needed due to somewhat confusing handling of the setorder option
}

*How much to show
if "`xshow'"!=""{ // Not correct yet
	local xshow = real("`xshow'")
}
else local xshow = _N

if "`if'"!=""{
	local if  `if' & \`x'<=`xshow'   //Don't expand x because the variable will be defined only later -> maybe place this macro somewhere else
}
else local if if \`x'<=`xshow'

*Other graphing options
local graphopt `options'

*Color settings
if "`intcol'"==""{
	local intcol `intcoldefault'
}
else if `: word count `intcol'' ==3{
		disp as error "Three distinct colors need to be specified for option 'intcol'. Colors should be names or RGB values."
		exit 198
	}
else{
	local color1 `:word 1 of `intcol''
	local color2 `:word 2 of `intcol''
	local color3 `:word 3 of `intcol''
	local intcol color1 color2 color3

}	

if "`nullcol'"==""{
	local nullcol `nullcoldefault'
}
	

/*

#### Set order of x-axis
	if (is.na(set.order[1]))  {set.order <- x}
	if "`setorder'"=="" local setorder x
	if "`setorder'"=="sgpv" local setorder `sgpv.combo' // Not correct yet; needs differnt variable if matrix or variable is used
	if (set.order[1]=="sgpv") {set.order <- order(sgpv.combo)}	

	*/	


	**** Compute SGPVs for plotting
	tempname sgpvs sgpvcombo
	tempvar sgpvcomb x nlo nhi
	if `varsfound'==1{
		sgpvalue, estlo(`estlo') esthi(`esthi') nulllo(`nulllo') nullhi(`nullhi') nomata `replace' `noshow'
		if ("`setorder'"=="sgpv") gen `sgpvcomb' = cond(pdelta==0,-dg,pdelta )
	}
	else if `varsfound'==0{ // Not correct yet
			sgpvalue, estlo(`estlo') esthi(`esthi') nulllo(`nulllo') nullhi(`nullhi') `nomata' `replace'
			mat `sgpvs' = r(results)
			if ("`sortorder'"=="sgpv"){
				mat `sgpvcombo' = J(`=rowsof(`sgpvs')',1,.) // Not possible if matrix is two large -> requires different solution
				mat colnames `sgpvcombo' = "sgpvcombo"
				forvalues i=1/`=rowsof(`sgpvs')'{ // Only needed if sorting is set to sgpv
					if `sgpvs'[`i',1]==0{
						mat `sgpvcombo'[`i',1]=-`=`sgpvs'[`i',2]'
					}
					else{
						mat `sgpvcombo'[`i',1]=`=`sgpvs'[`i',1]'
					}
				
				}
			}
	}
	/*if c(matsize)<`=rowsof(`sgpvs')'{
	
	}*/
	*else{

	*}
	*Convert matrix to variables -> directly plottig of matrices not possible
	preserve
	*Prepare matrix for conversion
	if (`varsfound'==0 & "`setorder'"=="sgpv") svmat `sgpvcombo' ,names(col)
	
	*Sort dataset
	if "`setorder'"=="sgpv"{ //Not correct parsing yet of the sorting order input
		if `varsfound'==0 local order sgpvcombo
		if `varsfound'==1 local order \`sgpvcomb'
	
	}
	if "`order'"!="" sort `order'
	else if "`setorder_var'"!="" sort `setorder_var'
	gen `x'=_n
	gen `nhi' =`nullhi'
	gen `nlo' = `nulllo'
	*keep if _n<=`xshow' // Not sure if needed for plotting -> taking over from R-code
	***Set up graphs
	*Null interval
	local nullint (rarea `nlo' `nhi' `x', sort lcolor("`nullcoldefault'") fcolor("`nullcoldefault'"))
	* Intervals where 0<SGPV<1
	local sgpv01 (rbar `estlo' `esthi' `x' if pdelta<1 & dg==., sort lcolor("``:word 1 of `intcol'''") fcolor("``:word 1 of `intcol'''"))

	* Intervals where SGPV==1
	local sgpv1 (rbar `estlo' `esthi' `x' if pdelta==1 & dg==., sort lcolor("``:word 3 of `intcol'''") fcolor("``:word 3 of `intcol'''"))

	* Intervals where SGPV==0
	local sgpv0  (rbar `estlo' `esthi' `x' if pdelta==0 & dg!=., sort lcolor("``:word 2 of `intcol'''") fcolor("``:word 2 of `intcol'''"))
	*Detail indifference zone
		local ynullpt yline(`nullpt', lpattern(dash))

		if "`outlinezone'"!="nooutlinezone"{
			local ynulllo	yline(`nulllo',  lcolor(white))
			local ynullhi	 yline(`nullhi', lcolor(white))
		}
	*Turning off axis	
	if "`ploty_axis'"=="noploty_axis" local yaxis yscale(off)
	if "`plotx_axis'"=="noplotx_axis" local xaxis xscale(off)
	
	*Legend
	if "`legend'"!="nolegend"{
	 local sgpvlegend	legend(on order(1 "Interval Null" 2 "0 < p <1"  3 "p = 1"  4 "p = 0")  position(1) ring(0) cols(1) symy(*0.25) region(lpattern(blank))) //-> Not done yet -> Not all settings in R-code are possible in Stata
	}	
	
	*Removing from graphopt unnecessary options
	
	
	***Plot: Set up the twoway plot
	twoway `nullint' `sgpv01' `sgpv1' `sgpv0' `if'  `in'  , title(`title') xtitle(`xtitle') ytitle(`ytitle') `ynullhi' `ynulllo' `ynullpt' `sgpvlegend' `xaxis' `yaxis'  `graphopt'
	
	restore
end

