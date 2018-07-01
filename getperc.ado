*!Returns the percentage of a categorical variable/dummy variable 
*!Version 1.0
capture program drop getperc
program getperc, rclass
	version 9.0
	syntax varname [if] [in], row(integer) [DISPlay]
	marksample touse
	qui tabulate `varlist' if `touse', matcell(freq)
	local rows = rowsof(freq)
	if !inrange(`row',1,`rows'){
		disp as error "Enter a valid row number which lies between 1 and `rows' for variable `varlist'."
		exit 198
	}
	if r(r)==1{// In case only one category exists...
		local freq_val = freq[1,1]
	}
	else{
		local freq_val = freq[`row',1]
	}
	local total = r(N)
	return scalar perc = round(`freq_val'/`total'*100,0.01)
	if "`display'"!="" disp " `=round(`freq_val'/`total'*100,0.01)'% in row `row' for variable `varlist'. "
end

