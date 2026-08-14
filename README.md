# SFEEDS

**Spectral-based fo Estimator Emphasized by Domination and Sequence (SFEEDS)** is a fundamental frequency estimation algorithm designed for use with Praat software.

SFEEDS can be used to estimate time-series changes in fundamental frequency from voice recordings, including both normal and hoarse voices.

## Current Version

**SFEEDS v1.1.0**

Version 1.1.0 improves the reproducibility and usability of the original SFEEDS implementation while retaining the original SFEEDS fo-estimation algorithm.

## Available Files

* `SFEEDS`
  Original SFEEDS script retained for backward compatibility with previously published or distributed links.

* `SFEEDS_v1_0_0.praat`
  Versioned copy of the original SFEEDS implementation.

* `SFEEDS_v1_1_0.praat`
  Current version. Recommended for new analyses.

* `README_v1.0.0.md`
  README for the original version.

## What's New in v1.1.0

SFEEDS v1.1.0 improves reproducibility and usability while retaining the original SFEEDS fo-estimation procedure.

Major updates include:

* analysis parameters that were user-adjustable in v1.0.0 are fixed at the original default values to improve reproducibility;
* automatic extraction of channel 1 from stereo or multichannel audio;
* automatic resampling to 44.1 kHz when required;
* standardized frame-by-frame output in TSV format;
* export of SFEEDS fo estimates as a Praat Pitch object;
* run-level logging of analysis settings and input-processing information;
* improved output-file and save-directory handling;
* additional input validation and error handling;
* selectable output options for PNG, TSV, Praat Pitch object, and log files.

The core SFEEDS fo-estimation procedure, including the Dominant Spectrum Test, Sequential Spectrum Test, and subsequent correction procedures, is retained from v1.0.0.

## Analysis Settings

To improve reproducibility, the principal SFEEDS analysis parameters are fixed in v1.1.0.

The default settings include:

* frame length: **0.1 s**
* time step: **0.0033 s**
* target sampling frequency: **44.1 kHz**
* mean intensity after normalization: **70 dB**
* silence threshold relative to the whole-sample spectral maximum: **30 dB**
* harmonic-component threshold relative to the frame spectral maximum: **20 dB**
* Dominant Spectrum Test threshold (`diff1`): **10 dB**
* Sequential Spectrum Test threshold (`diff2`): **10 dB**
* false-detection correction threshold (`diff3`): **10 dB**

These settings correspond to the original default settings used in SFEEDS v1.0.0.

## Prerequisites

### Download and Install Praat

Download and install Praat from:

https://www.fon.hum.uva.nl/praat/

Select the version compatible with your operating system (Windows, macOS, or Linux) and follow the installation instructions.

## Prepare the Audio Files

High-quality WAV recordings are recommended for acoustic voice analysis.

In the original SFEEDS study, voice samples were recorded in an acoustically treated room at a sampling rate of 44.1 kHz and 16-bit resolution using a head-mounted microphone, with a signal-to-noise ratio greater than 30 dB.

In SFEEDS v1.1.0:

* stereo or multichannel recordings are converted to mono by extracting channel 1;
* recordings are automatically resampled to 44.1 kHz when necessary;
* mean intensity is normalized to 70 dB before SFEEDS analysis.

## How to Use SFEEDS v1.1.0 in Praat

### 1. Open the Audio Files in Praat

Launch Praat.

Go to:

`Open > Read from file...`

and load the audio file or files to be analyzed.

The loaded recordings should appear as Sound objects in the Praat Objects window.

### 2. Open the SFEEDS Script

Open:

`SFEEDS_v1_1_0.praat`

in the Praat Script Editor.

### 3. Run the Script

Press the **Run** button in the Praat Script Editor.

A dialog box will appear.

### 4. Specify the Analysis Targets

Enter the Praat Sound object numbers to be analyzed.

For example, to analyze only Sound object No. 1:

* `left_Number_of_Object`: 1
* `right_Number_of_Object`: 1

To analyze consecutive Sound objects, enter the first and last object numbers.

### 5. Select Output Options

The following outputs can be enabled or disabled:

* PNG spectrogram
* SFEEDS Praat Pitch object
* frame-by-frame SFEEDS TSV
* run-level log TSV

The exported Praat Pitch object can also be automatically read back into the Praat Objects window.

### 6. Specify the Save Directory

Specify the directory in which the analysis results should be saved.

Using `/` as the path separator is recommended for cross-platform compatibility.

The specified directory must already exist before running the script.

Click **OK** to start the analysis.

## Output

Depending on the selected options, SFEEDS v1.1.0 generates the following files.

### Spectrogram

`Result_<SoundName>.png`

A 300-dpi PNG image showing the SFEEDS fo estimates overlaid on the spectrogram.

### Frame-by-Frame SFEEDS Data

`SFEEDS_<SoundName>.tsv`

A tab-separated file containing the SFEEDS result for each analysis frame.

The output columns are:

* `time_sec`
* `f0_Hz`
* `f0_dB`
* `voiced`

### Praat Pitch Object

`SFEEDS_<SoundName>.Pitch`

A Praat Pitch object containing the fo estimates generated by SFEEDS.

For long recordings, the Pitch object is written in chunks to reduce memory requirements during export.

### Run-Level Log

`SFEEDS_log.tsv`

A tab-separated log recording information including:

* SFEEDS version;
* original and analyzed sound names;
* original and analyzed sampling frequencies;
* number of channels;
* whether channel extraction was performed;
* whether resampling was performed;
* duration;
* frame length and time step;
* number of analysis frames;
* intensity-normalization settings;
* SFEEDS threshold parameters;
* selected output options.

## Version History

### v1.0.0

Original implementation of the SFEEDS algorithm.

The original script is also retained under the filename `SFEEDS` for backward compatibility.

### v1.1.0

Reproducibility and usability update.

The core SFEEDS fo-estimation procedure is retained, while analysis parameters, input handling, output functions, logging, save-directory handling, and error handling have been standardized or expanded.

## Citation

If you use SFEEDS in research, please cite the original publication describing the SFEEDS algorithm:

Kitayama I, Hosokawa K, et al. **Robust fundamental frequency-detection algorithm unaffected by the presence of hoarseness in human voice.** *The Journal of the Acoustical Society of America*. 2024;156:4217–4228. doi:10.1121/10.0034624
