capture program drop open
program define open, sortpreserve
    *! open file from stata
    version 14

    if "`c(os)'" == "Unix" {
        local shellout "xdg-open"
        local stdout "&>/dev/null"
    }
    else if "`c(os)'" == "MacOSX" {
        local shellout "open"
        local stdout "&>/dev/null"
    }
    else if "`c(os)'" == "windows" ///
        local shellout "start"
    else error 199

    quietly python query
    local python_exec = r(execpath)
    if "`python_exec'" != "" {
        quietly python: import os; os.system('`shellout' "`0'" `stdout' &')
    } 
    else {
        winexec `shellout' `0' &
    }
end
