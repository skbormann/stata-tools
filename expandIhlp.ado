*!parseIhelp Version 1.0 Date: 21.08.2018
*!Inserts .ihlp-files into .sthlp-files

capture program drop expandihlp
program define expandihlp, rclass
	syntax using/ [, REName NOTest SUFfix(string) ]
	
	 local version = _caller()
	if `version' < 14.2{
	version `version'
	disp as err "Tested only for Stata version 14.2 and higher."
	disp as err "Your Stata version `version' is not officially supported."
	}
	else{
		version 14.2
		}
	
	
	tempname fhin fhout
	*Experimental: Extended looking for a file
	
	local helpfile `"`using'"'
	gettoken word rest : helpfile, parse(".")
	if "`rest'"!=".sthlp"{
		local helpfile `helpfile'.sthlp
	}
	capture findfile `helpfile'
	if _rc{
			disp as err " `using' is an incorrect filename."
			disp as err "Provide a correct filename which looks like program.sthlp or provide the correct path to file `using'"
			exit 198
	}
	local helpfile `r(fn)'
	
	/*
	capture confirm file `"`using'"'
	if _rc{
		capture confirm file `using'.sthlp //Check if user forgot the sthlp-extension
		if !_rc{
			local using `using'.sthlp
		}
		else{
			disp as err " `using' is an incorrect filename."
			disp as err "Provide a correct filename which looks like program.sthlp"
			exit 198
		}
	}
	*/
	*Test whether any include directives exist
	if "`notest'"==""{
		includeTest using `helpfile'
		local inccnt `r(inccnt)'
		if `r(inccnt)'==0{
			disp as err "No include directives found. Nothing to include into `using'."
			exit
		}
	}
	
	*Get file name to create a new parsed file
	 _getfilename `helpfile'
	local filename `r(filename)'
	if "`suffix'"=="" local suffix _expanded
	gettoken word rest : filename, parse(".")
	local fileout `word'`suffix'.sthlp
	gettoken path filename : helpfile ,parse("/")
	local fileout `path'/`fileout'
	file open `fhin' using `helpfile', read 
	file open `fhout' using `"`fileout'"', write replace
	file read `fhin' line
	local linenumber 1
	while r(eof)==0{
		 local incfound 0 // Set a trigger to exclude a line with the INCLUDE
		 if regexm(`"`line'"',"^(INCLUDE)"){
		 *local linesave "`line'"
		 local incfound 1
		 *local line = subinstr("`line'", "{" ," ",.) // Remove brackets 
		 *local line = subinstr("`line'", "}" ," ",.)
		 local arg = word("`line'",3)
			tempname fh2
			*Extended file search
			capture findfile `arg'.ihlp
			*local ihlpfile `r(fn)'
			if !_rc{
			local ihelpfile `r(fn)'
			}
			
			else{
			disp as error "File `arg'.ihlp in line `linenumber' not found. Nothing to expand here."
			continue
			}
			/*
			capture confirm file `arg'.ihlp
				if _rc{
				 disp as error "File `arg'.ihlp in line `linenumber' not found. Nothing to expand here."
				 continue
				}
*/
			file open `fh2' using `ihelpfile', read
			file read `fh2' line2
			while r(eof)==0{
				if regexm(`"`line2'"',"^{\* ") continue // Ignore comments in the ihlp-file
				file write `fhout' `"`line2'"' _n
				file read `fh2' line2
			}
			file close `fh2'
			local incfiles "`incfiles' `arg'.ihlp"

		 }
		 if `incfound'!=1 file write `fhout' `"`line'"' _n
		 file read `fhin' line
		 local ++linenumber
	}
	*file write `fh' _n
	file close `fhin'
	file close `fhout'
	disp as txt "File `using' expanded to file `fileout'. "
	disp "`inccnt' .ihlp-files integrated."
	disp "`incfiles' integrated."
	
	if "`rename'"!=""{ //Still buggy function!
	renameFile `helpfile' `using' `word' `fileout'
	/*
		!ren `using' `word'_old.sthlp
		!ren `fileout' `using'
		disp "`using' renamed to `word'_old.sthlp." _n "`fileout' renamed to `using'."*
		*/
	}
	
	*Saved results
	return local inccnt  `inccnt'
	return local incfiles `incfiles'
	return local origfile `using'
	return local expfile `fileout'
end




program define includeTest, rclass
*Test for the existence of INCLUDE directives
	syntax using/
	tempname fhtest
	local inccnt 0
	file open `fhtest' using `"`using'"', read 
	file read `fhtest' line
	while r(eof)==0{
		if regexm(`"`line'"',"^(INCLUDE)"){
			local ++inccnt
		}
		file read `fhtest' line
	}
	file close `fhtest'
	*disp "Include directives found: `inccnt'"
	return local inccnt `inccnt'
end


program define renameFile, rclass
*rename file with respect to OS
args helpfile using word fileout

if c(os)=="Windows"{
	!ren `helpfile' `word'_old.sthlp
	!ren `fileout' `using'
}
else{
	!mv `helpfile' `word'_old.sthlp
	!mv `fileout' `using'
}

disp "`using' renamed to `word'_old.sthlp." _n "`fileout' renamed to `using'."
end
