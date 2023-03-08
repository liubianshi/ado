*! version 0.1.0 22Aug2022
*
*  regression by sub-sample
*
program define subsample, rclass
    version 14
    syntax varname [using/] [in] [if], Reg(string) ///
        [ Method(string) REGOpts(string) Cut(numlist ascending) Pre(string) noQuietly]
    marksample touse
    if "`method'" == "" {
        local t: type `varlist'
        local vl: value label `varlist'
        if strpos("`t'", "str") | "`vl'" != "" {
            local method "level"
        }
        else if regexm("`t'", "^(byte|int|long)$") {
            quietly tab `varlist'
            if `r(r)' <= 10 {
                local method "level"
            }
            else {
                local method "mean"
            }
        }
        else {
            local method "mean"
        }
    }
    if "`pre'" == "" {
            local pre = "subs"
    }
    if `"`regopts'"' != "" {
        local regopts = `", `regopts'"'
    }
    if `"`quietly'"' == "" {
        local quietly = "quietly"
    }
    else {
        local quietly = ""
    }
    `quietly' subsample_`method' `"`varlist'"' `"`touse'"' `"`reg'"' ///
        `"`regopts'"' `"`pre'"' `"`cut'"' 
    return add
    if `"$ESTTAB_OPTS"' == "" {
            local esttab_opts = "ar2 nogap mtitle"
    }
    else {
        local esttab_opts = `"$ESTTAB_OPTS"'
    }
    drop _est_`pre'_`varlist'_*
    if `"`using'"' != "" {
        esttab `pre'_`varlist'_* using `"`using'"', `esttab_opts'
        cap open `"`using'"'
    }
    else {
        esttab `pre'_`varlist'_*, `esttab_opts'
    }
end

program define subsample_cut, rclass
    args varname touse reg regopts pre cut
    if `"`cut'"' == "" {
        error 998
    }
    local i = 1
    while `:word count `cut'' != 0 {
        gettoken c cut: cut
        if `i' == 1 {
            `reg' if `touse' & `varname' < `c' `regopts'
            local cpre = `c'
            esti store `pre'_`varname'_c0
        }
        else {
            `reg' if `touse' & `varname' >= `cpre' & `varname' < `c' `regopts'
            esti store `pre'_`varname'_c`i'
        }
        local ++i
    }
    `reg' if `touse' & `varname' >= `cpre' `regopts'
    esti store `pre'_`varname'_c`i'
end

program subsample_level, rclass 
    *! regress by category
    args varname touse reg regopts pre cut
    levelsof `varname', local(lev)
    local isstr = strpos("`:type `varname''", "str")
    local i = 1
    foreach l of local lev {
        if `isstr' {
            `reg' if `touse' & `varname' == `"`l'"' `regopts'
        }
        else {
            `reg' if `touse' & `varname' == `l' `regopts'
        }
        esti store `pre'_`varname'_l`i'
        local ++i
    }
    return local levels = `"`lev'"'
end

program subsample_mean
    args varname touse reg regopts pre cut
    quietly sum `varname' if `touse', detail
    local _m = r(mean)
    `reg' if `touse' & `varname' < `_m' `regopts'
    esti store `pre'_`varname'_m0
    `reg' if `touse' & `varname' >= `_m' `regopts'
    esti store `pre'_`varname'_m1
end

program define subsample_qtile, rclass
    args varname touse reg regopts pre cut
    quietly sum `varname' if `touse', detail
    local q25 = r(q25)
    local q50 = r(q50)
    local q75 = r(q75)
    `reg' if `touse' & `varname' < `q25' `regopts'
    esti store `pre'_`varname'_q1
    `reg' if `touse' & `varname' >= `q25' & `varname' < `q50' `regopts'
    esti store `pre'_`varname'_q2
    `reg' if `touse' & `varname' >= `q50' & `varname' < `q75' `regopts'
    esti store `pre'_`varname'_q3
    `reg' if `touse' & `varname' >= `q75' `regopts'
    esti store `pre'_`varname'_q4
end


/* test code
set tracedepth 1
set trace on
subsample length, reg("reg price c.weight#c.weight") m("cut") pre("t") cut(170 192 204)

subsample foreign, reg("reg price c.weight#c.weight") m("factor") pre("t")



sum length, detail

return list

sysuse auto, clear
esti dir
esti restore t_length_m1
regress
esti dir

flevelsof foreign

program list flevelsof
di `r(r)'

*/
