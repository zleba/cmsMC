nEv=50
prepid=JME-RunIIFall18GS-00012
analysis=CMS_2016_I1459051
xsec=1.36333e9
cmsDriver="cmsDriver.py Configuration/GenProduction/python/${prepid}-fragment.py -s GEN --datatier=GEN-SIM-RAW --conditions auto:mc --eventcontent RAWSIM --no_exec -n $nEv --python_filename=${prepid}_cfg.py"
curl -s --insecure https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_setup/$prepid  | sed "s#^cmsDriver.py .*#$cmsDriver#" > setup.sh

bash setup.sh

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

cmsRun ${prepid}_cfg.py
