capture program drop my
program define my, sortpreserve byable(onecall)
    *! generate wrapper with addition option
    version 14

    * stata 的 syntax 的 exp 有 bug，当表达式带引号时报错 （type mismatching）
    * 所以只能自己解析参数
    if strpos(`"`0'"', "=") {
        gettoken varname 0: 0, parse("=")
        if `:word count `varname'' == 2 {
            gettoken vartype varname: varname
        }
        local expression = ""
        while !regexm(`"`0'"', "^ *(if|in|,|$)") {
            gettoken expr 0: 0, parse(", ") quotes
            local expression = `"`expression' `expr'"'
        }
        local 0 = `"`varname' `0'"'
    }
    syntax name(name=varname) [if] [in] [, label(string) replace ignore *]
    local exp = `"`expression'"'


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
                by `_byvars': gen `vartype' `varname' `exp' if `touse', `options'
            }
            else {
                gen `vartype' `varname' `exp' if `touse', `options'
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

