*!Version 0.5 Converts a number to a letter
*Development version, contain a change in return value which will break older usage of this program
program num2base26, rclass
	version 9.2
	syntax anything(name=num) [, LOWer DISPlay]
	local num = `num'
	* Checking if a number was provided
	if "`num'"==""{
		disp as error "Enter a number to be converted into a letter"
		exit 198
	}
	if real("`num'")==. | real("`num'")<0 | real("`num'")>16384{
		disp as error "Enter a number between 0 and 16384"
		exit 198
	}
	
	
	mata: letter = strtoreal(st_local("num"))
	mata: col = numtobase26(letter)
	mata: st_local("letter", col)
	
	if `"`lower'"'!=""{
	local letter = strlower("`letter'")
	}
	if "`display'"!=""{
		display "The letter is: `letter'"
	}
	
	return local letter = "`letter'"
end
