"""
verify_qardl_python.py
======================
Cross-validates the GAUSS QARDL library against an independent Python
implementation using numpy + statsmodels.

The script replicates the QARDL(p=2, q=1) estimation from demo.e and
compares results against the published expected values in
  doc/demo_result_explanation.txt

Requirements:
    pip install numpy pandas statsmodels scipy

Usage:
    python verify_qardl_python.py

The script loads examples/qardl_data.dat, constructs the identical
regressor matrix used by the GAUSS qardl() procedure, runs quantile
regression at tau = [0.25, 0.50, 0.75], and prints a comparison table.

Reference: Cho, Kim & Shin (2015). "Quantile cointegration in the
autoregressive distributed-lag modeling framework." J. Econometrics.
"""

import numpy as np
import pandas as pd
from scipy.stats import norm
try:
    from statsmodels.regression.quantile_regression import QuantReg
except ImportError:
    raise ImportError("statsmodels is required: pip install statsmodels")

# ---------------------------------------------------------------------------
# Expected values from doc/demo_result_explanation.txt (GAUSS benchmark)
# ---------------------------------------------------------------------------
EXPECTED_BETA = np.array([
    6.6645846, 6.6668972,   # tau=0.25: beta_x1, beta_x2
    6.6659552, 6.6666716,   # tau=0.50
    6.6652370, 6.6663398,   # tau=0.75
])

EXPECTED_PHI = np.array([
    0.25537159, -0.0043015969,   # tau=0.25: phi_{t-1}, phi_{t-2}
    0.26163588, -0.0069863046,   # tau=0.50
    0.26073101, -0.0063757138,   # tau=0.75
])

EXPECTED_GAMMA = np.array([
    4.9913074, 4.9930394,   # tau=0.25: gamma_x1, gamma_x2
    4.9684725, 4.9690065,   # tau=0.50
    4.9698987, 4.9707210,   # tau=0.75
])

TOLERANCE = 1e-3   # acceptable absolute difference


# ---------------------------------------------------------------------------
# Step 1 — Load data
# ---------------------------------------------------------------------------
def load_data(path: str) -> np.ndarray:
    """Load qardl_data.dat.  The file has no header; columns are [y, x1, x2]."""
    try:
        data = np.loadtxt(path)
    except Exception:
        data = pd.read_csv(path, header=None, sep=r"\s+").values
    assert data.ndim == 2 and data.shape[1] >= 3, \
        f"Expected at least 3 columns, got shape {data.shape}"
    return data


# ---------------------------------------------------------------------------
# Step 2 — Build QARDL(p, q) regressor matrix
#
# Replicates the GAUSS eei / xxi / yyi construction for the case p >= q.
# The regressor layout (matching bt rows in qardl.src) is:
#
#   ONEX[:,0]              : constant
#   ONEX[:,1:1+q*k]        : Δx_t, Δx_{t-1}, ..., Δx_{t-q+1}  (q*k cols)
#   ONEX[:,1+q*k:1+(q+1)*k]: x_t                                (k cols)
#   ONEX[:,1+(q+1)*k:]     : y_{t-1}, ..., y_{t-p}              (p cols)
#
# Dependent variable Y = y_t for t = T0+1,...,n  (T0 = max(p,q))
# ---------------------------------------------------------------------------
def build_qardl_regressors(y: np.ndarray, x: np.ndarray,
                            p: int, q: int) -> tuple[np.ndarray, np.ndarray]:
    """
    Returns (Y, ONEX) for QARDL(p, q).

    Parameters
    ----------
    y : (n,) array
    x : (n, k) array
    p : AR order
    q : DL order

    Returns
    -------
    Y    : (N,) where N = n - max(p,q)
    ONEX : (N, 1 + q*k + k + p)
    """
    n, k = x.shape
    T0 = max(p, q)
    N = n - T0

    # First differences of x: dx[t] = x[t+1] - x[t]  (0-indexed)
    # So Δx_t (0-indexed t) = x[t] - x[t-1] = dx[t-1]
    dx = np.diff(x, axis=0)  # shape (n-1, k)

    # Dependent variable
    Y = y[T0:T0 + N]

    cols = [np.ones((N, 1))]

    # Lagged differences of x: Δx_{t-j} for j=0,...,q-1
    # t runs T0,...,T0+N-1 (0-indexed).
    # Δx_{t-j} = x[t-j] - x[t-j-1] = dx[t-j-1]
    for j in range(q):
        # dx index for Δx_{t-j}: t-j-1 => ranges T0-j-1 to T0-j-1+N-1
        start = T0 - j - 1
        cols.append(dx[start:start + N, :])   # (N, k)

    # Level of x_t
    cols.append(x[T0:T0 + N, :])              # (N, k)

    # Lagged y: y_{t-1}, ..., y_{t-p}
    for j in range(1, p + 1):
        # y_{t-j} for t=T0,...: index T0-j,...
        cols.append(y[T0 - j:T0 - j + N].reshape(-1, 1))   # (N, 1)

    ONEX = np.hstack(cols)
    return Y, ONEX


# ---------------------------------------------------------------------------
# Step 3 — Run quantile regressions and extract QARDL parameters
# ---------------------------------------------------------------------------
def fit_qardl(Y: np.ndarray, ONEX: np.ndarray,
              taus: list[float], p: int, q: int, k: int) -> dict:
    """
    Fits quantile regression at each tau and extracts beta, phi, gamma.

    Parameter positions in ONEX (columns):
      0          : constant
      1:1+q*k    : Δx coefficients (not separately reported — short-run Δx)
      1+q*k:1+(q+1)*k : x-level (theta) = reported as 'gamma'
      1+(q+1)*k: : phi (lagged y)

    beta(tau) = gamma(tau) / (1 - sum(phi(tau)))
    """
    model = QuantReg(Y, ONEX)
    results = {}

    theta_start = 1 + q * k
    theta_end = 1 + (q + 1) * k
    phi_start = theta_end
    phi_end = phi_start + p

    betas, phis, gammas, alphas, rhos = [], [], [], [], []

    for tau in taus:
        res = model.fit(q=tau, max_iter=2000)
        params = res.params

        theta = params[theta_start:theta_end]   # x-level coef = gamma
        phi = params[phi_start:phi_end]
        phi_sum = phi.sum()
        rho = -(1 - phi_sum)
        beta = theta / (1 - phi_sum)
        alpha = params[0]

        betas.append(beta)
        phis.append(phi)
        gammas.append(theta)
        alphas.append(alpha)
        rhos.append(rho)

    return {
        "beta":  np.concatenate(betas),
        "phi":   np.concatenate(phis),
        "gamma": np.concatenate(gammas),
        "alpha": np.array(alphas),
        "rho":   np.array(rhos),
    }


# ---------------------------------------------------------------------------
# Step 4 — Compare and report
# ---------------------------------------------------------------------------
def compare(label: str, python_vals: np.ndarray,
            gauss_vals: np.ndarray, tol: float = TOLERANCE) -> bool:
    diff = np.abs(python_vals - gauss_vals)
    max_diff = diff.max()
    passed = max_diff < tol
    status = "PASS" if passed else "FAIL"
    print(f"\n  {label}")
    print(f"  {'':4s}  {'Python':>14s}  {'GAUSS':>14s}  {'|diff|':>10s}")
    for i, (p_val, g_val, d_val) in enumerate(zip(python_vals, gauss_vals, diff)):
        flag = "" if d_val < tol else " <-- MISMATCH"
        print(f"  [{i:2d}]  {p_val:14.7f}  {g_val:14.7f}  {d_val:10.2e}{flag}")
    print(f"  Status: {status}  (max |diff| = {max_diff:.2e}, tol = {tol:.0e})")
    return passed


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    import os

    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_path = os.path.join(script_dir, "qardl_data.dat")

    print("=" * 65)
    print("QARDL Python Cross-Validation")
    print("Replicating demo.e: QARDL(p=2, q=1), tau=[0.25, 0.50, 0.75]")
    print("=" * 65)

    # Load
    print(f"\nLoading data from: {data_path}")
    data = load_data(data_path)
    n = data.shape[0]
    y = data[:, 0]
    x = data[:, 1:3]
    k = x.shape[1]
    print(f"  n={n}, k={k}")

    # QARDL orders (from demo.e / BIC selection)
    p, q = 2, 1
    taus = [0.25, 0.50, 0.75]
    T0 = max(p, q)
    N = n - T0
    print(f"  Using p={p}, q={q}  =>  T0={T0}, estimation obs N={N}")

    # Build regressors
    Y_reg, ONEX = build_qardl_regressors(y, x, p, q)
    n_params = ONEX.shape[1]
    print(f"  ONEX shape: {ONEX.shape}  "
          f"(1 const + {q*k} Δx + {k} x-level + {p} lagged y = {n_params})")

    # Fit
    print("\nFitting quantile regressions...")
    est = fit_qardl(Y_reg, ONEX, taus, p, q, k)

    # Compare
    all_passed = True
    all_passed &= compare("Beta (long-run)",  est["beta"],  EXPECTED_BETA)
    all_passed &= compare("Phi (lagged y)",   est["phi"],   EXPECTED_PHI)
    all_passed &= compare("Gamma (x-level)",  est["gamma"], EXPECTED_GAMMA)

    print("\n" + "=" * 65)
    if all_passed:
        print("OVERALL: PASS — Python estimates match GAUSS benchmark")
    else:
        print("OVERALL: FAIL — discrepancies exceed tolerance; review above")
    print("=" * 65)

    # Also print derived alpha and rho (no GAUSS benchmark yet, but useful)
    print("\nDerived alpha and rho (for reference — no GAUSS benchmark):")
    for i, tau in enumerate(taus):
        print(f"  tau={tau:.2f}:  alpha={est['alpha'][i]:.6f},  "
              f"rho={est['rho'][i]:.6f}")


if __name__ == "__main__":
    main()
