#!/bin/bash

#Can't get TRENTO to compile on ASC because of boost dependency
#one option is to generate a number of trento events elsewhere and save the profiles,
#then copy these to ASC and run this script over those profiles


#set number of threads to accelerate cpu computation
export OMP_NUM_THREADS=$1
set OMP_NUM_THREADS $1

echo "**********************************************************"
echo "***********************OSU-RHIG***************************"
echo "**********************************************************"

echo "*****Running OSU-RHIG for VAH on pregenerated TRENTO profiles *****"

rm -R Results_2D_VAH
mkdir Results_2D_VAH

#loop over all initial profiles

for file in TRENTO_2Dprofiles/*.dat
do

#copy the initial energy density to the preequilibrium module
echo "*****Copying TRENTO profile to preequilibrium module*****"
cp $file ../Models/freestream-milne-VAH/initial_profiles/e.dat

#run preequilibrium module
echo "*****Running preequilibrium module*****"
cd ../Models/freestream-milne-VAH
rm -r output
mkdir output
./RunFreestreamMilne

#copy the results of preequilibrium module to the hydrodynamic module
echo "*****Copying results to hydro  module*****"
cp -a output/. ../cpu-vah/input/

#run the hydrodynamics model
echo "*****Running hydro module*****"
cd ../cpu-vah
rm -r output
mkdir output
./cpu-vah --config rhic-conf/ -o output -h

#copy the output of hydro module to Cooper Frye module
echo "*****Copying results to Cooper Frye module*****"
cp output/surface.dat ../iS3D/input/surface.dat

#run the Cooper Frye module
echo "*****Running Cooper Frye module*****"
cd ../iS3D
rm -r results
mkdir results

#./iS3D_GPU.e
./iS3D.e

#copy the spectra to the Results directory
echo "*****Copying Final results to /Results*****"

prefix="TRENTO_2Dprofiles/"
suffix=".dat"

foo=${file#$prefix}
foo=${foo%$suffix}

cd ../../ASC/Results_2D_VAH

#make a results directory
mkdir event-${foo}
cd event-${foo}

#copy output from all modules into results dir
cp ../../TRENTO_2Dprofiles/${foo}.dat TRENTO.dat

cp -R ../../../Models/freestream-milne-VAH/output freestream_output

cp -R ../../../Models/cpu-vah/output cpu-vah_output

cp -R ../../../Models/iS3D/results iS3D_output

#go back to ASC directory to start over again
cd ../../

done

echo "**********************************************************"
echo "***********************OSU-RHIG***************************"
echo "***********************Finished***************************"
echo "**********************************************************"
