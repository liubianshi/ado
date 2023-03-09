*! version 0.1.0 06Mar2023
*
*  get variable list from wdi, 
*  for example:
*      get_varlist_from_wdi varname indicator [varname indicator]

cap program drop get_varlist_from_wdi
program define get_varlist_from_wdi, sortpreserve rclass
    version 14
    gettoken var_pairs 0: 0, parse(",")
    if mod(`:word count `var_pairs'', 2) == 1 {
        error 228
    }
    forvalue i = 1/`= `:word count `var_pairs'' / 2' {
        local vars        `"`vars' `:word `=`i' * 2 - 1' of `var_pairs''"'
        local indicators  `"`indicators';`:word `=`i' * 2' of `var_pairs''"'
    }
    local vars       = ustrregexrf(`"`vars'"', "^ ", "")
    local indicators = ustrregexrf(`"`indicators'"', "^;", "")

    syntax, [Country(string) Year(string) Language(string) Save(string) replace clear]
    if `"`language'"' == "" {
        local language "en - English"
    }
    if `"`country'"' == "" {
        local country "$WDI_COUNTRY_LIST"
    }
    if `"`year'"' == "" {
        local year "$WDI_YEAR_LIST"
    }
    if `"`country'"' == "" | `"`year'"' == "" {
        error 229
    }
    if `"`save'"' != "" & `"`replace'"' == ""{
        cap confirm file `"`save'"'
        if !_rc {
            if `"`clear'"' != "" {
                use `"`save'"', `clear' 
            }
            exit
        }
    }

    if `"`clear'"' == "" &  `"`save'"' != "" {
        preserve
        clear
    }
    wbopendata,                   ///
        language("`language'")    ///
        country("`country'")      ///
        indicator("`indicators'") ///
        year(`year')              ///
        `clear' long
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
    rename countrycode country
    keep country year `vars'

    if `"`save'"' != "" {
        save `"`save'"', `replace' 
        if `"`clear'"' == "" {
            restore
        }
        return local file `"`save'"'
    }
end
