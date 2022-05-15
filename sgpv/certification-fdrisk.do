*!certification-fdrisk.do
*Collection of commands to ensure that the fdrisk-command produces the right results
*For now only a collection of known test cases taken from fdrisk.R
cscript "fdrisk-test until version 1.2" adofiles fdrisk 

**New syntax
*First example
local expfdr 0.059499
fdrisk, nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8) nullspace(log(1/1.1) log(1.1))  ///
		 altspace("2-1*invnorm(1-0.05/2)*0.8" "2+1*invnorm(1-0.05/2)*0.8") level(95)
assert reldif(`expfdr',`r(fdr)') <1e-6

*Second Example
local expfdr 0.050555
fdrisk, nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)   nullspace(0) /// 
		altspace("2-1*invnorm(1-0.041/2)*0.8" "2+1*invnorm(1-0.041/2)*0.8")  likelihood(0.125)
assert reldif(`expfdr',`r(fdr)') <1e-6

*Third example 
local expfdr .0489494
fdrisk, nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)  nullspace(0)  alttruncnormal ///
		altspace("2-1*invnorm(1-0.041/2)*0.8" "2+1*invnorm(1-0.041/2)*0.8")  likelihood(0.125)
assert reldif(`expfdr',`r(fdr)') <1e-6

*Fourth example
local expfdr 0.016883
fdrisk, nulllo(log(1/1.5)) nullhi(log(1.5))  stderr(0.8)  nullspace(0) altspace("2.5-1*invnorm(1-0.041/2)*0.8" "2.5+1*invnorm(1-0.041/2)*0.8")  likelihood(0.125)
assert reldif(`expfdr',`r(fdr)') <1e-6

*Fifth example
local expfdr 0.030595
fdrisk, fcr nulllo(log(1/1.5)) nullhi(log(1.5)) stderr(0.15) nullspace("0.01-1*invnorm(1-0.041/2)*0.15" "0.01+1*invnorm(1-0.041/2)*0.15") ///
		 altspace(log(1.5) 1.25*log(1.5)) likelihood(0.125) 
assert reldif(`expfdr',`r(fcr)') <1e-6
