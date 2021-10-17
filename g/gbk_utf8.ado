*! version 1.0.0

program gbk_utf8,
    version 14.0
    syntax, File(string)
    unicode analyze `file'
    if r(N_needed) == 1 {
        local codelist "gb18030"
        foreach code of local codelist {
            unicode encoding set `code'
            unicode translate `file'
        }
    }
end
