{smcl} 
{* *!Version 1.0}{...}
{title:Title}
{cmd:expandIhlp} {hline 1} inserts the content of .ihlp-files into .sthlp-files 
{title:Description}
{cmd:expandIhlp} is a tool meant for programmers who want to include the same text in the help-files for their programs. 
The standard way is via the "{INCLUDE help something}" SMCL-directive which integrates the content of something.ihlp into the .sthlp file.
 However, you have to distribute the .ihlp-files if you want to use this approach for a programs being installed into different directories.
{cmd:expandIhlp} reads in the .sthlp-file, searches for "{INCLUDE help something}" SMCL-directives and integrates the content of something.ihlp into the .sthlp file like the Stata viewer would do.
By default {cmd:expandIhlp} creates a new file named "program_parsed.sthlp" which contains the integrated content and leaves the original file unchanged. 

{title:Syntax}
{cmd:expandIhlp} using program.sthlp [, {cmdab:ren:ame} {cmd:test}  ] 

{synoptline}
{synoptset 20 tabbed}{...}
{synopthdr: Options}
{synoptline}
{synopt :{opt test}} test for existince of "{INCLUDE}"-directives and display the number (and the name of the files) to be included.
					If no "{INCLUDE}"-directives are found, then the program is aborted. {p_end}
{synopt :{opt ren:ame}} renames the newly created file "program_parsed.sthlp" to "program.sthlp" and "program.sthlp" to "program_old.sthlp"


{title:Examples}


{title:Saved results}

{INCLUDE help author}
