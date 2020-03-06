{smcl}
{* *! version 1.0  3 Mar 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "plotsgpv##syntax"}{...}
{viewerjumpto "Description" "plotsgpv##description"}{...}
{viewerjumpto "Options" "plotsgpv##options"}{...}
{viewerjumpto "Remarks" "plotsgpv##remarks"}{...}
{viewerjumpto "Examples" "plotsgpv##examples"}{...}
{title:Title}
{phang}
{bf:plotsgpv} {hline 2} Plotting Second-Generation P-Values

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:plotsgpv}
[{help if}]
[{help in}]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt esthi(string)}}  upper bound of interval estimate. Values may be finite or infinite.
{p_end}
{synopt:{opt estlo(string)}}  lower bound of interval estimate. Values may be finite or infinite.
{p_end}
{synopt:{opt nullhi(string)}}  upper bound of null interval.
{p_end}
{synopt:{opt nulllo(string)}}  lower bound of null interval.
{p_end}
{synopt:{opt seto:rder(string)}} a variable giving the desired order along the x-axis. 
{p_end}
{synopt:{opt xshow(string)}}  number representing the maximum ranking on the x-axis that is displayed. Default is to display all intervals.
{p_end}
{synopt:{opt nullcol(string)}}  coloring of the null interval (indifference zone). Default is the R-colour Hawkes Blue.
{p_end}
{synopt:{opt intc:ol(string)}} coloring of the intervals according to SGPV ranking. 
{p_end}
{synopt:{opt noploty:_axis}}  deactive showing the y-axis.
{p_end}
{synopt:{opt noplotx:_axis}}  deactive showing the x-axis.
{p_end}
{synopt:{opt nullpt(#)}} a scalar representing a point null hypothesis. {p_end}
{synopt:{opt nooutlinezone}}  deactivate drawing a slim white outline around the null zone. Helpful visual aid when plotting many intervals. Default is on.
{p_end}
{synopt:{opt t:itle(string)}}  title of the plot.
{p_end}
{synopt:{opt xt:itle(string)}}  label of the x-axis label.
{p_end}
{synopt:{opt yt:itle(string)}}  label of the y-axis.
{p_end}
{synopt:{opt noleg:end}}  deactivate plotting the legend.
{p_end}
{synopt:{opt nomata}}  do not use Mata for calculating the SGPVs if esthi() and estlo() are variables as inputs or if {cmd:c(matsize)} is smaller than the size of these options.
{p_end}
{synopt:{opt noshow}}  do not show the outcome of the SGPV calculations. Useful for larger calculations.
{p_end}
{synopt:{opt replace}}  replace existing variables in case the nomata-option was used.
{p_end}
{synopt:{opt two:way_opt(string asis)}}  any additional options for the plotting go here. 
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
Plot the second-generation {it:p}-value (SGPV), as introduced in Blume et al. (2018), for user supplied interval estimates (support intervals, confidence intervals, credible intervals, etc.) according to its associated second-generation {it:p}-value ranking.
This command and its companions commands  ({cmd:sgpvalue}, {cmd:sgpower}, {cmd:fdrisk}) are based on the R-code for the sgpv-package from {browse "https://github.com/weltybiostat/sgpv"}.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt esthi(string)}  upper bound of interval estimate. Values may be finite or infinite.
To specify that the upper limit is +infinity just specify the missing value . in this option. Must be of same length as in the option {it:estlo}. Multiple upper bounds can be entered. They must be separated by spaces. Typically the upper bound of a confidence interval can be used. A variable contained the upper bound can be also used.

{pstd}
{p_end}
{phang}
{opt estlo(string)}  lower bound of interval estimate. The lower limit is -infinity just specify the missing value . in this option. Multiple lower bounds can be entered. They must be separated by spaces. Typically the lower bound of a confidence interval can be used. A variable contained the lower bound can be also used.

{pstd}
{p_end}
{phang}
{opt nullhi(string)}     upper bound of null interval.

{pstd}
{p_end}
{phang}
{opt nulllo(string)}     lower bound of null interval.

{pstd}
{p_end}
{phang}
{opt seto:rder(string)}     a variable giving the desired order along the x-axis. If {bf:setorder} is set to {bf:"sgpv"}, the second-generation {it:p}-value ranking is used. If {bf:setorder} is empty, the original input ordering is used.

{pstd}
{p_end}
{phang}
{opt xshow(string)}     number representing the maximum ranking on the x-axis that is displayed. Default is to display all intervals.

{pstd}
{p_end}
{phang}
{opt nullcol(string)}  coloring of the null interval (indifference zone). Default is the R-colour "Hawkes Blue". You can see the colour before plotting via 
{stata palette color 208 216 232 }

{pstd}
{p_end}
{phang}
{opt intc:ol(string)}  coloring of the intervals according to SGPV ranking. Default are the R-colours ("cornflowerblue","firebrick3","darkslateblue")} for SGPVs of {it:0}, in {it:(0,1)}, and {it:1} respectively. 
You can see the colour before plotting via:
 
		{stata palette color 100 149 237 } // cornflowerblue
		{stata palette color 205 38 38 } // firebrick3
		{stata palette color 72 61 139 } // darkslateblue

{pstd}
{p_end}
{phang}
{opt noploty:_axis}     deactive showing the y-axis.

{pstd}
{p_end}
{phang}
{opt noplotx:_axis}    deactive showing the x-axis.

{pstd}
{p_end}
{phang}
{opt nullpt(#)} 	a scalar representing a point null hypothesis. Default is 0. If set, the command will draw a horizontal dashed red line at this location.

{pstd}
{p_end}
{phang}
{opt nooutlinezone}     deactivate drawing a slim white outline around the null zone. Helpful visual aid when plotting many intervals. Default is on.

{pstd}
{p_end}
{phang}
{opt t:itle(string)}     title of the plot.

{pstd}
{p_end}
{phang}
{opt xt:itle(string)}     label of the x-axis.

{pstd}
{p_end}
{phang}
{opt yt:itle(string)}     label of the y-axis.

{pstd}
{p_end}
{phang}
{opt noleg:end}     deactivate plotting the legend.

{pstd}
{p_end}
{phang}
{opt nomata}  deactivate the usage of Mata for calculating the SGPVs with large matrices or variables. If this option is set, an approach based on variables is used. Using variables instead of Mata is considerably faster, but new variables containing the results are created. If you don't want to create new variables and time is not an issue then don't set this option. Stata might become unresponsive when using Mata.

{pstd}
{p_end}
{phang}
{opt noshow}     do not show the outcome of the SGPV calculations. Useful for larger calculations.

{pstd}
{p_end}
{phang}
{opt replace} replace    replace existing variables in case the nomata-option was used.

{pstd}
{p_end}
{phang}
{opt two:way_opt(string asis)}     any additional options for the plotting go here. See {help twoway} for more information about the possible options. Options set here {bf:do not} override the values set in other options before.
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}
	{stata sysuse leukstats} // Load the example dataset provided with this command

	plotsgpv, esthi(ci_hi) estlo(ci_lo) nulllo(-0.3) nullhi(0.3) nomata replace noshow setorder(p_value) title("Leukemia Example") xtitle("Classical p-value ranking") ytitle("Fold Change (base 10)") twoway_opt(ylabel(`=log10(1/1000)' "1/1000" `=log10(1/100)' "1/100" `=log10(1/10)' "1/10" `=log10(1/2)' "1/2" `=log10(2)' "2" `=log10(10)' "10" `=log10(100)' "100" `=log10(1000)'  "1000")) //Replicate the example plot from the R-code

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
 {help fdrisk} {help sgpvalue} {help sgpower} {help sgpv}  

