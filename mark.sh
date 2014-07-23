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
                S_EXIT_CODE="The name can only contain a-zA-Z0-9 or \"_\" symbol"
                echo $S_EXIT_CODE
        else
            grep "export $@" $MARKDIR > /dev/null
                if [[ $? == 0  ]]; then
                        read -p "The name are already existed, can you want to override it?(Y/N)" ans
                        if [[ $ans == "n" || $ans == "N" ]]; then
                                S_EXIT_CODE="N"
                        fi
                fi
    fi
}

function s {
        mark_s_check_name "$@"
        if [[ -z $S_EXIT_CODE ]]; then
                mark_append "$MARKDIR" "export $1="
                CURDIR=$(echo $PWD | sed "s#^HOME#\$HOME#g")
                echo "export $1=$CURDIR" >> $MARKDIR
        fi
}

