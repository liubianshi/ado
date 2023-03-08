*! version 0.1.0 28Sep2022
*
*  add new var to current data
program define addvar, sortpreserve rclass
	version 14
	#delimit ;
	syntax newvarlist(min=1) [using], [ key(varlist) 
		Saving(passthru)
		replace
		mode(string)
		*
	];
	#delimit cr
	if `"`mode'"' == "" {
		local mode = "1:1"
	}
    if `"`key'$KEY"' == "" {
        di "need keys for merge"
        error 788
    }
    if `"`key'"' == "" {
        local key "$KEY"
    }
	if `=!inlist(`"`mode'"', "1:1", "m:1", "1:m")' {
		display as error "Match mode unacceptable, only accept 1:1, m:1 or 1:m"
		error 123
	}
	dogen `varlist' `using', `saving' `replace'
	local datafile = r(datafile)
	merge `mode' `key' using `"`datafile'"', keepusing(`varlist') `options'
end
