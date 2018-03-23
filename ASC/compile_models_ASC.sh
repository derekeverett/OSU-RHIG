
#Compile TRENTO
cd ../Models/TRENTO

#load dependencies
module load cmake/3.6.1
module load gnu/4.8.5 boost
module load   
module load hdf5-serial

mkdir build && cd build
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
