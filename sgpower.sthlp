{smcl}
{* *! version 1.0 13 Feb 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "sgpower##syntax"}{...}
{viewerjumpto "Description" "sgpower##description"}{...}
{viewerjumpto "Options" "sgpower##options"}{...}
{viewerjumpto "Remarks" "sgpower##remarks"}{...}
{viewerjumpto "Examples" "sgpower##examples"}{...}
{title:Title}
{phang}
{bf:sgpower} {hline 2} Power functions for Second-Generation p-values

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:sgpower}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt true(#)}}  The true value for the parameter of interest at which to calculate power. 
			Note that this is on the absolute scale of the parameter, and not the standard deviation or standard error scale.
{p_end}
{synopt:{opt nulllo(#)}}  The lower bound of the indifference zone (null interval) upon which the second-generation {it:p}-value is based.

{pstd}
{p_end}
{synopt:{opt nullhi(#)}}  The upper bound for the indifference zone (null interval) upon which the second-generation {it:p}-value is based.

{pstd}
{p_end}
{synopt:{opt inttype(string)}}  Class of interval estimate used for calculating the SGPV. Options are "confidence" for a (1-\alpha)100% confidence interval and "likelihood" for a 1/k likelihood support interval ("credible" not yet supported)

{pstd}
{p_end}
{synopt:{opt intlevel(#)}}  Level of interval estimate. If intervaltype is "confidence", the level is \alpha. 
				If "intervaltype" is "likelihood", the level is 1/k (not k).
{p_end}
{synopt:{opt stderr(#)}}  Standard error for the distribution of the estimator for the parameter of interest. 
			Note that this is the standard deviation for the estimator, not the standard deviation parameter for the data itself. 
			This will be a function of the sample size(s).
{p_end}
{synopt:{opt b:onus}}  Display the additional diagnostics for error type I

{pstd}
{p_end}
{synopt:{opt nomata}}  Do not use the user-provided command "integrate" for faster calculation of the bonus diagnostics

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
Compute power/type I error for Second-Generation p-values approach.

{pstd}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt true(#)}     The true value for the parameter of interest at which to calculate power. 
			Note that this is on the absolute scale of the parameter, and not the standard deviation or standard error scale.
{p_end}
{phang}
{opt nulllo(#)}     The lower bound of the indifference zone (null interval) upon which the second-generation {it:p}-value is based.

{pstd}
{p_end}
{phang}
{opt nullhi(#)}     The upper bound for the indifference zone (null interval) upon which the second-generation {it:p}-value is based.

{pstd}
{p_end}
{phang}
{opt inttype(string)}     Class of interval estimate used for calculating the SGPV. Options are "confidence" for a (1-\alpha)100% confidence interval and "likelihood" for a 1/k likelihood support interval ("credible" not yet supported)

{pstd}
{p_end}
{phang}
{opt intlevel(#)}     Level of interval estimate. If intervaltype is "confidence", the level is \alpha. 
				If "intervaltype" is "likelihood", the level is 1/k (not k).
{p_end}
{phang}
{opt stderr(#)}     Standard error for the distribution of the estimator for the parameter of interest. 
			Note that this is the standard deviation for the estimator, not the standard deviation parameter for the data itself. 
			This will be a function of the sample size(s).
{p_end}
{phang}
{opt b:onus}     Display the additional diagnostics for error type I

{pstd}
{p_end}
{phang}
{opt nomata}     Do not use the user-provided command "integrate" for faster calculation of the bonus diagnostics

{pstd}
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
{stata sgpower,true(2) nulllo(-1) nullhi(1) stderr(1) inttype("confidence") intlevel(0.05)}

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Locals}{p_end}
{synopt:{cmd:r(power0)}}  Probability of SGPV = 0 calculated assuming the parameter is equal to {cmd:true}. That is, {cmd:power.alt} = P(SGPV = 0 | \theta = } {cmd:true).  {p_end}
{synopt:{cmd:r(power1)}}  Probability of SGPV = 1 calculated assuming the parameter is equal to {cmd:true}. That is, {cmd:power.null} = P(SGPV = 1 | \theta = } {cmd:true). {p_end}
{synopt:{cmd:r(powerinc)}}  Probability of 0 < SGPV < 1 calculated assuming the parameter is equal to {cmd:true}. That is, {cmd:power.inc} = P(0 < SGPV < 1 | \theta = } {cmd:true). {p_end}
{synopt:{cmd:r(minI)}}  is the minimum type I error over the range ({cmd:null.lo}, {cmd:null.hi}), which occurs at the midpoint of ({cmd:null.lo}, {cmd:null.hi}). {p_end}
{synopt:{cmd:r(maxI)}}  is the maximum type I error over the range ({cmd:null.lo}, {cmd:null.hi}), which occurs at the boundaries of the null hypothesis, {cmd:null.lo} and {cmd:null.hi}.  {p_end}
{synopt:{cmd:r(avgI)}}  is the average type I error (unweighted) over the range ({cmd:null.lo}, {cmd:null.hi}). If 0 is included in the null hypothesis region, then "type I error summaries" also contains at 0, the type I error calculated assuming the true parameter value \theta is equal to 0. {p_end}


{title:References}
{pstd}
 Blume JD, D’Agostino McGowan L, Dupont WD, Greevy RA Jr. (2018). Second-generation {it:p}-values: Improved rigor, reproducibility, & transparency in statistical analyses. \emph{PLoS ONE} 13(3): e0188299. https://doi.org/10.1371/journal.pone.0188299

{pstd}
Blume JD, Greevy RA Jr., Welty VF, Smith JR, Dupont WD (2019). An Introduction to Second-generation {it:p}}-values. {it:The American Statistician}. In press. https://doi.org/10.1080/00031305.2018.1537893 


{title:Author}
{p}

Sven-Kristjan Bormann , School of Economics and Business Administration, University of Tartu.

Email {browse "mailto:sven-kristjan@gmx.de":sven-kristjan@gmx.de}



{title:See Also}
Related commands:
{help:sgpvalue} {help:fdrisk} {help:sgpv}

