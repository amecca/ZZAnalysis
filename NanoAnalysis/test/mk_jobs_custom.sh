#!/bin/sh

set -e
set -u

show_help(){ cat <<EOF
Usage: ${0##*/} [-h] [-d] MODEL"
Use the Condor job directory MODEL as a template to create jobs for gg4l Powheg

    -h      show help and exit
    -d      dry-run
EOF
}

SAMPLENAME=gg4l_POWHEG
XSEC=0.00440761
BASEDIR=/eos/user/p/psalvini/MARIO_TAMI/ZZVBS_Analysis/gg4l_POWHEG_NanoAOD
NTUPLENAME=gg4l

# SAMPLENAME=ZZ4Ljj_EWK_LL
# XSEC=0.000044337
# BASEDIR=/eos/user/p/psalvini/MARIO_TAMI/ZZVBS_Analysis/ZZ4Ljj_EWK_LL_NanoAOD
# NTUPLENAME=ZZ4Ljj_EWK_LL

# SAMPLENAME=ZZ4Ljj_EWK_LT
# XSEC=0.0001531
# BASEDIR=/eos/user/p/psalvini/MARIO_TAMI/ZZVBS_Analysis/ZZ4Ljj_EWK_LT_NanoAOD
# NTUPLENAME=ZZ4Ljj_EWK_LT

# SAMPLENAME=ZZ4Ljj_EWK_TT
# XSEC=0.0003112
# BASEDIR=/eos/user/p/psalvini/MARIO_TAMI/ZZVBS_Analysis/ZZ4Ljj_EWK_TT_NanoAOD
# NTUPLENAME=ZZ4Ljj_EWK_TT

dryrun=false
OPTIND=1
while getopts "hd" opt; do
    case $opt in
        h)
	    show_help
            exit 0 ;;
        d)
	    dryrun=true ;;
        *)
	    show_help >&2
            exit 1 ;;
    esac
done
shift "$((OPTIND-1))"

[ $# -eq 1 ] || { show_help >&2 ; exit 1 ; }
[ -d $1 ] || { echo "$1 does not exist or is not a directory" >&2 ; exit 2 ; }

$dryrun && EXEC="echo" || EXEC=""
chunk0=${SAMPLENAME}_Chunk0

echo "INFO: making $chunk0"
$EXEC mkdir $chunk0
$EXEC cp $1/{run_cfg.py,batchScript.sh} $chunk0/
$EXEC mkdir $chunk0/log

files_0=$(printf "${BASEDIR}/${NTUPLENAME}_%d.root\n" $(seq 0 9))
files_0_quoted=$(printf "\"%s\", " $files_0)

$EXEC sed -i "/setConf(\"fileNames\"/c setConf(\"fileNames\", [$files_0_quoted])" $chunk0/run_cfg.py
$EXEC sed -i -r "s/\"XSEC\",[^\)]+/\"XSEC\", $XSEC/" $chunk0/run_cfg.py
$EXEC sed -i -r "s/\"SAMPLENAME\",[^\)]+/\"SAMPLENAME\", \"$SAMPLENAME\"/" $chunk0/run_cfg.py

for i in $(seq 1 9) ; do
    echo "INFO: making ${SAMPLENAME}_Chunk$i"
    $EXEC cp -r $chunk0 ${SAMPLENAME}_Chunk$i || break
    $EXEC sed -r -i "s/_([0-9]).root/_$i\1.root/g" ${SAMPLENAME}_Chunk$i/run_cfg.py || break
done
