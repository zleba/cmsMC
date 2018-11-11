#!/bin/env python

lines = []
with open("listRivet") as f:
    lines = [line.rstrip('\n') for line in f]

analysis=""
for d in lines:
    ds = d.strip()
    if len(ds) < 2: continue
    if ds[0] == "%" or ds[0] == "!": continue
    elif ds[0] == "#" and ds[1] != "#":
        analysis=ds[1:]
    elif ds[0] == "#" and ds[1] == "#":
        glName=ds[2:]
    else:
        if analysis == '': continue
        r = ds.split(' ')
        nEv= int(r[2]) / 100
        evJob = 4000
        nJob = nEv / evJob
        evPerJob = nEv / nJob
        #print r[0], r[1], analysis, nJob, evJob
        from subprocess import call
        name=glName+'/'+r[0]
        call(['./runRivet', name, r[1], analysis, str(nJob), str(evJob)])

