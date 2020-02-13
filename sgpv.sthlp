{smcl}
{* *! version 1.0 13 Feb 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "sgpv##syntax"}{...}
{viewerjumpto "Description" "sgpv##description"}{...}
{viewerjumpto "Options" "sgpv##options"}{...}
{viewerjumpto "Remarks" "sgpv##remarks"}{...}
{viewerjumpto "Examples" "sgpv##examples"}{...}
{title:Title}
{phang}
{bf:sgpv} {hline 2} A wrapper command for calculating the Second-Generation P-Values and their associated diagnosis.  

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:sgpv}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt q:uietly}}  suppress the output of the estimation command

{pstd}
{p_end}
{synopt:{opt nulllo(#)}}  change the upper limit of the null-hypothesis intervall.

{pstd}
{p_end}
{synopt:{opt nullhi(#)}}  change the lower limit of the null-hypothesis intervall.

{pstd}
{p_end}
{synopt:{opt esti:mate(name)}}  takes the name of a previously stored estimation.

{pstd}
{p_end}
{synopt:{opt matl:istopt(string)}}  change the options of the displayed matrix. The same options as for {helpb matlist:matlist} can be used.

{pstd}
{p_end}
{synopt:{opt m:atrix(name)}}  takes the name of matrix as input for the calculation.

{pstd}
{p_end}
{synopt:{opt altweights(string)}}  Probability distribution for the alternative parameter space. Options are currently "Uniform", and "TruncNormal".

{pstd}
{p_end}
{synopt:{opt altspace(string)}}  Support for the alternative probability distribution.  If "altweights" is  is "Uniform" or "TruncNormal", then "altspace" is a two numbers separated by a space.

{pstd}
{p_end}
{synopt:{opt nullspace(string)}}  Support of the null probability distribution.

{pstd}
{p_end}
{synopt:{opt nullweights(string)}}  Probability distribution for the null parameter space.

{pstd}
{p_end}
{synopt:{opt intl:evel(string)}}  Level of interval estimate.

{pstd}
{p_end}
{synopt:{opt intt:ype(string)}}  Class of interval estimate used. This determines the functional form of the power function. Options are "confidence" for a (1-\alpha)100% confidence interval and "likelihood" for a 1/k likelihood support interval.

{pstd}
{p_end}
{synopt:{opt pi0(#)}}  Prior probability of the null hypothesis. Default is 0.5.

{pstd}
{p_end}
{synopt:{opt coef:ficient(string)}}  allows the selection of the coefficients for which the SGPVs and other statistics are calculated. The selected coefficients need to have the same names as displayed in the estimation output.

{pstd}
{p_end}
{synopt:{opt nomata}}  deactivates the usage of an additional user-provided command for numerical integration. 

{pstd}
{p_end}
{synopt:{opt nobonus(string)}}  deactive the display and calculation of bonus statistics like delta gaps and fdr/fcr. Possible values are "deltagap", "fdrisk", "all".

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:sgpv} allows the calculation of the Second-Generation P-Values (SGPV) developed by Blume et.al.(2018,2019) for and after commonly used estimation commands. The false discovery/confirmation risks (fdr/fcr) can be also reported. The SGPVs are reported alongside the usually reported p-values. 
An ordinary user should use this command and not other commands on which {cmd:sgpv} is based upon. {cmd:sgpv} uses sensible default values for calculating the SGPVs and the accompaning fdr/fcr, which can be changed.  
This wrapper command runs the commands translated into Stata which are based on the original R-code from for the sgpv-package from {browse "https://github.com/weltybiostat/sgpv"} 

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt q:uietly}     suppress the output of the estimation command

{pstd}
{p_end}
{phang}
{opt nulllo(#)}  change the upper limit of the null-hypothesis intervall. The default is 0.

{pstd}
{p_end}
{phang}
{opt nullhi(#)}  change the lower limit of the null-hypothesis intervall. The default is 0.

{pstd}
{p_end}
{phang}
{opt esti:mate(name)}     takes the name of a previously stored estimation.

{pstd}
{p_end}
{phang}
{opt matl:istopt(string)}     change the options of the displayed matrix. The same options as for {helpb matlist:matlist} can be used.

{pstd}
{p_end}
{phang}
{opt m:atrix(name)}  takes the name of matrix as input for the calculation. The matrix must follow the structure of the r(table) matrix returned after commonly used estimation commands due to the hardcoded row numbers used for identifiying the necessary numbers. Meaning that the parameter estimate has to be in the 1st row, the standard errors need to be in the 2nd row, the p-values in 4th row, the lower bound in the 5th and the upper bound in the 6th row.

{pstd}
{p_end}
{phang}
{opt altweights(string)}     Probability distribution for the alternative parameter space. Options are currently "Uniform", and "TruncNormal".

{pstd}
{p_end}
{phang}
{opt altspace(string)}     Support for the alternative probability distribution.  If "altweights" is  is "Uniform" or "TruncNormal", then "altspace" is a two numbers separated by a space.

{pstd}
{p_end}
{phang}
{opt nullspace(string)}  Support of the null probability distribution. If "nullweights" is "Point", then "nullspace" is a single number. If "nullweights" is "Uniform" or "TruncNormal", then "nullspace" is a two numbers separated by a space.

{pstd}
{p_end}
{phang}
{opt nullweights(string)}  Probability distribution for the null parameter space. Options are currently "Point", "Uniform", and "TruncNormal". The default is "Point".

{pstd}
{p_end}
{phang}
{opt intl:evel(string)}  Level of interval estimate. If inttype is "confidence", the level is \alpha. If "inttype" is "likelihood", the level is 1/k (not k).

{pstd}
{p_end}
{phang}
{opt intt:ype(string)}  Class of interval estimate used. This determines the functional form of the power function. Options are "confidence" for a (1-\alpha)100% confidence interval and "likelihood" for a 1/k likelihood support interval. The default is "confidence".

{pstd}
{p_end}
{phang}
{opt pi0(#)}     Prior probability of the null hypothesis. Default is 0.5.

{pstd}
{p_end}
{phang}
{opt coef:ficient(string)}     allows the selection of the coefficients for which the SGPVs and other statistics are calculated. The selected coefficients need to have the same names as displayed in the estimation output.

{pstd}
{p_end}
{phang}
{opt nomata}  deactivates the usage of an additional user-provided command for numerical integration. The numerical integration is required to calculate the false discovery/confirmation risks. Instead the numerical integration Stata command is used.  

{pstd}
{p_end}
{phang}
{opt nobonus(string)}     deactive the display and calculation of bonus statistics like delta gaps and fdr/fcr. Possible values are "deltagap", "fdrisk", "all".

{pstd}
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}
 	
{stata sysuse auto, clear}

{pstd}
Usage of {cmd:spgv} as a prefix-command{p_end}
{stata sgpv: regress price mpg weight foreign} 

{pstd}
{stata regress price mpg weight foreign}

{pstd}
Save estimation for later usage {p_end}
{stata estimate store pricereg} 

{pstd}
The same result but this time after the last estimation.{p_end}
{stata sgpv} 

{pstd}
{stata qreg price mpg weight foreign}

{pstd}
{stata estimates store priceqreg}

{pstd}
Calculate SPGVs for the stored estimation and only the foreign coefficient{p_end}
{stata sgpv, estimate(pricereg) coeffient("foreign")} 

{pstd}

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(comparison)}}  a matrix containing the displayed results {p_end}


{title:References}
{pstd}
 Blume JD, D’Agostino McGowan L, Dupont WD, Greevy RA Jr. (2018). Second-generation {it:p}-values: Improved rigor, reproducibility, & transparency in statistical analyses. \emph{PLoS ONE} 13(3): e0188299. https://doi.org/10.1371/journal.pone.0188299

{pstd}
Blume JD, Greevy RA Jr., Welty VF, Smith JR, Dupont WD (2019). An Introduction to Second-generation {it:p}}-values. {it:The American Statistician}. In press. https://doi.org/10.1080/00031305.2018.1537893 


{title:Author}
{p}

Sven-Kristjan Bormann , School of Economics and Business Administration, University of Tartu.

Email {browse "mailto:sven-kristjan@gmx.de":sven-kristjan@gmx.de}


