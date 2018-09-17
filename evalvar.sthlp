{smcl}
{* *! version 1.0 11 Aug 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "evalvar##syntax"}{...}
{viewerjumpto "Description" "evalvar##description"}{...}
{viewerjumpto "Options" "evalvar##options"}{...}
{viewerjumpto "Remarks" "evalvar##remarks"}{...}
{viewerjumpto "Examples" "evalvar##examples"}{...}
{title:Title}
{phang}
{bf:evalvar} {hline 2} allows to create a temporary variable to be used in other commands

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:evalvar}
anything
[{help if}]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt com:mand(string)}}  the command including options in the evaluated variable should be used {p_end}
{synopt:{opt var:id(string)}}  specify an alternative variable identifier. To allow more commands, a variable identifier is required to identify the place where the transformed variable should be placed. The default identifier is VAR  {p_end}
{synopt:{opt egen}}  use egen instead of gen to create the temporay variable {p_end}
{synopt:{opt gen:erate(varname)}}  allows to save the transformed variable under the given name. The variable is not allowed to exist before. {p_end}
{synopt:{opt rep:lace}}  replaced an existing variable with the same an in {opt:generate()}  {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:evalvar} is meant for those situations in which you want to use a transformation of a variable in another command without having to create the transformed 
					variable first. An example could be plot the histogram of the logarithm of a variable, but without wanting to later use the transformed variable.
					{cmd:evalvar} is meant for quick testing of variable transformations. 

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt com:mand(string)}  the command including options in the evaluated variable should be used {p_end}

{phang}
{opt var:id(string)}  specify an alternative variable identifier. To allow more commands, a variable identifier is required to identify the place where the transformed variable should be placed. The default identifier is VAR  {p_end}

{phang}
{opt egen}  use egen instead of gen to create the temporay variable {p_end}

{phang}
{opt gen:erate(varname)}  allows to save the transformed variable under the given name. The variable is not allowed to exist before. {p_end}

{phang}
{opt rep:lace}  replaced an existing variable with the same an in {opt:generate()}  {p_end}


{marker examples}{...}
{title:Examples}
{pstd}
{stata evalvar ln(price), command(hist VAR)} 

{pstd}

{title:Stored results}
{p2col 5 15 19 2: Locals}{p_end}
{synopt:{cmd:r(exp)}}  returns the expression/transformation. {p_end}{synopt:{cmd:r(command)}}  returns the command as it was typed in. {p_end}

{title:Author}
{p}

Sven-Kristjan Bormann

Email {browse "mailto:sven-kristjan@gmx.de":sven-kristjan@gmx.de}



{title:See Also}
Related commands:
 Further Stata programs and development versions can be found under https://github.com/skbormann/stata-tools ]

{pstd}

Help file created with the help of {cmd:makehlp} by Adrian Mander {browse "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk} 
