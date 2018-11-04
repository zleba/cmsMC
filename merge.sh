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

for dd in farm/[A-Z]*
do
   d=`basename $dd`
   yodamerge -o farm/$d/${d}.yoda farm/$d/histos/Rivet*.yoda

done
