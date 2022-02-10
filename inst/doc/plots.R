## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(musclesyneRgies)

## ---- message = FALSE, results = "hide", fig.width = 7, fig.asp = 0.9---------
# Load the built-in example data set
data("RAW_DATA")

# Raw EMG can be plotted with the following (the first three seconds are plot by default)
pp <- plot_rawEMG(
  RAW_DATA[[1]],
  trial = names(RAW_DATA)[1],
  row_number = 4,
  col_number = 4,
  line_col = "tomato3"
)

## ---- message = FALSE, results = "hide", fig.width = 7, fig.asp = 0.9---------
# Filter...
filtered_EMG <- lapply(RAW_DATA, function(x) filtEMG(x))
# ...and normalise raw EMG
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

# The filtered and time-normalised EMG can be plotted with the following
pp <- plot_meanEMG(
  norm_EMG[[1]],
  trial = names(norm_EMG)[1],
  row_number = 4,
  col_number = 4,
  line_size = 0.8,
  line_col = "tomato3"
)

## ---- message = FALSE, results = "hide", fig.width = 6, fig.asp = 1-----------
# Extract synergies via NMF
SYNS <- lapply(norm_EMG, synsNMF)

# The extracted synergies can be plotted with the following
pp <- plot_syn_trials(SYNS[[1]],
  max_syns = max(unlist(lapply(SYNS, function(x) x$syns))),
  trial = names(SYNS)[1],
  line_size = 0.8,
  line_col = "tomato1",
  sd_col = "tomato4"
)

## ---- message = FALSE, results = "hide", fig.width = 5, fig.asp = 0.7---------
# Load synergies
data("SYNS")

# Classify with k-means
# A plot of FWHM vs. CoA of the classified synergies appears by default
# This should help the user to identify potential malfunctions in the clustering
SYNS_classified <- classify_kmeans(SYNS)

## ---- message = FALSE, results = "hide", fig.width = 6, fig.asp = 1-----------
# Classified synergies can be finally plotted with
pp <- plot_classified_syns(SYNS_classified,
  line_col = "tomato1",
  sd_col = "tomato4",
  condition = "TW"
) # "TW" = Treadmill Walking, change with your own

## ---- message = FALSE, results = "hide", fig.width = 5, fig.asp = 1.4---------
pp <- plot_classified_syns_UMAP(
  SYNS_classified,
  condition = "TW"
)

