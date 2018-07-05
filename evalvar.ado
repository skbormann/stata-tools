*!Eval_var
* Allows to use an expression for variables in in other commands
* without needing to create them first
* Version 0.5: Does not save the return of the issued command yet
* Not really byable yet
capture program drop evalvar
program define evalvar, rclass byable(recall)
version 11.0
	syntax anything [if] [in] , COMmand(string) [copt(string) egen keep]
	local exp `anything'
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
	capture noisily `command' `temp', `copt'
	return add
	if "`keep'"=="" drop `temp'
	return local exp "`exp'"
	return local command  "`command'"
	return local copt  "`copt'"
end
