#!/bin/sh
# This script is to run the EMC-verif_global package 
# HOW TO USE: run_EMC_verif_oneCase.sh AL052021 ELSA 20210630 20210710
# 1st arg: TC case, AL: basin, 05: TC number; 2021: year
# 2nd arg: TC name
# 3rd arg: TC start date in yyyymmdd format
# 4th arg: TC end date in yyyymmdd format

# USERS NEED TO MODIFY:
# OUTPUTROOT: it is defined in parm/config/config.vrfy.tc
# INTPUT a/b-deck: these two directories are defined in ush/set_up_verif_global.sh
# account info: it is defined in ush/set_up_verif_global.sh

# ---------------------------------------------------------------------------------- 
export HOMEverif_global=`eval "cd ../;pwd"`  # Home base of verif_global
export OUTPUTDIR="/mnt/lfs4/HFIP/hwrfv3/Yan.Jin/ptmp/veri4TC/"

export nhc_atcfnoaa_adeck_dir="/lfs4/HFIP/hwrf-data/hwrf-input/abdeck/aid_nws"
export nhc_atcfnoaa_bdeck_dir="/lfs4/HFIP/hwrf-data/hwrf-input/abdeck/btk"

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

#modify config file
echo "modify config file"
[ -e config.vrfy.tcTmp ] && rm config.vrfy.tcTmp
cp $HOMEverif_global/parm/config/config.vrfy.tc config.vrfy.tcTmp
sed -i 's#start_date="20210101"#start_date="'$tcBeginTime'"#g' config.vrfy.tcTmp
sed -i 's#end_date="20211231"#end_date="'$tcEndTime'"#g' config.vrfy.tcTmp
sed -i 's#tropcyc_storm_list="AL_2021_ALLNAMED"#tropcyc_storm_list="'$tcCase'"#g' config.vrfy.tcTmp
sed -i 's#OUTPUTROOT="/mnt/lfs4/HFIP/hwrfv3/Yan.Jin/ptmp/veri4TC/$now"#OUTPUTROOT="'$OUTPUTDIR'$now"#g' config.vrfy.tcTmp

#modify set_up_verif_global.sh
echo "modify a/b-deck data file"
sed -i 's#nhc_atcfnoaa_adeck_dir="/lfs4/HFIP/hwrf-data/hwrf-input/abdeck/aid_nws"#nhc_atcfnoaa_adeck_dir="'$nhc_atcfnoaa_adeck_dir'"#g' $HOMEverif_global/ush/set_up_verif_global.sh
sed -i 's#nhc_atcfnoaa_bdeck_dir="/lfs4/HFIP/hwrf-data/hwrf-input/abdeck/btk"#nhc_atcfnoaa_bdeck_dir="'$nhc_atcfnoaa_bdeck_dir'"#g' $HOMEverif_global/ush/set_up_verif_global.sh

$HOMEverif_global/ush/run_verif_global.sh config.vrfy.tcTmp


