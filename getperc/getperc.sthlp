{smcl}
{title:Titel}
{cmd:getperc} {hline 2} Returns the percentage of a categorical variable/dummy variable

{title:Description}
{cmd:getperc} is meant to be used in creating custom tables like custom descriptive tables, which contain mixtures of average and percentages.
A simple dialog box is avaiable {stata db getperc:here}.
{title: Syntax}
{cmd:getperc} {it:varname} [if], row(integer) [DISPplay]

{title:Options}
{opt row()} takes the row number for which the percentage should be extracted. The row count starts from 1.
{opt disp:lay} displays the percentage.

{title:Examples}

{phang}{cmd:. use auto}

{phang}{cmd:. getperc foreign, row(2) }

{phang} 29.73% in row 2 for variable foreign.

{phang}{cmd:. disp r(perc)}

{phang}29.73

{title:Saved results}
{cmd:getperc} saves the following in {cmd:r()}:
{synoptset 10 tabbed}{...}
Scalar:
{synopt: {cmd:r(perc)}} percentage of the categorical variable.{p_end}

{p2colreset}{...}

{title:Author}
Sven-Kristjan Bormann

{title:Bug Reporting}
Please submit bugs, comments and suggestions via email to:
sven-kristjan@gmx.de
