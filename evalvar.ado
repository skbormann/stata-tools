*!Eval_var: Version 0.7
* Allows to use an expression for variables in in other commands
* without needing to create them first
* Version 0.7: 
* Not really byable yet
*Test makehlp to automate help file generation
/* START HELP FILE
title[allows to create a temporary variable to be used directly in other commands]
desc[{cmd:evalvar} is meant for those situations in which you want to use a transformation of a variable in another command without having to create the transformed 
					variable first. An example could be plot the histogram of the logarithm of a variable, but without wanting to later use the transformed variable.
					{cmd:evalvar} is meant for quick testing of variable transformations. ]
opt[command() the command including options in the evaluated variable should be used]
opt2[varid() specify an alternative variable identifier. 
To allow more commands, a variable identifier is required to identify the place where the transformed variable should be placed. 
	The default identifier is {bf:VAR}.]
opt[egen use egen instead of gen to create the temporay variable]
opt2[generate() allows to save the transformed variable under the given name. 
	The variable is not allowed to exist before, 
	unless the {opt replace} is specified.]
opt[replace replace an existing variable with the same an in {opt generate()} ]
example[{stata sysuse auto}]
example[{stata evalvar ln(price), command(hist VAR)} ]
author[Sven-Kristjan Bormann]
email[sven-kristjan@gmx.de]
return[exp returns the expression/transformation.]
return[command returns the command as it was typed in.]
seealso[Further Stata programs and development versions can be found under {browse "https://github.com/skbormann/stata-tools":https://github.com/skbormann/stata-tools} ]
END HELP FILE */
capture program drop evalvar
program define evalvar, rclass sortpreserve byable(recall)
version 11.0
	syntax anything [if] , COMmand(string) [ VARid(string) egen GENerate(varname) REPlace] 
	local exp `anything'
	if "`varid'"=="" local varid VAR
	tempvar temp
	if "`egen'"!="" {
	 egen `temp' = `exp' `if'
	}
	else{
		capture gen `temp' = `exp' `if'
		if _rc==198{
		disp as error "Expression not valid for generate, use egen option instead"
		exit 198
		}
	}
	*Add VAR identifier similar to multif
	if regexm("`command'","`varid'")==0{
		disp as error "No valid variable identifier provided. Use option varid()."
		exit 198
	}
	local command = subinstr("`command'","`varid'","`temp'",.)
	capture noisily `command' 
	return add
	if "`generate'"!="" {
		if "`replace'"!="" qui drop `generate'
		clonevar `generate' = `temp'
	}
	return local exp "`exp'"
	return local command  "`command'"
end
