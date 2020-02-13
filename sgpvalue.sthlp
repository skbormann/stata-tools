{smcl}
{* *! version 1.0 13 Feb 2020}{...}
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
[anything]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt esthi(string)}}  A numeric vector of upper bounds of interval estimates. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:estlo}. Multiple upper bounds can be entered. They must be separated by spaces. Typically the upper bound of a confidence interval can be used.

{pstd}
{p_end}
{synopt:{opt estlo(string)}}  A numeric vector of lower bounds of interval estimates. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:estlo}. Multiple lower bounds can be entered. They must be separated by spaces. Typically the lower bound of a confidence interval can be used.

{pstd}
{p_end}
{synopt:{opt nullhi(string)}}  A numeric vector of upper bounds of null intervals. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:nulllo}.

{pstd}
{p_end}
{synopt:{opt nulllo(string)}}  A numeric vector of lower bounds of null intervals. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:nullhi}.

{pstd}
{p_end}
{synopt:{opt nowarn:ings}}  Disable showing the warnings for problematic intervals.

{pstd}
{p_end}
{synopt:{opt infcorrection(#)}}  Default value is 1e-5.{p_end}
{synopt:{opt nodeltagap}}  disable the display of the delta gap. Mainly used inside of {cmd:sgpv}, since delta-gaps are less useful to most users of p-values.  

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
This function computes the second-generation {it:p}-value (SGPV) and its associated delta gaps, as introduced in Blume et al. (2018).
This command and its companions commands ({cmd:sgpower}, {cmd:fdrisk}) are based on the R-code for the sgpv-package from {browse "https://github.com/weltybiostat/sgpv"}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt esthi(string)}     A numeric vector of upper bounds of interval estimates. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:estlo}. Multiple upper bounds can be entered. They must be separated by spaces. Typically the upper bound of a confidence interval can be used.

{pstd}
{p_end}
{phang}
{opt estlo(string)}     A numeric vector of lower bounds of interval estimates. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:estlo}. Multiple lower bounds can be entered. They must be separated by spaces. Typically the lower bound of a confidence interval can be used.

{pstd}
{p_end}
{phang}
{opt nullhi(string)}     A numeric vector of upper bounds of null intervals. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:nulllo}.

{pstd}
{p_end}
{phang}
{opt nulllo(string)}     A numeric vector of lower bounds of null intervals. Values may be finite or {it:-Inf} or {it:+Inf}. Must be of same length as in the option {it:nullhi}.

{pstd}
{p_end}
{phang}
{opt nowarn:ings}     Disable showing the warnings for problematic intervals.

{pstd}
{p_end}
{phang}
{opt infcorrection(#)}  A small scalar to denote a positive but infinitesimally small SGPV. Default is 1e-5. SGPVs that are infinitesimally close to 1 are assigned 1-infcorrection. This option can only be invoked when one of the intervals has infinite length.

{pstd}
{p_end}
{phang}
{opt nodeltagap}     (not implemented yet!) disable the display of the delta gap. Mainly used inside of {cmd:sgpv}, since delta-gaps are less useful to most users of p-values.  

{pstd}
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}
The examples are based on the original documentation for the R-code, but are modified to resemble more closely the usual Stata convention.

{pstd}
 {bf:Simple example for three estimated log odds ratios but the same null interval}{p_end}


		 local lb log(1.05) log(1.3) log(0.97)
		
		 local ub log(1.8) log(1.8) log(1.02)
		
		 sgpvalue , estlo() esthi() nulllo(log(1/1.1)) nullhi(log(1.1))
		
	{bf: A simple more Stata-like example with a point null hypothesis}{p_end}
	
		{stata sysuse auto, clear}
		{stata regress price mpg}
		{stata mat table = r(table)}  //Copy the regression results into a new matrix for the next calculations
		
		The numbers for the options could be also copied by hand, we use here directly the matrix.
		
		 {stata sgpvalue, esthi(table[6,1]) estlo(table[5,1]) nullhi(0) nulllo(0)}

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(results)}}  matrix with the results {p_end}


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
{help:sgpower} {help:fdrisk} {help:sgpv}

