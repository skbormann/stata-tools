*!certification-fdrisk.do
*Collection of commands to ensure that the fdrisk-command produces the right results
*For now only a collection of known test cases taken from fdrisk.R
cscript "fdrisk-test until version 1.1" adofiles fdrisk 

**Testing the old syntax
*First example
local expfdr 0.059499
fdrisk, sgpval(0)  nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)  nullweights("Uniform")  nullspace(log(1/1.1) log(1.1))  ///
		  altweights("Uniform") altspace("2-1*invnorm(1-0.05/2)*0.8" "2+1*invnorm(1-0.05/2)*0.8") inttype("confidence")  intlevel(0.05)
assert reldif(`expfdr',`r(fdr)') <1e-6

*Second Example
local expfdr 0.050555
fdrisk, sgpval(0)  nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)   nullweights("Point")  nullspace(0) /// 
		altweights("Uniform") altspace("2-1*invnorm(1-0.041/2)*0.8" "2+1*invnorm(1-0.041/2)*0.8")  inttype("likelihood")  intlevel(1/8)
assert reldif(`expfdr',`r(fdr)') <1e-6

*Third example 
local expfdr .0489494
fdrisk, sgpval(0)  nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)   nullweights("Point")  nullspace(0)  altweights("TruncNormal") ///
		altspace("2-1*invnorm(1-0.041/2)*0.8" "2+1*invnorm(1-0.041/2)*0.8")  inttype("likelihood")  intlevel(1/8)
assert reldif(`expfdr',`r(fdr)') <1e-6

*Fourth example
local expfdr 0.016883
fdrisk, sgpval(0)  nulllo(log(1/1.5)) nullhi(log(1.5))  stderr(0.8)   nullweights("Point")  nullspace(0) /// 
		  altweights("Uniform") altspace("2.5-1*invnorm(1-0.041/2)*0.8" "2.5+1*invnorm(1-0.041/2)*0.8")  inttype("likelihood")  intlevel(1/8)

assert reldif(`expfdr',`r(fdr)') <1e-6

*Fifth example
local expfdr 0.030595
fdrisk, sgpval(1)  nulllo(log(1/1.5)) nullhi(log(1.5))  stderr(0.15)   nullweights("Uniform") nullspace("0.01 - 1*invnorm(1-0.041/2)*0.15" "0.01 + 1*invnorm(1-0.041/2)*0.15") ///
		altweights("Uniform")  altspace(log(1.5) 1.25*log(1.5))  inttype("likelihood")  intlevel(1/8) 
assert reldif(`expfdr',`r(fcr)') <1e-6

**New syntax
*First example
local expfdr 0.059499
fdrisk,  fdr nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)  nulluniform nullspace(log(1/1.1) log(1.1))  ///
		  altuniform altspace("2-1*invnorm(1-0.05/2)*0.8" "2+1*invnorm(1-0.05/2)*0.8") level(95)
assert reldif(`expfdr',`r(fdr)') <1e-6

*Second Example
local expfdr 0.050555
fdrisk, fdr nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)   nullspace(0) /// 
		altuniform altspace("2-1*invnorm(1-0.041/2)*0.8" "2+1*invnorm(1-0.041/2)*0.8")  likelihood(0.125)
assert reldif(`expfdr',`r(fdr)') <1e-6

*Third example 
local expfdr .0489494
fdrisk, fdr nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)  nullspace(0)  alttruncnormal ///
		altspace("2-1*invnorm(1-0.041/2)*0.8" "2+1*invnorm(1-0.041/2)*0.8")  likelihood(0.125)
assert reldif(`expfdr',`r(fdr)') <1e-6

*Fourth example
local expfdr 0.016883
fdrisk, fdr nulllo(log(1/1.5)) nullhi(log(1.5))  stderr(0.8)  nullspace(0) altuniform altspace("2.5-1*invnorm(1-0.041/2)*0.8" "2.5+1*invnorm(1-0.041/2)*0.8")  likelihood(0.125)
assert reldif(`expfdr',`r(fdr)') <1e-6

*Fifth example
local expfdr 0.030595
fdrisk, fcr nulllo(log(1/1.5)) nullhi(log(1.5)) stderr(0.15) nulluniform nullspace("0.01-1*invnorm(1-0.041/2)*0.15" "0.01+1*invnorm(1-0.041/2)*0.15") ///
		altuniform  altspace(log(1.5) 1.25*log(1.5)) likelihood(0.125) 
assert reldif(`expfdr',`r(fcr)') <1e-6
