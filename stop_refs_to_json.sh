#!/bin/bash

id=''
echo -n '{'

sed -ne 's/.*node id="\([^"]*\)".*/\1/p; s/.*<tag k="ref" v="\([^"]*\)".*/ref: \1/p' | while read x
do
	if [ "${x:0:5}" = 'ref: ' ]
	then
		echo -n "\"${x:5}\":\"$id\","
	else
		id="$x"
	fi
done
echo -n '"dummy":0}'
