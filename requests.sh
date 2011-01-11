#!/bin/bash
# requests.sh - Nginx requests stats
#
# Copyright 2010 Frode Petterson. All rights reserved.
# See README.rdoc for license. 

rrdtool=/usr/bin/rrdtool
db=/var/lib/rrd/requests.rrd
img=/var/www/stats
url=http://127.0.0.1/status

if [ ! -e $db ]
then 
	$rrdtool create $db \
	DS:requests:DERIVE:600:0:50000000000 \
	RRA:AVERAGE:0.5:1:576 \
	RRA:AVERAGE:0.5:6:672 \
	RRA:AVERAGE:0.5:24:732 \
	RRA:AVERAGE:0.5:144:1460
fi

$rrdtool update $db -t requests N:`wget -qO- $url |head -3|tail -1|cut -d' ' -f4`

for period in day week month year
do
	$rrdtool graph $img/requests-$period.png -s -1$period \
	-t "Requests the last $period" -z \
	-c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
	-c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
	-c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 134 -w 543 -l 0 -a PNG -v "Requests/sec" \
	DEF:requests=$db:requests:AVERAGE \
	VDEF:min=requests,MINIMUM \
        VDEF:max=requests,MAXIMUM \
        VDEF:avg=requests,AVERAGE \
        VDEF:lst=requests,LAST \
	VDEF:tot=requests,TOTAL \
	"COMMENT: \l" \
	"COMMENT:                " \
	"COMMENT:Minimum   " \
	"COMMENT:Maximum   " \
	"COMMENT:Average   " \
	"COMMENT:Current   " \
	"COMMENT:Total     \l" \
	"COMMENT:  " \
	"AREA:requests#EDA362:Requests  " \
	"LINE1:requests#F47200" \
	"GPRINT:min:%5.1lf %s   " \
	"GPRINT:max:%5.1lf %s   " \
	"GPRINT:avg:%5.1lf %s   " \
	"GPRINT:lst:%5.1lf %s   " \
	"GPRINT:tot:%5.lf %s   \l" > /dev/null
done
