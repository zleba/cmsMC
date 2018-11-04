#!/bin/bash

nEv=20
#prepid=JME-RunIIFall18GS-00012
prepid=JME-RunIIFall18GS-00004
#prepid=JME-RunIIFall18wmLHEGS-00014
#prepid=HIG-RunIIFall18wmLHEGS-00002
analysis=CMS_2016_I1459051



if [ "$#" -eq 3 ]
then
prepid=$1
analysis=$2
nEv=$3
fi


xsec=1
if [[ $prepid == *wmLHE* ]]
then
cmsDriver="cmsDriver.py Configuration/GenProduction/python/${prepid}-fragment.py  --mc --eventcontent RAWSIM --datatier GEN-SIM-RAW  --conditions auto:mc --step LHE,GEN --nThreads 1   --no_exec -n $nEv --python_filename=${prepid}_cfg.py"
else
cmsDriver="cmsDriver.py Configuration/GenProduction/python/${prepid}-fragment.py  --mc --step GEN --datatier=GEN-SIM-RAW --conditions auto:mc --eventcontent RAWSIM --no_exec -n $nEv --python_filename=${prepid}_cfg.py"
fi

curl -s --insecure https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_setup/$prepid  | sed "s#^cmsDriver.py .*#$cmsDriver#" > setup.sh

chmod u+x setup.sh
. ./setup.sh

seed=${RANDOM}${RANDOM}
sed -i "/process.maxEvents/i process.RandomNumberGeneratorService.generator.initialSeed = $seed" ${prepid}_cfg.py

cat <<EOF >>  ${prepid}_cfg.py
def customise(process):
    process.load('GeneratorInterface.RivetInterface.rivetAnalyzer_cfi')
    process.rivetAnalyzer.AnalysisNames = cms.vstring('$analysis')
    process.rivetAnalyzer.OutputFile = cms.string('Rivet.yoda')
    process.rivetAnalyzer.CrossSection = cms.double($xsec)
    process.generation_step+=process.rivetAnalyzer
    process.schedule.remove(process.RAWSIMoutput_step)
    return(process)     
process = customise(process)
EOF

rm -f stderr.log
cmsRun ${prepid}_cfg.py  2> >(tee -a stderr.log >&2)
xsec=`grep "^After filter: final cross section =" stderr.log | awk '{print $7}'`


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
yodascale -c  ".* ${xsec}x" Rivet.yoda
mv -f Rivet-scaled.yoda Rivet.yoda
