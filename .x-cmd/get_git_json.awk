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
    gsub(/\[.*\]/, "", text)
    gsub(/<.*>/, "", text)
    # debug(text)
    # /^-/ 匹配行首字母是-的
    # ~ 匹配正则
    if (text ~ /^-/){
        # 把text里面的内容用" "拆分，结果放到arr数组里面
        split(text,arr," ")
        # debug(text)
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
        split(text,arrcom," ")
        if(arrcom[1] == "filter-branch" || arrcom[1] == "help" || arrcom[1] == "daemon" || arrcom[1] == "http-backend" || arrcom[1] == "mailinfo" || arrcom[1] == "restore" || arrcom[1] == "cherry-pick" || arrcom[1] == "fetch" || arrcom[1] == "pull" || arrcom[1] == "push" || arrcom[1] == "revert" || arrcom[1] == "switch" || arrcom[1] == "tag" || arrcom[1] == "fast-export" || arrcom[1] == "prune" || arrcom[1] == "repack" || arrcom[1] == "pack-objects" || arrcom[1] == "read-tree" || arrcom[1] == "send-pack"){
            opt=opt "\nprintf \""space"%s\\n\" \"\\\"" arrcom[1] "\\\": \"null\",\""
        }else if(arrcom[1] == "or:" || arrcom[1] == "initialize" || arrcom[1] == "directory" || arrcom[1] == "reference" || arrcom[1] == "checkout" || arrcom[1] == "path" || arrcom[1] == "create" || arrcom[1] == "deepen" || arrcom[1] == "separate" || arrcom[1] == "set" || arrcom[1] == "option" || arrcom[1] == "ignore" || arrcom[1] == "choose" || arrcom[1] == "use" || arrcom[1] == "equivalent" || arrcom[1] == "moved" || arrcom[1] == "how" || arrcom[1] == "generate" || arrcom[1] == "output" || arrcom[1] == "synonym" || arrcom[1] == "highlight" || arrcom[1] == "show" || arrcom[1] == "prepend" || arrcom[1] == "specify" || arrcom[1] == "break" || arrcom[1] == "detect" || arrcom[1] == "omit" || arrcom[1] == "when" || arrcom[1] == "hide" || arrcom[1] == "treat" || arrcom[1] == "look" || arrcom[1] == "select"|| arrcom[1] == "new" || arrcom[1] == "do" || arrcom[1] == "read" ){
            opt=opt ""
        }
        else{
            opt=opt "\nprintf \""space"%s\\n\" \"\\\"" arrcom[1] "\\\": $(indent=" indent+1 " get_deep " CUR_CMD " " arrcom[1] "),\""
        }
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
    # opt = "printf \"{\\n\"" opt "\nprintf \"" space "%s\\n\" \"}\""
    # print opt
    text=""
    IS_COMMANDS=false
    opt=""
}