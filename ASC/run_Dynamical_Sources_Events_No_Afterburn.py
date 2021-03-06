import csv
import os
import sys
from multiprocessing import Process, current_process
import datetime as dt
import time

print("**********************************************************")
print("***********************OSU-RHIG***************************")
print("**********************************************************")
print("**Running OSU-RHIG for Dynamically Sourced Hydro profiles**")

start_time = time.time()
#number of events
nevents = int(sys.argv[1])
#number of cpu cores
ncores = int(sys.argv[2])

print("**Number of CPU Cores : " + str(ncores) + "**")
print("**Number of Events : " + str(nevents) + "**")

#os.system('module load cuda')
os.system('module load intel/18.0.0')

os.system('rm -R ResultsDynamicSource')
os.system('mkdir ResultsDynamicSource')

print("**Beginning event loop**")
#loop over independent events
for event in range(1, nevents + 1):
    print("**Starting Event #" + str(event) + " of " + str(nevents) + "**")
    event_dir = "event_" + str(event)

    #Generate UrQMD event for Initial Condition
    urqmd_dir = "../Models/urqmd-modified"
    os.chdir( urqmd_dir )
    os.system( 'mkdir ' + event_dir )
    os.chdir( event_dir )
    os.system( 'mkdir output' )
    os.system( 'ln -s ../runqmd.bash runqmd.bash' )
    os.system( 'ln -s ../urqmd.x86_64 urqmd.x86_64' )
    os.system( 'ln -s ../inputfile inputfile' )
    #run urqmd
    print("**Running UrQMD to generate Initial Conditions**")
    os.system( './runqmd.bash' )

    #copy results to part2s
    part2s_dir = "../../part2s"
    os.chdir( part2s_dir )
    os.chdir( 'sourceTerms' )

    #go to part2s directory to get source terms
    os.system( 'mkdir ' + event_dir )
    os.chdir( event_dir )
    os.system( 'ln -s ../../../urqmd-modified/' + event_dir + '/output/event1.dat Set.dat' )
    os.system( 'mkdir output' )
    os.system( 'ln -s ../part2s part2s' )
    os.system( 'ln -s ../parameter.dat parameter.dat' )
    #run part2s
    print("**Running part2s to generate Hydro Source Terms**")
    os.system( './part2s' )

    #copy results to cpu-vh directory
    os.chdir( '../../../cpu-vh' )
    os.system( 'mkdir ' + event_dir )
    os.chdir( event_dir )
    os.system( 'mkdir output' )

    os.system( 'mkdir input' )
    os.chdir( 'input' )
    os.system( 'ln -s ../../../part2s/sourceTerms/' + event_dir + '/output DynamicalSources' )
    os.chdir( '..' )

    os.system( 'ln -s ../rhic-conf rhic-conf' )
    os.system( 'ln -s ../run.sh run.sh' )
    os.system( 'ln -s ../cpu-vh cpu-vh' )
    #run cpu-vh
    print("**Running CPU-VH Hydro**")
    os.system('sh run.sh ' + str(ncores))

    #copy freezeout surface to iS3D directory
    os.chdir( '../../iS3D' )
    os.system( 'mkdir ' + event_dir )
    os.chdir( event_dir )
    os.system( 'mkdir results' )
    os.system( 'mkdir input' )
    os.chdir( 'input' )
    os.system( 'ln -s ../../../cpu-vh/' + event_dir + '/output/surface.dat surface.dat' )
    os.chdir( '..' )
    os.system( 'ln -s ../parameters.dat parameters.dat' )
    os.system( 'ln -s ../deltaf_coefficients deltaf_coefficients' )
    os.system( 'ln -s ../tables tables' )
    os.system( 'ln -s ../PDG PDG' )
    os.system( 'ln -s ../iS3D.e iS3D.e' )

    #check if freezeout surface is empty
    #if so, skip sampler and afterburner
    non_empty_surf = os.stat("input/surface.dat").st_size
    if (non_empty_surf):
        #run iS3D to get particle spectra
        print("**Running iS3D Sampler**")
        os.system( './iS3D.e' )

        #copy results to event directory
        os.chdir( '../../ASC/ResultsDynamicSource' )
        os.system( 'mkdir ' + event_dir )
        os.chdir( event_dir )
        os.system( 'cp -R ../../../Models/iS3D/' + event_dir + '/results .' )
        os.chdir( '../../' )

    else:
        print("***Freezeout surface is empty for this event...***")
        print("***Continuing to next event***")

end_time = time.time()

print("Total time = " + str( end_time - start_time ))
