#!/bin/bash
# memory.sh - Memory usage stats
#
# Copyright 2010 Frode Petterson. All rights reserved.
# See README.rdoc for license. 

rrdtool=/usr/bin/rrdtool
db=/var/lib/rrd/memory.rrd
img=/var/www/stats

if [ ! -e $db ]
then 
	$rrdtool create $db \
	DS:usage:GAUGE:600:0:50000000000 \
	RRA:AVERAGE:0.5:1:576 \
	RRA:AVERAGE:0.5:6:672 \
	RRA:AVERAGE:0.5:24:732 \
	RRA:AVERAGE:0.5:144:1460
fi

$rrdtool update $db -t usage N:`free -b |grep cache:|cut -d":" -f2|awk '{print $1}'`

for period in day week month year
do
	$rrdtool graph $img/memory-$period.png -s -1$period \
	-t "Memory usage the last $period" -z \
	-c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
	-c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
	-c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 134 -w 543 -l 0 -a PNG -v "B" \
	DEF:usage=$db:usage:AVERAGE \
	VDEF:min=usage,MINIMUM \
        VDEF:max=usage,MAXIMUM \
        VDEF:avg=usage,AVERAGE \
        VDEF:lst=usage,LAST \
	"COMMENT: \l" \
	"COMMENT:               " \
	"COMMENT:Minimum    " \
	"COMMENT:Maximum    " \
	"COMMENT:Average    " \
	"COMMENT:Current    \l" \
	"COMMENT:   " \
	"AREA:usage#EDA362:Usage  " \
	"LINE1:usage#F47200" \
	"GPRINT:min:%5.1lf %sB   " \
	"GPRINT:max:%5.1lf %sB   " \
	"GPRINT:avg:%5.1lf %sB   " \
	"GPRINT:lst:%5.1lf %sB   \l" > /dev/null
done
