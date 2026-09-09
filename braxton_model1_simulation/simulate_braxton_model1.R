
# simulate_braxton_model1.R
# Clean simulation of Braxton et al. Model 1 for learning/debugging the Kalman filter + EM algorithm.

set.seed(123)

N <- 2500
years <- 2011:2025
T <- length(years)

# Model 1 parameters reported in Braxton et al. Table 2
F  <- 0.9316
QE <- 0.06894
QU <- 0.2751
BE <- 0.0005
BU <- -0.1877
Q0 <- 0.6733

# Table 2 does not report R, so this is a simulation choice.
R <- 0.05

# Employment transition probabilities are simulation choices.
p_EU <- 0.04
p_UE <- 0.57

result <- vector("list", N * T)
row_num <- 1

for (i in seq_len(N)) {

  member_id <- sprintf("M%06d", i)

  # z_i0 ~ N(0, Q0)
  z_prev <- rnorm(1, mean = 0, sd = sqrt(Q0))

  # Paper's sampling setup begins with everyone employed
  employed_prev <- 1

  for (tt in seq_along(years)) {

    if (tt == 1) {
      employed <- 1
    } else if (employed_prev == 1) {
      employed <- as.integer(runif(1) >= p_EU)
    } else {
      employed <- as.integer(runif(1) < p_UE)
    }

    lE <- employed
    lU <- 1 - employed

    B <- if (employed == 1) BE else BU
    Q <- if (employed == 1) QE else QU

    # Persistent state equation:
    # z_it = F z_i,t-1 + B(l_it) + nu_it
    nu <- rnorm(1, mean = 0, sd = sqrt(Q))
    z <- F * z_prev + B + nu

    # Measurement equation:
    # y_it = z_it + omega_it if employed; missing if unemployed
    if (employed == 1) {
      omega <- rnorm(1, mean = 0, sd = sqrt(R))
      y <- z + omega
    } else {
      omega <- NA_real_
      y <- NA_real_
    }

    result[[row_num]] <- data.frame(
      member_id = member_id,
      year = years[tt],
      t = tt,
      lE = lE,
      lU = lU,
      y = y,
      z_true = z,
      z_lag_true = z_prev,
      nu_true = nu,
      omega_true = omega
    )

    row_num <- row_num + 1
    z_prev <- z
    employed_prev <- employed
  }
}

truth <- do.call(rbind, result)

observed <- truth[, c("member_id", "year", "t", "lE", "lU", "y")]

write.csv(truth, "simulated_income_truth.csv", row.names = FALSE)
write.csv(observed, "simulated_income_observed.csv", row.names = FALSE)
