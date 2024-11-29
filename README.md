# SFEEDS
Spectral-based fo Estimator Emphasized by Domination and Sequence (SFEEDS) scripts activated in Praat software.

This repository contains the SFEEDS custom script designed for use with Praat, a free acoustic analysis software.

This script can be used to calculate time series changes in fundamental frequency from voice files, with or without hoarseness.

Below are step-by-step instructions to help you get started.　　

# Prerequisites
## Download and install Praat:
Visit the Praat website. (https://www.fon.hum.uva.nl/praat/)

Select the version compatible with your operating system (Windows, macOS, or Linux).　　

Download and install the software following the provided instructions.　　

## Prepare the audio files:
Ensure you have the required audio files ready for analysis:

Voice samples should be recorded in an acoustically treated room and stored as a digitised WAV. format with a sampling rate of 44.1 kHz and 16-bit resolution using a head-mounted microphone, and meet the generally required level of signal-to-noise ratio (>30 dB). 


# How to Use SFEEDS in Praat
## Open the audio files in Praat:
Launch Praat.

Go to Open > Read from file in the menu to load your audio files.

## Run the SFEEDS script:
In Praat, click on Praat > New Praat Script > Paste the SFEEDS script > 

Once the script is loaded, press the Run button in the script editor to start the process.

## Input parameters in the SFEESS script:
Enter the following details in the pop-up dialog box:

Sound Number: number assigned to the file in the Praat Objects window. Enter the start and end points to be analysed. (If you want to analyse only Object No. 1, enter 1 to 1).

Save directory: Specify the directory where the analysis results should be saved.

Click OK after entering all parameters.

The script will generate:　　

・PNG file: Image with the fundamental frequencies estimated by SFEEDS overlaid on the narrow-band Spctrogram.
