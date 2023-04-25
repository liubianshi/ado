program define pull_match_table_after_psmatch2, sortpreserve rclass
    syntax using/, [id(varname) replace]

    confirm numeric variable _nn _id _n1 _pscore
    if `"`replace'"' == "" {
        confirm new file `"`using'"'
    }
    
    if `"`id'"' == "" {
        local id = "_id"
    }

    preserve
        gen _match_id = string(`id')
        sort _id

        quietly sum _nn
        local ratio = r(max)
        if `ratio' < 1 {
            error 111
        }
        forvalue i = 1/`ratio' {
            gen _n`i'_id = `id'[_n`i'] if _n`i' != .
            gen _n`i'_pscore = _pscore[_n`i'] if _n`i' != .
            replace _match_id = _match_id + "-" + string(`id'[_n`i']) if _n`i' != .
        }
        keep if _match_id != string(`id')
        keep `id' _n*_id _match_id _pscore _n*_pscore
        tempfile temp
        save `temp', replace

        gen _group = 0
        forvalue i = 1/`ratio' {
            append using `temp'
            replace _group  = `i'          if _group == .
            replace `id'    = _n`i'_id     if _group == `i'
            replace _pscore = _n`i'_pscore if _group == `i'
        }
        
        keep  `id' _pscore _group  _match_id
        order `id' _group  _pscore _match_id

        save `"`using'"', nolabel `replace'

        return scalar ratio = `ratio'
        quietly {
            count if _group == 0
            return scalar treat_matched = r(N)

            keep if _group != . & _group > 0
            duplicates drop
            count
            return scalar control_matched = r(N)
        }
    restore
end


