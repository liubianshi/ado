*! version 0.1.0 06Mar2023
*
*  get variable list from wdi, 
*  for example:
*      get_varlist_from_wdi varname indicator [varname indicator]

cap program drop get_varlist_from_wdi
program define get_varlist_from_wdi, sortpreserve rclass
    version 14

    // handle syntax ---------------------------------------------------- {{{1
    gettoken var_pairs 0: 0, parse(",")
    if mod(`:word count `var_pairs'', 2) == 1 {
        error 228
    }
    forvalue i = 1/`= `:word count `var_pairs'' / 2' {
        local vars        `"`vars' `:word `=`i' * 2 - 1' of `var_pairs''"'
        local indicators  `"`indicators';`:word `=`i' * 2' of `var_pairs''"'
    }
    local vars       = ustrregexrf(`"`vars'"',       "^ ", "")
    local indicators = ustrregexrf(`"`indicators'"', "^;", "")
    foreach v of varlist `vars' {
        cap confirm new variable `v'
        if _rc {
            local rc = _rc 
            di as error "variablealready defined:    `v'"
        }
    }
    if `"`rc'"' != "" {
        di as error "r(`rc');"
        exit
    }

    syntax, c(namelist min=1 max=1) y(namelist min=1 max=1) [ ///
        COUNTRY(string) YEAR(string)                          ///
        Language(string)                                      ///
        SAVE(string)                                          ///
        replace clear add                                     ///
        noGEN                                                 ///
    ]

    // handle option ---------------------------------------------------- {{{1
    // handle option: language ------------------------------------------ {{{2
    if `"`language'"' == "" {
        local language "en - English"
    }

    // handle option: country ------------------------------------------- {{{2
    if `"`country'"' == "" {
        confirm string variable `c'
        cap glevelsof `c', local(country) clean sep(";") silent
        if _rc {
            quietly levelsof `c', local(country) clean sep(";")
        }
    }

    // handle option: year
    if `"`year'"' == "" {
        confirm numeric variable `y'
        quietly sum `y', detail
        local year_min = r(min)
        local year_max = r(max)
        local year `"`year_min':`year_max'"' 
    }

    if `"`add'`save'`clear'"' == "" {
        di "must set 'add', 'save', or 'clear'"
        error 200
    }
    if `"`add'"' != "" & `"`clear'"' != "" {
        di "cannot set 'add' and 'clear' at the same time"
        error 200
    }

    if `"`save'"' != "" & `"`replace'"' == ""{
        cap confirm file `"`save'"'
        if !_rc {
            if `"`clear'"' != "" {
                use `"`save'"', `clear' 
            }
            if `"add"' != "" {
                merge m:1 `c' `y' using `save', keep(master match) `gen'
            }
            exit
        }
    }

    // fetch data from wdi ---------------------------------------------- {{{1
    if `"`clear'"' == "" {
        preserve
    }
    wbopendata,                   ///
        language("`language'")    ///
        country("`country'")      ///
        indicator("`indicators'") ///
        year("`year'")              ///
        clear long
    forvalue i = 1 / `:word count `vars'' {
        local  var_name       = `"`:word `i' of `vars''"'
        local  var_old_name   = r(varname`i')
        local  var_label      = r(varlabel`i')
        local  var_indicator  = r(indicator`i')
        local  var_source     = r(source`i')
        rename `var_old_name' `var_name'
        label  variable       `var_name'  "`var_label'"
        note   `var_name':    `=ustrregexrf(`"`var_source'"', "^[^A-z]+", "")' (`var_indicator'), last visit date: $S_DATE
    }
    rename countrycode `c' 
    rename year `y'
    keep `c' `y' `vars'

    // save data -------------------------------------------------------- {{{1
    if `"`save'"' != "" {
        save `"`save'"', `replace' 
        restore
        if `"`add'"' != "" {
            merge m:1 `c' `y' using `save', keep(master match) `gen'
        }
        return local file `"`save'"'
    }
    else if `"`add'"' != "" {
        tempfile temp
        save `temp'
        restore
        merge m:1 `c' `y' using `temp', keep(master match) `gen'
    }
end
