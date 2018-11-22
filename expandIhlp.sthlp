{smcl}
{* *! version 1.0 16.11.2018}{...}
{title:Title}
{phang}
{cmd:expandihlp} {hline 2} inserts the content of .ihlp-files into .sthlp-files 

{title:Description}
{cmd:expandihlp} is a tool meant for programmers who want to include the same text in the help-files for their programs. 
The standard way to do so is via the "INCLUDE help something" SMCL-directive which integrates the content of something.ihlp into the .sthlp file.
However, you have to distribute the .ihlp-files if you want to use this approach for a program being installed by someone else.
{cmd:expandihlp} reads the .sthlp-file, searches for "INCLUDE help something" SMCL-directives and integrates the content of something.ihlp into the .sthlp file like the Stata viewer would do.
By default {cmd:expandihlp} tests for the existince of the directives, reports the numbers (and names) and creates a new file named "program_expanded.sthlp" which contains the integrated content and leaves the original file unchanged. 

{title:Syntax}
{phang}
{cmd:expandihlp} using program.sthlp [, {cmdab:ren:ame} {cmdab:not:est} {cmdab:suf:fix(string)} ] 

{synoptline}
{synoptset 10 tabbed}{...}
{synopthdr: Options}
{synoptline}
{synopt :{opt not:est}} do not test for the existince of "INCLUDE"-directives and expands the file irrespective whether .ihlp files and display the number (and the name of the files) to be included. 
If no "INCLUDE"-directives are found, then the program is aborted. {p_end}
{synopt :{opt ren:ame}} renames the newly created file "program_expanded.sthlp" to "program.sthlp" and "program.sthlp" to "program_old.sthlp"{p_end}
{synopt :{opt suf:fix}} changes the suffix of the newly created file. By default the suffix "_parsed" is added to the program name.{p_end}

{* title:Examples}


{title:Saved results}
{synoptset 15 tabbed}{...}
{cmd:expandihlp} saves the following in {cmd:r()}:
{p2col 5 20 24 2: Macro}{p_end}
{synopt: {cmd:r(inccnt)}}the number of files included.{p_end}
{synopt: {cmd:r(incfiles)}}the expanded and included ihlp-files. {p_end}
{synopt: {cmd:r(origfile)}}the filename of the original help-file. {p_end}
{synopt: {cmd:r(expfile)}}the filename of the expanded help-file. {p_end}
{* p2colreset}{...}

INCLUDE help author



