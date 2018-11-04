#!/bin/env python

lines = []
with open("listRivet") as f:
    lines = [line.rstrip('\n') for line in f]

analysis=""
for d in lines:
    ds = d.strip()
    if len(ds) < 1: continue
    if ds[0] == "%": continue
    if ds[0] == "#":
        analysis=ds[1:]
    else:
        if analysis == '': continue
        r = ds.split(' ')
        nEv= int(r[2]) / 1000
        evJob = 300
        nJob = nEv / evJob
        evPerJob = nEv / nJob
        #print r[0], r[1], analysis, nJob, evJob
        from subprocess import call
        call(['./runRivet', r[0], r[1], analysis, str(nJob), str(evJob)])

