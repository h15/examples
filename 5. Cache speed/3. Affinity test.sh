#!/bin/bash

#
#	Different masks
#
./2.\ Threads\ and\ counters >> /dev/null &
pid=$!
mask=1
#	How much cpus on this host?
cpus=$(grep 'physical id' /proc/cpuinfo | uniq | wc -l)
#	Maximal mask's value + 1
let "max = 2^cpus"

while [ -d /proc/$pid ]
do
	taskset -p $mask $pid
	let "mask++"
	
	if [[ "$mask" -eq "$max" ]]
	then
		mask=1
	fi
done

echo "Different:	$SECONDS" > result_3.txt

#
#	Constant mask
#
./2.\ Threads\ and\ counters >> /dev/null &
pid=$!
mask=1

while [ -d /proc/$pid ]
do
        taskset -p $mask $pid
done

echo "Constant:	$SECONDS" >> result_3.txt
