#!/bin/bash

nEv=50
#prepid=JME-RunIIFall17GS-00006
#prepid=JME-RunIIFall18GS-00012

#prepid=JME-RunIIFall18wmLHEGS-00023

#prepid=JME-RunIIFall18wmLHEGS-00029

#prepid=JME-RunIIFall18GS-00003
prepid=JME-RunIIFall18GS-00019
prepid=JME-RunIIFall18GS-00021

#hg7
#prepid=JME-RunIIFall18GS-00022
#hg7
prepid=JME-RunIIFall18GS-00023
#4C
prepid=JME-RunIIFall18GS-00025




#prepid=JME-RunIIFall18wmLHEGS-00017
#prepid=JME-RunIIFall18wmLHEGS-00014
#prepid=HIG-RunIIFall18wmLHEGS-00002
analysis=CMS_2019_incJets



if [ "$#" -ge 3 ]
then
prepid=$1
analysis=$2
nEv=$3
fi


xsec=1.0
if [[ $prepid == *wmLHE* ]]
then
cmsDriver="cmsDriver.py Configuration/GenProduction/python/${prepid}-fragment.py  --mc --eventcontent RAWSIM --datatier GEN-SIM-RAW  --conditions auto:mc --step LHE,GEN  --no_exec -n $nEv --python_filename=${prepid}_cfg.py"
else
cmsDriver="cmsDriver.py Configuration/GenProduction/python/${prepid}-fragment.py  --mc --step GEN --datatier=GEN-SIM-RAW --conditions auto:mc --eventcontent    RAWSIM --no_exec   -n $nEv --python_filename=${prepid}_cfg.py"
fi

curl -s --insecure --retry 100 https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_setup/$prepid  | sed "s#^cmsDriver.py .*#$cmsDriver#" > setup.sh
sed -i "s/--retry 2/--retry 100/" setup.sh
#sed -i "/cd CMSSW_.*src/a cp -r /nfs/dust/cms/user/zlebcr/met/mcProduction/cmsMC/CMSSW_10_2_13_patch1/src/GeneratorInterface ." setup.sh
echo "before setup run"

echo export RIVET_ANALYSIS_PATH=/nfs/dust/cms/user/zlebcr/met/cmsMC/rivetAnals  >> setup.sh

#cat setup.sh
chmod u+x setup.sh
. ./setup.sh

seed=${RANDOM}
#seed=42
echo $seed
sed -i "/process.maxEvents/i process.RandomNumberGeneratorService.generator.initialSeed = $seed" ${prepid}_cfg.py
sed -i "/process.maxEvents/i process.RandomNumberGeneratorService.externalLHEProducer.initialSeed = $seed" ${prepid}_cfg.py
sed -i "/eventHandlers = cms.string('\/Herwig\/EventHandlers'),/ i seed = cms.untracked.int32($seed)," ${prepid}_cfg.py

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

if [ "$#" -eq 4 ]
then
    exit 0
fi
echo "before cmsRun"

rm -f stderr.log
cmsRun ${prepid}_cfg.py  2> >(tee -a stderr.log >&2)
#exit 0

xsec=`grep "^After filter: final cross section =" stderr.log | awk '{print $7}'`

#setup version for merge of yoda files
cmsRel=CMSSW_10_1_0
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc700

if [ -r $cmsRel/src ] ; then
     echo release $cmsRel already exists
else
     scram p CMSSW $cmsRel
fi
cd $cmsRel/src
eval `scram runtime -sh`

scram b
cd ../../
echo yodascale -c  ".* ${xsec}x" Rivet.yoda
yodascale -c  ".* ${xsec}x" Rivet.yoda
mv -f Rivet-scaled.yoda Rivet.yoda
