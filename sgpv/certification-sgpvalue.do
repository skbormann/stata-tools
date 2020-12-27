*!certification-sgpvalue.do
*Collection of commands to ensure that the sgpvalue-command produces the right results
*For now only a collection of known test cases taken from sgpvalue.R
*Later add test for input errors
cscript "sgpvalue-test until version 1.05" adofiles sgpvalue 

*First example
disp "Running first example"
local lb log(1.05) log(1.3) log(0.97)	
local ub log(1.8) log(1.8) log(1.02)	
mat pdelta_exp = 0.1220227 \ 0.0000000 \ 1.0000000
mat deltagap_exp = . \ 1.752741 \      .
sgpvalue , estlo(`lb') esthi(`ub') nulllo(log(1/1.1)) nullhi(log(1.1))
mat results = r(results)
mat pdelta_res = results[1...,1]
mat deltagap_res = results[1...,2]
assert mreldif(pdelta_exp, pdelta_res) <1e-6
assert mreldif(deltagap_exp, deltagap_res) <1e-6

*Second example
disp "Running second example"
mat pdelta_exp = 0
mat deltagap_exp= 0.1670541
sgpvalue, estlo(log(1.3)) esthi(.) nulllo(.) nullhi(log(1.1))
mat results = r(results)
mat pdelta_res = results[1...,1]
mat deltagap_res = results[1...,2]
assert mreldif(pdelta_exp, pdelta_res) <1e-6
assert mreldif(deltagap_exp, deltagap_res) <1e-6 

*Third example
disp "Running third example"
mat pdelta_exp = .00001
mat deltagap_exp= .
sgpvalue, estlo(log(1.05)) esthi(.) nulllo(.) nullhi(log(1.1))
mat results = r(results)
mat pdelta_res = results[1...,1]
mat deltagap_res = results[1...,2]
assert mreldif(pdelta_exp, pdelta_res) <1e-6
assert mreldif(deltagap_exp, deltagap_res) <1e-6
*Input error checks
