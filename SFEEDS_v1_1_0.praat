form SFEEDS ver.1.1.0
    comment Spectral-based fo Estimator Emphasized by Domination and Sequence
    comment Analysis target: Praat Sound object numbers
    real left_Number_of_Object 1
    real right_Number_of_Object 1

    comment Output options
    boolean save_png 1
    boolean save_sfeeds_pitch_object 1
    comment Pitch export chunk size; default 1000. If memory is insufficient, reduce this value.
    natural pitch_export_chunk_size 1000
    boolean read_sfeeds_pitch_object_into_praat 1
    boolean save_sfeeds_tsv 1
    boolean save_log_tsv 1

    comment Save directory; use / as path separator when possible
    sentence Save_directory C:/Apps/Praat/Result
endform

#############################################
# Fixed parameters for SFEEDS v1.1.0
# These parameters are fixed to preserve reproducibility
# and compatibility with the original SFEEDS algorithm.
# Do not modify unless validating a new version.
#############################################

# Frame length and distance between frame centres
frame_length = 0.1
time_step = 0.0033

# Input standardization
convert_stereo_to_mono = 1
target_sampling_frequency = 44100
resample_to_target_sampling_frequency = 1

# Unified average intensity of samples
intensity_resample = 1
avg_int = 70

# Differential value of dB judged as a silent frame
noLoud_lower_than_allsample = 30

# Differential value of dB determined as frames containing harmonics
noHarmonics_lower_than_frame = 20

# Difference between fo candidate and maximum value between 50-400 Hz [dB]
diff1 = 10

# Frequency proximity of the Sequential Spectrum Test
diff2 = 10

# For correcting false detection
diff3 = 10

# Drawing option used internally for PNG export
draw_estimated_pitch = 1

# Core SFEEDS parameters
d = diff1
dd = diff2
ddd = diff3

# Use a forward slash separator for cross-platform compatibility.
# The save directory must already exist.

#############################################
# Prepare run-level log TSV
#############################################
if save_log_tsv = 1
    log_tsv_file$ = save_directory$ + "/SFEEDS_log.tsv"
    if fileReadable(log_tsv_file$)
        deleteFile: log_tsv_file$
    endif
    appendFileLine: log_tsv_file$, "SFEEDS_version", tab$, "Original_object_name", tab$, "Analyzed_sound_name", tab$, "Original_sampling_frequency", tab$, "Analyzed_sampling_frequency", tab$, "Target_sampling_frequency", tab$, "Original_channels", tab$, "Analyzed_channels", tab$, "Converted_to_mono", tab$, "Resampled_to_target", tab$, "Duration", tab$, "Frame_length", tab$, "Time_step", tab$, "Number_of_frames", tab$, "Intensity_resampling", tab$, "Average_intensity", tab$, "diff1", tab$, "diff2", tab$, "diff3", tab$, "Save_png", tab$, "Save_SFEEDS_pitch_object", tab$, "Pitch_export_chunk_size", tab$, "Read_SFEEDS_pitch_object_into_Praat", tab$, "Save_SFEEDS_tsv"
endif

for s from left_Number_of_Object to right_Number_of_Object

    #############################################
    # Select sound and basic input preparation
    #############################################
    select 's'
    sounddefo = selected("Sound")
    namedefo$ = selected$("Sound")
    original_name$ = namedefo$
    converted_to_mono = 0
    resampled_to_target = 0

    # Convert stereo/multichannel sounds to mono by extracting channel 1.
    selectObject: sounddefo
    number_of_channels = Get number of channels
    if number_of_channels <> 1
        if convert_stereo_to_mono = 1
            Extract one channel: 1
            mono_sound = selected("Sound")
            selectObject: sounddefo
            Remove
            selectObject: mono_sound
            Rename: "'namedefo$'"
            sounddefo = selected("Sound")
            converted_to_mono = 1
        else
            exitScript: "SFEEDS error: Sound '", namedefo$, "' is not mono."
        endif
    endif

    # Resample to the target sampling frequency if requested.
    selectObject: sounddefo
    original_sampling_frequency = Get sampling frequency
    if abs(original_sampling_frequency - target_sampling_frequency) > 0.5
        if resample_to_target_sampling_frequency = 1
            Resample: target_sampling_frequency, 50
            resampled_sound = selected("Sound")
            selectObject: sounddefo
            Remove
            selectObject: resampled_sound
            Rename: "'namedefo$'"
            sounddefo = selected("Sound")
            resampled_to_target = 1
        else
            exitScript: "SFEEDS error: Sound '", namedefo$, "' has sampling frequency ", original_sampling_frequency, " Hz."
        endif
    endif

    selectObject: sounddefo
    analyzed_sampling_frequency = Get sampling frequency
    analyzed_number_of_channels = Get number of channels
    duration = Get total duration
    if duration <= frame_length
        exitScript: "SFEEDS error: Sound '", namedefo$, "' is too short for the selected frame length."
    endif

    x = frame_length
    n = round((duration - frame_length) / time_step) + 2
    if n < 1
        exitScript: "SFEEDS error: The number of analysis frames is less than 1."
    endif

    #############################################
    # Unify the average intensity of the sample
    #############################################
    if intensity_resample = 1
        Scale intensity: avg_int
    endif

    #############################################
    # Calculate whole-sample spectral maximum
    #############################################
    To Spectrum... yes
    To Ltas (1-to-1)

    # Maximum spectral peak for the entire sample, used for silence evaluation.
    sample_all_dB = Get maximum... 0 0 none

    selectObject: "Spectrum 'namedefo$'"
    plusObject: "Ltas 'namedefo$'"
    Remove

    #############################################
    # Draw overall spectrogram
    #############################################
    Erase all

    selectObject: sounddefo
    To Pitch (ac): 0, 75, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, 600
    Rename: "'namedefo$'_axis"

    do ("Select outer viewport...", 0, 10, 0, 8)
    selectObject: sounddefo
    To Spectrogram... 0.1 1000 0.002 2 Gaussian
    Black
    Paint... 0 0 0 0 100 yes 50 0 0 no
    Text: duration/2, "centre", 1020, "half", "'namedefo$'"
    Red
    Text: duration/2, "centre", -20, "half", "SFEEDS"

    do ("Select outer viewport...", 0, 10, 0, 8)
    Black
    Line width... 0.5
    selectObject: "Pitch 'namedefo$'_axis"
    Formula: "0"
    Draw... 0 0 0 1000 yes

    #############################################
    # Create frame sounds for frame-by-frame analysis
    #############################################
    for number from 1 to n
        selectObject: sounddefo
        Extract part: (number - 1) * time_step, x + (number - 1) * time_step, "Gaussian1", 1, "no"
        Rename: "'namedefo$'_'number'"
    endfor

    #############################################
    # Frame-by-frame SFEEDS analysis
    #############################################
    h1_Hz_0 = 0
    h1_score_0 = 0

    for i from 1 to n
        selectObject: "Sound 'namedefo$'_'i'"
        sound = selected("Sound")
        name$ = selected$("Sound")

        To Ltas: 6

        # Maximum spectral peak in the frame.
        frame_all_dB = Get maximum... 0 0 none

        # Maximum spectral peak between 50 and 400 Hz.
        h_defo_dB = Get maximum... 50 400 none
        h_defo_Hz = Get frequency of maximum... 50 400 none

        for z from 2 to 7
            h_'z'_dB = Get maximum... (z-1)/8*h_defo_Hz z/8*h_defo_Hz none
            h_'z'_Hz = Get frequency of maximum... (z-1)/8*h_defo_Hz z/8*h_defo_Hz none
        endfor

        #############################################
        # Dominant Spectrum Test
        #############################################
        if h_2_dB > h_defo_dB - d and h_2_dB > h_3_dB
            h1_Hz = h_2_Hz
            h1_dB = h_2_dB
        elsif h_2_dB > h_defo_dB - d and h_2_dB < h_3_dB
            h1_Hz = h_3_Hz
            h1_dB = h_3_dB
        elsif h_3_dB > h_defo_dB - d and h_3_dB > h_4_dB
            h1_Hz = h_3_Hz
            h1_dB = h_3_dB
        elsif h_3_dB > h_defo_dB - d and h_3_dB < h_4_dB
            h1_Hz = h_4_Hz
            h1_dB = h_4_dB
        elsif h_4_dB > h_defo_dB - d and h_4_dB > h_5_dB
            h1_Hz = h_4_Hz
            h1_dB = h_4_dB
        elsif h_4_dB > h_defo_dB - d and h_4_dB < h_5_dB
            h1_Hz = h_5_Hz
            h1_dB = h_5_dB
        elsif h_5_dB > h_defo_dB - d and h_5_dB > h_6_dB
            h1_Hz = h_5_Hz
            h1_dB = h_5_dB
        elsif h_5_dB > h_defo_dB - d and h_5_dB < h_6_dB
            h1_Hz = h_6_Hz
            h1_dB = h_6_dB
        elsif h_6_dB > h_defo_dB - d and h_6_dB > h_7_dB
            h1_Hz = h_6_Hz
            h1_dB = h_6_dB
        elsif h_6_dB > h_defo_dB - d and h_6_dB < h_7_dB
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

        #############################################
        # Sequential Spectrum Test
        #############################################
        previous = i - 1
        if h1_Hz_'previous' <> 0
            h_CompareWithPrevious_dB = Get maximum... 9/10*h1_Hz_'previous' 11/10*h1_Hz_'previous' none
            h_CompareWithPrevious_Hz = Get frequency of maximum... 9/10*h1_Hz_'previous' 11/10*h1_Hz_'previous' none

            if h_CompareWithPrevious_dB > h1_score_'previous' - dd and h_CompareWithPrevious_dB < h1_score_'previous' + dd and h_CompareWithPrevious_dB > frame_all_dB - noHarmonics_lower_than_frame
                h1_score_'i' = h_CompareWithPrevious_dB
                h1_Hz_'i' = h_CompareWithPrevious_Hz
            endif
        endif

        #############################################
        # Correction if 2fo is mis-detected
        #############################################
        h_search15_dB_'i' = Get maximum... 1.5*h1_Hz_'i'-10 1.5*h1_Hz_'i'+10 none
        h_search15_Hz_'i' = Get frequency of maximum... 1.5*h1_Hz_'i'-10 1.5*h1_Hz_'i'+10 none

        h_search05_dB_'i' = Get maximum... 1/2*h1_Hz_'i'-10 1/2*h1_Hz_'i'+10 none
        h_search05_Hz_'i' = Get frequency of maximum... 1/2*h1_Hz_'i'-10 1/2*h1_Hz_'i'+10 none

        if h_search05_dB_'i' > h1_score_'i' - ddd and h_search05_dB_'i' > frame_all_dB - noHarmonics_lower_than_frame
            h1_score_'i' = h_search05_dB_'i'
            h1_Hz_'i' = h_search05_Hz_'i'
        endif

        #############################################
        # Correction if 1.5fo is mis-detected
        #############################################
        h_search23_dB_'i' = Get maximum... 2/3*h1_Hz_'i'-10 2/3*h1_Hz_'i'+10 none
        h_search23_Hz_'i' = Get frequency of maximum... 2/3*h1_Hz_'i'-10 2/3*h1_Hz_'i'+10 none

        if h_search23_dB_'i' > h1_score_'i' - ddd and h_search23_dB_'i' > frame_all_dB - noHarmonics_lower_than_frame
            h1_score_'i' = h_search23_dB_'i'
            h1_Hz_'i' = h_search23_Hz_'i'
        endif

        #############################################
        # Silence and low-frequency exclusion
        #############################################
        if h1_score_'i' < sample_all_dB - noLoud_lower_than_allsample
            h1_score_'i' = 0
            h1_Hz_'i' = 0
        endif

        if h1_Hz_'i' < 50
            h1_score_'i' = 0
            h1_Hz_'i' = 0
        endif

        #############################################
        # Draw extracted fo for each frame
        #############################################
        if draw_estimated_pitch = 1
            if h1_score_'i' > 0
                do ("Select outer viewport...", 0, 10, 0, 8)
                Red
                Paint circle (mm): "red", time_step * (i - 1) + frame_length / 2, h1_Hz_'i', 0.6
            endif
        endif

        # Save results in variables.
        bin_f0PeakdB_'i' = h1_score_'i'
        bin_f0PeakHz_'i' = h1_Hz_'i'

        # Remove unwanted Ltas object generated by frame analysis.
        selectObject: "Ltas 'name$'"
        Remove
    endfor

    #############################################
    # Remove frame sounds
    #############################################
    selectObject: "Sound 'namedefo$'_1"
    for number from 2 to n
        plusObject: "Sound 'namedefo$'_'number'"
    endfor
    Remove

    #############################################
    # Export SFEEDS f0 track as TSV
    #############################################
    if save_sfeeds_tsv = 1
        tsv_file$ = save_directory$ + "/SFEEDS_" + namedefo$ + ".tsv"
        if fileReadable(tsv_file$)
            deleteFile: tsv_file$
        endif
        appendFileLine: tsv_file$, "time_sec", tab$, "f0_Hz", tab$, "f0_dB", tab$, "voiced"
        for i from 1 to n
            time_sec = time_step * (i - 1) + frame_length / 2
            voiced = 0
            if bin_f0PeakHz_'i' > 0
                voiced = 1
            endif
            appendFileLine: tsv_file$, fixed$(time_sec, 6), tab$, fixed$(bin_f0PeakHz_'i', 6), tab$, fixed$(bin_f0PeakdB_'i', 6), tab$, string$(voiced)
        endfor
    endif

    #############################################
    # Export SFEEDS f0 track as a Praat Pitch object
    #############################################
    if save_sfeeds_pitch_object = 1
        pitch_file$ = save_directory$ + "/SFEEDS_" + namedefo$ + ".Pitch"
        if fileReadable(pitch_file$)
            deleteFile: pitch_file$
        endif

        # Writing a Pitch object line-by-line is very slow in Praat, especially on Windows.
        # Therefore, SFEEDS v1.1.0 writes the header once and then writes frame data in chunks.
        pitch_header$ = "File type = ""ooTextFile""" + newline$ +             "Object class = ""Pitch 1""" + newline$ + newline$ +             "xmin = 0" + newline$ +             "xmax = " + fixed$(duration, 10) + newline$ +             "nx = " + string$(n) + newline$ +             "dx = " + fixed$(time_step, 10) + newline$ +             "x1 = " + fixed$(frame_length / 2, 10) + newline$ +             "ceiling = 1000" + newline$ +             "maxnCandidates = 1" + newline$ +             "frames []:" + newline$
        appendFile: pitch_file$, pitch_header$

        pitch_chunk$ = ""
        pitch_chunk_size = round(pitch_export_chunk_size)
        if pitch_chunk_size < 1
            pitch_chunk_size = 1000
        endif
        for i from 1 to n
            f0 = bin_f0PeakHz_'i'
            score_dB = bin_f0PeakdB_'i'
            strength = 0
            if f0 > 0
                strength = 1
            endif

            pitch_chunk$ = pitch_chunk$ +                 "    frames [" + string$(i) + "]:" + newline$ +                 "        intensity = " + fixed$(score_dB, 6) + newline$ +                 "        nCandidates = 1" + newline$ +                 "        candidates []:" + newline$ +                 "            candidates [1]:" + newline$ +                 "                frequency = " + fixed$(f0, 6) + newline$ +                 "                strength = " + fixed$(strength, 6) + newline$

            if i = floor(i / pitch_chunk_size) * pitch_chunk_size
                appendFile: pitch_file$, pitch_chunk$
                pitch_chunk$ = ""
            endif
        endfor

        if length(pitch_chunk$) > 0
            appendFile: pitch_file$, pitch_chunk$
        endif

        if read_sfeeds_pitch_object_into_praat = 1
            Read from file: pitch_file$
            Rename: "SFEEDS_'namedefo$'"
        endif
    endif

    #############################################
    # Append run-level log TSV
    #############################################
    if save_log_tsv = 1
        appendFileLine: log_tsv_file$, "1.1.0", tab$, original_name$, tab$, namedefo$, tab$, fixed$(original_sampling_frequency, 3), tab$, fixed$(analyzed_sampling_frequency, 3), tab$, fixed$(target_sampling_frequency, 3), tab$, string$(number_of_channels), tab$, string$(analyzed_number_of_channels), tab$, string$(converted_to_mono), tab$, string$(resampled_to_target), tab$, fixed$(duration, 6), tab$, fixed$(frame_length, 6), tab$, fixed$(time_step, 6), tab$, string$(n), tab$, string$(intensity_resample), tab$, fixed$(avg_int, 3), tab$, fixed$(diff1, 3), tab$, fixed$(diff2, 3), tab$, fixed$(diff3, 3), tab$, string$(save_png), tab$, string$(save_sfeeds_pitch_object), tab$, string$(pitch_export_chunk_size), tab$, string$(read_sfeeds_pitch_object_into_praat), tab$, string$(save_sfeeds_tsv)
    endif

    #############################################
    # Export PNG spectrogram
    #############################################
    if save_png = 1
        png_file$ = save_directory$ + "/Result_" + namedefo$ + ".png"
        do ("Select outer viewport...", 0, 12, 0, 9)
        do ("Save as 300-dpi PNG file...", png_file$)
    endif

    # Remove drawing helper objects, but keep SFEEDS Pitch object if read into Praat.
    selectObject: "Pitch 'namedefo$'_axis"
    plusObject: "Spectrogram 'namedefo$'"
    Remove

endfor

exitScript: "Finished!"
