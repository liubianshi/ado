*! version 0.1.0 22Apr2023
*
*  This build match sampe
program define build_match_smaple, sortpreserve rclass
    version 14
    ** authentication the auguments ------------------------------------- {{{2
    syntax varlist [if] [in], save(string)                      ///
                 [ id(varname)                                  ///
                   time(varname)                                ///
                   method(string)                               ///
                   Treat_start(numlist integer asc min=1 max=2) ///
                   cov_vari_dummy(varlist)                      ///
                   match_step(integer 1) lag(integer 1) *       ]
    gettoken treat     varlist:   varlist
    local varlist_for_balance_check `"`varlist'"'
    gettoken savefile  replace:   save,      parse(", ")
    gettoken comma     replace:   replace,   parse(", ")
    if `"`replace'"' == "" {
        confirm new file `"`savefile'"'
    }

    cap quietly xtset
    if _rc {
        if (`"`id'"' == "" | `"`time'"' == "" )  error _rc 
        else                                     xtset `id' `time'
    }
    if `"`id'"'   == ""   local id   = r(panelvar)
    if `"`time'"' == ""   local time = r(timevar)
    
    if `"`treat_start'"' != "" {
        gettoken treat_start_min treat_start_max:  treat_start
        if `"`treat_start_max'"' == ""  {
            local treat_start_max `"`treat_start_min'"'
        }
    }

    marksample touse, novarlist
    ** preprocess the data ---------------------------------------------- {{{2
    preserve
    quietly {
        keep `id' `time' `treat' 
        tempvar treat_start_time
        sort `id'  `time'
        by `id': gen `treat_start_time' = `time'      ///
                    if `treat' - `treat'[_n - 1] == 1 ///
                     | (_n == 1 & `treat' == 1)
        sort `id'  `treat_start_time'
        by   `id': replace `treat_start_time' = `treat_start_time'[1]
    }

    quietly {
        if `"`treat_start_min'"' == "" {
            sum `treat_start_time'
            local treat_start_min = r(min)
            local treat_start_max = r(max)
        }
        else {
            keep if `treat_start_time' == .                        ///
                 |  inrange(`treat_start_time', `treat_start_min', ///
                                                `treat_start_max') 
        }
        keep `id' `treat_start_time'
        gduplicates drop
        tempfile keep_obs
        save `keep_obs'
    }
    restore

    ** execute the match process ---------------------------------------- {{{2
    preserve
    quietly {
        merge m:1 `id' using `keep_obs', nogen keep(match)
        drop if `time' > `treat_start_time'

        tempname matchid pscore treated_group
        gen `matchid' = ""
        gen `treated_group' = (`treat_start_time' != .)
        sort `id' `time'
        if `"`method'"' == "full-sample" {
            tempvar Ftreat
            logit `treat' L`lag'.(`varlist') if `touse'
            predict `pscore', pr
            local options `"pscore(`pscore') `options'"'
            local varlist ""
            local cov_vari_dummy ""
        }
        else {
            gen `pscore'  = .
        }
    }

    forvalue y = `treat_start_min'/`treat_start_max' {
        if mod(`y', `match_step') != mod(`treat_start_min', `match_step') {
            continue
        }
        snappreserve before_match, label(Build Match Sample: before match) force
        di "First treated between `y' and `=`y'+`match_step'-1'"

        // using data from the time before treated
        quietly {
            if `"`method'"' == "full-sample" {
                keep if inrange(`time', `y' - (`match_step' - 1), `y')
            }
            else {
                keep if inrange(`time', `y' - `lag' - (`match_step' - 1), ///
                                        `y' - `lag')
            }
            keep if (`treat_start_time' == . & `matchid' == "")       ///
                  | inrange(`treat_start_time', `y', `y' + `match_step' - 1)
        }

        // use the value from one year before treated
        if `"`cov_vari_dummy'"' != "" {
            sort `id' `time'
            foreach dummy of local cov_vari_dummy {
                quietly by `id': replace `dummy' = `dummy'[_N]
            }
        }
        collapse (mean) `treated_group' `pscore' `varlist', by(`id')

        * match and fetch match result
        quietly {
            quietly psmatch2 `treated_group' `varlist', `options'
            count if `treated_group' == 1
            local total_treated = r(N)
            count if `treated_group' == 0
            local total_control = r(N)
            count if _n1 != . & `treated_group' == 1
            local match_treated = r(N)
        }
        di "   Treated: `match_treated'/`total_treated'"

        if `match_treated' == 0 {
            di "   Control: 0/`total_control'"
            snaprestore before_match
            continue
        }
        tempfile match_result
        quietly pull_match_table_after_psmatch2 using `match_result', id(`id') replace
        local match_control = r(control_matched)
        di "   Control: `match_control'/`total_control'"
        snaprestore before_match
        
        * update origin data with matching result
        quietly {
            merge   m:1 `id' using `match_result', ///
                    keep(master match) keepusing(_pscore _match_id) nogen
            replace `pscore'  = _pscore   if `pscore' == .
            replace `matchid' = _match_id if `matchid' == ""
            drop    _pscore _match_id
        }
    }

    quietly {
        sort `matchid' `treat_start_time'
        by `matchid': replace `treat_start_time' = `treat_start_time'[1] ///
                      if `matchid' != ""
        sort `id' `time'
    }
    
    * chech the balance of sample before and after matching ------------- {{{2
    rename `pscore' _pscore
    balance_check _pscore `varlist_for_balance_check'                       ///
        if `touse'                                                          ///
        , treat(`treated_group')
    matrix balance_before_match = r(balance_check_result)
    return matrix balance_before = balance_before_match

    balance_check _pscore `varlist_for_balance_check'                       ///
        if `touse' & `time' == `treat_start_time' - `lag' & `matchid' != "" ///
        , treat(`treated_group')
    matrix balance_after_match = r(balance_check_result)
    return matrix balance_after = balance_after_match 
    
    * save match result ------------------------------------------------- {{{2
    quietly {
        keep if `matchid' != ""
        keep `id' `treat_start_time' `matchid'
        gduplicates drop
    }
    rename (`matchid'   `treat_start_time') ///
           (_match_id   treatStartTime)
    save `"`savefile'"', nolabel `replace'
    return local data_file = `"`savefile'"'
    restore
end // ------------------------------------------------------------------

