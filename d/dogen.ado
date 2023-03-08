* Generate variable by do file
*! generate variable by do file which will created a intermediate data file
* by: LUO Wei (liu.bian.shi@gmail.com)

program dogen, rclass
    version 14
    syntax namelist(min=1) [using/] [, Saving(string) replace]

    local dofile "`using'"
    if "`using'" == "" {
        local dofile = `"`=subinstr("`namelist'", " ", "_", .)'.do"'
    }

    local data "`saving'"
    if "`data'" == "" {
        if "`dir'" == "" {
            local dir "./output"
        }
        local data `"`dir'/`=subinstr("`namelist'", " ", "_", .)'.dta"'
    }

    capture confirm file "`data'"
    if _rc | "`replace'" != "" {
        do "`dofile'"
    }

    return local varlist  "`namelist'"
    return local dofile   "`dofile'"
    return local datafile "`data'"
end

