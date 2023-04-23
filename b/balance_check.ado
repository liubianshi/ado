*! version 0.1.0 21Apr2023
*
*  balance check

program define balance_check, sortpreserve rclass
    version 14
    syntax varlist [if] [in], treat(varname)
    marksample touse

    tempname Balance
    local colnames "Num Untreated Treated Diff pValue"  
    local rows_num: word count `varlist'
    local cols_num: word count `colnames'
    matrix `Balance' = J(`rows_num', `cols_num', 0)
    matrix rownames `Balance' = `varlist'
    matrix colnames `Balance' = `colnames'

    local i = 0
    foreach v of local varlist {
        local ++i
        quietly mean `v' if `touse', over(`treat') coeflegend
        local coef:      colnames e(b)
        local untreated: word 1 of `coef'
        local treated:   word 2 of `coef'

        matrix `Balance'[`i', 1] = e(N)
        matrix `Balance'[`i', 2] = _b[`untreated'] 
        matrix `Balance'[`i', 3] = _b[`treated'] 
        matrix `Balance'[`i', 4] = _b[`treated'] - _b[`untreated']

        quietly lincom _b[`treated'] - _b[`untreated']
        matrix `Balance'[`i', 5] = 2 * t(r(df), -abs(r(estimate))/r(se))
    }
    return matrix balance_check_result = `Balance'
end
