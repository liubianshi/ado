*! version 1.0.0 
// 调整数据显示格式，便于浏览

program wide_half
    version 14
    syntax varname(string) [, Newvar(name) replace ]
    local varname = "`varlist'"
    if "`newvar'" == "" & "`replace'" == "" {
        gen `varname'_half = `varname'
        local newvar = "`varname'_half"
    }
    else if "`newvar'" == "" & "`replace'" != "" local newvar = "`varname'"
    else {
        cap confirm variable `newvar'
        error !_rc
        gen `newvar' = `varname'
    }

    replace `newvar' = subinstr(`newvar', "ａ", "a", .)
    replace `newvar' = subinstr(`newvar', "ｂ", "b", .)
    replace `newvar' = subinstr(`newvar', "ｃ", "c", .)
    replace `newvar' = subinstr(`newvar', "ｄ", "d", .)
    replace `newvar' = subinstr(`newvar', "ｅ", "e", .)
    replace `newvar' = subinstr(`newvar', "ｆ", "f", .)
    replace `newvar' = subinstr(`newvar', "ｇ", "g", .)
    replace `newvar' = subinstr(`newvar', "ｈ", "h", .)
    replace `newvar' = subinstr(`newvar', "ｉ", "i", .)
    replace `newvar' = subinstr(`newvar', "ｇ", "g", .)
    replace `newvar' = subinstr(`newvar', "ｋ", "k", .)
    replace `newvar' = subinstr(`newvar', "ｌ", "l", .)
    replace `newvar' = subinstr(`newvar', "ｍ", "m", .)
    replace `newvar' = subinstr(`newvar', "ｎ", "n", .)
    replace `newvar' = subinstr(`newvar', "ｏ", "o", .)
    replace `newvar' = subinstr(`newvar', "ｐ", "p", .)
    replace `newvar' = subinstr(`newvar', "ｑ", "q", .)
    replace `newvar' = subinstr(`newvar', "ｒ", "r", .)
    replace `newvar' = subinstr(`newvar', "ｓ", "s", .)
    replace `newvar' = subinstr(`newvar', "ｔ", "t", .)
    replace `newvar' = subinstr(`newvar', "ｕ", "u", .)
    replace `newvar' = subinstr(`newvar', "ｖ", "v", .)
    replace `newvar' = subinstr(`newvar', "ｗ", "w", .)
    replace `newvar' = subinstr(`newvar', "ｘ", "x", .)
    replace `newvar' = subinstr(`newvar', "ｙ", "y", .)
    replace `newvar' = subinstr(`newvar', "ｚ", "z", .)
    replace `newvar' = subinstr(`newvar', "Ａ", "A", .)
    replace `newvar' = subinstr(`newvar', "Ｂ", "B", .)
    replace `newvar' = subinstr(`newvar', "Ｃ", "C", .)
    replace `newvar' = subinstr(`newvar', "Ｄ", "D", .)
    replace `newvar' = subinstr(`newvar', "Ｅ", "E", .)
    replace `newvar' = subinstr(`newvar', "Ｆ", "F", .)
    replace `newvar' = subinstr(`newvar', "Ｇ", "G", .)
    replace `newvar' = subinstr(`newvar', "Ｈ", "H", .)
    replace `newvar' = subinstr(`newvar', "Ｉ", "I", .)
    replace `newvar' = subinstr(`newvar', "Ｊ", "J", .)
    replace `newvar' = subinstr(`newvar', "Ｋ", "K", .)
    replace `newvar' = subinstr(`newvar', "Ｌ", "L", .)
    replace `newvar' = subinstr(`newvar', "Ｍ", "M", .)
    replace `newvar' = subinstr(`newvar', "Ｎ", "N", .)
    replace `newvar' = subinstr(`newvar', "Ｏ", "O", .)
    replace `newvar' = subinstr(`newvar', "Ｐ", "P", .)
    replace `newvar' = subinstr(`newvar', "Ｑ", "Q", .)
    replace `newvar' = subinstr(`newvar', "Ｒ", "R", .)
    replace `newvar' = subinstr(`newvar', "Ｓ", "S", .)
    replace `newvar' = subinstr(`newvar', "Ｔ", "T", .)
    replace `newvar' = subinstr(`newvar', "Ｕ", "U", .)
    replace `newvar' = subinstr(`newvar', "Ｖ", "V", .)
    replace `newvar' = subinstr(`newvar', "Ｗ", "W", .)
    replace `newvar' = subinstr(`newvar', "Ｘ", "X", .)
    replace `newvar' = subinstr(`newvar', "Ｙ", "Y", .)
    replace `newvar' = subinstr(`newvar', "Ｚ", "Z", .)
    replace `newvar' = subinstr(`newvar', "１", "1", .)
    replace `newvar' = subinstr(`newvar', "２", "2", .)
    replace `newvar' = subinstr(`newvar', "３", "3", .)
    replace `newvar' = subinstr(`newvar', "４", "4", .)
    replace `newvar' = subinstr(`newvar', "５", "5", .)
    replace `newvar' = subinstr(`newvar', "６", "6", .)
    replace `newvar' = subinstr(`newvar', "７", "7", .)
    replace `newvar' = subinstr(`newvar', "８", "8", .)
    replace `newvar' = subinstr(`newvar', "９", "9", .)
    replace `newvar' = subinstr(`newvar', "０", "0", .)
end
