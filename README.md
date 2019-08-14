# r_machine_learning

This project contains the code developed in MATLAB and R for an aerial photography image processing application for roof detection using machine learning.

The main project code for the machine learning is contained in several R scripts, the initiating script includes in its titel "Main". The MATLAB scripts that are also included were used for feature extraction of the raw image files which where captured with a UAV over some blocks of flats. The MATLAB scripts generate a .csv file which is then used as an input to the R scripts for machine learning and roof detection. The output of the machine learning preditions in R can then be fed back into the final MATLAB script for prediction rendering.
