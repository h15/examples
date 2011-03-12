#!/bin/bash

#
#   Make actual hash
#
function __read_fs {
    for filename in `find $1 -type f | sort`
    do
        filename=`readlink -f $filename`
        
        size=`stat -c "%s" $filename`
        
        md5=`md5sum $filename`
        md5=${md5:0:32}
        
        md5_hash_current["$md5-$size"]+="$filename$n"
    done
}

#
#   Write actual hash into file $dest
#
function __write_file {
    echo -n > $dest

    for key in ${!md5_hash_current[@]}
    do
        echo "$key$n${md5_hash_current[$key]}" >> $dest
    done
}

#
#   Read hash file into md5_hash_file (associative array)
#
function __read_hash_from_file {
    isNewCell=1
    key=''
    
    cat $dest | while read line
    do
        echo -n '.'
        if [[ $isNewCell -eq 1 ]]
        then
            key=$line
            isNewCell=0
            continue
        fi
        
        if [[ $line -eq $'' ]]
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
function __check {
    for key in ${!md5_hash_file[@]}
    do
        ${md5_hash_current[$key]} | while read line
        do
            echo $line
        done
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

#__read_hash_from_file
#exit

case $option in
    '-make')
        echo '[!] Reading file system...'; __read_fs $*
        echo '[!] Write dump into file.' ; __write_file
        echo '[+] Done!'
        ;;
    '-check')
        echo '[!] Reading dump file...'  ; __read_hash_from_file
        echo '[!] Reading file system...'; __read_fs $*
        echo '[!] Compare dump with actual state.'; __check
        echo '[+] Done!'
        ;;
    *)
        echo $"[!] Usage: $0 {-make|-check} hash_file [path1] [pathN]"
        exit 1
esac
