{smcl}
{* *! version 1.0  3 Mar 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "fdrisk##syntax"}{...}
{viewerjumpto "Description" "fdrisk##description"}{...}
{viewerjumpto "Options" "fdrisk##options"}{...}
{viewerjumpto "Remarks" "fdrisk##remarks"}{...}
{viewerjumpto "Examples" "fdrisk##examples"}{...}
{title:Title}
{phang}
{bf:fdrisk} {hline 2} False Discovery or Confirmation Risk for Second-Generation p-values

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:fdrisk}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt nullhi(string)}}  the upper bound for the indifference zone (null interval) upon which the second-generation {it:p}-value was based.

{pstd}
{p_end}
{synopt:{opt nulllo(string)}}  the lower bound of the indifference zone (null interval) upon which the second-generation {it:p}-value was based.

{pstd}
{p_end}
{synopt:{opt std:err(#)}}  standard error of the point estimate.

{pstd}
{p_end}
{synopt:{opt intt:ype(string)}}  class of interval estimate used.

{pstd}
{p_end}
{synopt:{opt intl:evel(string)}}  level of interval estimate. 

{pstd}
{p_end}
{synopt:{opt nulls:pace(string)}}  support of the null probability distribution.

{pstd}
{p_end}
{synopt:{opt nullw:eights(string)}}  probability distribution for the null parameter space.

{pstd}
{p_end}
{synopt:{opt alts:pace(string)}}  support for the alternative probability distribution.

{pstd}
{p_end}
{synopt:{opt altw:eights(string)}}  probability distribution for the alternative parameter space. 

{pstd}
{p_end}
{synopt:{opt sgpv:al(#)}}  the observed second-generation {it:p}-value.

{pstd}
{p_end}
{synopt:{opt pi0(#)}}  prior probability of the null hypothesis. Default is 0.5.

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
This command computes the false discovery risk (sometimes called the "empirical bayes FDR") for a second-generation {it:p}-value of 0, or the false confirmation risk for a second-generation {it:p}-value of 1. 
This command should be used mostly for single calculations. 
For calculations after estimation commands use the {help sgpv} command. 

		The false discovery risk is defined as: 	P(H_0|p_δ=0) = (1 + P(p_δ = 0| H_1)/P(p_δ=0|H_0) * r)^(-1)
		The false confirmation risk is defined as: 	P(H_1|p_δ=1) = (1 + P(p_δ = 1| H_0)/P(p_δ=1|H_1) * 1/r )^(-1)
		with r = P(H_1)/P(H_0) being the prior probability.	
		See equation(4) in Blume et.al.(2018)

{pstd}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt nullhi(string)}     the upper bound for the indifference zone (null interval) upon which the second-generation {it:p}-value was based.

{pstd}
{p_end}
{phang}
{opt nulllo(string)}     the lower bound of the indifference zone (null interval) upon which the second-generation {it:p}-value was based.

{pstd}
{p_end}
{phang}
{opt std:err(#)}     standard error of the point estimate.

{pstd}
{p_end}
{phang}
{opt intt:ype(string)}  class of interval estimate used. This determines the functional form of the power function. 
Options are "confidence" for a (1-α)100% confidence interval and "likelihood" for a 1/k likelihood support interval ("credible" not yet supported).

{pstd}
{p_end}
{phang}
{opt intl:evel(string)}     level of interval estimate. If inttype is "confidence", the level is α. If "inttype" is "likelihood", the level is 1/k (not k).

{pstd}
{p_end}
{phang}
{opt nulls:pace(string)}  support of the null probability distribution. If "nullweights" is "Point", then "nullspace" is a scalar. 
If "nullweights" is "Uniform", then "nullspace" are two numbers separated by a space.

{pstd}
{p_end}
{phang}
{opt nullw:eights(string)}     probability distribution for the null parameter space. Options are currently "Point", "Uniform", and "TruncNormal".

{pstd}
{p_end}
{phang}
{opt alts:pace(string)}  support for the alternative probability distribution. 
If "altweights" is "Point", then "altspace" is a scalar. If "altweights" is "Uniform" or "TruncNormal", then "altspace" are two numbers separated by a space.

{pstd}
{p_end}
{phang}
{opt altw:eights(string)}     probability distribution for the alternative parameter space. Options are currently "Point", "Uniform", and "TruncNormal".

{pstd}
{p_end}
{phang}
{opt sgpv:al(#)}  the observed second-generation {it:p}-value. Default is 0, which gives the false discovery risk. Setting it to 1 gives the false confirmation risk.

{pstd}
{p_end}
{phang}
{opt pi0(#)}     prior probability of the null hypothesis. Default is 0.5.

{pstd}
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
{bf:false discovery risk with 95% confidence level:}{p_end}
	 fdrisk, sgpval(0)  nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)  nullweights("Uniform")  nullspace(log(1/1.1) log(1.1)) altweights("Uniform") ///
		altspace(2-1*invnorm(1-0.05/2)*0.8 2+1*invnorm(1-0.05/2)*0.8) inttype("confidence") intlevel(0.05)


{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Locals}{p_end}
{synopt:{cmd:r(fdr)}}  false discovery risk {p_end}
{synopt:{cmd:r(fcr)}}  false confirmation risk  {p_end}


{title:References}
{pstd}
 Blume JD, D’Agostino McGowan L, Dupont WD, Greevy RA Jr. (2018). Second-generation {it:p}-values: Improved rigor, reproducibility, & transparency in statistical analyses. {it:PLoS ONE} 13(3): e0188299. 
{browse "https://doi.org/10.1371/journal.pone.0188299"}

{pstd}
Blume JD, Greevy RA Jr., Welty VF, Smith JR, Dupont WD (2019). An Introduction to Second-generation {it:p}-values. {it:The American Statistician}. In press. {browse "https://doi.org/10.1080/00031305.2018.1537893"} 


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
 {help plotsgpv} {help sgpvalue} {help sgpower} {help sgpv}  

