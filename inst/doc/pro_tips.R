## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(musclesyneRgies)

## ---- eval = FALSE------------------------------------------------------------
#  # Load the built-in example data set
#  data("FILT_EMG")
#  
#  # Create cluster for parallel computing if not already done
#  clusters <- objects()
#  
#  if (sum(grepl("^cl$", clusters)) == 0) {
#    # Decide how many processor threads have to be excluded from the cluster
#    # It is a good idea to leave at least one free, so that the machine can be
#    # used during computation
#    cl <- parallel::makeCluster(max(1, parallel::detectCores() - 1))
#  }
#  # Extract synergies in parallel (will speed up computation only for larger data sets)
#  # with a useful progress bar from `pbapply`
#  SYNS <- pbapply::pblapply(FILT_EMG, musclesyneRgies::synsNMF, cl = cl)
#  
#  parallel::stopCluster(cl)

## -----------------------------------------------------------------------------
# Thirty-cycle locomotor primitive from Santuz & Akay (2020)
data(primitive)

# HFD with k_max = 10 to consider only the most linear part of the log-log plot
# (it's the default value for this function anyway)
Higuchi_fd <- HFD(primitive$signal, k_max = 10)$Higuchi
message("Higuchi's fractal dimension: ", round(Higuchi_fd, 3))

# H with min_win = 200 points, which is the length of each cycle
Hurst_exp <- Hurst(primitive$signal, min_win = max(primitive$time))$Hurst
message("Hurst exponent: ", round(Hurst_exp, 3))

