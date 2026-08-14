form  SFEEDS ver.1
comment "Spectral-based fo Estimator Emphasized by Domination and Sequence"
comment
    real left_Number_of_Object 
    real right_Number_of_Object 1
comment ▼Frame length, Distance between frame centres
　positive　frame_length　0.1
　real　time_step　0.0033
comment ▼Unified average intensity of samples
  boolean intensity_resample 1
  positive   avg_int  70

comment ▼Differential value of dB judged as a silent frame
  real   noLoud_lower_than_allsample 30
comment ▼Differential values of dB determined as frames containing harmonics
  real   noHarmonics_lower_than_frame 20
comment ▼Difference between fo candidate and maximum value between 50-400 Hz (dB)
    positive   diff1 10
comment ▼Frequency proximity of the Sequential Spectrum Test
    positive   diff2 10
comment ▼For correcting false detection
    positive   diff3 10
comment ▼Spectrogram drawing options
    boolean draw_estimated_pitch 1

comment ▼Save
    sentence Save_directory /Users/Username/Desktop/Filename
endform

d = diff1
dd = diff2
ddd = diff3



for s from left_Number_of_Object to right_Number_of_Object
select 's'
sounddefo = selected("Sound")
namedefo$ = selected$("Sound")

duration = Get total duration
x = frame_length
n = round((duration-frame_length)/time_step)+2


#######Unify the average INTENSITY of the sample with avg_int########################
#Default is to resample Intensity
if intensity_resample = 1
Scale intensity: avg_int
endif


#######Calculate the mean fo of the sample####################
# Create a long-term average spectrum.
To Spectrum... yes
To Ltas (1-to-1)

#Find the spectral maximum peak for the entire sample (to be used as a comparison during silence evaluation).
sample_all_dB = Get maximum... 0 0 none

selectObject: "Spectrum 'namedefo$'"
plusObject: "Ltas 'namedefo$'"
Remove


#################################################################
### Spectrogram plotting of the entire spectrum (0-1000 Hz)######
#################################################################
Erase all

selectObject: sounddefo
To Pitch (ac): 0, 75, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, 600
Rename... 'namedefo$'_1



#Spectrograms up to 1000 Hz are drawn. (with 500 horizontal * 400 vertical ratio）
do ("Select outer viewport...", 0, 10, 0, 8)
select Sound 'namedefo$'
    To Spectrogram... 0.1 1000 0.002 2 Gaussian
　　    Black
      Paint... 0 0 0 0 100 yes 50 0 0 no
    Text: duration/2, "centre", 1020, "half", "'namedefo$'"
　　#Text: 0, "right", h1_all_Hz, "half", fixed$(h1_all_Hz, 1)
　　Red
　　Text: duration/2, "centre", -20, "half", "'SFEEDS'"

do ("Select outer viewport...", 0, 10, 0, 8)
    Black
    Line width... 0.5
   　select Pitch 'namedefo$'_1
     Formula: "0"
   　Draw... 0 0 0 1000 yes


#################################################################
################### End of overall delineation.　######################
#################################################################




#################################################################
#########Start of frame-by-frame calculation and delineation.　############
#################################################################


#######　Create files for frame analysis (Gaussian window ). ###############
##### x is the frame length #####
####  n is the number of frames ########
##### x*n = number of seconds available for analysis ##########


for number from 1 to 'n'
　　selectObject: sounddefo
   Extract part: (number-1)*'time_step', x+(number-1)*'time_step', "Gaussian1", 1, "no"
   Rename: "'namedefo$'_'number'"
endfor


############ Start of frame-by-frame circulation.　######################
#################################################################

for i from 1 to 'n'
selectObject: "Sound 'namedefo$'_'i'"

sound = selected("Sound")
name$ = selected$ ("Sound")

To Ltas: 6

#Find the maximum spectral peak in the frame.
frame_all_dB = Get maximum... 0 0 none


h_defo_dB = Get maximum... 50 400 none
h_defo_Hz = Get frequency of maximum... 50 400 none


for z from 2 to 7
h_'z'_dB = Get maximum... (z-1)/8*h_defo_Hz z/8*h_defo_Hz None
h_'z'_Hz = Get frequency of maximum... (z-1)/8*h_defo_Hz z/8*h_defo_Hz None
endfor

#################################################################
################### Dominant Spectrum Test　######################
#################################################################

#Select the fundamental frequency from these spectral peaks
#If the difference between the highest spectral peak and the highest spectral peak is within d(dB), the structure is recognised as an harmonics structure.
#In order from the lowest frequency.
#Adopt larger peaks in adjacent search ranges

if h_2_dB > h_defo_dB - d  and   h_2_dB > h_3_dB
  h1_Hz = h_2_Hz
  h1_dB = h_2_dB
elsif h_2_dB > h_defo_dB - d  and   h_2_dB < h_3_dB
  h1_Hz = h_3_Hz
  h1_dB = h_3_dB

elsif h_3_dB > h_defo_dB - d  and   h_3_dB > h_4_dB
  h1_Hz = h_3_Hz
  h1_dB = h_3_dB
elsif h_3_dB > h_defo_dB - d  and   h_3_dB < h_4_dB
  h1_Hz = h_4_Hz
  h1_dB = h_4_dB

elsif h_4_dB > h_defo_dB - d  and   h_4_dB > h_5_dB
  h1_Hz = h_4_Hz
  h1_dB = h_4_dB
elsif h_4_dB > h_defo_dB - d  and   h_4_dB < h_5_dB
  h1_Hz = h_5_Hz
  h1_dB = h_5_dB

elsif h_5_dB > h_defo_dB - d   and   h_5_dB > h_6_dB
  h1_Hz = h_5_Hz
  h1_dB = h_5_dB
elsif h_5_dB > h_defo_dB - d   and   h_5_dB < h_6_dB
  h1_Hz = h_6_Hz
  h1_dB = h_6_dB

elsif h_6_dB > h_defo_dB - d  and   h_6_dB > h_7_dB
  h1_Hz = h_6_Hz
  h1_dB = h_6_dB
elsif h_6_dB > h_defo_dB - d  and   h_6_dB < h_7_dB
  h1_Hz = h_7_Hz
  h1_dB = h_7_dB
 
elsif h_7_dB > h_defo_dB - d and h_7_dB > h_defo_dB
  h1_Hz = h_7_Hz
  h1_dB = h_7_dB

else
   h1_Hz = h_defo_Hz
   h1_dB = h_defo_dB
endif

  h1_score_'i' = h1_dB
  h1_Hz_'i' = h1_Hz


#################################################################
#################################################################
################ Sequential Spectrum Test　######################
#################################################################
#################################################################

#In the frequency band 1/10 around the frequency calculated in the previous frame (h1_Hz_'previous').
#If a frequency component with equivalent power (within ±1/10) and within ◯dB (noHarmonics_lower_than_frame) of the maximum spectrum in the frame is also present in this frame.
#The result of the Sequential Spectrum test is used as the frame frequency candidate in preference to the Dominant Spectrum test.
#In other words, when a continuous fo spectral structure cannot be confirmed between consecutive frames, such as at the start and end of a phrase or during a Pitch Jump, a new fo is detected by the Dominant Spectrum Test.

h1_Hz_0 = 0
h1_score_0 = 0
previous = i-1
previous2 = i-2
#appendInfoLine: previous
#appendInfoLine: h1_Hz_'previous'


######
if h1_Hz_'previous'<>0 
h_CompareWithPrevious_dB = Get maximum... 9/10*h1_Hz_'previous' 11/10*h1_Hz_'previous' None
h_CompareWithPrevious_Hz = Get frequency of maximum... 9/10*h1_Hz_'previous' 11/10*h1_Hz_'previous' None
#appendInfoLine: "previous_was_not0Hz"

if h_CompareWithPrevious_dB > h1_score_'previous' - dd and h_CompareWithPrevious_dB < h1_score_'previous' + dd and h_CompareWithPrevious_dB > frame_all_dB - noHarmonics_lower_than_frame 
  h1_score_'i' = h_CompareWithPrevious_dB
  h1_Hz_'i' = h_CompareWithPrevious_Hz

else
 #
endif

else
 #
endif


#################################################################
#################################################################
############# Dominant Spectrum Test　Completed ##################
############# Sequential Spectrum Test　Completed ################
#################################################################
#################################################################




################Search above and below the candidate frequency (h1_Hz_'i') in the frame####################
########################Correction if 2fo is mis-detected.####################################
###
# 1.5 times Hz of the extracted frequency
h_search15_dB_'i' = Get maximum... 1.5*h1_Hz_'i'-10 1.5*h1_Hz_'i'+10 None
h_search15_Hz_'i' = Get frequency of maximum... 1.5*h1_Hz_'i'-10 1.5*h1_Hz_'i'+10 None

# 0.5 times Hz of the extracted frequency
h_search05_dB_'i' = Get maximum... 1/2*h1_Hz_'i'-10 1/2*h1_Hz_'i'+10 None
h_search05_Hz_'i' = Get frequency of maximum... 1/2*h1_Hz_'i'-10 1/2*h1_Hz_'i'+10 None


#If 2fo is mis-detected, the spectral intensity should be fo≒2fo.
#If the spectrum with the lower (0.5x) intra-frame candidate frequency (h1_Hz_'i') is within ddd(db) of the peak difference with h1_score_'i' and is strong enough to be a valid overtone compared to the whole frame dB, then 2fo is mis-detected.
if h_search05_dB_'i' > h1_score_'i' - ddd and h_search05_dB_'i' > frame_all_dB - noHarmonics_lower_than_frame
  h1_score_'i' =   h_search05_dB_'i'
  h1_Hz_'i' =  h_search05_Hz_'i' 
endif


########################Correction if 1.5fo is mis-detected####################################
# 2/3 times Hz of the extracted frequency
h_search23_dB_'i' = Get maximum... 2/3*h1_Hz_'i'-10 2/3*h1_Hz_'i'+10 None
h_search23_Hz_'i' = Get frequency of maximum... 2/3*h1_Hz_'i'-10 2/3*h1_Hz_'i'+10 None

# If h_search23_dB is within ddd(db) of the peak difference from h1_score_'i' and is strong enough to be a valid overtone compared to the whole frame dB, 1.5 fo is corrected as mis-detected.
if  h_search23_dB_'i' > h1_score_'i' - ddd   and  h_search23_dB_'i' > frame_all_dB - noHarmonics_lower_than_frame
  h1_score_'i' =   h_search23_dB_'i'
  h1_Hz_'i' =  h_search23_Hz_'i' 
endif


###############################################################


#▲Frames that are lower than the maximum dB of the entire sample by more than ◯dB (noLoud_lower_than_allsample) are set to 0 dB as "silent".
if  h1_score_'i' < sample_all_dB - noLoud_lower_than_allsample
  h1_score_'i' = 0
  h1_Hz_'i' = 0
endif

#Excludes recording noise and the low-frequency spectrum generated by speech tremor.
if h1_Hz_'i' <50
   h1_score_'i' = 0
  　h1_Hz_'i' = 0
endif


#################################################################
if draw_estimated_pitch = 1

#Drawing extracted fo for each frame.
#The spectrum set to 0 above as too weak is not drawn in the Spectrogram.
if  h1_score_'i' > 0
do ("Select outer viewport...", 0, 10, 0, 8)
    Red
    Paint circle (mm): "red", time_step*(i-1)+frame_length/2, h1_Hz_'i', 0.6
endif


endif


#################################################################
#################################################################

#Remove unwanted files generated by frame analysis.
selectObject: "Ltas 'name$'"
Remove


 bin_f0PeakdB_'i' = h1_score_'i' 
 bin_f0PeakHz_'i' = h1_Hz_'i'

endfor


#################################################################
############### End of frame-by-frame delineation.　###################
#################################################################



selectObject: "Sound 'namedefo$'_1"
for number from 2 to 'n'
plusObject: "Sound 'namedefo$'_'number'"
endfor
Remove





#################################################################
###################### Exporting spectrograms.　###################
#################################################################


 select Pitch 'namedefo$'_1
 plus Spectrogram 'namedefo$'
  Remove

label nonvoice
    #fappendinfo 'save_directory$'/'namedefo$'.txt
    do ("Select outer viewport...", 0, 12, 0, 9)
    do ("Save as 300-dpi PNG file...", "/Users/Username/Desktop/Filename/Result'namedefo$'.png")
endfor


#################################################
exitScript: "Finished!"
