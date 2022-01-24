#!/bin/sh
basin="AL"
tcYear="2021"
export HOMEverif_global=`eval "cd ../;pwd"`  # Home base of verif_global
WORKverif_global="$HOMEverif_global/run"
mkdir -p $WORKverif_global

cd $WORKverif_global
tcId=$1
tcName=$2
tcBeginTime=$3
tcEndTime=$4

tcNum=`echo ${tcId} | cut -c3-4`
basin=`echo ${tcId} | cut -c1-2`
tcYear=`echo ${tcId} | cut -c5-8`

#example: AL052021 ELSA 20210630 20210710

echo 'storm=' $tcName
echo 'cyc=' $tcNum
echo 'stormid=' ${tcId}

tcCase=$basin"_"$tcYear"_"$tcName
tcNameNum="_"$tcId"_"$tcName

echo "$tcNameNum, $tcCase, $tcBeginTime, $tcEndTime"
#output example: _AL052021_ELSA, AL_2021_ELSA, 20210630, 20210710


#cd ../parm/config
echo "in config/"
[ -e config.vrfy.tcTmp ] && rm config.vrfy.tcTmp
cp $HOMEverif_global/parm/config/config.vrfy.tc config.vrfy.tcTmp
echo "start to modify"
sed -i 's#start_date="20210101"#start_date="'$tcBeginTime'"#g' config.vrfy.tcTmp
sed -i 's#end_date="20211231"#end_date="'$tcEndTime'"#g' config.vrfy.tcTmp
sed -i 's#tropcyc_storm_list="AL_2021_ALLNAMED"#tropcyc_storm_list="'$tcCase'"#g' config.vrfy.tcTmp

$HOMEverif_global/ush/run_verif_global.sh config.vrfy.tcTmp


