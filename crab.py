
if __name__ == '__main__':

    from CRABAPI.RawCommand import crabCommand

    from CRABClient.UserUtilities import config, getUsernameFromSiteDB
    config = config()

    config.General.requestName = 'tutorial_May2015_MC_generation'
    config.General.workArea = 'crab_projects'
    config.General.transferOutputs = True
    config.General.transferLogs = False

    config.JobType.pluginName = 'PrivateMC'
    config.JobType.psetName = 'JME-RunIIFall18GS-00004_cfg.py'
    config.JobType.disableAutomaticOutputCollection = True
    config.JobType.outputFiles = 'Rivet.yoda'

    config.Data.outputPrimaryDataset = 'MinBias'
    config.Data.splitting = 'EventBased'
    config.Data.unitsPerJob = 10
    NJOBS = 10  # This is not a configuration parameter, but an auxiliary variable that we use in the next line.
    config.Data.totalUnits = config.Data.unitsPerJob * NJOBS
    config.Data.outLFNDirBase = '/store/user/%s/' % (getUsernameFromSiteDB())
    config.Data.publication = False
    config.Data.outputDatasetTag = 'CRAB3_tutorial_May2015_MC_generation'
    config.Data.ignoreLocality = True

    config.Site.storageSite = "T2_DE_DESY"


    crabCommand('submit', config = config)
