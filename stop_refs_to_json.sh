#!/bin/bash



id=''
echo '{'

sed -ne 's/.*node id="\([^"]*\)".*/\1/p; s/.*<tag k="ref" v="\([^"]*\)".*/ref: \1/p' < xapibus_pvta.xml | while read x
do
	if [ "${x:0:5}" = 'ref: ' ]
	then
		echo "'${x:5}': '$id',"
	else
		id="$x"
	fi
done
echo 'dummy:0}'
