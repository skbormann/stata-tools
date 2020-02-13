{smcl}
{* *! version 1.0 13 Feb 2020}{...}
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
{bf:fdrisk} {hline 2} False Discovery Risk for Second-Generation p-values

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
{synopt:{opt nullhi(string)}}  The upper bound for the indifference zone (null interval) upon which the second-generation {it:p}-value was based.

{pstd}
{p_end}
{synopt:{opt nulllo(string)}}  The lower bound of the indifference zone (null interval) upon which the second-generation {it:p}-value was based.

{pstd}
{p_end}
{synopt:{opt std:err(#)}}  Standard error of the point estimate.

{pstd}
{p_end}
{synopt:{opt intt:ype(string)}}  Class of interval estimate used. This determines the functional form of the power function. Options are "confidence" for a (1-\alpha)100% confidence interval and "likelihood" for a 1/k likelihood support interval ("credible" not yet supported).

{pstd}
{p_end}
{synopt:{opt intl:evel(string)}}  Level of interval estimate. If inttype is "confidence", the level is \alpha. If "inttype" is "likelihood", the level is 1/k (not k).

{pstd}
{p_end}
{synopt:{opt nulls:pace(string)}}  Support of the null probability distribution. If "nullweights" is "Point", then "nullspace" is a scalar. If "nullweights" is "Uniform", then "nullspace" is a vector of length two.

{pstd}
{p_end}
{synopt:{opt nullw:eights(string)}}  Probability distribution for the null parameter space. Options are currently "Point", "Uniform", and "TruncNormal".

{pstd}
{p_end}
{synopt:{opt alts:pace(string)}}  Support for the alternative probability distribution. If "altweights" is "Point", then "altspace" is a scalar. If "altweights" is "Uniform" or "TruncNormal", then "altspace" is a vector of length two.

{pstd}
{p_end}
{synopt:{opt altw:eights(string)}}  Probability distribution for the alternative parameter space. Options are currently "Point", "Uniform", and "TruncNormal".

{pstd}
{p_end}
{synopt:{opt sgpval(#)}}  The observed second-generation {it:p}-value. Default is 0, which gives the false discovery risk. Setting it to 1 gives the false confirmation risk

{pstd}
{p_end}
{synopt:{opt pi0(#)}}  Prior probability of the null hypothesis. Default is 0.5.

{pstd}
{p_end}
{synopt:{opt nomata}}  deactivates the usage of an additional user-provided command for numerical integration. The numerical integration is required to calculate the false discovery/confirmation risks. Instead the numerical integration Stata command is used.  

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
This command computes the false discovery risk (sometimes called the "empirical bayes FDR") for a second-generation {it:p}-value of 0, or the false confirmation risk for a second-generation {it:p}-value of 1. This command should be used for single calculations. For calculations for or after estimation commands use the {cmd:sgpv} command. 

{pstd}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt nullhi(string)}     The upper bound for the indifference zone (null interval) upon which the second-generation {it:p}-value was based.

{pstd}
{p_end}
{phang}
{opt nulllo(string)}     The lower bound of the indifference zone (null interval) upon which the second-generation {it:p}-value was based.

{pstd}
{p_end}
{phang}
{opt std:err(#)}     Standard error of the point estimate.

{pstd}
{p_end}
{phang}
{opt intt:ype(string)}     Class of interval estimate used. This determines the functional form of the power function. Options are "confidence" for a (1-\alpha)100% confidence interval and "likelihood" for a 1/k likelihood support interval ("credible" not yet supported).

{pstd}
{p_end}
{phang}
{opt intl:evel(string)}     Level of interval estimate. If inttype is "confidence", the level is \alpha. If "inttype" is "likelihood", the level is 1/k (not k).

{pstd}
{p_end}
{phang}
{opt nulls:pace(string)}     Support of the null probability distribution. If "nullweights" is "Point", then "nullspace" is a scalar. If "nullweights" is "Uniform", then "nullspace" is a vector of length two.

{pstd}
{p_end}
{phang}
{opt nullw:eights(string)}     Probability distribution for the null parameter space. Options are currently "Point", "Uniform", and "TruncNormal".

{pstd}
{p_end}
{phang}
{opt alts:pace(string)}     Support for the alternative probability distribution. If "altweights" is "Point", then "altspace" is a scalar. If "altweights" is "Uniform" or "TruncNormal", then "altspace" is a vector of length two.

{pstd}
{p_end}
{phang}
{opt altw:eights(string)}     Probability distribution for the alternative parameter space. Options are currently "Point", "Uniform", and "TruncNormal".

{pstd}
{p_end}
{phang}
{opt sgpval(#)}     The observed second-generation {it:p}-value. Default is 0, which gives the false discovery risk. Setting it to 1 gives the false confirmation risk

{pstd}
{p_end}
{phang}
{opt pi0(#)}     Prior probability of the null hypothesis. Default is 0.5.

{pstd}
{p_end}
{phang}
{opt nomata}     deactivates the usage of an additional user-provided command for numerical integration. The numerical integration is required to calculate the false discovery/confirmation risks. Instead the numerical integration Stata command is used.  

{pstd}
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
{bf:false discovery risk with 95% confidence level}

{pstd}
fdrisk, sgpval(0)  nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)  nullweights("Uniform")  nullspace(log(1/1.1) log(1.1)) altweights("Uniform")  altspace(2-1*invnorm(1-0.05/2)*0.8 2+1*invnorm(1-0.05/2)*0.8) inttype("confidence") intlevel(0.05)

{pstd}

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Locals}{p_end}
{synopt:{cmd:r(fdr)}}  False discovery risk {p_end}
{synopt:{cmd:r(fcr)}}  False confirmation risk  {p_end}


{title:References}
{pstd}
 Blume JD, D’Agostino McGowan L, Dupont WD, Greevy RA Jr. (2018). Second-generation {it:p}-values: Improved rigor, reproducibility, & transparency in statistical analyses. \emph{PLoS ONE} 13(3): e0188299. https://doi.org/10.1371/journal.pone.0188299

{pstd}
Blume JD, Greevy RA Jr., Welty VF, Smith JR, Dupont WD (2019). An Introduction to Second-generation {it:p}}-values. {it:The American Statistician}. In press. https://doi.org/10.1080/00031305.2018.1537893 


{title:Author}
{p}

Sven-Kristjan Bormann , School of Economics and Business Administration, University of Tartu.

Email {browse "mailto:sven-kristjan@gmx.de":sven-kristjan@gmx.de}


