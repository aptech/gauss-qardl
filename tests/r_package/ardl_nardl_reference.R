args <- commandArgs(trailingOnly = TRUE)

arg_value <- function(flag, default = NULL) {
  hit <- which(args == flag)
  if (!length(hit) || hit == length(args)) {
    return(default)
  }
  args[[hit + 1]]
}

repo_root <- normalizePath(arg_value("--repo-root", file.path(getwd(), "..")), winslash = "/", mustWork = TRUE)
actual_dir <- normalizePath(arg_value("--actual-dir", file.path(repo_root, "tests", "r_package", "actual")), winslash = "/", mustWork = TRUE)
expected_dir <- arg_value("--expected-dir", file.path(repo_root, "tests", "r_package", "r_expected"))
tolerance <- as.numeric(arg_value("--tolerance", "1e-6"))
relative_tolerance <- as.numeric(arg_value("--relative-tolerance", "1e-6"))

dir.create(expected_dir, recursive = TRUE, showWarnings = FALSE)

options(device = function(...) grDevices::pdf(file = tempfile(fileext = ".pdf")))
suppressPackageStartupMessages(library(ardl.nardl))

read_numeric <- function(name) {
  path <- file.path(actual_dir, name)
  if (!file.exists(path)) {
    stop("Missing GAUSS output: ", path, call. = FALSE)
  }
  as.numeric(as.matrix(read.csv(path, check.names = FALSE)))
}

write_numeric <- function(name, value) {
  write.csv(data.frame(value = as.numeric(value)),
            file.path(expected_dir, name),
            row.names = FALSE)
}

clean_vector <- function(value) {
  value <- as.numeric(value)
  value[!is.na(value)]
}

longrun_estimate <- function(object) {
  lr <- object$Longrun_relation
  if (is.null(lr)) {
    stop("R package output does not include Longrun_relation", call. = FALSE)
  }
  if ("Estimate" %in% colnames(lr)) {
    return(as.numeric(lr[, "Estimate"]))
  }
  as.numeric(lr[, 1])
}

ols_fit <- function(y, x) {
  coef <- as.numeric(solve(crossprod(x), crossprod(x, y)))
  fitted <- as.numeric(x %*% coef)
  resid <- as.numeric(y - fitted)
  sigma2 <- sum(resid^2) / (length(y) - ncol(x))
  list(coef = coef, fitted = fitted, resid = resid, sigma2 = sigma2)
}

gauss_partial_sums <- function(x) {
  n <- length(x)
  pos <- neg <- dxp <- dxn <- numeric(n)
  for (i in 2:n) {
    delta <- x[[i]] - x[[i - 1]]
    pos[[i]] <- pos[[i - 1]]
    neg[[i]] <- neg[[i - 1]]
    if (delta > 0) {
      dxp[[i]] <- delta
      pos[[i]] <- pos[[i]] + delta
    } else if (delta < 0) {
      dxn[[i]] <- delta
      neg[[i]] <- neg[[i]] + delta
    }
  }
  list(pos = pos, neg = neg, dxp = dxp, dxn = dxn)
}

gauss_style_nardl_recm <- function(df, p = 2, q_decomp = 2, q_control = 1) {
  y <- df$y
  x1 <- df$x1
  x2 <- df$x2
  n <- nrow(df)
  ps <- gauss_partial_sums(x1)
  dx_ctrl <- c(0, diff(x2))
  max_lag <- max(p, q_decomp, q_control)

  level_idx <- seq.int(max_lag + 1, n)
  y_lags <- do.call(cbind, lapply(seq_len(p), function(j) y[level_idx - j]))
  dxp_lags <- do.call(cbind, lapply(0:(q_decomp - 1), function(j) ps$dxp[level_idx - j]))
  dxn_lags <- do.call(cbind, lapply(0:(q_decomp - 1), function(j) ps$dxn[level_idx - j]))
  dxc_lags <- do.call(cbind, lapply(0:(q_control - 1), function(j) dx_ctrl[level_idx - j]))
  x_level <- cbind(1, ps$pos[level_idx], ps$neg[level_idx], x2[level_idx],
                   y_lags, dxp_lags, dxn_lags, dxc_lags)
  level_fit <- ols_fit(y[level_idx], x_level)

  phi_start <- 5
  denom <- 1 - sum(level_fit$coef[phi_start:(phi_start + p - 1)])
  beta_pos <- level_fit$coef[[2]] / denom
  beta_neg <- level_fit$coef[[3]] / denom
  beta_control <- level_fit$coef[[4]] / denom

  ecm_idx <- seq.int(max_lag + 2, n)
  ec_lag <- y[ecm_idx - 1] -
    ps$pos[ecm_idx - 1] * beta_pos -
    ps$neg[ecm_idx - 1] * beta_neg -
    x2[ecm_idx - 1] * beta_control
  dy_lags <- do.call(cbind, lapply(seq_len(p - 1), function(j) {
    y[ecm_idx - j] - y[ecm_idx - j - 1]
  }))
  dxp_ecm <- do.call(cbind, lapply(0:(q_decomp - 1), function(j) ps$dxp[ecm_idx - j]))
  dxn_ecm <- do.call(cbind, lapply(0:(q_decomp - 1), function(j) ps$dxn[ecm_idx - j]))
  dxc_ecm <- do.call(cbind, lapply(0:(q_control - 1), function(j) dx_ctrl[ecm_idx - j]))
  x_ecm <- cbind(1, ec_lag, dy_lags, dxp_ecm, dxn_ecm, dxc_ecm)
  y_ecm <- y[ecm_idx] - y[ecm_idx - 1]

  ols_fit(y_ecm, x_ecm)
}

compare_numeric <- function(name, gauss, reference, required = TRUE) {
  gauss <- as.numeric(gauss)
  reference <- as.numeric(reference)

  compare_n <- min(length(gauss), length(reference))
  if (compare_n > 0) {
    abs_diff <- abs(gauss[seq_len(compare_n)] - reference[seq_len(compare_n)])
    max_abs <- max(abs_diff)
    denom <- pmax(1, abs(reference[seq_len(compare_n)]))
    max_rel <- max(abs_diff / denom)
  } else {
    max_abs <- NA_real_
    max_rel <- NA_real_
  }

  length_match <- length(gauss) == length(reference)
  tolerance_match <- isTRUE(max_abs <= tolerance || max_rel <= relative_tolerance)
  pass <- length_match && tolerance_match

  data.frame(
    check = name,
    required = required,
    gauss_n = length(gauss),
    r_n = length(reference),
    compared_n = compare_n,
    length_match = length_match,
    gauss_first = if (length(gauss)) gauss[[1]] else NA_real_,
    r_first = if (length(reference)) reference[[1]] else NA_real_,
    max_abs_diff = max_abs,
    max_rel_diff = max_rel,
    tolerance = tolerance,
    relative_tolerance = relative_tolerance,
    pass = pass
  )
}

ardl_df <- read.csv(file.path(actual_dir, "ardl_input.csv"), check.names = FALSE)
nardl_df <- read.csv(file.path(actual_dir, "nardl_input.csv"), check.names = FALSE)

r_watch <- proc.time()

ardl_ref <- ardl_uecm(
  x = ardl_df,
  p_order = c(2),
  q_order = c(2, 2),
  dep_var = c("y"),
  expl_var = c("x1", "x2"),
  order_l = 4,
  graph_save = FALSE,
  case = 3
)

nardl_ref <- nardl_uecm(
  x = nardl_df,
  decomp = c("x1"),
  control = c("x2"),
  c_q_order = c(1),
  p_order = c(2),
  q_order = c(2),
  dep_var = c("y"),
  order_l = 4,
  graph_save = FALSE,
  case = 3
)

r_elapsed <- (proc.time() - r_watch)[["elapsed"]]

ardl_lr <- longrun_estimate(ardl_ref)
ardl_fitted <- clean_vector(stats::fitted(ardl_ref$ARDL_fit))
ardl_resid <- clean_vector(stats::resid(ardl_ref$ARDL_fit))
ardl_sigma2 <- sum(ardl_resid^2) /
  (length(ardl_resid) - length(stats::coef(ardl_ref$ARDL_fit)))
ardl_uecm_bt <- clean_vector(stats::coef(ardl_ref$ARDL_ECM_fit))
ardl_uecm_fitted <- clean_vector(stats::fitted(ardl_ref$ARDL_ECM_fit))
ardl_uecm_resid <- clean_vector(stats::resid(ardl_ref$ARDL_ECM_fit))
ardl_uecm_sigma2 <- sum(ardl_uecm_resid^2) /
  (length(ardl_uecm_resid) - length(stats::coef(ardl_ref$ARDL_ECM_fit)))

nardl_lr <- longrun_estimate(nardl_ref)
nardl_fitted <- clean_vector(stats::fitted(nardl_ref$NARDL_fit))
nardl_resid <- clean_vector(stats::resid(nardl_ref$NARDL_fit))
nardl_sigma2 <- sum(nardl_resid^2) /
  (length(nardl_resid) - length(stats::coef(nardl_ref$NARDL_fit)))
nardl_recm <- gauss_style_nardl_recm(nardl_df)
nardl_uecm_bt <- clean_vector(stats::coef(nardl_ref$NARDL_ECM_fit))
nardl_uecm_fitted <- clean_vector(stats::fitted(nardl_ref$NARDL_ECM_fit))
nardl_uecm_resid <- clean_vector(stats::resid(nardl_ref$NARDL_ECM_fit))
nardl_uecm_sigma2 <- sum(nardl_uecm_resid^2) /
  (length(nardl_uecm_resid) - length(stats::coef(nardl_ref$NARDL_ECM_fit)))

write_numeric("ardl_bigbt.csv", ardl_lr)
write_numeric("ardl_fitted.csv", ardl_fitted)
write_numeric("ardl_resid.csv", ardl_resid)
write_numeric("ardl_sigma2.csv", ardl_sigma2)
write_numeric("ardl_nobs.csv", length(ardl_fitted))
write_numeric("ardl_uecm_bt.csv", ardl_uecm_bt)
write_numeric("ardl_uecm_fitted.csv", ardl_uecm_fitted)
write_numeric("ardl_uecm_resid.csv", ardl_uecm_resid)
write_numeric("ardl_uecm_sigma2.csv", ardl_uecm_sigma2)
write_numeric("ardl_uecm_nobs.csv", length(ardl_uecm_fitted))
write_numeric("nardl_bigbt.csv", nardl_lr)
write_numeric("nardl_fitted.csv", nardl_fitted)
write_numeric("nardl_resid.csv", nardl_resid)
write_numeric("nardl_sigma2.csv", nardl_sigma2)
write_numeric("nardl_nobs.csv", length(nardl_fitted))
write_numeric("nardl_recm_bt.csv", nardl_recm$coef)
write_numeric("nardl_recm_fitted.csv", nardl_recm$fitted)
write_numeric("nardl_recm_resid.csv", nardl_recm$resid)
write_numeric("nardl_recm_sigma2.csv", nardl_recm$sigma2)
write_numeric("nardl_recm_nobs.csv", length(nardl_recm$fitted))
write_numeric("nardl_uecm_bt.csv", nardl_uecm_bt)
write_numeric("nardl_uecm_fitted.csv", nardl_uecm_fitted)
write_numeric("nardl_uecm_resid.csv", nardl_uecm_resid)
write_numeric("nardl_uecm_sigma2.csv", nardl_uecm_sigma2)
write_numeric("nardl_uecm_nobs.csv", length(nardl_uecm_fitted))

summary <- rbind(
  compare_numeric("ARDL long-run coefficients", read_numeric("ardl_bigbt.csv"), ardl_lr, required = FALSE),
  compare_numeric("ARDL fitted values", read_numeric("ardl_fitted.csv"), ardl_fitted),
  compare_numeric("ARDL residuals", read_numeric("ardl_resid.csv"), ardl_resid),
  compare_numeric("ARDL sigma2", read_numeric("ardl_sigma2.csv"), ardl_sigma2),
  compare_numeric("ARDL nobs", read_numeric("ardl_nobs.csv"), length(ardl_fitted)),
  compare_numeric("ARDL UECM coefficients", read_numeric("ardl_uecm_bt.csv"), ardl_uecm_bt),
  compare_numeric("ARDL UECM fitted values", read_numeric("ardl_uecm_fitted.csv"), ardl_uecm_fitted),
  compare_numeric("ARDL UECM residuals", read_numeric("ardl_uecm_resid.csv"), ardl_uecm_resid),
  compare_numeric("ARDL UECM sigma2", read_numeric("ardl_uecm_sigma2.csv"), ardl_uecm_sigma2),
  compare_numeric("ARDL UECM nobs", read_numeric("ardl_uecm_nobs.csv"), length(ardl_uecm_fitted)),
  compare_numeric("NARDL long-run coefficients", read_numeric("nardl_bigbt.csv"), nardl_lr, required = FALSE),
  compare_numeric("NARDL fitted values", read_numeric("nardl_fitted.csv"), nardl_fitted, required = FALSE),
  compare_numeric("NARDL residuals", read_numeric("nardl_resid.csv"), nardl_resid, required = FALSE),
  compare_numeric("NARDL sigma2", read_numeric("nardl_sigma2.csv"), nardl_sigma2),
  compare_numeric("NARDL nobs", read_numeric("nardl_nobs.csv"), length(nardl_fitted), required = FALSE),
  compare_numeric("NARDL restricted ECM coefficients", read_numeric("nardl_recm_bt.csv"), nardl_recm$coef),
  compare_numeric("NARDL restricted ECM fitted values", read_numeric("nardl_recm_fitted.csv"), nardl_recm$fitted),
  compare_numeric("NARDL restricted ECM residuals", read_numeric("nardl_recm_resid.csv"), nardl_recm$resid),
  compare_numeric("NARDL restricted ECM sigma2", read_numeric("nardl_recm_sigma2.csv"), nardl_recm$sigma2),
  compare_numeric("NARDL restricted ECM nobs", read_numeric("nardl_recm_nobs.csv"), length(nardl_recm$fitted)),
  compare_numeric("NARDL UECM coefficients", read_numeric("nardl_uecm_bt.csv"), nardl_uecm_bt),
  compare_numeric("NARDL UECM fitted values", read_numeric("nardl_uecm_fitted.csv"), nardl_uecm_fitted),
  compare_numeric("NARDL UECM residuals", read_numeric("nardl_uecm_resid.csv"), nardl_uecm_resid),
  compare_numeric("NARDL UECM sigma2", read_numeric("nardl_uecm_sigma2.csv"), nardl_uecm_sigma2),
  compare_numeric("NARDL UECM nobs", read_numeric("nardl_uecm_nobs.csv"), length(nardl_uecm_fitted))
)

write.csv(summary, file.path(expected_dir, "comparison_summary.csv"), row.names = FALSE)
write.csv(data.frame(engine = "R ardl.nardl", seconds = r_elapsed),
          file.path(expected_dir, "r_performance.csv"),
          row.names = FALSE)

required_fail <- summary$required & !summary$pass
if (any(required_fail)) {
  print(summary)
  stop("GAUSS ARDL/NARDL outputs differ from ardl.nardl reference outputs", call. = FALSE)
}

cat(sprintf("ardl_nardl_reference.R: PASS in %.3f seconds\n", r_elapsed))
