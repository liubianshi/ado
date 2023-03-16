capture program drop group_integer
program define group_integer, sortpreserve
    gettoken var 0 : 0, parse(", ")
    confirm int variable `var'

    quietly sum `var', detail
    local var_min = r(min)
    local var_max = r(max)
    syntax, step(integer) [            ///
        start(integer `var_min')       ///
        end(integer `var_max')         ///
        newvar(namelist min=1 max=1)   ///
        newlabel(namelist min=1 max=1) ///
        replace                        ///
    ]
    if `"`newvar'"' == "" {
        local newvar = "`var'_group"
    }
    if `"`newlabel'"' == "" {
        local newlabel = "`newvar'"
    }

    if `"`replace'"' == "" {
        confirm new variable `newvar'
        label define `newlabel' 0 "[`var_min', `var_max']"
    }
    else {
        label define `newlabel' 0 "[`var_min', `var_max']", replace
    }

    local i = 0
    local cut_values = "`=`var_min' - 1'"

    if `var_min' < `start' {
        local s = `var_min'
        local e = `start' - 1
        local cut_values "`cut_values', `=`e'+1'"
        label define `newlabel' `i' "[`s', `e']", modify add
        local ++i
    }
    else {
        local e = `start' - 1
    }

    while `e' < `end' {
        local s = `e' + 1
        if `s' == `start' & mod(`end' - `start' + 1, `step') > 0 {
            local e = `s' + mod(`end' - `start' + 1, `step') - 1
        }
        else {
            local e = `s' + `step' - 1
        }
        local cut_values "`cut_values', `=`e'+1'"
        label define `newlabel' `i' "[`s', `e']", add modify
        local ++i
    }

    if `var_max' > `end' {
        local s = `end'
        local e = `var_max'
        local cut_values "`cut_values', `=`e'+1'"
        label define `newlabel' `i' "[`s', `e']", add modify
    }

    tempname vargroup
    egen `vargroup' = cut(`var'), at(`cut_values') icodes
    cap drop `newvar'
    rename `vargroup' `newvar'
    label value `newvar' `newlabel'
    tab `newvar'
end
