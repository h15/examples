#!/bin/bash

#
#   Make actual hash
#
function read_fs {
    for filename in `find "$1" -type f | sort`
    do
        filename=`readlink -f "$filename"`
        
        size=`stat -c "%s" "$filename"`
        
        md5=`md5sum "$filename"`
        md5=${md5:0:32}
        
        md5_hash_current["$md5-$size"]+="$filename$n"
    done
}

#
#   Write actual hash into file $dest
#
function write_file {
    echo -n > $dest

    for key in ${!md5_hash_current[@]}
    do
        echo "$key$n${md5_hash_current[$key]}" >> $dest
    done
}

#
#   Read hash file into md5_hash_file (associative array)
#
function read_hash_from_file {
    isNewCell=1
    key=''

    exec 9<$dest

    while read -u9 line
    do
        if [[ $isNewCell -eq 1 ]]
        then
            key=$line
            isNewCell=0
            continue
        fi
        
        if [[ ${#line} -eq 0 ]]
        then
            isNewCell=1
            continue
        fi
        
        md5_hash_file["$key"]+="$line$n"
    done
}

#
#   diff md5_hash_file and md5_hash_current
#
function check_hashes {
    isChanged=0
    
    # No white space here!
    SAVE_IFS=$IFS
    IFS=$'\n'

    for key in ${!md5_hash_file[@]}
    do
        for line in ${md5_hash_file[$key]}
        do
            # find substring $line in ${md5_hash_current[$key]}
            echo ${md5_hash_current[$key]} | grep $line >/dev/null 2>&1
            if [ "$?" != "0" ]
            then
                echo ">>> $line"
                isChanged=1
            fi
        done
    done
    
    IFS=$SAVE_IFS
    
    if [ $isChanged = 0 ]
    then
        echo ">>> No files changed."
    fi
}

#
#   For debug
#
function print_hash {
    for key in ${!md5_hash_file[@]}
    do
        echo "$key$n${md5_hash_file[$key]}"
    done
}

#
#   Main
#

declare -A md5_hash_file
declare -A md5_hash_current

n=$'\n'

option=$1
shift
dest=$1
shift

case $option in
    '-make')
        echo '[!] Reading file system...'; read_fs $*
        echo '[!] Write dump into file.' ; write_file
        echo '[+] Done!'
        ;;
    '-check')
        echo '[!] Reading dump file...'  ; read_hash_from_file
        echo '[!] Reading file system...'; read_fs $*
        echo '[!] Compare dump with actual state.'; check_hashes
        echo '[+] Done!'
        ;;
    *)
        echo $"[!] Usage: $0 {-make|-check} hash_file [path1] [pathN]"
        exit 1
esac
