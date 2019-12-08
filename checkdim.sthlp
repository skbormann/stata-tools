{smcl}
{* *! version 1.0 19 Aug 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install checkdim" "ssc install checkdim"}{...}
{vieweralsosee "Help checkdim (if installed)" "help checkdim"}{...}
{viewerjumpto "Syntax" "checkdim##syntax"}{...}
{viewerjumpto "Description" "checkdim##description"}{...}
{viewerjumpto "Options" "checkdim##options"}{...}
{viewerjumpto "Remarks" "checkdim##remarks"}{...}
{viewerjumpto "Examples" "checkdim##examples"}{...}
{title:Title}
{phang}
{bf:checkdim2} {hline 2} Check if variable(s) exist(s) for all values of another variable

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:checkdim2}
[{help varlist}]
[{help in}]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt dim:ension(varname)}}  the variable for which all values are checked. Currently only one dimension possible but extension to more variables in one go possible. 

{pstd}
{p_end}
{synopt:{opt no:show}}  do not show the results

{pstd}
{p_end}
{synopt:{opt drop}}  drop if  the drop condition is met

{pstd}
{p_end}
{synopt:{opt dropcond:ition(string)}}  the condition for which variable(s) should be dropped.

{pstd}
{p_end}
{synopt:{opt showcond:ition(string)}}  the condition for which variables should be shown.

{pstd}
{p_end}
{synopt:{opt sort}}  sort the results in descending order.

{pstd}
{p_end}
{synopt:{opt keep}}  keep the generated variables

{pstd}
{p_end}
{synopt:{opt keepn:ame(string)}}  the stub for the generated variables. The default stub is "mis".

{pstd}
{p_end}
{synopt:{opt replace}}  replace existing variables which contain the results.

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
 {cmd:checkdim2} allows you to check if a variable or multiple variables has/have missing values for all values of another variable/dimension. The results are saved in temporary variables which can be made permanent.  The results can be replayed if the {opt keep} has been specified in the first run of the command. To replay the results, just type {cmd:checkdim2} without the dimension and any variables.  It is possible to filter the output by using the {opt showcondition()} option. Variables can also be dropped based on the results by using the options {opt drop} and {opt dropcondition()} together. 

{pstd}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt dim:ension(varname)}     the variable for which all values are checked. Currently only one dimension possible but extension to more variables in one go possible. 

{pstd}
{p_end}
{phang}
{opt no:show}     do not show the results

{pstd}
{p_end}
{phang}
{opt drop}     drop if  the drop condition is met

{pstd}
{p_end}
{phang}
{opt dropcond:ition(string)}     the condition for which variable(s) should be dropped.

{pstd}
{p_end}
{phang}
{opt showcond:ition(string)}     the condition for which variables should be shown.

{pstd}
{p_end}
{phang}
{opt sort}     sort the results in descending order.

{pstd}
{p_end}
{phang}
{opt keep}     keep the generated variables

{pstd}
{p_end}
{phang}
{opt keepn:ame(string)}     the stub for the generated variables. The default stub is "mis".

{pstd}
{p_end}
{phang}
{opt replace} replace    replace existing variables which contain the results.

{pstd}
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Locals}{p_end}
{synopt:{cmd:r(dropvar)}}  list of dropped variables {p_end}
{synopt:{cmd:r(dropcondition)}}  the condition under which variables are dropped. {p_end}
{synopt:{cmd:r(showcondition)}}  the condition for which variables should be shown. {p_end}
{synopt:{cmd:r(keepname)}}  the stub for the generated variables {p_end}


{title:Author}
{p}


