capture program drop my
program define my, sortpreserve byable(onecall)
    *! generate wrapper with addition option
    version 14
    syntax name(name=varname) [=exp] [if] [in] [, label(string) replace ignore *]
    if "`replace'" != "" & "`ignore'" != "" {
        di as error "Cannot set replace and ignore simultaneously!"
        error 184
    }

    * 如果没有待表达式，那么该命令的作用变为给变量加标签
    if `"`exp'"' == "" & `"`label'"' == "" {
        exit 0
    }

    * 确定变量是否已经存在
    cap confirm new variable `varname'
    local rc = _rc
    if !inlist(`rc', 0, 110) {
        error `rc'
    }
    if  (`rc' == 110 & `"`ignore'"' == "" & `"`replace'"' == "")  {
        di as error "`varname' is exist, needed to set option: ignore | replace"
        error `rc'
    }

    marksample touse
    * 变量已经存在，但用户设置了选项 replace
    if `rc' == 110 & `"`replace'"' != "" {
        tempvar tmp
        rename `varname' `tmp'
        cap {
            if _by() {
                by `_byvars': gen `varname' `exp' if `touse', `options'
            }
            else {
                gen `varname' `exp' if `touse', `options'
            }
        }
        if _rc {
            rename `tmp' `varname'
        }
        else {
            drop `tmp'
        }
    }

    * 变量没有存在的情况
    if `rc' == 0 {
        if _by() {
            by `_byvars': gen `varname' `exp' if `touse', `options'
        }
        else {
            gen `varname' `exp' if `touse', `options'
        }
    }

    if `"`label'"' != "" {
        label variable `varname' `"`label'"'
    }

    exit 0 
end

