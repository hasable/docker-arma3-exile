#!/bin/sh

for url in "$@" 
do      
	wget --timeout=2 --tries=1 --spider ${url} > /dev/null 2>&1
	if [ $? = 0 ]
	then
		echo ${url} 
		exit 0
	fi
done

echo "No valid URL found"
exit 1
