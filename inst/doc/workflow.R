## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(musclesyneRgies)

## ---- eval = FALSE------------------------------------------------------------
#  # Load package
#  library(musclesyneRgies)
#  
#  # The simplest formulation, using the native (R >= `4.1.0`) pipe operator
#  # Here, the raw data set is already in the correct format and named `RAW_DATA`
#  SYNS_classified <- lapply(RAW_DATA, function(x) subsetEMG(x, cy_max = 32)) |>
#    lapply(filtEMG) |>
#    lapply(function(x) normEMG(x, cy_max = 30, cycle_div = c(100, 100))) |>
#    lapply(synsNMF) |>
#    classify_kmeans()
#  
#  # Alternatively, one can save every step for subsequent inspection/analysis as follows
#  # Read raw data from ASCII files
#  RAW_DATA <- rawdata(header_cycles = FALSE)
#  # Subset EMG to reduce the amount of data to the first 32 available cycles
#  RAW_DATA <- lapply(RAW_DATA, function(x) subsetEMG(x, cy_max = 32))
#  # Filter EMG
#  FILT_DATA <- lapply(RAW_DATA, filtEMG)
#  # Normalise filtered EMG, trim first and last cycle (32 were available, 30 will be left)
#  # and divide cycle into two phases of 100 data points each
#  NORM_EMG <- lapply(FILT_DATA, function(x) normEMG(x, cy_max = 30, cycle_div = c(100, 100)))
#  # Extract synergies
#  SYNS <- lapply(NORM_EMG, synsNMF)
#  # Classify synergies with k-means
#  # (the result is equivalent to the previous obtained with piping)
#  SYNS_classified <- classify_kmeans(SYNS)

## -----------------------------------------------------------------------------
data("RAW_DATA")
head(RAW_DATA[[1]]$cycles)
head(RAW_DATA[[1]]$emg)

## -----------------------------------------------------------------------------
# Load built-in data set
data("RAW_DATA")

# Get current working directory
data_path <- getwd()
data_path <- paste0(data_path, .Platform$file.sep)

# Create two conveniently-named subfolders if they don't already exist
# (if they exist, please make sure they're empty!)
dir.create("cycles", showWarnings = FALSE)
dir.create("emg", showWarnings = FALSE)

# Export ASCII data from built-in data set to the new subfolders
write.table(RAW_DATA[[1]]$cycles,
  file = paste0(data_path, "cycles", .Platform$file.sep, names(RAW_DATA)[1], ".txt"),
  sep = "\t", row.names = FALSE
)
write.table(RAW_DATA[[1]]$emg,
  file = paste0(data_path, "emg", .Platform$file.sep, names(RAW_DATA)[1], ".txt"),
  sep = "\t", row.names = FALSE
)

# Run the function to parse ASCII files into objects of class `EMG`
raw_data_from_files <- rawdata(
  path_cycles = paste0(data_path, "/cycles/"),
  path_emg = paste0(data_path, "/emg/"),
  header_cycles = FALSE
)

# Check data in the new folders if needed before running the following (will delete!)

# Delete folders
unlink("cycles", recursive = TRUE)
unlink("emg", recursive = TRUE)

## ---- message = FALSE, results = "hide"---------------------------------------
# Load the built-in example data set
data("RAW_DATA")

# Say you recorded more cycles than those you want to consider for the analysis
# You can subset the raw data (here we keep only 3 cycles, starting from the first)
RAW_DATA_subset <- lapply(
  RAW_DATA,
  function(x) {
    subsetEMG(x,
      cy_max = 3,
      cy_start = 1
    )
  }
)

# The raw EMG data set then needs to be filtered
# If you don't want to subset the data set, just filter it as it is
# Here we filter the whole data set with the default parameters for locomotion:
# - Demean EMG
# - High-pass IIR Butterworth 4th order filter (cut-off frequency 50 Hz)
# - Full-wave rectification (default)
# - Low-pass IIR Butterworth 4th order filter (cut-off frequency 20 Hz)
# - Minimum subtraction
# - Amplitude normalisation
filtered_EMG <- lapply(RAW_DATA, function(x) filtEMG(x))

# If you decide to change filtering parameters, just give them as arguments:
another_filtered_EMG <- lapply(
  RAW_DATA,
  function(x) {
    filtEMG(x,
      demean = FALSE,
      rectif = "halfwave",
      HPf = 30,
      HPo = 2,
      LPf = 10,
      LPo = 2,
      min_sub = FALSE,
      ampl_norm = FALSE
    )
  }
)

# Now the filtered EMG needs some time normalisation so that cycles will be comparable
# Here we time-normalise the filtered EMG, including only three cycles and trimming first
# and last to remove unwanted filtering effects
# Each cycle is divided into two parts, each normalised to a length of 100 points
norm_EMG <- lapply(
  filtered_EMG,
  function(x) {
    normEMG(x,
      trim = TRUE,
      cy_max = 3,
      cycle_div = c(100, 100)
    )
  }
)

# If this cycle division does not work for you, it can be changed
# But please remember to have the same amount of columns in the cycle times as the number
# of phases you want your cycles to be divided into
# Here we divide each cycle with a ratio of 60%-40% and keep only two cycles (first and last
# are still trimmed, so to have two cycles you must start with at least four available)
another_norm_EMG <- lapply(
  filtered_EMG,
  function(x) {
    normEMG(x,
      trim = TRUE,
      cy_max = 2,
      cycle_div = c(120, 80)
    )
  }
)

# At this stage, synergies can be extracted
# This is the core function to extract synergies via NMF
SYNS <- lapply(norm_EMG, synsNMF)

# Now synergies don't have a functional order and need classification
# Let's load the built-in data set to have some more trial to classify
# (clustering cannot be done on only one trial and having just a few,
# say less than 10, won't help)
data("SYNS")

# Classify with k-means# and producing a plot that shows how the clustering went with:
# - Full width at half maximum on the x-axis
# - Centre of activity on the y-axis
# (both referred to the motor primitives of the classified muscle synergies)
SYNS_classified <- classify_kmeans(SYNS)

