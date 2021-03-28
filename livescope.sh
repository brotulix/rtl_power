#!/bin/bash

powpath="/home/brotulix/source/rtl-sdr/build/src"
rtl_ds_path="/home/brotulix/source/ja450n/librtlsdr/build/src"
ts="$(date +%Y-%m-%dT%H%MZ --utc)"
bf="1M"
ef="16M"
bw="500"
ii="30s"
#rt="18m"
ss="-1"
ds="-D 2" # only hardware-modified dongle
ol="20%"
gain="50"
#ppm="15"
#filt="9"
wind="blackman-harris"
#offs="1" # only for E4000 tuner
#tee="1" # Write to stdout as well
pwd=`pwd`
tmp="/tmp/"
tmpfn="${tmp}/livescope.csv"
pid="0"

foiled="${ts}_noise_${bf}-${ef}_BW${bw}_i${ii}_e${rt}"
echo "=> ${foiled}"

rtparm="-f ${bf}:${ef}:${bw}"

if [ -z ${rt+x} ]
then
	if [ -z ${ss+x} ]
	then
		echo "- Runtime is unspecified."
	else
		echo "+ Single-shot."
		rtparm+=" ${ss}" 2>/dev/null
	fi
else
	echo "+ Applying runtime of ${rt}."
	rtparm+=" -e ${rt}" 2>/dev/null
fi

if [ -z ${filt+x} ]
then
	echo "- Filtering is unspecified."
else
	echo "+ Applying filter ${filt}."
	rtparm+=" -F ${filt}" 2>/dev/null
fi

if [ -z ${offs+x} ]
then
	echo "- No offset tuning."
else
	echo "+ Offset tuning enabled."
	rtparm+=" -O" 2>/dev/null
fi

if [ -z ${ppm+x} ]
then
	echo "- Frequency correction is unspecified."
else
	echo "+ Applying frequency correction of ${ppm} ppm."
	rtparm+=" -p ${ppm}" 2>/dev/null
fi

if [ -z ${wind+x} ]
then
	echo "- Windowing is unspecified."
else
	echo "+ Using '${wind}' windowing."
	rtparm+=" -w ${wind}" 2>/dev/null
fi

if [ -z ${ds+x} ]
then
	echo "- Direct Sampling disabled."
else
	echo "+ Enabling Direct Sampling."
	powpath="${rtl_ds_path}"
	rtparm+=" ${ds}" 2>/dev/null
fi

if [ -z ${ol+x} ]
then
	echo "- Unspecified overlap."
else
	echo "+ Using ${ol} overlap."
	rtparm+=" -c ${ol}" 2>/dev/null
fi

if [ -z ${gain+x} ]
then
	echo "- Unspecified gain."
else
	echo "+ Setting gain to ${gain} dB."
	rtparm+=" -g ${gain}" 2>/dev/null
fi

if [ -z ${ii+x} ]
then
	echo "- Unspecified integration interval."
else
	echo "+ Integration interval set to ${ii}."
	rtparm+=" -i ${ii}" 2>/dev/null
fi

echo "=> ${rtparm}"

#shotwell noise.png &
#pid=$!
#echo "Pid: ${pid}"
#exit

for i in `seq 1 8640`;
do
    # Run in background to avoid processing postponing next sample interval.
    time ${powpath}/rtl_power ${rtparm} ${tmpfn}
    cat ${tmpfn} >> ${pwd}/${foiled}.csv
    
	#kill -9 {pid}
    #shotwell ${pwd}/${foiled}.png &
    #pid=$!

done    

python heatmap.py ${pwd}/${foiled}.csv ${pwd}/${foiled}.png --ytick 5m
