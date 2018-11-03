#export LD_LIBRARY_PATH_STORED=$LD_LIBRARY_PATH
nJobs=50

jobName=myRun2

mkdir -p farm/$jobName/logs
mkdir -p farm/$jobName/histos
cp runMC.sh farm/$jobName

condor_submit nJobs=$nJobs jobName=$jobName runRivet.submit