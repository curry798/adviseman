BEGIN{
    # 控制缩进
    space = "  "
    for(i = 0;i < indent; i++){
        space = space "  "
    }
    true=1; false=0
    opt=""
    IS_COMMANDS=false
}
function debug(msg){
    print "\033[1;31m" msg "\033[0;0m"
}
function get_json(text,    i,arr,arrcom){
    # 把text里面首次正则匹配到的内容用""替换掉,/^[ \t]+/ 匹配行首以空格或者\t(制表符)开头一个或多个内容
    sub(/^[ \t]+/, "",text)
    gsub(/\[.*\]/, "", text)
    gsub(/<.*>/, "", text)
    gsub("`","\\`",text)
    gsub(/"/, "\\\"", text)
    # debug(text)
    # /^-/ 匹配行首字母是-的
    # ~ 匹配正则
    if (text ~ /^-/){
        # 把text里面的内容用" "拆分，结果放到arr数组里面
        split(text,arr," ")
        opt=opt "\nprintf \""space"%s\\n\"  \"\\\""
        for (i in arr){
            # 把arr[i]里面所有正则匹配到的内容都用""替换掉
            # :blank: 表示空格
            gsub(/[[:blank:]]*/,"",arr[i])
            # print (arr[i])
            if (arr[i] ~ /^-/){
                # 把arr[i]里面所有的,换成|
                gsub(/,/,"|",arr[i])
                # debug(arr[i])
                opt=opt arr[i]
            }else{
                break
            }
        }
        if(match(text, / +[a-z]/)){
            desc = substr(text, RSTART)
            sub(/^[ \t]+/, "",desc)
        }
        opt=opt "\\\": \\\""desc"\\\",\""
        # opt=opt "\\\": null,\""
        return
    }

    if(text ~ /[Commands]/){
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
            # debug(str)
        }
        if(match(text, / +[A-Z]/)){
            sub_desc = substr(text, RSTART)
            sub(/^[ \t]+/, "",sub_desc)
            # debug(sub_desc)
        }
        # split(text,arrcom," ")
        split(str,arrcom," ")
        for(i in arrcom){
            gsub(/,/, "|", arrcom[i])
            if(arrcom[i] == "filter-branch" || arrcom[i] == "clone" || arrcom[i] == "range-diff" || arrcom[i] == "http-backend"){
                break
            }else{
                opt=opt "\nprintf \""space"%s\\n\"  \"\\\""
                opt=opt arrcom[i]
                opt=opt "\\\": $(indent=" indent+1 " get_deep " CUR_CMD " " arrcom[1] ")"
                opt=opt "\\\"#desc\\\": \\\""sub_desc"\\\"\"\"\n"space"}\,\""
            }
            # debug(opt)
            # debug(sub_desc)
        }
        return
    }
}
{
    text=$0
    get_json(text)
}

END{
    opt = "printf \"{\\n\"" opt "\nprintf \"" space "%s\\n\" "
    print opt
    text=""
    IS_COMMANDS=false
    opt=""
}