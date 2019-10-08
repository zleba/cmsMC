#!/bin/env python

lines = []
with open("listRivet") as f:
    lines = [line.rstrip('\n') for line in f]

analysis=""
for iL, d in enumerate(lines):
    ds = d.strip()
    if len(ds) < 2: continue
    if ds[0] == "%" or ds[0] == "!": continue
    elif ds[0] == "#" and ds[1] != "#":
        analysis=ds[1:]
    elif ds[0] == "#" and ds[1] == "#":
        #glName=ds[2:]
        glName, nJobsTot  =  tuple(ds[2:].split())
        nJobsTot = int(nJobsTot)
        #print glName, nJobs

        iLn = iL+1
        nEvTot = 0
        while lines[iLn].strip() != "":
            nEvTot += int(lines[iLn].strip().split()[2])
            iLn += 1
    else:
        if analysis == '': continue
        r = ds.split()
        #print r
        nEv= int(r[2]) 

        nJobs = (nJobsTot * nEv) / nEvTot
        evJob = nEv / nJobs

        #evJob = 4000
        #nJob = nEv / evJob
        #evPerJob = nEv / nJob
        #print r[0], r[1], analysis, nJob, evJob
        from subprocess import call
        name=glName+'/'+r[0]


        #print 'ahoj', glName, nJobs, evJob
        call(['./runRivet', name, r[1], analysis, str(nJobs), str(evJob)])

