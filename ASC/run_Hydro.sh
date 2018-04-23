#!/bin/bash

#Can't get TRENTO to compile on ASC because of boost dependency
#one option is to generate a number of trento events elsewhere and save the profiles,
#then copy these to ASC and run this script over those profiles


echo "**********************************************************"
echo "***********************OSU-RHIG***************************"
echo "**********************************************************"

echo "*****Running OSU-RHIG on pregenerated TRENTO profiles *****"

rm -R Results_Hydro
mkdir Results_Hydro

#run the hydrodynamics model
echo "*****Running hydro module*****"
#cd ../Models/gpu-vh
cd ../Models/cpu-vah
rm -r output
mkdir output
#./gpu-vh --config rhic-conf/ -o output -h
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

cd ../../ASC/Results_Hydro


#copy output from all modules into results dir 

#cp -R ../../Models/gpu-vh/output gpu-vh_output

cp -R ../../Models/cpu-vah/output cpu-vah_output

cp -R ../../Models/iS3D/results iS3D_output

echo "**********************************************************"
echo "***********************OSU-RHIG***************************"
echo "***********************Finished***************************"
echo "**********************************************************"
