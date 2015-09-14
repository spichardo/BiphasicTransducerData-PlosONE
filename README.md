# BiphasicTransducerData-PlosONE
Data for paper "Efficient Driving of Piezoelectric Transducers Using a Biaxial Driving Technique" published in Plos-ONE

CalculatePowerVsPhase.m script runs the Matlab code to process the data from the scale measurements to produce the figures and tables. 

This script requires the Statistics Toolbox from Matlab. To produce the figures for publishing, the script uses the export_fig function (https://github.com/altmany/export_fig).

Data is organized by transducer sample:
DL47-T1,
DL47-T2 and
DL47-T3

Each transducer directory has 24 matlab data files, with the following naming convention:

[Driving type]_Exp[#]_[Frequency type]acquisition_[Experiment date].mat.

where [Driving type] can be:
"L_D" for tests using ONLY the P mode driving method.
"LS_S" for tests using both the dual mode P+L driving method.

[#] is number of repetition of same experiment (1 to 3)

[Frequency type] is the frequency being tested and can be:
"AVG" when testing the average frequency of P and L modes
"f1" when testing with the resonant frequency of P mode
"f2" when testing with the resonant frequency of L mode

[Experiment date] indicates date and time when data was saved (at end of experiment).

Every data file include an structure data array called "acquisition" which contains all radiation forces measurements.
Each entry in "acquisition" has the following fields

current_amplitude: Amplitude value used on the P channel (before amplification,this remains constant for a given experiment)
 
MassVector_Pre_Measure: vector of mass reading values from the scale read BEFORE the ultrasound activated. This vector is used to calculate the evaporation rate.
TimeVector_Pre_Measure: vector of time points corresponding to MassVector_Pre_Measure
current_mass:vector of mass reading values from the scale read during the ultrasound activated
TimeVector: vector of time points corresponding to current_mass
Power_Shear: reading of effective applied power (A-B) on the L channel
Power_Shear_PowerB: reading of reflected power (B) on the L channel
Power_Longitudinal:  reading of effective applied power (A-B) on the P channel
Power_Longitudinal_PowerB: reading of reflected power (B) on the P channel
current_phase: Phase (in degrees) applied to L channel

"acquisition" array in "LS_S" experiments contains 73 entries, corresponding to a population of dephase values from 0 to 360 degrees for the "L" channel, in steps of 5 degrees and in a random order

"acquisition" array in "LD" experiments contains 4 entries. The dephase values for these experiments are ignored since the "L" channel was desactivated.
