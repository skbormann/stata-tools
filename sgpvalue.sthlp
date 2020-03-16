{smcl}
{* *! version 0.98a  15 Mar 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "sgpvalue##syntax"}{...}
{viewerjumpto "Description" "sgpvalue##description"}{...}
{viewerjumpto "Options" "sgpvalue##options"}{...}
{viewerjumpto "Remarks" "sgpvalue##remarks"}{...}
{viewerjumpto "Examples" "sgpvalue##examples"}{...}
{title:Title}
{phang}
{bf:sgpvalue} {hline 2} Second-Generation p-values

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:sgpvalue}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt esthi(string)}}   upper bound of interval estimate. Values may be finite or infinite.
{p_end}
{synopt:{opt estlo(string)}}  lower bound of interval estimate. Values may be finite or infinite.
{p_end}
{synopt:{opt nullhi(string)}}  upper bound of null interval.
{p_end}
{synopt:{opt nulllo(string)}}  lower bound of null interval.
{p_end}
{synopt:{opt nowarnings}}  disable showing the warnings about potentially problematic intervals.
{p_end}
{synopt:{opt infcorrection(#)}}  a small scalar to denote a positive but infinitesimally small SGPV. Default is 1e-5.
{p_end}
{synopt:{opt nodeltagap}}  disable the display of the delta-gap. 
{p_end}
{synopt:{opt nomata}}  do not use Mata for calculating the SGPVs if esthi() and estlo() are variables as inputs or if {cmd:c(matsize)} is smaller than the size of these options.
{p_end}
{synopt:{opt noshow}}  do not show the outcome of the calculations. Useful for larger calculations.
{p_end}
{synopt:{opt replace}}  replace existing variables in case the nomata-option was used.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
Compute the second-generation {it:p}-value (SGPV) and its associated delta-gaps, as introduced in Blume et al. (2018). 
This command and its companions commands ({cmd:sgpower}, {cmd:fdrisk}, {cmd:plotsgpv}) are based on the R-code for the sgpv-package from {browse "https://github.com/weltybiostat/sgpv"}.
A wrapper command {help sgpv} also exists  which makes the computation after common estimation commands easier.
The {cmd:sgpvalue} command should be used mostly for individual SGPV calculations.
A {dialog sgpvalue:dialog box} exists to make using this command easier. {p_end}
{pstd}
When {it:"nullhi"} and {it:"nulllo"} are of length 1, the same null interval is used for every interval estimate of [{it:"estlo"}, {it:"esthi"}]. 
If {it:"nullhi"} is not of length 1, its length must match that of {it:"esthi"}.{p_end}

 {col 10} The SGPV is defined as : 	p_δ  = |I ∩ H_0|/|I|*max{|I|/(2|H_0|), 1} 
{col 10}				    = |I ∩ H_0|/|I| 		when |I|<=2|H_0| 
	{col 10}				    = 1/2*|I ∩ H_0|/|I| 	when |I|> 2|H_0| 
		{col 10}			  with I = {θ_l,θ_u} and |I|= θ_u - θ_l.  
								 
{pstd}								 
θ_u and θ_l are typically the upper and lower bound of a (1-α)100% confidence interval but any other interval estimate is also possible. {break}
H_0 is the null hypothesis and |H_0| its length. {break}
The null hypothesis should be an interval which contains all effects that are not scientifically relevant. {break}
The p-values reported by most of Stata's estimation commands are based on the null hypothesis of exactly 0. {break}
Point null-hypothesis are supported by SGPVs, but they are discouraged. 
See answer 11 in the {browse "https://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0188299.s002&type=supplementary":Frequently asked questions} to Blume et al. (2018).
You could set a small null-hypothesis interval which includes effects of less than 1% or 0.1%. The exact numbers depend on what you deem a priori as not scientifically relevant.

{pstd}
p_δ lies between 0 and 1. {break}
A p_δ of 0 indicates that 0% of the null hypotheses are compatible with the data.  {break} 
A p_δ of 1 indicates that 100% of the null hypotheses are compatible with the data. {break}
A p_δ between 0 and 1 indicates inconclusive evidence. {break}
A p_δ of 1/2 indicates strictly inconclusive evidence.  {break} 

{pstd}
For more information about how to interpret the SGPVs and other common questions, 
see {browse "https://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0188299.s002&type=supplementary":Frequently Asked Questions} by Blume et al. (2018).

{pstd}
The delta-gap is have a way of ranking two studies that both have second-generation p-values of zero (p_δ = 0). 
It is defined as the distance between the intervals in δ units with δ being the half-width of the interval null hypothesis.{p_end}

		The delta-gap is calculated as: gap   	  = max(θ_l, H_0l) - min(H_0u, θ_u) 
						delta 	  = |H_0|/2 
						delta.gap = gap/delta 
						
{pstd}								
For the standard case of a point 0 null hypothesis and a 95% confidence interval, delta is set to be equal to 1. {break}
Then the delta-gap is just the distance between either the upper or the lower bound of the confidence interval and 0. {break}
If both θ_u and θ_l are negative then, the delta-gap is just θ_u, the upper bound of the confidence interval. {break}
If both bounds of the confidence interval are positive, then the delta-gap is equal to the lower bound of the confidence interval.{p_end}

{pstd}
When possible, one should compute the second-generation {it:p}-value on a scale that is symmetric about the null hypothesis. 
For example, if the parameter of interest is an odds ratio, computations are typically done on the log scale. 
This keeps the magnitude of positive and negative delta-gaps comparable. 
Also, recall that the delta-gaps magnitude is not comparable across different null intervals.{p_end}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt esthi(string)}  upper bound of interval estimate. Values may be finite or infinite.
To specify that the upper limit is +infinity just specify the missing value . in this option. Must be of same length as in the option {it:estlo}. Multiple upper bounds can be entered. They must be separated by spaces. Typically the upper bound of a confidence interval can be used. A variable contained the upper bound can be also used.

{phang}
{opt estlo(string)}  lower bound of interval estimate. The lower limit is -infinity just specify the missing value . in this option. Multiple lower bounds can be entered. They must be separated by spaces. 
Typically the lower bound of a confidence interval can be used. A variable contained the lower bound can be also used.

{phang}
{opt nullhi(string)}     upper bound of null interval.

{phang}
{opt nulllo(string)}     lower bound of null interval.

{phang}
{opt nowarnings}     disable showing the warnings about potentially problematic intervals.

{phang}
{opt infcorrection(#)}  a small scalar to denote a positive but infinitesimally small SGPV. Default is 1e-5. SGPVs that are infinitesimally close to 1 are assigned 1-infcorrection. 
This option can only be invoked when one of the intervals has infinite length.

{phang}
{opt nodeltagap}     disable the display of the delta-gap. Mainly used inside of {help sgpv}, since delta-gaps are less useful to most users of p-values. 

{phang}
{opt nomata}  deactivate the usage of Mata for calculating the SGPVs with large matrices or variables. If this option is set, an approach based on variables is used. 
Using variables instead of Mata will be faster, but new variables containing the results are created. 
If you don't want to create new variables and time is not an issue then don't set this option. Stata might become unresponsive when using Mata because it takes time to return a large matrix.

{phang}
{opt noshow}     do not show the outcome of the calculations. Useful for larger calculations.

{phang}
{opt replace} replace    replace existing variables in case the nomata-option was used.

{marker examples}{...}
{title:Examples}
{pstd}
The following examples are based on the original documentation for the R-code, but are modified to resemble more closely the usual Stata conventions.

{pstd}
 {bf:Simple example for three estimated log odds ratios but the same null interval} (To run this example copy the following lines into Stata and hit return.)
 
		 local lb log(1.05) log(1.3) log(0.97)	
		 local ub log(1.8) log(1.8) log(1.02)	
		 sgpvalue , estlo(`lb') esthi(`ub') nulllo(log(1/1.1)) nullhi(log(1.1))
		 
	{bf:One sided intervals/infinite interval bounds}
	{stata sgpvalue, estlo(`=log(1.3)') esthi(.) nulllo(.) nullhi(`=log(1.1)')}
	{stata sgpvalue, estlo(`=log(1.05)') esthi(.) nulllo(.) nullhi(`=log(1.1)')}
	
	 {bf:Example t-test with simulated data}
	 {stata sgpvalue_examples ttest_sim} (see the code {view sgpvalue_examples.ado##ttest:here})
	 
	 {bf:Simulated two-group dichotomous data for different parameters}
	 {stata sgpvalue_examples dichdata_sim} (see the code {view sgpvalue_examples.ado##dichdata:here})
	 
		
	{bf: A simple more Stata-like example with a point null hypothesis (not based on the R-code)}{p_end}	
		{stata sysuse auto, clear}
		{stata regress price mpg}
		{stata mat table = r(table)}  //Copies the regression results into a new matrix for the next calculations
		
	The numbers for the options could be also copied by hand, we use here directly the matrix.
		 {stata sgpvalue, esthi(table[6,1]) estlo(table[5,1]) nullhi(0) nulllo(0)} 
		 

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(results)}}  matrix with the results {p_end}


{title:References}
{pstd}
 Blume JD, D’Agostino McGowan L, Dupont WD, Greevy RA Jr. (2018). Second-generation {it:p}-values: Improved rigor, reproducibility, & transparency in statistical analyses. {it:PLoS ONE} 13(3): e0188299. 
{browse "https://doi.org/10.1371/journal.pone.0188299"}

{pstd}
Blume JD, Greevy RA Jr., Welty VF, Smith JR, Dupont WD (2019). An Introduction to Second-generation {it:p}-values. {it:The American Statistician}. In press. 
{browse "https://doi.org/10.1080/00031305.2018.1537893"} 


{title:Author}
{p}

Sven-Kristjan Bormann, School of Economics and Business Administration, University of Tartu.

{title:Bug Reporting}
{psee}
Please submit bugs, comments and suggestions via email to:	{browse "mailto:sven-kristjan@gmx.de":sven-kristjan@gmx.de}{p_end}
{psee}
Further Stata programs and development versions can be found under {browse "https://github.com/skbormann/stata-tools":https://github.com/skbormann/stata-tools}{p_end}

{title:See Also}
Related commands:
{help plotsgpv} {help sgpower} {help fdrisk} {help sgpv}

