BEGIN{
    # 控制缩进
    space = ""
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
        opt=opt "\\\": null,\""
        return
    }
    if(text ~ "Commands:"){
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
        split(text,arrcom," ")
        gsub(/\*$/, "", arrcom[1])
        opt=opt "\nprintf \""space"%s\\n\" \"\\\"" arrcom[1] "\\\": $(indent=" indent+1 " get " CUR_CMD " " arrcom[1] "),\""
        return
    }
    
}
{
    text=$0
    get_json(text)
}

END{

    if( opt == ""){
        opt="printf \"null\""
    }else{
        opt=substr(opt,1,length(opt)-2) "\""
        opt = "printf \"{\\n\"" opt "\nprintf \"" space "%s\\n\" \"}\""
    }
    print opt
    text=""
    IS_COMMANDS=false
    opt=""
}