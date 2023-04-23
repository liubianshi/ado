*! version 0.1.0 22Apr2023
*
*  This build match sampe
capture program drop build_match_smaple
program define build_match_smaple, sortpreserve rclass
    version 14
    di `"`0'"'
    syntax varlist using/ [if] [in], save(string)               ///
                   Treat_start(numlist integer asc min=1 max=2) ///
                 [ id(varname)                                  ///
                   time(varname)                                ///
                   cov_vari_dummy(varlist)                      ///
                   match_step(integer 1)                        ///
                   match_options(string)                        ///
                 ]
    confirm file `"`using'"'

    gettoken treat           varlist:          varlist
    gettoken treat_start_min treat_start_max:  treat_start
    gettoken savefile        replace:          save,      parse(", ")
    gettoken comma           replace:          replace,   parse(", ")
    if `"`replace'"'         == ""  confirm new file        `"`savefile'"'

    if `"`treat_start_max'"' == ""    local treat_start_max `"`treat_start_min'"'
    if `"`match_options'"'   == ""    local match_options   `"$G_matchMethod"'

    cap quietly xtset
    if _rc &  (`"`id'"' == "" | `"`time'"' == "" )  error 121
    if `"`id'"' == ""                 local id   = r(panelvar)
    if `"`time'"' == ""               local time = r(timevar)
    
    preserve
    use `id' `time' `treat' `if' `in' using `"`using'"', clear

    tempvar treat_start_time
    sort `id'  `time'
    by   `id': gen `treat_start_time' = `time' if `treat' - `treat'[_n - 1] == 1
    sort `id'  `treat_start_time'
    by   `id': replace `treat_start_time' = `treat_start_time'[1]

    tempvar treated_group
    gen `treated_group' = (`treat_start_time' != .)

    keep if inrange(`treat_start_time', `treat_start_min', `treat_start_max') ///
          | `treated_group' == 0

    
    keep `id' `treated_group' `treat_start_time'
    gduplicates drop
    tempfile keep_obs
    save `keep_obs'
    use `"`using'"', clear
    merge m:1 `id' using `keep_obs', nogen keep(match)

    sort `id' `time'
    tempname matchid pscore
    gen `matchid' = ""
    gen `pscore' = .

    forvalue y = `treat_start_min'/`treat_start_max' {
        if mod(`y', `match_step') != mod(`treat_start_min', `match_step') {
            continue
        }

        cap snapshot erase $SNAPSHOT_before_match
        cap macro drop SNAPSHOT_before_match
        snappreserve before_match, label(Build Match Sample: before match)

        // using data from the time before treated
        keep if inrange(`time', `y' - `match_step', `y' - 1)
        keep if (`treated_group' == 0 & `matchid' == "") /// not matched control group
              | (`treated_group' == 1 &                  /// time-appropriate treated
                  inrange(`treat_start_time', `y', `y' + `match_step' - 1))

        // use the value from one year before treated
        sort `id'
        foreach dummy of varlist `cov_vari_dummy' {
            by `id': replace `dummy' = `dummy'[_N]
        }

        collapse (mean) `treated_group' `varlist', by(`id')
        psmatch2 `treated_group' `varlist', `match_options'

        quietly count if _n1 != . & `treated_group' == 1
        if r(N) == 0 {
            snaprestore before_match
            continue
        }
        tempfile match_result
        pull_match_table_after_psmatch2 using `match_result', id(`id') replace
        snaprestore before_match
        
        merge m:1 `id' using `match_result', ///
              keep(master match) keepusing(_pscore _match_id) nogen
        replace `pscore'  = _pscore   if `pscore' == .
        replace `matchid' = _match_id if `matchid' == ""
        drop _pscore _match_id
    }
    
    sort `matchid' `treat_start_time'
    by `matchid': replace `treat_start_time' = `treat_start_time'[1] if `matchid' != ""
    rename `pscore' _pscore
    rename `matchid' _match_id

    sort `id' `time'

    balance_check _pscore `varlist', treat(`treated_group')
    matrix balance_before_match = r(balance_check_result)
    return matrix balance_before_match = balance_before_match

    balance_check _pscore `varlist'                                            ///
               if `time' == `treat_start_time' - 1 & _match_id != "" ///
                , treat(`treated_group')
    matrix balance_after_match = r(balance_check_result)
    return matrix balance_after_match = balance_after_match 
    
    keep if _match_id != ""
    keep `id' `treat_start_time' _match_id 
    rename `treat_start_time' teatStartTime
    gduplicates drop
    save `"`savefile'"', nolabel `replace'
    restore
end

