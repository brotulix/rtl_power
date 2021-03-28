#!/bin/bash
powpath="/home/brotulix/source/rtl-sdr/build/src"
rtl_ds_path="/home/brotulix/source/ja450n/librtlsdr/build/src"
ts="$(date +%Y-%m-%dT%H%MZ --utc)"
bf="1M"
ef="16M"
#bf="1M"
#ef="1G"
#bw="100k"
bw="500"
#ii="60s"
ii="30s"
#rt="18m"
#rt="180s"
#rt="180m"
#rt="86370s"
ss="-1"

# 2 = HF connector on modified receiver
ds="-D 2" # only hardware-modified dongle

ol="20%"
#gain="50"
#ppm="15"
#filt="9"
wind="blackman-harris"
#offs="1" # only for E4000 tuner
#tee="1" # Write to stdout as well
pwd=`pwd`

echo "Start at  ${bf} Hz"
echo "Stop at   ${ef} Hz"
echo "Bandwidth ${bw} Hz"

foiled="${ts}_noise_${bf}-${ef}_BW${bw}_i${ii}_e${rt}"
echo "=> ${foiled}"

rtparm="-f ${bf}:${ef}:${bw}"

if [ -z ${rt+x} ]
then
	if [ -z ${ss+x} ]
	then
		echo "- Runtime is unspecified. Try stopping the run with CTRL+D?"
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



if [ -z ${tee+x} ]
then
	echo "- Not printing to stdout."
else
	echo "+ Printing samples to stdout as well using tee."
	rtparm+="- | tee -a "
fi

echo "=> ${rtparm}"

# Execute!
#rtl_power ${rtparm} ${foiled}.csv
time ${powpath}/rtl_power ${rtparm} ${pwd}/${foiled}.csv
python heatmap.py ${foiled}.csv ${foiled}.png --ytick 5m
#shotwell ${foiled}.png &
