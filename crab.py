#!/bin/env python
setName='mgTest'
#prepid='JME-RunIIFall18GS-00012'
prepid='HIG-RunIIFall18wmLHEGS-00002'

if __name__ == '__main__':

    from CRABAPI.RawCommand import crabCommand

    from CRABClient.UserUtilities import config, getUsernameFromSiteDB
    config = config()

    config.General.requestName = setName
    config.General.workArea = 'crab_projects'
    config.General.transferOutputs = True
    config.General.transferLogs = False

    config.JobType.pluginName = 'PrivateMC'
    config.JobType.psetName = prepid + '_cfg.py'
    config.JobType.disableAutomaticOutputCollection = True
    config.JobType.outputFiles = ['Rivet.yoda']

    config.Data.outputPrimaryDataset = 'mcValidation'
    config.Data.splitting = 'EventBased'
    config.Data.unitsPerJob = 10
    NJOBS = 10  # This is not a configuration parameter, but an auxiliary variable that we use in the next line.
    config.Data.totalUnits = config.Data.unitsPerJob * NJOBS
    config.Data.outLFNDirBase = '/store/user/%s/' % (getUsernameFromSiteDB())
    config.Data.publication = False
    config.Data.outputDatasetTag = setName
    config.Data.ignoreLocality = True

    config.Site.whitelist = ["T2_*"] #for ignoreLocality
    config.Site.storageSite = "T2_DE_DESY"


    crabCommand('submit', config = config)
