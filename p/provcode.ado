*! version 1.0.0
program provcode
    version 12.1
    syntax varlist(min=1 max=1 string)
    local v = "`varlist'"
    di `v'
    gen `v'Code = .
    label variable `v'Code "省份编码"
    replace `v'Code = 11 if strpos(`v', "北京")
    replace `v'Code = 12 if strpos(`v', "天津")
    replace `v'Code = 13 if strpos(`v', "河北")
    replace `v'Code = 14 if strpos(`v', "山西")
    replace `v'Code = 15 if strpos(`v', "内蒙")
    replace `v'Code = 21 if strpos(`v', "辽宁")
    replace `v'Code = 22 if strpos(`v', "吉林")
    replace `v'Code = 23 if strpos(`v', "黑龙")
    replace `v'Code = 31 if strpos(`v', "上海")
    replace `v'Code = 32 if strpos(`v', "江苏")
    replace `v'Code = 33 if strpos(`v', "浙江")
    replace `v'Code = 34 if strpos(`v', "安徽")
    replace `v'Code = 35 if strpos(`v', "福建")
    replace `v'Code = 36 if strpos(`v', "江西")
    replace `v'Code = 37 if strpos(`v', "山东")
    replace `v'Code = 41 if strpos(`v', "河南")
    replace `v'Code = 42 if strpos(`v', "湖北")
    replace `v'Code = 43 if strpos(`v', "湖南")
    replace `v'Code = 44 if strpos(`v', "广东")
    replace `v'Code = 45 if strpos(`v', "广西")
    replace `v'Code = 46 if strpos(`v', "海南")
    replace `v'Code = 50 if strpos(`v', "重庆")
    replace `v'Code = 51 if strpos(`v', "四川")
    replace `v'Code = 52 if strpos(`v', "贵州")
    replace `v'Code = 53 if strpos(`v', "云南")
    replace `v'Code = 54 if strpos(`v', "西藏")
    replace `v'Code = 61 if strpos(`v', "陕西")
    replace `v'Code = 62 if strpos(`v', "甘肃")
    replace `v'Code = 63 if strpos(`v', "青海")
    replace `v'Code = 64 if strpos(`v', "宁夏")
    replace `v'Code = 65 if strpos(`v', "新疆")
    replace `v'Code = 71 if strpos(`v', "台湾")
    replace `v'Code = 81 if strpos(`v', "香港")
    replace `v'Code = 82 if strpos(`v', "澳门")
end
