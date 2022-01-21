#!/bin/sh -e
##---------------------------------------------------------------------------
##---------------------------------------------------------------------------
## NCEP EMC GLOBAL MODEL VERIFICATION
##
## CONTRIBUTORS: Mallory Row, mallory.row@noaa.gov, NOAA/NWS/NCEP/EMC-VPPGB
## PURPOSE: Set up environment based on user configurations
##---------------------------------------------------------------------------
##---------------------------------------------------------------------------

echo "BEGIN: set_up_verif_global.sh"

export NET="verif_global"
export RUN_ENVIR="emc"
export envir="dev"

## Create output directory and set output related environment variables
if [ -d "$OUTPUTROOT" ] ; then
   echo "OUTPUTROOT ($OUTPUTROOT) ALREADY EXISTS"
   echo "OVERRIDE CURRENT OUTPUTROOT? [yes/no]"
   read override
   case "$override" in
       yes)
           echo "Removing current OUTPUTROOT and making new directory"
           rm -r $OUTPUTROOT
           mkdir -p $OUTPUTROOT
           ;;
       no)
           echo "Please set new OUTPUTROOT"
           exit
           ;;
       *)
           echo "$override is not a valid choice, please choose [yes or no]"
           exit
           ;;
   esac
else
   mkdir -p ${OUTPUTROOT}
fi

echo "Output will be in: $OUTPUTROOT"
export COMROOT="$OUTPUTROOT/com"
export NWGESROOT="$OUTPUTROOT/nwges"
export DCOMROOT="$OUTPUTROOT/dcom"
export PCOMROOT="$OUTPUTROOT/pcom"
export DATAROOT="$OUTPUTROOT/tmpnw${envir}"
export job=${job:-$LSB_JOBNAME}
export jobid=${jobid:-$$}
export DATA=${DATAROOT}/$NET.$jobid
mkdir -p $COMROOT $NWGESROOT $DCOMROOT $PCOMROOT $DATAROOT $DATA
mkdir -p $COMROOT/$NET/$envir
mkdir -p $COMROOT/logs/jlogfiles
mkdir -p $COMROOT/output/$envir/today
mkdir -p $COMROOT/output/$envir/$(date +%Y%m%d)
export DCOM=${DCOM:-$DCOMROOT/$NET}
export PCOM=${PCOM:-$PCOMROOT/$NET}
export GESIN=${GESIN:-$GESROOT/$envir}
export GESOUT=${GESOUT:-$GESROOT/$envir}
mkdir -p $DCOM $PCOM
cd $DATA
echo

## Get machine, set environment variable 'machine', and check that it is a supported machine
python $HOMEverif_global/ush/get_machine.py
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

## Load modules, set paths to MET and METplus, and some executables
. $HOMEverif_global/ush/load_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status
[[ $status -eq 0 ]] && echo "Succesfully loaded modules"
echo

## Set paths for verif_global, MET, and METplus
export HOMEverif_global=$HOMEverif_global
export PARMverif_global=$HOMEverif_global/parm
export USHverif_global=$HOMEverif_global/ush
export UTILverif_global=$HOMEverif_global/util
export EXECverif_global=$HOMEverif_global/exec
export HOMEMET=$HOMEMET
export HOMEMETplus=$HOMEMETplus
export PARMMETplus=$HOMEMETplus/parm
export USHMETplus=$HOMEMETplus/ush
export PATH="${USHMETplus}:${PATH}"
export PYTHONPATH="${USHMETplus}:${PYTHONPATH}"

## Set machine specific fix directory
if [ $machine = "HERA" ]; then
    export FIXverif_global="/scratch1/NCEPDEV/global/glopara/fix/fix_verif"
elif [ $machine = "ORION" ]; then
    export FIXverif_global="/work/noaa/global/glopara/fix/fix_verif"
elif [ $machine = "WCOSS_C" ] ; then
    export FIXverif_global="/gpfs/hps3/emc/global/noscrub/emc.glopara/git/fv3gfs/fix/fix_verif"
elif [ $machine = "WCOSS_DELL_P3" ]; then
    export FIXverif_global="/gpfs/dell2/emc/modeling/noscrub/emc.glopara/git/fv3gfs/fix/fix_verif"
elif [ $machine = "S4" ]; then
    export FIXverif_global="/data/prod/glopara/fix/fix_verif"
elif [ $machine = "JET" ]; then
    export FIXverif_global="/lfs4/HFIP/hfv3gfs/glopara/git/fv3gfs/fix/fix_verif"
fi

## Set machine specific account, queues, and run settings
if [ $machine = "HERA" ]; then
    export ACCOUNT="fv3-cpu"
    export QUEUE="batch"
    export QUEUESHARED="batch"
    export QUEUESERV="service"
    export PARTITION_BATCH=""
    export nproc="40"
    export MPMD="YES"
elif [ $machine = "ORION" ]; then
    export ACCOUNT="fv3-cpu"
    export QUEUE="batch"
    export QUEUESHARED="batch"
    export QUEUESERV="service"
    export PARTITION_BATCH="orion"
    export nproc="40"
    export MPMD="YES"
elif [ $machine = "WCOSS_C" -o $machine = "WCOSS_DELL_P3" ]; then
    export ACCOUNT="GFS-DEV"
    export QUEUE="dev"
    export QUEUESHARED="dev_shared"
    export QUEUESERV="dev_transfer"
    export PARTITION_BATCH=""
    if [ $machine = "WCOSS_C" ]; then
        export nproc="24"
    elif [ $machine = "WCOSS_DELL_P3" ]; then
        export nproc="28"
    fi
    export MPMD="YES"
elif [ $machine = "S4" ]; then
    export ACCOUNT="star"
    export QUEUE="s4"
    export QUEUESHARED="s4"
    export QUEUESERV="service"
    export PARTITION_BATCH="s4"
    export nproc="32"
    export MPMD="YES"
elif [ $machine = "JET" ]; then
#    export ACCOUNT="hfv3gfs"
    export ACCOUNT="hwrfv3"
    export QUEUE="batch"
    export QUEUESHARED="batch"
    export QUEUESERV="service"
    export PARTITION_BATCH="xjet"
    export nproc="10"
    export MPMD="YES"
fi

## Set machine and user specific directories
if [ $machine = "HERA" ]; then
    export NWROOT="/scratch1/NCEPDEV/global/glopara/nwpara"
    export HOMEDIR="/scratch1/NCEPDEV/global/$USER"
    export STMP="/scratch1/NCEPDEV/stmp2/$USER"
    export PTMP="/scratch1/NCEPDEV/stmp4/$USER"
    export NOSCRUB="/scratch1/NCEPDEV/global/$USER"
    export global_archive="/scratch1/NCEPDEV/global/Mallory.Row/archive"
    export prepbufr_arch_dir="/scratch1/NCEPDEV/global/Mallory.Row/prepbufr"
    export obdata_dir="/scratch1/NCEPDEV/global/Mallory.Row/obdata"
    export ccpa_24hr_arch_dir="/scratch1/NCEPDEV/global/Mallory.Row/obdata/ccpa_accum24hr"
    export METviewer_AWS_scripts_dir="/scratch1/NCEPDEV/global/Mallory.Row/VRFY/METviewer_AWS"
elif [ $machine = "ORION" ]; then
    export NWROOT=${NWROOT:-"/work/noaa/global/glopara/nwpara"}
    export HOMEDIR="/work/noaa/nems/$USER"
    export STMP="/work/noaa/stmp/$USER"
    export PTMP="/work/noaa/stmp/$USER"
    export NOSCRUB="/work/noaa/nems/$USER"
    export global_archive="/work/noaa/ovp/mrow/archive"
    export prepbufr_arch_dir="/work/noaa/ovp/mrow/prepbufr"
    export obdata_dir="/work/noaa/ovp/mrow/obdata"
    export ccpa_24hr_arch_dir="/work/noaa/ovp/mrow/obdata/ccpa_accum24hr"
    export METviewer_AWS_scripts_dir="/work/noaa/ovp/mrow/VRFY/METviewer_AWS"
elif [ $machine = "WCOSS_C" ]; then
    export NWROOT=${NWROOT:-"/gpfs/hps/nco/ops/nwprod"}
    export HOMEDIR="/gpfs/hps3/emc/global/noscrub/$USER"
    export STMP="/gpfs/hps2/stmp/$USER"
    export PTMP="/gpfs/hps2/ptmp/$USER"
    export NOSCRUB="/gpfs/hps3/emc/global/noscrub/$USER"
    export global_archive="/gpfs/dell2/emc/verification/noscrub/emc.verif/global/archive"
    export prepbufr_arch_dir="/gpfs/dell2/emc/verification/noscrub/emc.verif/global/archive/prepbufr"
    export obdata_dir="/gpfs/dell2/emc/verification/noscrub/emc.verif/global/archive"
    export ccpa_24hr_arch_dir="/gpfs/dell2/emc/verification/noscrub/emc.verif/global/archive/ccpa_accum24hr"
    export METviewer_AWS_scripts_dir="/gpfs/dell2/emc/verification/noscrub/emc.metplus/METviewer_AWS"
elif [ $machine = "WCOSS_DELL_P3" ]; then
    export NWROOT=${NWROOT:-"/gpfs/dell1/nco/ops/nwprod"}
    export HOMEDIR="/gpfs/dell2/emc/modeling/noscrub/$USER"
    export STMP="/gpfs/dell3/stmp/$USER"
    export PTMP="/gpfs/dell3/ptmp/$USER"
    export NOSCRUB="/gpfs/dell2/emc/modeling/noscrub/$USER"
    export global_archive="/gpfs/dell2/emc/verification/noscrub/emc.verif/global/archive"
    export prepbufr_arch_dir="/gpfs/dell2/emc/verification/noscrub/emc.verif/global/archive/prepbufr"
    export obdata_dir="/gpfs/dell2/emc/verification/noscrub/emc.verif/global/archive"
    export ccpa_24hr_arch_dir="/gpfs/dell2/emc/verification/noscrub/emc.verif/global/archive/ccpa_accum24hr"
    export METviewer_AWS_scripts_dir="/gpfs/dell2/emc/verification/noscrub/emc.metplus/METviewer_AWS"
elif [ $machine = "S4" ]; then
    export NWROOT=${NWROOT:-"/data/prod/glopara/nwpara"}
    export HOMEDIR="/data/users/$USER"
    export STMP="/scratch/short/users/$USER"
    export PTMP="/scratch/users/$USER"
    export NOSCRUB="/data/users/$USER"
    export global_archive="/data/prod/glopara/MET_data/archive"
    export prepbufr_arch_dir="/data/prod/glopara/MET_data/prepbufr"
    export obdata_dir="/data/prod/glopara/MET_data/obdata"
    export ccpa_24hr_arch_dir="/data/prod/glopara/MET_data/obdata/ccpa_accum24hr"
    export METviewer_AWS_scripts_dir="/data/prod/glopara/MET_data/METviewer_AWS"
elif [ $machine = "JET" ]; then
    export NWROOT=${NWROOT:-"/lfs4/HFIP/hfv3gfs/glopara/nwpara"}
    export HOMEDIR="/lfs4/HFIP/hfv3gfs/$USER"
    export STMP="/lfs4/HFIP/hfv3gfs/$USER/stmp"
    export PTMP="lfs4/HFIP/hfv3gfs/$USER/ptmp"
    export NOSCRUB="$HOMEDIR"
    export global_archive="/lfs4/HFIP/hfv3gfs/Mallory.Row/archive"
    export prepbufr_arch_dir="/lfs4/HFIP/hfv3gfs/Mallory.Row/prepbufr"
    export obdata_dir="/lfs4/HFIP/hfv3gfs/Mallory.Row/obdata"
    export ccpa_24hr_arch_dir="/lfs4/HFIP/hfv3gfs/Mallory.Row/obdata/ccpa_accum24hr"
    export METviewer_AWS_scripts_dir="/lfs4/HFIP/hfv3gfs/Mallory.Row/VRFY/METviewer_AWS"
fi

## Set operational directories
export prepbufr_prod_upper_air_dir="/gpfs/dell1/nco/ops/com/gfs/prod"
export prepbufr_prod_conus_sfc_dir="/gpfs/dell1/nco/ops/com/nam/prod"
export ccpa_24hr_prod_dir="/gpfs/dell1/nco/ops/com/verf/prod"
#export nhc_atcfnoaa_bdeck_dir="/gpfs/dell2/nhc/noscrub/data/atcf-noaa/btk"
#export nhc_atcfnoaa_adeck_dir="/gpfs/dell2/nhc/noscrub/data/atcf-noaa/aid_nws"
#export nhc_atcfnoaa_bdeck_dir="/gpfs/dell2/emc/modeling/noscrub/Jiayi.Peng/atcf-noaa/btk"
#export nhc_atcfnoaa_adeck_dir="/gpfs/dell2/emc/modeling/noscrub/Jiayi.Peng/atcf-noaa/aid_nws"
export nhc_atcfnoaa_bdeck_dir="/lfs4/HFIP/hwrf-data/hwrf-input/abdeck/btk"
export nhc_atcfnoaa_adeck_dir="/lfs4/HFIP/hwrf-data/hwrf-input/abdeck/aid_nws"

export nhc_atcfnavy_bdeck_dir="/gpfs/dell2/nhc/noscrub/data/atcf-navy/btk"
export nhc_atcfnavy_adeck_dir="/gpfs/dell2/nhc/noscrub/data/atcf-navy/aid"

## Set online and FTP sites
export nhc_atcf_bdeck_ftp="ftp://ftp.nhc.noaa.gov/atcf/btk/"
export nhc_atcf_adeck_ftp="ftp://ftp.nhc.noaa.gov/atcf/aid_public/"
export nhc_atfc_arch_ftp="ftp://ftp.nhc.noaa.gov/atcf/archive/"
export navy_atcf_bdeck_ftp="https://www.metoc.navy.mil/jtwc/products/best-tracks/"
export iabp_ftp="http://iabp.apl.washington.edu/Data_Products/Daily_Full_Res_Data"
export ghrsst_ncei_avhrr_anl_ftp="https://podaac-opendap.jpl.nasa.gov/opendap/allData/ghrsst/data/GDS2/L4/GLOB/NCEI/AVHRR_OI/v2.1"
export ghrsst_ospo_geopolar_anl_ftp="https://podaac-opendap.jpl.nasa.gov/opendap/hyrax/allData/ghrsst/data/GDS2/L4/GLOB/OSPO/Geo_Polar_Blended/v1"

echo "END: set_up_verif_global.sh"
