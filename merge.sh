#!/bin/bash
#setup version for merge of yoda files
cmsRel=CMSSW_10_1_0
source /cvmfs/cms.cern.ch/cmsset_default.sh
#export SCRAM_ARCH=slc6_amd64_gcc700
if [ -r $cmsRel/src ] ; then
     echo release $cmsRel already exists
else
     scram p CMSSW $cmsRel
fi
cd $cmsRel/src
eval `scram runtime -sh`

scram b
cd ../../

#merge individual MCs
for dd in farm/[A-Z]*/[A-Z]*
do
   d=`basename $dd`
   yodamerge -o $dd/${d}.yoda $dd/histos/Rivet*.yoda
done

#merge slices
for dd in farm/[A-Z]*/
do
   d=`basename $dd`

   yodamerge --add -o $dd/${d}.yoda   $dd/*/*.yoda
done

#plot rivet
#rivet-mkhtml --mc-errs -o farm/qcdPlots   farm/*/*.yoda
