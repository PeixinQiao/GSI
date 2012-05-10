#! /bin/ksh

#------------------------------------------------------------------
#
#  plot_summary.sh
#
#------------------------------------------------------------------

set -ax
export list=$listvars

SATYPE2=$1

#------------------------------------------------------------------
# Set environment variables.
tmpdir=${STMP_USER}/plot_summary_${SUFFIX}_${SATYPE2}.$PDATE
rm -rf $tmpdir
mkdir -p $tmpdir
cd $tmpdir



#------------------------------------------------------------------
#   Set dates
bdate=`$NDATE -720 $PDATE`
edate=$PDATE
bdate0=`echo $bdate|cut -c1-8`
edate0=`echo $edate|cut -c1-8`

#--------------------------------------------------------------------
# Set ctldir to point to correct control file source

imgdef=`echo ${#IMGNDIR}`
if [[ $imgdef -gt 0 ]]; then
  ctldir=$IMGNDIR/time
else
  ctldir=$TANKDIR/time
fi

echo ctldir = $ctldir


#--------------------------------------------------------------------
# Create plots and place on server (rzdm)

for type in ${SATYPE2}; do

   $NCP $ctldir/${type}.ctl* ./
   uncompress *.ctl.Z

   cdate=$bdate
   while [[ $cdate -le $edate ]]; do
      $NCP $TANKDIR/time/${type}.${cdate}.ieee_d* ./
      adate=`$NDATE +6 $cdate`
      cdate=$adate
   done
   uncompress *.ieee_d.Z

cat << EOF > ${type}.gs
'open ${type}.ctl'
'run ${GSCRIPTS}/plot_summary.gs ${type} x1100 y850'
'quit'
EOF

   timex $GRADS -bpc "run ${tmpdir}/${type}.gs"

   ssh -l ${WEB_USER} ${WEB_SVR} "mkdir -p ${WEBDIR}/summary"
   scp ${type}.summary.png ${WEB_USER}@${WEB_SVR}:${WEBDIR}/summary/

   rm -f ${type}.ctl 
   rm -f ${type}*.ieee_d
   rm -f ${type}.summary.png

done



#--------------------------------------------------------------------
# Clean $tmpdir. 
#
cd $tmpdir
cd ../
rm -rf $tmpdir


exit
