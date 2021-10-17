* Exploratory Regression
* by: LUO Wei (liu.bian.shi@gmail.com)

cap program drop testreg
program testreg, nclass
    version 14
    *! use reghdfe for test regression analysis

    * parse syntax ============================================================ {{{1
    * subcommand -------------------------------------------------------------- {{{2
    gettoken field 0 : 0, parse(", ")  // get subcommand to `field'
    if !inlist("`field'", "dep", "core", "control", "fe", "sample") {
        display as error "subcommand must be dep, core, control, fe or sample"
        error 197
    }

    * Command Syntax ---------------------------------------------------------- {{{2
    syntax varlist(min=1 fv ts)                           /// Variable list which will be added to all regressions
        [using]                                          /// output file
        [if] [in],                                        /// Used for sample filter
        Test(varlist min=1 fv ts)                         /// Variable list used in different regressions
        [fe(varlist)                                      /// Fixed Effects
         Method(name)                                     /// Regression Method
         Pre(name)                                         /// Wether keep estimation result
         Accumulate                                       /// Join one by one or cumulatively
         noCONstant                                       /// Wether constant constant in report table
         Open                                             /// Wether open saved result
         vce(passthru) b(integer 3) noAR2 GAP noDEPvars * /// Parameters will be delivered to esttab
         ]

    * Method ------------------------------------------------------------------ {{{2
    if "`method'" == "" {
        local method = "reghdfe"  // default method
    }

    * baseic sample ----------------------------------------------------------- {{{2
    marksample basesample
    if "`field'" == "sample" {
        fvexpand `test' if `basesample'   // Sample must specified in factor variable form
        local test = r(varlist)
        local test: subinstr local test "b." ".", all
        local addnotes_sample = ""
        local i = 1
        foreach sample_index of local test {
            local addnotes_sample = `"`addnotes_sample'"Model `i' limited the sample by `sample_index'." "'
            local ++i
        }
    }

    * dependent var ----------------------------------------------------------- {{{2
    if "`field'" != "dep" {
        gettoken dep varlist : varlist
    }

    * independent var --------------------------------------------------------- {{{2
    local indep "`varlist'"
    if inlist("`field'", "dep", "fe", "sample") {
        local varlist_order = "`varlist'"
    }
    else {
        local varlist_order = "`varlist' `test'"
    }

    * fiexed effect ----------------------------------------------------------- {{{2
    local absorb = "`fe'"
    if "`field'" == "fe" {
        local fixedeffects = ""
        foreach femacro of local test {
            local fixedeffects = "`fixedeffects' FE_`=ustrregexra("`femacro'", "[^\w]", "_")'"
        }
    }
    if "`fe'" != "" {
        local addnotes_fe: subinstr local fe " " ", ", all
        local addnotes_fe "All model absorbed `addnotes_fe'."
    }
    if `"`addnotes_sample'`addnotes_fe'"' != "" {
        local add_notes = `"addnotes(`addnotes_sample' "`addnotes_fe'")"'
    }

    preserve
    * Regression ============================================================== {{{1
        if "`pre'" == "" {
            tempname R
        }
        else {
            local R "`pre'"
        }

    foreach t of local test {
        * construct dependent variable ---------------------------------------- {{{2
        if "`field'" == "dep" {
            local dep = "`t'"
        }

        * construct independent variables ------------------------------------- {{{2
        if inlist("`field'", "core", "control") {
            if "`accumulate'" == "" {
                local indep = "`t' `varlist'"
            }
            else {
                local indep = "`t' `indep'"
            }
        }

        * construct absorb factor variables ----------------------------------- {{{2
        if "`field'" == "fe" {
            if "`accumulate'" == "" {
                local absorb = "`t' `fe'"
            }
            else {
                local absorb = "`t' `absorb'"
            }
        }
        if "`absorb'" == "" {
            local absorb_option = "noabsorb"
        }
        else {
            local absorb_option = "absorb(`absorb')"
        }

        * construct sample index ---------------------------------------------- {{{2
        if "`field'" == "sample" {
            tempvar sample
            gen `sample' = `basesample' & `t'
        }
        else {
            tempvar sample
            gen `sample' = `basesample'
        }

        * run regress --------------------------------------------------------- {{{2
        eststo, prefix("`R'") noesample: ///
            `method' `dep' `indep' if `sample', `absorb_option' `noconstant' `vce'

        * add extra macro ----------------------------------------------------- {{{2
        quietly {
            if "`field'" == "fe" {
                local absvars = e(extended_absvars)
                foreach femacro of local test {
                    local femacro_value = "N"
                    foreach absvar of local absvars {
                        if `"`=ustrregexra("`femacro'", "i\.", "")'"' == "`absvar'" {
                            local femacro_value = "Y"
                        }
                    }
                    estadd local FE_`=ustrregexra("`femacro'", "[^\w]", "_")' "`femacro_value'"
                }
            }
        }
    }

    * export result =========================================================== {{{1
    if "`fixedeffects'" != "" { local scalars = "scalars(`fixedeffects')"
    }
    if "`ar2'" != "noar2"         local ar2 = "ar2"
    if "`depvars'" != "nodepvars" local depvars = "depvars"
    if "`gap'" == ""              local gap = "nogap"
    esttab `R'* `using', `replace' `scalars' `add_notes' ///
        b(`b') `ar2' `depvars' `gap' order(`varlist_order') `options'

    * open result ============================================================= {{{1
    if ("`open'" != "" & `"`using'"' != "") {
        if "`c(os)'" == "Unix" {
            local shellout "xdg-open"
        }
        else if "`c(os)'" == "MacOSX" {
            local shellout "open"
        }
        else if "`c(os)'" == "MacOSX" {
            local shellout "start"
        }
        shell `shellout' "`using'" >& /dev/null &
    }
    restore //

    * on.exit ================================================================= {{{1
    cap drop `basesample'
end

* END ========================================================================= {{{1
/* test
webuse nlswork, clear
save /tmp/test.dta, replace
use /tmp/test.dta, clear

cap gen sample_index = inrange(_n, 1, 10000)


cap program drop testreg
set trace on
set tracedepth 2

testreg fe ln_w grade age ttl_exp tenure not_smsa south, ///
    t(idcode#occ idcode year occ) replace  compress pre(T)

testreg fe ln_w grade age ttl_exp tenure not_smsa south ///
    using /tmp/temp.txt, ///
    t(idcode#occ idcode year occ) replace


testreg sample ln_w grade age ttl_exp tenure not_smsa south ///
    using "/tmp/test sample.txt", ///
    t(i.sample_index) fe(idcode year) append drop(grade) b(4)

* fe
testreg fe ln_w  age ttl_exp tenure not_smsa south ///
    using /tmp/temp.html, ///
    t(idcode year occ idcode#occ) replace

* control
testreg control ln_w age ///
    using "/tmp/test control.txt", ///
    t(ttl_exp tenure not_smsa south) fe(idcode year) replace
    help join

*/
* vim: set ft=stata fdm=markder noet 
