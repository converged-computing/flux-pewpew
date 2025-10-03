# Flux Pew Pew Pew! 🔫

Err, I mean, PU PU PU.

I started working on this at the level of the PU (processing unit) but I think we largely want to get the cores mapped to cpusets, which each have (if you look at the XML). I think PU is too granular. What I'm finding is that when I ask for 2 cores, I get the _last_ two recorded in the xml. I don't know why and this is what I need to know next. The questions I have to keep working on this:

- I think we need the PUs to see the content of a CPUSET.

## Development

Open the DevContainer in VSCode. Start Flux.

```bash
flux start
fluxroot@a5487f26e9a2:/workspaces/flux-pewpew# flux resource list
     STATE NNODES NCORES NGPUS NODELIST
      free      1      8     0 a5487f26e9a2
 allocated      0      0     0 
      down      0      0     0 
```

## Discover Actual Topology

Note there are no arguments.

```bash
bash scripts/show_topology.sh
```

## Discovery Faux Topology

Run with an xml file to discover faux topology:

```bash
bash scripts/show_topology.sh scripts/topology/numa-node-1.xml
```

Here is a faux topology I made with more than one numa node.

```bash
bash scripts/show_topology.sh scripts/topology/chonker.xml 
```

## Run kripke

For some reason, the match-policy in this container is high, so to get low:

```bash
flux start --config-path=./scripts/broker/match-policy-low.toml
python3 test-binding.py  --match-policy low
```

Or for high, just use without the custom flux start.

```bash
python3 test-binding.py  --match-policy high
```
```
Parsing actual bindings from job output...
 1 a5487f26e9a2 0x0000c000 0
hwloc-calc --pulist 0x0000c000
 0 a5487f26e9a2 0x00003000 0
hwloc-calc --pulist 0x00003000
Actual core for each rank: {1: '0x0000c000 (14,15)', 0: '0x00003000 (12,13)'}

4. Validating Results
🟢 Rank 0 - Correctly bound to physical core 0x00003000 (12,13)
🟢 Rank 1 - Correctly bound to physical core 0x0000c000 (14,15)

🎉 Implicit exclusivity and dense packing are working as predicted.
```

Exclusive does seem to use all the tasks on the node, and we can emulate that prediction if we understand how it works.
I haven't thought about it yet, I'm not sure others are engaged in this.

```bash
python3 test-binding.py  --match-policy high --exclusive
🥸  Discovering Ground Truth Hardware Topology
{
    "0": {
        "cores": {
            "0": "0x00000003",
            "1": "0x0000000c",
            "2": "0x00000030",
            "3": "0x000000c0",
            "4": "0x00000300",
            "5": "0x00000c00",
            "6": "0x00003000",
            "7": "0x0000c000"
        },
        "gpus": []
    }
}

Predicting Layout for 2 Tasks with 1 core(s) each ---
hwloc-calc --pulist 0x00003000
hwloc-calc --pulist 0x0000c000
Predicted cpuset for each rank: {0: '0x00003000 (12,13)', 1: '0x0000c000 (14,15)'}

Running Experiment with 1 nodes and 2 tasks
Executing: flux run -o cpu-affinity=per-task -N 1 -n 2 --exclusive /usr/bin/bash /workspaces/flux-pewpew/scripts/report_and_run.sh kripke --procs 1,2,1
rank  node  binding  numa domain
PEWPEWPEW 0 a5487f26e9a2 0x000000ff 0

rank  node  binding  numa domain

PEWPEWPEW 1 a5487f26e9a2 0x0000ff00 0

_  __       _         _
| |/ /      (_)       | |
| ' /  _ __  _  _ __  | | __ ___
|  <  | '__|| || '_ \ | |/ // _ \
| . \ | |   | || |_) ||   <|  __/
|_|\_\|_|   |_|| .__/ |_|\_\\___|
| |
|_|        Version 1.2.5-dev

LLNL-CODE-775068

Copyright (c) 2014-25, Lawrence Livermore National Security, LLC

Kripke is released under the BSD 3-Clause License, please see the
LICENSE file for the full license

This work was produced under the auspices of the U.S. Department of
Energy by Lawrence Livermore National Laboratory under Contract
DE-AC52-07NA27344.

Author: Adam J. Kunen <kunen1@llnl.gov>

Compilation Options:
Architecture:           Sequential
Compiler:               /usr/bin/mpicxx
Compiler Flags:         "-I/opt/Caliper-2.13.1/src/interface/c_fortran -I/opt/Caliper-2.13.1/src/include    "
Linker Flags:           " "
CHAI Enabled:           No
CUDA Enabled:           No
MPI Enabled:            Yes
OpenMP Enabled:         No
Caliper Enabled:        Yes

Input Parameters
================

Problem Size:
Zones:                 16 x 16 x 16  (4096 total)
Groups:                32
Legendre Order:        4
Quadrature Set:        Dummy S2 with 96 points

Physical Properties:
Total X-Sec:           sigt=[0.100000, 0.000100, 0.100000]
Scattering X-Sec:      sigs=[0.050000, 0.000050, 0.050000]

Solver Options:
Number iterations:     10

MPI Decomposition Options:
Total MPI tasks:       2
Spatial decomp:        1 x 2 x 1 MPI tasks
Block solve method:    Sweep

Per-Task Options:
DirSets/Directions:    8 sets, 12 directions/set
GroupSet/Groups:       2 sets, 16 groups/set
Zone Sets:             1 x 1 x 1
Architecture:          Sequential
Data Layout:           DGZ

Generating Problem
==================

Decomposition Space:   Procs:      Subdomains (local/global):
---------------------  ----------  --------------------------
(P) Energy:            1           2 / 2
(Q) Direction:         1           8 / 8
(R) Space:             2           1 / 2
(Rx,Ry,Rz) R in XYZ:   1x2x1       1x1x1 / 1x2x1
(PQR) TOTAL:           2           16 / 32

Material Volumes=[8.789062e+03, 1.177734e+05, 2.753438e+06]

Memory breakdown of Field variables:
Field Variable            Num Elements    Megabytes
--------------            ------------    ---------
data/sigs                        15360        0.117
dx                                  16        0.000
dy                                  16        0.000
dz                                  16        0.000
ell                               2400        0.018
ell_plus                          2400        0.018
i_plane                         786432        6.000
j_plane                         786432        6.000
k_plane                         786432        6.000
mixelem_to_fraction               4352        0.033
phi                            3276800       25.000
phi_out                        3276800       25.000
psi                           12582912       96.000
quadrature/w                        96        0.001
quadrature/xcos                     96        0.001
quadrature/ycos                     96        0.001
quadrature/zcos                     96        0.001
rhs                           12582912       96.000
sigt_zonal                      131072        1.000
volume                            4096        0.031
--------                  ------------    ---------
TOTAL                         34238832      261.222

Generation Complete!

Steady State Solve
==================

iter 0: particle count=3.743744e+07, change=1.000000e+00
iter 1: particle count=5.629276e+07, change=3.349511e-01
iter 2: particle count=6.569619e+07, change=1.431351e-01
iter 3: particle count=7.036907e+07, change=6.640521e-02
iter 4: particle count=7.268400e+07, change=3.184924e-02
iter 5: particle count=7.382710e+07, change=1.548355e-02
iter 6: particle count=7.438973e+07, change=7.563193e-03
iter 7: particle count=7.466578e+07, change=3.697158e-03
iter 8: particle count=7.480083e+07, change=1.805479e-03
iter 9: particle count=7.486672e+07, change=8.801810e-04
Solver terminated

Timers
======

Timer                    Count       Seconds
----------------  ------------  ------------
Generate                     1       0.00174
LPlusTimes                  10       0.54563
LTimes                      10       0.39702
Population                  10       0.11155
Scattering                  10       0.79002
Solve                        1       2.57644
Source                      10       0.00054
SweepSolver                 10       0.63009
SweepSubdomain             160       0.57832

TIMER_NAMES:Generate,LPlusTimes,LTimes,Population,Scattering,Solve,Source,SweepSolver,SweepSubdomain
TIMER_DATA:0.001736,0.545635,0.397016,0.111545,0.790022,2.576436,0.000541,0.630085,0.578323

Figures of Merit
================

Throughput:         4.883845e+07 [unknowns/(second/iteration)]
Grind time :        2.047567e-08 [(seconds/iteration)/unknowns]
Sweep efficiency :  91.78477 [100.0 * SweepSubdomain time / SweepSolver time]
Number of unknowns: 12582912

END

Parsing actual bindings from job output...
 0 a5487f26e9a2 0x000000ff 0
hwloc-calc --pulist 0x000000ff
 1 a5487f26e9a2 0x0000ff00 0
hwloc-calc --pulist 0x0000ff00
Actual core for each rank: {0: '0x000000ff (0,1,2,3,4,5,6,7)', 1: '0x0000ff00 (8,9,10,11,12,13,14,15)'}

4. Validating Results
🔴 Rank 0 - Predicted cpuset: 0x00003000 (12,13), Actual cpuset: 0x000000ff (0,1,2,3,4,5,6,7)
🔴 Rank 1 - Predicted cpuset: 0x0000c000 (14,15), Actual cpuset: 0x0000ff00 (8,9,10,11,12,13,14,15)

❌ Found 2 binding mismatches.
```

Note that the actual cpusets do suggest exclusivity of the node.
