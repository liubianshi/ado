capture program drop open
program define open, sortpreserve
    *! open file from stata
    version 14

    if "`c(os)'" == "Unix" {
        if `=strpos(`"`0'"', ".svg")' {
            local shellout "display -density 600"
        }
        else {
            local shellout "xdg-open"
        }
        local stdout "&>/dev/null"
    }
    else if "`c(os)'" == "Unix" {
        local shellout "xdg-open"
        local stdout "&>/dev/null"
    }
    else if "`c(os)'" == "Windows" ///
        local shellout ""
    else error 199

    cap python query
    local python_exec = r(execpath)
    if "`python_exec'" != "" {
        quietly python: import os; os.system('`shellout' "`0'" `stdout' &')
    } 
    else {
        shell `shellout' `0' &
    }
end
