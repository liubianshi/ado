* Exploratory Regression
* by: LUO Wei (liu.bian.shi@gmail.com)

cap program drop testreg
program testreg, nclass
    version 14
    *! use reghdfe for test regression analysis
    syntax anything [using] [if] [in], Test(varlist min=1 fv ts) [Method(name) *]
    if `"`method'"' == "" | `"`method'"' == "reghdfe" {
        testreg_reghdfe `0'
    }
    else {
        di as error "Method `method' is not supported yet!"
        error 199
    }
end

* test using reghdfe ========================================================== {{{1
program testreg_reghdfe, nclass
    * parsing auguments ------------------------------------------------------- {{{2
    di `"`0'"'
    gettoken field 0 : 0, parse(", ")  // get subcommand to `field'
    if !inlist("`field'", "dep", "core", "control", "fe", "sample") {
        display as error "subcommand must be dep, core, control, fe or sample"
        error 197
    }
    syntax varlist(min=1 fv ts) [using/] [if] [in],       ///
        Test(varlist min=1 fv ts)                         /// Variable list used in different regressions
        [fe(varlist)                                      /// Fixed Effects
         Pre(name)                                        /// Wether keep estimation result
         Accumulate                                       /// Join one by one or cumulatively
         noCONstant                                       /// Wether constant constant in report table
         Open                                             /// Wether open saved result
         vce(passthru) noar2 noDEPvars gap b(integer 3) *                                  /// Parameters will be delivered to esttab
         ]
    marksample basesample

    * sample info ------------------------------------------------------------- {{{2
    if "`field'" == "sample" {
        gen_sample_varlist `test' if `basesample'
        local test = r(varlist)
        local addnotes_sample = r(addnotes)
        local addnotes_sample = `""`addnotes_sample'""'
    }
    * dep and indep varlist --------------------------------------------------- {{{2
    if "`field'" != "dep" ///
        gettoken dep varlist : varlist
    local indep "`varlist'"
    if inlist("`field'", "dep", "fe", "sample") ///
        local varlist_order = "`varlist'"
    else local varlist_order = "`varlist' `test'"
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
    * model prefix ------------------------------------------------------------ {{{2
    if "`pre'" == "" ///
        tempname R
    else local R "`pre'"

    * run regression ---------------------------------------------------------- {{{2
    preserve
    foreach t of local test {
        * dep, indep, fe, absorb and smaple handle ---------------------------- {{{3
        if "`field'" == "dep" ///
            local dep = "`t'"
        if inlist("`field'", "core", "control") {
            if "`accumulate'" == "" ///
                local indep = "`t' `varlist'"
            else local indep = "`t' `indep'"
        }
        if "`field'" == "fe" {
            if "`accumulate'" == "" ///
                local absorb = "`t' `fe'"
            else local absorb = "`t' `absorb'"
        }
        if "`absorb'" == "" ///
            local absorb_option = "noabsorb"
        else local absorb_option = "absorb(`absorb')"
        tempvar sample
        if "`field'" == "sample" ///
            gen `sample' = `basesample' & `t'
        else gen `sample' = `basesample'
        * run regress --------------------------------------------------------- {{{3
        eststo, prefix("`R'") noesample: ///
            reghdfe `dep' `indep' if `sample', `absorb_option' `constant' `vce'
        * add extra macro ----------------------------------------------------- {{{2
        if "`field'" == "fe" {
            local absvars = e(extended_absvars)
            foreach femacro of local test {
                local femacro_value = "N"
                foreach absvar of local absvars {
                    if `"`=ustrregexra("`femacro'", "i\.", "")'"' == "`absvar'" ///
                        local femacro_value = "Y"
                }
                estadd local FE_`=ustrregexra("`femacro'", "[^\w]", "_")' "`femacro_value'"
            }
        }
    }

    * export result ----------------------------------------------------------- {{{2
    if "`fixedeffects'" != ""     local scalars = "scalars(`fixedeffects')"
    if "`ar2'" != "noar2"         local ar2 = "ar2"
    if "`depvars'" != "nodepvars" local depvars = "depvars"
    if "`gap'" == ""              local gap = "nogap"
    if `"`using'"' != "" local using2 = `"using "`using'""'
    esttab `R'* `using2', `replace' `scalars' `add_notes' ///
        b(`b') `ar2' `depvars' `gap' order(`varlist_order') `options'

    * open result ------------------------------------------------------------- {{{2
    if "`open'" != "" & `"`using'"' != "" open `using'

    * on.exit ----------------------------------------------------------------- {{{1
    cap drop `basesample'
    restore
end

program define gen_sample_varlist, rclass
    syntax anything [if]
    local varlist = "`anything'"
    fvexpand `varlist' `if'
    local test = r(varlist)
    local test: subinstr local test "b." ".", all
    local addnotes_sample = ""
    local i = 1
    foreach sample_index of local test {
        local addnotes_sample = `"`addnotes_sample'"Model `i' limited the sample by `sample_index'." "'
        local ++i
    }
    return local varlist `test'
    return local addnotes `addnotes_sample'
end






* END ========================================================================= {{{1
* b(integer 3) noAR2 GAP noDEPvars
/* test
webuse nlswork, clear
save /tmp/test.dta, replace
use /tmp/test.dta, clear

cap gen sample_index = inrange(_n, 1, 10000)


cap program drop testreg
set trace on
set tracedepth 2

testreg fe ln_w grade age ttl_exp tenure not_smsa south, ///
    t(idcode#occ idcode year occ) replace compress pre(T)

testreg fe ln_w grade age ttl_exp tenure not_smsa south ///
    using /tmp/temp.txt, ///
    t(idcode#occ idcode year occ) replace open


cap program drop testreg
testreg sample ln_w grade age ttl_exp tenure not_smsa south ///
    using "/tmp/test sample.txt", ///
    t(i.sample_index) fe(idcode year) append drop(grade) b(4) open

* fe
testreg fe ln_w  age ttl_exp tenure not_smsa south ///
    using /tmp/temp.html, ///
    t(idcode year occ idcode#occ) replace open

* control
testreg control ln_w age ///
    using "/tmp/test control.txt", ///
    t(ttl_exp tenure not_smsa south) fe(idcode year) replace open

*/
* vim: set ft=stata fdm=marker noet:
*
*
