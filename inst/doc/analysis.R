## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(musclesyneRgies)

## ---- results = "hide", fig.width = 4, fig.asp = 1----------------------------
# Load a typical motor primitive of 30 cycles (from locomotion)
data("primitive")

# Reduce primitive to the first cycle
prim_sub <- primitive$signal[1:which(primitive$time == max(primitive$time))[1]]

# Calculate FWHM of the first cycle
prim_sub_FWHM <- FWHM(prim_sub)
# Calculate CoA of the first cycle
prim_sub_CoA <- CoA(prim_sub)

# Half maximum (for the plots)
hm <- min(prim_sub) + (max(prim_sub) - min(prim_sub)) / 2
hm_plot <- prim_sub
hm_plot[which(hm_plot > hm)] <- hm
hm_plot[which(hm_plot < hm)] <- NA

# Plots
plot(prim_sub, ty = "l", xlab = "Time", ylab = "Amplitude")
lines(hm_plot, lwd = 3, col = 2) # FWHM (horizontal, in red)
graphics::abline(v = prim_sub_CoA, lwd = 3, col = 4) # CoA (vertical, in blue)

## ---- results = "hide"--------------------------------------------------------
prim <- primitive$signal

# Calculate the local complexity or Higuchi's fractal dimension (HFD)
nonlin_HFD <- HFD(prim)$Higuchi
# Calculate the local complexity or Hurst exponent (H)
nonlin_H <- Hurst(prim, min_win = max(primitive$time))$Hurst

message("Higuchi's fractal dimension: ", round(nonlin_HFD, 3))
message("Hurst exponent: ", round(nonlin_H, 3))

