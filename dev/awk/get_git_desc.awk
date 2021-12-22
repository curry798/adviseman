BEGIN{
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
    sub(/^[ \t]+/, "",text)
    gsub(/\[.*\]/, "", text)
    gsub(/<.*>/, "", text)
    gsub("`","\\`",text)
    gsub(/"/, "\\\"", text)
    if (text ~ /^-/){
        split(text,arr," ")
        opt=opt "\nprintf \""space"%s\\n\"  \"\\\""
        for (i in arr){
            gsub(/[[:blank:]]*/,"",arr[i])
            if (arr[i] ~ /^-/){
                gsub(/,/,"|",arr[i])
                opt=opt arr[i]
            }else{
                break
            }
        }
        if(match(text, / +[a-z]/)){
            desc = substr(text, RSTART)
            sub(/^[ \t]+/, "--- ",desc)
        }
        opt=opt "\\\": \\\""desc"\\\",\""
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
        if(match(text, / +[A-Z]/)){
            str = substr(text, 1, RSTART)
        }
        if(match(text, / +[A-Z]/)){
            sub_desc = substr(text, RSTART)
            sub(/^[ \t]+/, "",sub_desc)
        }
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