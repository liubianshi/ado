* Generate variable by do file
*! generate variable by do file which will created a intermediate data file
* by: LUO Wei (liu.bian.shi@gmail.com)

program dogen, rclass
    version 14
    syntax [namelist] [using/] [, Saving(string) replace clear]

    local dofile `"`using'"'
    if `"`using'"' == "" {
        local dofile = `"`=subinstr("`namelist'", " ", "_", .)'.do"'
    }

    local data `"`saving'"'
    if "`data'" == "" {
        local data `"out/`=subinstr("`namelist'", " ", "_", .)'.dta"'
    }

    return local varlist  `"`namelist'"'
    return local dofile   `"`dofile'"'
    return local datafile `"`data'"'

    capture confirm file `"`data'"'
    if _rc | "`replace'" != "" {
        preserve
            do `"`dofile'"'
            save `"`data'"', replace
        restore
    }
    
    if `"`clear'"' != "" {
        use `"`data'"', clear
    }
end

