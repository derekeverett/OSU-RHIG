#!/bin/bash

#Can't get TRENTO to compile on ASC because of boost dependency
#one option is to generate a number of trento events elsewhere and save the profiles,
#then copy these to ASC and run this script over those profiles


#set number of threads to accelerate cpu computation
export OMP_NUM_THREADS=10
set OMP_NUM_THREADS 10


echo "**********************************************************"
echo "***********************OSU-RHIG***************************"
echo "**********************************************************"


echo "*****Running OSU-RHIG on pregenerated TRENTO profiles *****"

#loop over all initial profiles

for file in TRENTO_profiles/*.dat
do

#copy the initial energy density to the preequilibrium module
echo "*****Copying TRENTO profile to preequilibrium module*****"
cp $file ../Models/freestream-milne/initial_profiles/e.dat

#run preequilibrium module
echo "*****Running preequilibrium module*****"
cd ../Models/freestream-milne
rm -r output
mkdir output
./RunFreestreamMilne


#if [ $1 -gt 1 ]
#then

#copy the results of preequilibrium module to the hydrodynamic module
echo "*****Copying results to hydro  module*****"
cp -a output/. ../gpu-vh/input/

#run the hydrodynamics model
echo "*****Running hydro module*****"
cd ../gpu-vh
rm -r output
mkdir output
./gpu-vh --config rhic-conf/ -o output -h

#else

#copy the results of preequilibrium module to the hydrodynamic module
#echo "*****Copying results to hydro  module*****"
#cp -a output/. ../cpu-vh/input/

#run the hydrodynamics model
#echo "*****Running hydro module*****"
#cd ../cpu-vh
#rm -r output
#mkdir output
#./cpu-vh --config rhic-conf/ -o output -h

#fi


#copy the output of hydro module to Cooper Frye module
echo "*****Copying results to Cooper Frye module*****"
cp output/surface.dat ../iS3D/input/surface.dat

#run the Cooper Frye module
echo "*****Running Cooper Frye module*****"
cd ../iS3D
rm -r results
mkdir results

#if [ $1 -gt 1 ]
#then

./iS_GPU.e

#else

#./iS.e

#fi

#copy the spectra to the Results directory
echo "*****Copying Final results to /Results*****"
#mkdir ../../ASC/Results/results_${file}

prefix="TRENTO_profiles/"
suffix=".dat"

foo=${file#$prefix}
foo=${foo%$suffix}
cp results/dN_pTdpTdphidy.dat ../../ASC/Results/dN_pTdpTdphidy_${foo}.dat

#go back to ASC directory to start over again
cd ../../ASC

done
