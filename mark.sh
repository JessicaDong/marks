#! /usr/bin/bash

if [[ ! -n "$MARKDIR" ]]; then
    MARKDIR=~/.markdir
    touch $MARKDIR
fi

function mark_s_check_name {
    S_EXIT_CODE=""
        if [[ -z $@ ]]; then
                S_EXIT_CODE="The mark needs a name"
                echo $S_EXIT_CODE
        elif [[ $@ != "$(echo "$@" | sed 's/[^a-zA-Z0-9_]//g')" ]]; then
                S_EXIT_CODE="The name can only contain a-zA-Z0-9 or \
\"_\" symbol"
                echo $S_EXIT_CODE
        else
            grep "export $@" $MARKDIR > /dev/null
                if [[ $? == 0  ]]; then
                        tmphead=$(echo $1 | cut -d_ -f1)
                        [[ $tmphead = "tmp" ]] && return
                        read -p "The name are already existed, can you \
 want to override it?(Y/N)" ans
                        if [[ $ans == "n" || $ans == "N" ]]; then
                                S_EXIT_CODE="N"
                        fi
                fi
    fi
}


ffunction s {
        mark_s_check_name "$@"
        if [[ -z $S_EXIT_CODE ]]; then
                mark_append "$MARKDIR" "export $1="
                CURDIR=$(echo $PWD | sed "s#^HOME#\$HOME#g")
                echo "export $1=$CURDIR" >> $MARKDIR
        fi
}

function mark_g_check_name {
         G_EXIT_CODE=""
        if [[ -z $@ ]]; then
                G_EXIT_CODE="Null Parameter"
#               echo $G_EXIT_CODE
        elif [[ "$@" != "$(echo "$@" | sed 's/[^a-zA-Z0-9_]//g')" ]]; then
                G_EXIT_CODE="The name can only contain a-zA-Z0-9 or \"_\" symbol"
                echo $G_EXIT_CODE
        elif [[ $@ =~ M[0-9]+ ]]; then
                return
        else
            grep "export $@" $MARKDIR > /dev/null
                if [[ $? == 1  ]]; then
                                G_EXIT_CODE="The name is not existed right now"
                                echo $G_EXIT_CODE
                fi
    fi
}


function g {
        mark_g_check_name $@
        if [[ $@ =~ M[0-9]+ ]]; then
                line_num=$( echo  $@ | sed 's/M//g' )
                target=$( head -$line_num $MARKDIR | tail -1 | cut -d= -f2 )
                cd $target
        elif [[ -z $G_EXIT_CODE ]]; then
                target=$( grep "export $@=" $MARKDIR | cut -d=  -f2 )
                cd $target
        elif [[ $G_EXIT_CODE == "Null Parameter" ]]; then
                target=$( cat $MARKDIR | tail -1 | cut -d= -f2 )
                curdir=$(pwd)
                tmpname=${curdir##*/}
                s tmp_${tmpname}
                cd $target
        fi
}

function l {
        cut -d" " -f2 $MARKDIR |  \
                awk -F= 'BEGIN{printf "%-12s %s\n","MarkName",\
"MarkDirectory"} {printf "%-12s %s\n",$1,$2}'
}

function mark_append {
    if [[ -s "$1" ]]; then
        t=$(mktemp -t marks.XXXXXX) || exit 1
        trap "rm -f -- '$t'" EXIT
        sed "/$2/d" "$1" > "$t"
        mv "$t" "$1"
        rm -f -- "$t"
        trap - EXIT
    fi
}

function mark_del {
    
}
