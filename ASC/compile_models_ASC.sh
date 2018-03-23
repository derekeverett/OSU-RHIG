
#Compile TRENTO
cd ../Models/TRENTO

#load dependencies
module load cmake/3.6.1
module load gnu/6.3.0 boost
module load gnu/6.3.0 hdf5-serial

mkdir build
cd build
make clean
cmake ..
make install

cd ../


#compile freestream-milne
cd freestream-milne
sh cleanMake.sh
cd ../

#compile iS3D
cd iS3D
sh cleanMake.sh
cd ../
