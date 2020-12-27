*!certification-sgpower.do
*Collection of commands to ensure that the sgpower-command produces the right results
*For now only a collection of known test cases taken from sgpower.R
cscript "sgpower-test until version 1.05" adofiles sgpower 
*First example
sgpower,true(2) nulllo(-1) nullhi(1) stderr(1)  bonus
assert (r(avgI) - .0094374436885119)<1e-05
assert (r(maxI) - .025037480533843)<1e-05
assert (r(minI) - .00307675008577)<1e-05
assert (r(pow0) - .00307675008577)<1e-05
assert (r(powerinc) - 0.831463)<1e-05
assert (r(powernull) - 0)<1e-05
assert (r(poweralt) -  0.168537)<1e-05
*Second example 
sgpower,true(0) nulllo(-1) nullhi(1) stderr(1)  bonus
assert (r(avgI) - .0094374436885119)<1e-05
assert (r(maxI) - .025037480533843)<1e-05
assert (r(minI) - .00307675008577)<1e-05
assert (r(pow0) - .00307675008577)<1e-05
assert (r(powerinc) - .99692324991423)<1e-05
assert (r(powernull) - 0)<1e-05
assert (r(poweralt) - .00307675008577)<1e-05

