# Simulated Braxton et al. Model 1 dataset

This is a deliberately clean annual panel for implementing the paper's Kalman filter,
Kalman smoother, and EM algorithm before introducing complications from real transaction data.

## Files

- `simulated_income_observed.csv`
  - Use this for estimation.
  - Columns: `member_id`, `year`, `t`, `lE`, `lU`, `y`.
  - `y` is residual log earnings and is missing when `lU = 1`.

- `simulated_income_truth.csv`
  - Same panel plus latent variables used to generate the data.
  - Use only after estimation to validate your recovered states/shocks.
  - Adds `z_true`, `z_lag_true`, `nu_true`, `omega_true`.

- `simulation_parameters.csv`
  - True DGP parameters.

- `simulate_braxton_model1.R`
  - R code implementing the DGP.

## DGP

Measurement equation:

    y_it = z_it + omega_it        if employed
    y_it = missing               if unemployed

Persistent state equation:

    z_it = F * z_i,t-1 + B(l_it) + nu_it

with

    Var(nu_it | employed)   = QE
    Var(nu_it | unemployed) = QU
    Var(omega_it | employed)= R
    z_i0 ~ N(0, Q0)

The reported Model 1 estimates from Table 2 are used for:
F, QE, QU, BE, BU, and Q0.

The paper's Table 2 does not report R, so R = 0.05 is a transparent simulation choice.

Employment transitions are simulated with:
P(U_t = 1 | E_t-1 = 1) = 0.04
P(E_t = 1 | U_t-1 = 1) = 0.57

These transition probabilities are only used to generate observed employment histories;
the baseline income filter conditions on employment status.

## Sample

- N = 2,500 individuals
- T = 15 years (2011-2025)
- Rows = 37,500
- Simulated unemployment share = 5.776%
- Employed earnings observations = 35,334

Start with `simulated_income_observed.csv`.
Do not use the truth columns in the filter or EM updates.
