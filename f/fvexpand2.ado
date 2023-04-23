*! version 0.1.0 13Apr2023
*
*  expand variable like factor variable,
*  especially when the variable is character variable or contain negetive value

capture program drop fvexpand2
program define fvexpand2, sortpreserve
    version 14
    syntax varname(fv ts) [in] [if], gen(name) ///
        [OMIT_levels(string) KEEP_levels(string) replace]
    marksample touse, novarlist

    if (strpos(`"`varlist'"', ".")) {
        local prefix  = ustrregexrf(`"`varlist'"', "\.\w+$", ".")
        local varname = subinstr(`"`varlist'"', `"`prefix'"', "", 1)
    }
    else {
        local prefix = "i."
        local varname = `"`varlist'"'
    }

    confirm variable `varname'
    if `"`replace'"' != "" {
        cap drop `gen'
        cap label drop `gen'
    }
    confirm new variable `gen'

    if `"`keep_levels'"' == "" {
        quietly levelsof `varname' if `touse', local(keep_levels)
    } 
    if `"`omit_levels'"' != "" {
        local keep_levels: list keep_levels - omit_levels
    }

    cap confirm str variable `varname'
    if !_rc {
        encode `varname', gen(`gen')
        foreach level of local keep_levels {
            local inlist `"`inlist', `"`level'"'"'
        }
    }
    else {
        quietly sum `varname' if `touse', detail
        local min = r(min)
        if `min' < 0 {
            gen `gen' = `varname' - `min'
            label define `gen' 0 `"`varname' = `min'"'
            levelsof `gen' if `touse', local(levels)
            foreach level of local levels {
                if (`level' == 0) continue
                label define `gen' `level' `"`varname' = `=`level'+`min''"', add modify
            }
            label values `gen' `gen'
        }
        else {
            gen `gen' = `varname'
        }
        foreach level of local keep_levels {
            local inlist `"`inlist', `level'"'
        }
    }
    fvexpand `prefix'`gen' if `touse' & inlist(`varname'`inlist')
end

