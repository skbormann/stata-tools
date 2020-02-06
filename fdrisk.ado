*!False discovery rates

capture program drop fdrisk

program define fdrisk, rclass
version 14
syntax, nullhi(real) nulllo(real) stderr(real) INTType(string) INTLevel(real) ///
		nullspace(string) nullweights(string) altspace(string) altweight(string) ///
		[sgpval(integer 0) pi0(real 0.5)]
*Syntax parsing
if !inlist("`sgpval'",0,1){
	disp as error "Only values 0 and 1 allowed for the option 'sgpval'"
	exit 198
}

if !inlist("`inttype'", "confidence","likelihood"){
	disp as err "Parameter intervaltype must be one of the following: confidence or likelihood "
	exit 198
}
*Power functions
*Not the correct approach yet
if `sgpval'==0{
	sgpower, true() nullhi(`nullhi') nulllo(`nulllo') stderr(`stderr') inttype(`inttype') intlevel(`intlevel')
	local power `r(power0)'
}
if `sgpval'==1{

	sgpower, true() nullhi(`nullhi') nulllo(`nulllo') stderr(`stderr') inttype(`inttype') intlevel(`intlevel')
	local power `r(power1)'


}


*** calculate P.sgpv.H0

    * point null
end