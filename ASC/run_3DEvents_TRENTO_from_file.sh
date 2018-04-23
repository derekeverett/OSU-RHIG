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

rm -R Results3D
mkdir Results3D

#loop over all initial profiles

for file in TRENTO_3Dprofiles/*.dat
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

./iS3D_GPU.e

#else

#./iS3D.e

#fi

#copy the spectra to the Results directory
echo "*****Copying Final results to /Results*****"
#mkdir ../../ASC/Results/results_${file}

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
