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

os.system('rm -R ResultsDynamicSource')
os.system('mkdir ResultsDynamicSource')

#loop over independent events
for event in range(1, nevents + 1):

    event_dir = "event_" + str(event)

    #Generate UrQMD event for Initial Condition
    urqmd_dir = "../Models/urqmd"
    os.chdir( urqmd_dir )
    os.system( 'mkdir ' + event_dir )
    os.chdir( event_dir )
    os.system( 'mkdir output' )
    os.system( 'ln -s ../runqmd.bash runqmd.bash' )
    os.system( 'ln -s ../urqmd.x86_64 urqmd.x86_64' )
    os.system( 'ln -s ../inputfile inputfile' )
    #run urqmd
    os.system( './runqmd.bash' )

    #copy results to part2s
    part2s_dir = "../../part2s"
    os.chdir( part2s_dir )
    os.chdir( 'sourceTerms' )
    os.system( 'ln -s ../urqmd/' + event_dir + '/output/Set.dat Set.dat' )

    #go to part2s directory to get source terms
    os.system( 'mkdir ' + event_dir )
    os.chdir( event_dir )
    os.system( 'mkdir output' )
    os.system( 'ln -s ../part2s part2s' )
    os.system( 'ln -s ../parameter.dat parameter.dat' )
    #run part2s
    os.system( './part2s' )

    #copy results to cpu-vh directory
    os.chdir( '../../../cpu-vh' )
    os.system( 'mkdir ' + event_dir )
    os.chdir( event_dir )
    os.system( 'ln -s ../../part2s/sourceTerms/' + event_dir + '/output input' )
    os.system( 'mkdir output' )
    os.system( 'ln -s ../rhic-conf rhic-conf' )
    os.system( 'ln -s ../run.sh ../run.sh' )
    os.system( 'ln -s ../cpu-vh cpu-vh' )
    #run cpu-vh
    os.system('sh run.sh ' + str(ncores))

    #copy freezeout surface to iS3D directory
    os.chdir( '../../iS3D' )
    os.system( 'mkdir ' + event_dir )
    os.chdir( event_dir )
    os.system( 'mkdir output' )
    os.system( 'mkdir input' )
    os.system( 'ln -s ../../cpu-vh/' + event_dir + '/output/surface.dat input/surface.dat' )
    #run iS3D sampler to get particles list(s)
    os.system( './iS3D.e' )

    #copy particle list(s) to afterburner directory
    os.chdir( '../../urqmd-afterburner' )
    os.system( 'mkdir ' + event_dir )
    os.chdir( event_dir )
    os.system()
