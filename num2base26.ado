program num2base26, rclass
*!Version 0.5 Converts a number to a letter
	syntax anything(name=num) [, LOWer]
	local num = `num'
	* Checking if a number was provided
	if "`num'"==""{
	disp as error "Enter a number to be converted into a letter"
	}
	if real("`num'")==. {
		disp as error "Enter an integer number"
	}
	
	
	mata: my_col = strtoreal(st_local("num"))
	mata: col = numtobase26(my_col)
	mata: st_local("col_let", col)
	
	if `"`lower'"'!=""{
	local col_let = strlower("`col_let'")
	}
	
	return local col_letter = "`col_let'"
end
