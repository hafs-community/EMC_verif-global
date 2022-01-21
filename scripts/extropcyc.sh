#!/bin/sh
# Program Name: tropcyc
# Author(s)/Contact(s): Mallory Row
# Abstract: Calculate and plot tropical cyclone
#           track and intensity error
# History Log:
#   11/2019: Initial version of script
#
# Usage:
#   Parameters:
#       agrument to script
#   Input Files:
#       file
#   Output Files:
#       file
#
# Condition codes:
#       0 - Normal exit
#
# User controllable options: None


set -x

export RUN_abbrev="$RUN"

# Set up directories
mkdir -p $RUN
cd $RUN

# Check machine to be sure we can get the data
#if [[ "$machine" =~ ^(HERA|ORION|WCOSS_C|S4|JET)$ ]]; then
#    echo "ERROR: Cannot run ${RUN} on ${machine}, cannot retrieve data from web in queue ${QUEUE}"
#    exit
#fi

# Check user's configuration file
python $USHverif_global/check_config.py
status=$?
[[ $status -ne 0 ]] && exit $status
[[ $status -eq 0 ]] && echo "Succesfully ran check_config.py"
echo

# Set up environment variables for initialization, valid, and forecast hours and source them
python $USHverif_global/set_init_valid_fhr_info.py
status=$?
[[ $status -ne 0 ]] && exit $status
[[ $status -eq 0 ]] && echo "Succesfully ran set_init_valid_fhr_info.py"
echo
. $DATA/$RUN/python_gen_env_vars.sh
status=$?
[[ $status -ne 0 ]] && exit $status
[[ $status -eq 0 ]] && echo "Succesfully sourced python_gen_env_vars.sh"
echo

# Link needed data files and set up model information
mkdir -p data
python $USHverif_global/get_data_files.py
status=$?
[[ $status -ne 0 ]] && exit $status
[[ $status -eq 0 ]] && echo "Succesfully ran get_data_files.py"
echo

# Create output directories for METplus
python $USHverif_global/create_METplus_output_dirs.py
status=$?
[[ $status -ne 0 ]] && exit $status
[[ $status -eq 0 ]] && echo "Succesfully ran create_METplus_output_dirs.py"
echo

# Create job scripts to run METplus for tc_pairs
export METplus_tropcyc_process="tc_pairs"
python $USHverif_global/create_METplus_job_scripts.py
status=$?
[[ $status -ne 0 ]] && exit $status
[[ $status -eq 0 ]] && echo "Succesfully ran create_METplus_job_scripts.py"

# Run METplus job scripts for tc_pairs
chmod u+x metplus_job_scripts/job*
if [ $MPMD = YES ]; then
    ncount=$(ls -l  metplus_job_scripts/poe* |wc -l)
    nc=0
    while [ $nc -lt $ncount ]; do
        nc=$((nc+1))
        poe_script=$DATA/$RUN/metplus_job_scripts/poe_jobs${nc}
        chmod 775 $poe_script
        export MP_PGMMODEL=mpmd
        export MP_CMDFILE=${poe_script}
        if [ $machine = WCOSS_C ]; then
            launcher="aprun -j 1 -n ${nproc} -N ${nproc} -d 1 cfp"
        elif [ $machine = WCOSS_DELL_P3 ]; then
            launcher="mpirun -n ${nproc} cfp"
        elif [ $machine = HERA -o $machine = ORION -o $machine = S4 -o $machine = JET ]; then
            launcher="srun --export=ALL --multi-prog"
        fi
        $launcher $MP_CMDFILE
    done
else
    ncount=$(ls -l  metplus_job_scripts/job* |wc -l)
    nc=0
    while [ $nc -lt $ncount ]; do
        nc=$((nc+1))
        sh +x $DATA/$RUN/metplus_job_scripts/job${nc}
    done
fi
export ncount_poe=$(ls -l  metplus_job_scripts/poe* |wc -l)
export ncount_job=$(ls -l  metplus_job_scripts/job* |wc -l)

# Create job scripts to run METplus for tc_stat
# and plotting scripts for individual
# storms and all storms in a given basin
export METplus_tropcyc_process="tc_stat"
python $USHverif_global/create_METplus_job_scripts.py
status=$?
[[ $status -ne 0 ]] && exit $status
[[ $status -eq 0 ]] && echo "Succesfully ran create_METplus_job_scripts.py"

# Run METplus job scripts for tc_stat
# and plotting scripts for individual
# storms and all storms in a given basin
chmod u+x metplus_job_scripts/job*
if [ $MPMD = YES ]; then
    ncount=$(ls -l  metplus_job_scripts/poe* |wc -l)
    nc=$ncount_poe
    while [ $nc -lt $ncount ]; do
        nc=$((nc+1))
        poe_script=$DATA/$RUN/metplus_job_scripts/poe_jobs${nc}
        chmod 775 $poe_script
        export MP_PGMMODEL=mpmd
        export MP_CMDFILE=${poe_script}
        if [ $machine = WCOSS_C ]; then
            launcher="aprun -j 1 -n 1 -N 1 -d 1 cfp"
        elif [ $machine = WCOSS_DELL_P3 ]; then
            launcher="mpirun -n ${nproc} cfp"
        elif [ $machine = HERA -o $machine = ORION -o $machine = S4 -o $machine = JET ]; then
            launcher="srun --export=ALL --multi-prog"
        fi
        $launcher $MP_CMDFILE
    done
else
    ncount=$(ls -l  metplus_job_scripts/job* |wc -l)
    nc=$ncount_job
    while [ $nc -lt $ncount ]; do
        nc=$((nc+1))
        sh +x $DATA/$RUN/metplus_job_scripts/job${nc}
    done
fi

# Create custom webpage template and send
# custome templates and images to web
if [ $SEND2WEB = YES ] ; then
    mkdir -p $DATA/$RUN/create_webpage_templates
    python $USHverif_global/build_webpage.py
    status=$?
    [[ $status -ne 0 ]] && exit $status
    [[ $status -eq 0 ]] && echo "Succesfully ran build_webpage.py"
    echo
else
    if [ $KEEPDATA = NO ]; then
        cd ..
        rm -rf $RUN
    fi
fi
