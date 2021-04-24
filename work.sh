work(){

    awk '

    function nocomma(s){
        if (s ~ /[^,],/) {
            gsub(/,$/, "", s)
        }
        return(s)
    }

    {
        s=":"
        if ($1 ~ /^--?[^ ,]+/) {
            s=s nocomma($1) ":"
        }

        if ($2 ~ /^--?[^ ,]+/) {
            s=s nocomma($2) ":"
        }

        if ($3 ~ /^--?[^ ,]+/) {
            s=s nocomma($3) ":"
        }

        if (s != ":") print "\"" s "\": null,"
    }
    '
}
