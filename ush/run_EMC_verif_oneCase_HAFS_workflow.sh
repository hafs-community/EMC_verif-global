#!/bin/sh
basin="AL"
tcYear="2021"
#nTCs=21
#nmodels=4
#let nprocesses=$nTCs*$nmodels
#echo $nprocesses
#nodes=8

tcId="AL052021"
tcName="ELSA"
tcBeginTime="20210630"
tcEndTime="20210710"


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

## configs setting. can be found in parm/config/conf.vrfy
# Map the global workflow environment variables to EMC_verif-global variables
export RUN_TROPCYC=${RUN_TROPCYC:-"YES"}
export RUN_GRID2GRID_STEP1==${RUN_GRID2GRID_STEP1:-"NO"}
export RUN_GRID2GRID_STEP2=${RUN_GRID2GRID_STEP2:-"NO"}
export RUN_GRID2OBS_STEP1=${RUN_GRID2OBS_STEP1:-"NO"}
export RUN_GRID2OBS_STEP2=${RUN_GRID2OBS_STEP2:-"NO"}
export RUN_PRECIP_STEP1=${RUN_PRECIP_STEP1:-"NO"}
export RUN_PRECIP_STEP2=${RUN_PRECIP_STEP2:-"NO"}
export RUN_SATELLITE_STEP1=${RUN_SATELLITE_STEP1:-"NO"}
export RUN_SATELLITE_STEP2=${RUN_SATELLITE_STEP2:-"NO"}
export RUN_FIT2OBS_PLOTS=${RUN_FIT2OBS_PLOTS:-"NO"}


#!!!check
#export HOMEverif_global=${HOMEverif_global:-${HOMEgfs}/sorc/verif-global.fd}
export HOMEverif_global=`eval "cd ../;pwd"`  # Home base of verif_global

#input data setting
export model_list=${model_list:-"gfs hwrf hmon ctcx"}
export model_dir_list=${model_stat_dir:-"/gpfs/dell2/emc/modeling/noscrub/emc.glopara /gpfs/dell2/emc/verification/noscrub/emc.verif /gpfs/dell2/emc/verification/noscrub/emc.verif /gpfs/dell2/emc/verification/noscrub/emc.verif"}
export model_stat_dir_list=${model_stat_dir_list:-"/gpfs/dell2/emc/verification/noscrub /gpfs/dell2/emc/verification/noscrub /gpfs/dell2/emc/verification/noscrub /gpfs/dell2/emc/verification/noscrub"}
export model_file_format_list=${model_file_format_list:-"pgbf{lead?fmt=%2H}.gfs.{init?fmt=%Y%m%d%H} pgbf{lead?fmt=%2H}.hwrf.{init?fmt=%Y%m%d%H}.grib2 pgbf{lead?fmt=%2H}.hmon.{init?fmt=%Y%m%d%H}.grib2 pgbf{lead?fmt=%2H}.ctcx.{init?fmt=%Y%m%d%H}.grib2"}
export model_data_run_hpss=${model_data_run_hpss:-"NO"}
export model_hpss_dir_list=${model_hpss_dir_list:-"/NCEPPROD/hpssprod/runhistory /NCEPDEV/emc-global/5year/emc.glopara /NCEPDEV/emc-global/5year/emc.glopara /NCEPDEV/emc-global/5year/emc.glopara"}
export hpss_walltime=${hpss_walltime:-"20"}

## OUTPUT DATA SETTINGS
export now=$(date +"%m-%d-%Y-%T")
echo "$now"
export OUTPUTROOT=${OUTPUTROOT:-"/mnt/lfs4/HFIP/hwrfv3/Yan.Jin/emc_verif_hafsi/$now"}

## DATE SETTINGS
#export start_date="${VDATE:-$(echo $($NDATE -${VRFYBACK_HRS} $CDATE) | cut -c1-8)}"
#export end_date="${VDATE:-$(echo $($NDATE -${VRFYBACK_HRS} $CDATE) | cut -c1-8)}"
#export make_met_data_by=${make_met_data_by:-VALID}
export start_date=${start_date:-$tcBeginTime}
export end_date=${end_date:-$tcEndTime}
export make_met_data_by=${make_met_data_by:-"VALID"}
export plot_by=${plot_by:-"VALID"}

## WEB SETTINGS
export SEND2WEB="NO"
export webhost="emcrzdm.ncep.noaa.gov"
export webhostid="$USER"
export webdir="/home/people/emc/www/htdocs/gmb/${webhostid}/METplus/TEST"
export img_quality="low"

## DATA DIRECTIVE SETTINGS
export SENDARCH=${SENDARCH:-"NO"}
export SENDMETVIEWER=${SENDMETVIEWER:-"NO"}
export KEEPDATA=${KEEPDATA:-"YES"}
export SENDECF=${SENDECF:-"NO"}
export SENDCOM=${SENDCOM:-"NO"}
export SENDDBN=${SENDDBN:-"NO"}
export SENDDBN_NTC=${SENDDBN_NTC:-"NO"}

## METPLUS SETTINGS
export MET_version=${MET_version:-"9.1"}
export METplus_version=${METplus_version:-"3.1"}
export METplus_verbosity=${METplus_verbosity:-"INFO"}
export MET_verbosity=${MET_verbosity:-"2"}
export log_MET_output_to_METplus=${log_MET_output_to_METplus:-"yes"}

#TROPCYC 
export tropcyc_model_plot_name_list=${tropcyc_model_plot_name_list:-"GFS HWRF HMON CTCX"}
export tropcyc_model_atcf_name_list=${tropcyc_model_atcf_name_list:-"AVNO HWRF HMON CTCX"}
export tropcyc_storm_list=${tropcyc_storm_list:-"$tcCase"}
export tropcyc_fcyc_list=${tropcyc_fcyc_list:-"00 06 12 18"}
export tropcyc_vhr_list=${tropcyc_vhr_list:-"00 06 12 18"}
export tropcyc_fhr_min=${tropcyc_fhr_min:-"00"}
export tropcyc_fhr_max=${tropcyc_fhr_max:-"120"}
export tropcyc_model_file_format_list=${tropcyc_model_file_format_list:-"ADECK ADECK ADECK ADECK"}
export tropcyc_stat_list=${tropcyc_stat_list:-"AMAX_WIND-BMAX_WIND ABS(AMAX_WIND-BMAX_WIND) ALTK_ERR CRTK_ERR ABS(TK_ERR)"}
export tropcyc_init_storm_level_list=${tropcyc_init_storm_level_list:-"SD SS TD TS HU"}
export tropcyc_valid_storm_level_list=${tropcyc_valid_storm_level_list:-"SD SS TD TS HU"}
export tropcyc_plot_CI_bars=${tropcyc_plot_CI_bars:-"NO"}
export tropcyc_model_type=${tropcyc_model_type:-"regional"}


##output set up
##parameters can be found in set_up_verif_global.sh
echo "BEGIN: set_up_verif_global.sh"

export NET="verif_global"
export RUN_ENVIR="emc"
export envir="dev"

echo "Output will be in: $OUTPUTROOT"
export DATAROOT="$OUTPUTROOT/tmpnw${envir}"
export DATA=$OUTPUTROOT
export pid=${pid:-$$}
export jobid=${job}.${pid}
mkdir -p $DATA
cd $DATA

if [ $METPCASE = tropcyc ]; 
then
    RUN_DIR="tropcyc"
fi
if [ -d $RUN_DIR ]; 
then
    rm -r $RUN_DIR
fi

## Get machine
python $HOMEverif_global/ush/get_machine.py
echo $machine
status=$?
[[ $status -ne 0 ]] && exit $status
[[ $status -eq 0 ]] && echo "Succesfully ran get_machine.py"
echo

if [ -s config.machine ]; then
    . $DATA/config.machine
    status=$?
    [[ $status -ne 0 ]] && exit $status
    [[ $status -eq 0 ]] && echo "Succesfully sourced config.machine"
fi

if [[ "$machine" =~ ^(HERA|ORION|WCOSS_C|WCOSS_DELL_P3|S4|JET)$ ]]; then
   echo
else
    echo "ERROR: $machine is not a supported machine"
    exit 1
fi

## Load modules and set machine specific paths
. $HOMEverif_global/ush/load_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status
[[ $status -eq 0 ]] && echo "Succesfully loaded modules"
echo

## Account and queues for machines
# set_up_verif_global.sh
export ACCOUNT=${ACCOUNT:-"hwrfv3"}
export QUEUE=${QUEUE:-"batch"}
export QUEUESHARED=${QUEUE_SHARED:-"batch"}
export QUEUESERV=${QUEUE_SERVICE:-"service"}
export PARTITION_BATCH=${PARTITION_BATCH:-"xjet"}
echo $ACCOUNT
export nproc="10"
export MPMD="YES"

## Set paths for verif_global, MET, and METplus
export HOMEverif_global=$HOMEverif_global
export PARMverif_global=$HOMEverif_global/parm
export FIXverif_global="/lfs4/HFIP/hfv3gfs/glopara/git/fv3gfs/fix/fix_verif"
#export FIXverif_global=$FIXgfs/fix_verif
export USHverif_global=$HOMEverif_global/ush
export UTILverif_global=$HOMEverif_global/util
export EXECverif_global=$HOMEverif_global/exec
export HOMEMET=$HOMEMET
export HOMEMETplus=$HOMEMETplus
export PARMMETplus=$HOMEMETplus/parm
export USHMETplus=$HOMEMETplus/ush
export PATH="${USHMETplus}:${PATH}"
export PYTHONPATH="${USHMETplus}:${PYTHONPATH}"



if [ $machine = "HERA" ]; then
    export global_archive="/scratch1/NCEPDEV/global/Mallory.Row/archive"
    export prepbufr_arch_dir="/scratch1/NCEPDEV/global/Mallory.Row/prepbufr"
    export ccpa_24hr_arch_dir="/scratch1/NCEPDEV/global/Mallory.Row/obdata/ccpa_accum24hr"
elif [ $machine = "ORION" ]; then
    export global_archive="/work/noaa/ovp/mrow/archive"
    export prepbufr_arch_dir="/work/noaa/ovp/mrow/prepbufr"
    export ccpa_24hr_arch_dir="/work/noaa/ovp/mrow/obdata/ccpa_accum24hr"
elif [ $machine = "WCOSS_C" ]; then
    export global_archive="/gpfs/dell2/emc/verification/noscrub/emc.verif/global/archive"
    export prepbufr_arch_dir="/gpfs/dell2/emc/verification/noscrub/emc.verif/global/archive/prepbufr"
    export ccpa_24hr_arch_dir="/gpfs/dell2/emc/verification/noscrub/emc.verif/global/archive/ccpa_accum24hr"
elif [ $machine = "WCOSS_DELL_P3" ]; then
    export global_archive="/gpfs/dell2/emc/verification/noscrub/emc.verif/global/archive"
    export prepbufr_arch_dir="/gpfs/dell2/emc/verification/noscrub/emc.verif/global/archive/prepbufr"
    export ccpa_24hr_arch_dir="/gpfs/dell2/emc/verification/noscrub/emc.verif/global/archive/ccpa_accum24hr"
elif [ $machine = "S4" ]; then
    export global_archive="/data/prod/glopara/MET_data/archive"
    export prepbufr_arch_dir="/data/prod/glopara/MET_data/prepbufr"
    export ccpa_24hr_arch_dir="/data/prod/glopara/MET_data/obdata/ccpa_accum24hr"
elif [ $machine = "JET" ]; then
    export global_archive="/lfs4/HFIP/hfv3gfs/Mallory.Row/archive"
    export prepbufr_arch_dir="/lfs4/HFIP/hfv3gfs/Mallory.Row/prepbufr"
    export ccpa_24hr_arch_dir="/lfs4/HFIP/hfv3gfs/Mallory.Row/obdata/ccpa_accum24hr"
fi

## Set operational directories
export prepbufr_prod_upper_air_dir="/gpfs/dell1/nco/ops/com/gfs/prod"
export prepbufr_prod_conus_sfc_dir="/gpfs/dell1/nco/ops/com/nam/prod"
export ccpa_24hr_prod_dir="/gpfs/dell1/nco/ops/com/verf/prod"
#input a/b deck
# set_up_verif_global.sh
export nhc_atcfnoaa_adeck_dir=${nhc_atcfnoaa_adeck_dir:-"/lfs4/HFIP/hwrf-data/hwrf-input/abdeck/aid_nws"}
export nhc_atcfnoaa_bdeck_dir=${nhc_atcfnoaa_bdeck_dir:-"/lfs4/HFIP/hwrf-data/hwrf-input/abdeck/btk"}
export nhc_atcfnavy_adeck_dir=${nhc_atcfnavy_adeck_dir:-"/gpfs/dell2/nhc/noscrub/data/atcf-navy/aid"}
export nhc_atcfnavy_bdeck_dir=${nhc_atcfnavy_bdeck_dir:-"/gpfs/dell2/nhc/noscrub/data/atcf-navy/btk"}
export nhc_atcf_bdeck_ftp="ftp://ftp.nhc.noaa.gov/atcf/btk/"
export nhc_atcf_adeck_ftp="ftp://ftp.nhc.noaa.gov/atcf/aid_public/"
export nhc_atfc_arch_ftp="ftp://ftp.nhc.noaa.gov/atcf/archive/"
export navy_atcf_bdeck_ftp="https://www.metoc.navy.mil/jtwc/products/best-tracks/"

## Run METplus
echo "=============== RUNNING METPLUS ==============="
if [ $RUN_TROPCYC = YES ] ; then
    echo
    echo "===== RUNNING TROPICAL CYCLONE VERIFICATION  ====="
    echo "===== creating TC verifcation using METplus ====="
    export RUN="tropcyc"
    $HOMEverif_global/scripts/extropcyc.sh
fi

