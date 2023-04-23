*! version 0.1.0 21Apr2023
*
*  clear group if variable smaller or bigger than

cap program drop clear_if
program define clear_if, sortpreserve
    version 14
    gettoken opname 0: 0
    if !inlist(`"`opname'"', "(min)", "(max)") {
        di as error "only accept `(min)` or `(max)`"
        error 910
    }

    gettoken varname 0: 0
    confirm numeric variable `varname'

    gettoken op 0: 0, bind
    if !inlist(`"`op'"', ">", ">=", "<", "<=", "==", "!=") {
        error 911
    }

    gettoken num 0: 0, parse(" ,")
    confirm number `num'

    syntax [if] [in], by(varlist min=1) [dropvar]

    marksample touse
    tempvar oriid
    tempvar varback
    gen `oriid' = _n

    if `"`opname'"' == "(min)" {
        sort `by' `varname'
        by `by': gen `varback' = `varname'[1] if `touse'
    }
    if `"`opname'"' == "(max)" {
        sort `by' -`varname'
        by `by': gen `varback' = `varname'[_N] if `touse'
    }
    drop if `touse' & `varback' `op' `num'
    if `"`dropvar'"' == "dropvar" {
        drop `varname'
    }
    sort `oriid'
end
