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
            if (arr[i] ~ /^-/){
                # 把arr[i]里面所有的,换成|
                gsub(/,/,"|",arr[i])
                opt=opt arr[i]
                # debug(opt)
            }else{
                break
            }
        }
        opt=opt "\\\": null,\""
        return
    }
    if(text ~ "commands"){
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
            text = substr(text, 1, RSTART)
        }
        # 把, 变成 ,方便等下split的时候,紧挨着第二个subcommand(即build ，b)，这样到时候arrcom[1]才会是build而不是build|
        gsub(/, /, " ,", text)
        split(text,arrcom," ")
        # debug(text)
        opt=opt "\nprintf \""space"%s\\n\"  \"\\\""
        # gsub(/,/, "|", text)
        # opt=opt text
        for(i in arrcom){
            gsub(/,/, "|", arrcom[i])
            # debug(arrcom[i])
            opt=opt arrcom[i]
            # debug(opt)
        }
        opt=opt "\\\": $(indent=" indent+1 " get " CUR_CMD " " arrcom[1] "),\""
        # debug(opt)
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