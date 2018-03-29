#!/bin/bash

#Can't get TRENTO to compile on ASC because of boost dependency
#one option is to generate a number of trento events elsewhere and save the profiles, 
#then copy these to ASC and run this script over those profiles


#set number of threads to accelerate cpu computation
export OMP_NUM_THREADS=10
set OMP_NUM_THREADS 10


#loop over all initial profiles 

for file in TRENTO_profiles/*/e.dat
do

#copy the initial energy density to the preequilibrium module 
cp $file ../Models/freestream-milne/initial_profiles/.

#run preequilibrium module 
cd ../Models/freestream-milne
rm -r output
mkdir output
./RunFreestreamMilne

#copy the results of preequilibrium module to the hydrodynamic module  
cp -R output ../gpu-vh/input

#run the hydrodynamics model
cd ../gpu-vh
rm -r output
mkdir output
./gpu-vh --config rhic-conf/ -o output -h

#copy the output of hydro module to Cooper Frye module 
cp output/surface.dat ../iS3d/input/.

#run the Cooper Frye module
rm -r results
mkdir results
./iS_GPU.e 

#copy the spectra to the Results directory 
mkdir ../../ASC/Results/results_${file}
cp results/dN_pTdpTdphidy.dat ../../ASC/Results/results_${file}/.

#go back to ASC directory to start over again 
cd ../../ASC

done

