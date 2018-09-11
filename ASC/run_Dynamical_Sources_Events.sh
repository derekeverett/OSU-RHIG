#!/bin/bash

#set number of threads to accelerate cpu computation
export OMP_NUM_THREADS=$1
set OMP_NUM_THREADS $1


echo "**********************************************************"
echo "***********************OSU-RHIG***************************"
echo "**********************************************************"

echo "*****Running OSU-RHIG for Dynamically Sourced Hydro profiles *****"

rm -R Results3D
mkdir Results3D

#loop over all initial profiles
for file in UrQMD_ICs/*.dat
do

#or run UrQMD to generate a profile?


#copy the UrQMD particle list to part2s to generate source terms 
echo "*****Copying initial particle list to source term module*****"
cp $file ../Models/part2s/Set.dat 

#run source terms module 
echo "*****Running source terms module*****"
cd ../Models/part2s
rm -r output
mkdir output
./part2s

#copy the results of source terms module to the hydrodynamic module
echo "*****Copying results to hydro module*****"
cp -a output/. ../cpu-vh/input/DynamicalSources/

#run the hydrodynamics model
echo "*****Running hydro module*****"
cd ../cpu-vh
rm -r output
mkdir output
sh run.sh $1

#copy the output of hydro module to particle sampler module
echo "*****Copying results to particle sampler module*****"
cp output/surface.dat ../iS3D/input/surface.dat

#run the sampler module
echo "*****Running particle sampler module*****"
cd ../iS3D
rm -r results
mkdir results
sh runCPU.sh 1

#copy results to afterburner
echo "*****Copying results to afterburner module*****"
cd ../afterburner/bin
cp ../../iS3D/results/particle_list_osc.dat .

#run the afterburner module 
./afterburner particle_list_osc.dat final_particles.dat

#copy results back for analysis


#copy the spectra to the Results directory
echo "*****Copying Final results to /Results*****"

prefix="TRENTO_3Dprofiles/"
suffix=".dat"

foo=${file#$prefix}
foo=${foo%$suffix}

cd ../../ASC/Results3D

#make a results directory
mkdir event-${foo}
cd event-${foo}

#copy output from all modules into results dir
cp ../../TRENTO_3Dprofiles/${foo}.dat TRENTO.dat

cp -R ../../../Models/freestream-milne/output freestream_output

cp -R ../../../Models/gpu-vh/output gpu-vh_output

cp -R ../../../Models/iS3D/results iS3D_output

#go back to ASC directory to start over again
cd ../../

done


echo "**********************************************************"
echo "***********************OSU-RHIG***************************"
echo "***********************Finished***************************"
echo "**********************************************************"
