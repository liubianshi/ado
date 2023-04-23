*! version 0.1.0 21Apr2023
*
*  save data to tempfile

program define save2tempfile, sortpreserve
    local filename "`1'"
    tempfile temp
    save `temp', replace
    c_local `filename' "`temp'"
end
