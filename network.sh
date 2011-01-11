#!/bin/bash
# network.sh - Network usage stats
#
# Copyright 2010 Frode Petterson. All rights reserved.
# See README.rdoc for license. 

rrdtool=/usr/bin/rrdtool
db=/var/lib/rrd/network.rrd
img=/var/www/stats
if=eth0

if [ ! -e $db ]
then 
	$rrdtool create $db \
	DS:in:DERIVE:600:0:12500000 \
	DS:out:DERIVE:600:0:12500000 \
	RRA:AVERAGE:0.5:1:576 \
	RRA:AVERAGE:0.5:6:672 \
	RRA:AVERAGE:0.5:24:732 \
	RRA:AVERAGE:0.5:144:1460
fi

$rrdtool update $db -t in:out N:`/sbin/ifconfig $if |grep bytes|cut -d":" -f2|cut -d" " -f1`:`/sbin/ifconfig $if |grep bytes|cut -d":" -f3|cut -d" " -f1`

for period in day week month year
do
	$rrdtool graph $img/network-$period.png -s -1$period \
	-t "Network traffic the last $period" -z \
	-c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
	-c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
	-c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 134 -w 543 -l 0 -a PNG -v "B/s" \
	DEF:in=$db:in:AVERAGE \
	DEF:out=$db:out:AVERAGE \
	VDEF:minin=in,MINIMUM \
	VDEF:minout=out,MINIMUM \
	VDEF:maxin=in,MAXIMUM \
	VDEF:maxout=out,MAXIMUM \
	VDEF:avgin=in,AVERAGE \
	VDEF:avgout=out,AVERAGE \
	VDEF:lstin=in,LAST \
	VDEF:lstout=out,LAST \
	VDEF:totin=in,TOTAL \
	VDEF:totout=out,TOTAL \
	"COMMENT: \l" \
	"COMMENT:               " \
	"COMMENT:Minimum      " \
	"COMMENT:Maximum      " \
	"COMMENT:Average      " \
	"COMMENT:Current      " \
	"COMMENT:Total        \l" \
	"COMMENT:   " \
	"AREA:out#EDA362:Out  " \
	"LINE1:out#F47200" \
	"GPRINT:minout:%5.1lf %sB/s   " \
	"GPRINT:maxout:%5.1lf %sB/s   " \
	"GPRINT:avgout:%5.1lf %sB/s   " \
	"GPRINT:lstout:%5.1lf %sB/s   " \
	"GPRINT:totout:%5.1lf %sB   \l" \
	"COMMENT:   " \
	"AREA:in#8AD3F1:In   " \
	"LINE1:in#49BEEF" \
	"GPRINT:minin:%5.1lf %sB/s   " \
	"GPRINT:maxin:%5.1lf %sB/s   " \
	"GPRINT:avgin:%5.1lf %sB/s   " \
	"GPRINT:lstin:%5.1lf %sB/s   " \
	"GPRINT:totin:%5.1lf %sB   \l" > /dev/null
done
