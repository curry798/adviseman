BEGIN{
    # 控制缩进
    space = "  "
    for(i = 0;i < indent; i++){
        space = space "  "
    }
    true=1; false=0
    opt=""
    IS_COMMANDS=false
    IS_OPTION=false
}

function debug(msg){
    print "\033[1;31m" msg "\033[0;0m"
}

function get_json(text,    i,arr,arrcom){
    # 把text里面首次正则匹配到的内容用""替换掉,/^[ \t]+/ 匹配行首以空格或者\t(制表符)开头一个或多个内容
    # sub(/^[ \t]+/, "",text)
    # gsub(/<.*>.../, "", text)
    gsub("`","\\`",text)
    # /^-/ 匹配行首字母是-的
    # ~ 匹配正则
    if (text ~ "OPTIONS:"){
        if (IS_OPTION == false){
            IS_OPTION=true
            return
        }
    }
    if(IS_OPTION == true){
        if(text ~ /^[ \t\r]*$/){
            IS_OPTION=false
            return
        }
        # 把text里面的内容用" "拆分，结果放到arr数组里面
        sub(/^[ \t]+/, "",text)
        # split(text,arr," ")
        if(text ~ /^-/){
            debug(text)
        }


        # opt=opt "\nprintf \""space"%s\\n\"  \"\\\""
        # for (i in arr){
        #     # 把arr[i]里面所有正则匹配到的内容都用""替换掉
        #     # :blank: 表示空格
        #     gsub(/[[:blank:]]*/,"",arr[i])
        #     if (arr[i] ~ /^-/){
        #         # 把arr[i]里面所有的,换成|
        #         gsub(/,/,"|",arr[i])
        #         opt=opt arr[i]
        #         # debug(opt)
        #     }else{
        #         break
        #     }
        # }
        # 获取bat的
        # if(match(text, / +[A-Z]/)){
        #     desc = substr(text, RSTART)
        #     sub(/^[ \t]+/, "",desc)
        # }


        # opt=opt "\\\": null,\""
        # printf "%s\n"  "\"-Z\": null,"
        # opt=opt "\\\": \\\""desc"\\\",\""
        # debug(opt)
        return
    }
    if(text ~ "SUBCOMMANDS:"){
        if (IS_COMMANDS == false){
            IS_COMMANDS=true
            return
        }
    }
    if (IS_COMMANDS == true){
        if(text ~ /^[ \t\r]*$/){
            IS_COMMANDS=false
            return
        }
        # 把text里面的内容用" "分隔开，结果放到arrcom里面
        if(match(text, / +[A-Z]/)){
            str = substr(text, 1, RSTART)
        }
        if(match(text, / +[A-Z]/)){
            sub_desc = substr(text, RSTART)
            sub(/^[ \t]+/, "",sub_desc)
            # debug(sub_desc)
        }
        # 把, 变成 ,方便等下split的时候,紧挨着第二个subcommand(即build ，b)，这样到时候arrcom[1]才会是build而不是build|
        gsub(/, /, " ,", str)
        split(str,arrcom," ")
        # debug(str)
        opt=opt "\nprintf \""space"%s\\n\"  \"\\\""
        gsub(/,/, "|", text)
        # opt=opt text
        # debug(opt)
        for(i in arrcom){
            gsub(/,/, "|", arrcom[i])
            opt=opt arrcom[i]
            # debug(arrcom[i])
        }
        opt=opt "\\\": $(indent=" indent+1 " get " CUR_CMD " " arrcom[1] ")"
        # opt=opt "\\\": $(indent=" indent+1 " get " CUR_CMD " " arrcom[1] ")\n  \\\"#desc\\\": \\\""sub_desc"\\\"\","
        # opt=substr(opt,1,length(opt)-2)
        opt=opt "\\\"#desc\\\": \\\""sub_desc"\\\"\"\"\n"space"}\,\""
        # opt=opt "\)\,"
        # debug(opt)
        return
    }
}

{
    text=$0
    get_json(text)
    # supplement(get_json(text))
}

END{
    opt = "printf \"{\\n\"" opt "\nprintf \"" space "%s\\n\" "
    # print opt
    # debug(opt)
    text=""
    IS_COMMANDS=false
    IS_OPTION=false
    opt=""
}