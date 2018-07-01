{smcl}
{title:Title}
{cmd:emptyvar}{hline 2} Shows and drops variables, which contain only missing values.

{title:Description}
{pstd}
{cmd:emptyvar} is a datamanagement tool to find variables which contain only missing values.
While these variables do not consume memory, they can be still annoying, if you have remember, which variables are actually useful and which not.
These variables often times exist as an artifact from an earlier data processing step.
{cmd:emptyvar} is a faster way to find and remove than
{bf:Warning:} The variables are dropped without any further question for confirmation like an ordinary {help drop} command.

{pstd}
{cmd:emptyvar show} shows the variables that contain only missing values

{pstd}
{cmd:emptyvar drop} shows and drops variables that contain only missing values

{title:Syntax}
{phang}
Show empty variables

{p 8 10 2}
{cmd:emptyvar} {opt show} [{varlist}] [,{cmdab:cond:ition}()]

{phang}
Shows and drops empty variables

{p 8 10 2}
{cmd:emptyvar} {opt drop} [{varlist}] [,{cmdab:cond:ition}()]

{synoptset 20 tabbed}{...}
{synopthdr: Options}
{synoptline}
{synopt :{opt cond:ition()}}add an additional condition to find empty variables.



{title:Examples}

{phang2}{cmd:. sysuse auto}{p_end}
{pstd}Generate an empty variable. There are no prices lower than 2000 in the dataset.{p_end}
{phang2}{cmd:. gen test=1 if price<2000}{p_end}
{phang2}{cmd:. emptyvar show}{p_end}
{phang2}Variable test contains no observations{p_end}
{phang2}{cmd:. emptyvar drop}{p_end}
{phang2}Variable test contains no observations{p_end}
{phang2}Variable test will be dropped{p_end} 



{title:Saved results}
{cmd:emptyvar} saves the following in {cmd:r()}:
{p2col 5 20 24 2: Macro}{...}

{p2col: r(emptyvar)}empty variables found {p_end}
{p2col: r(droppedvar)}dropped empty variables{p_end}
{p2col: r(condition)}additional condition provided through {opt condition()} {p_end}
{p2colreset}{...}

{title:Author}
Sven-Kristjan Bormann

{title:Bug Reporting}
{psee}
Please submit bugs, comments and suggestions via email to:	sven-kristjan@gmx.de
