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

compare_numeric <- function(name, gauss, reference) {
  gauss <- as.numeric(gauss)
  reference <- as.numeric(reference)

  if (length(gauss) != length(reference)) {
    stop(sprintf("%s length mismatch: GAUSS=%d R=%d",
                 name, length(gauss), length(reference)), call. = FALSE)
  }

  abs_diff <- abs(gauss - reference)
  max_abs <- if (length(abs_diff)) max(abs_diff) else 0
  denom <- pmax(1, abs(reference))
  max_rel <- if (length(abs_diff)) max(abs_diff / denom) else 0
  pass <- max_abs <= tolerance || max_rel <= relative_tolerance

  data.frame(
    check = name,
    n = length(gauss),
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

nardl_lr <- longrun_estimate(nardl_ref)
nardl_fitted <- clean_vector(stats::fitted(nardl_ref$NARDL_fit))
nardl_resid <- clean_vector(stats::resid(nardl_ref$NARDL_fit))
nardl_sigma2 <- sum(nardl_resid^2) /
  (length(nardl_resid) - length(stats::coef(nardl_ref$NARDL_fit)))

write_numeric("ardl_bigbt.csv", ardl_lr)
write_numeric("ardl_fitted.csv", ardl_fitted)
write_numeric("ardl_resid.csv", ardl_resid)
write_numeric("ardl_sigma2.csv", ardl_sigma2)
write_numeric("ardl_nobs.csv", length(ardl_fitted))
write_numeric("nardl_bigbt.csv", nardl_lr)
write_numeric("nardl_fitted.csv", nardl_fitted)
write_numeric("nardl_resid.csv", nardl_resid)
write_numeric("nardl_sigma2.csv", nardl_sigma2)
write_numeric("nardl_nobs.csv", length(nardl_fitted))

summary <- rbind(
  compare_numeric("ARDL long-run coefficients", read_numeric("ardl_bigbt.csv"), ardl_lr),
  compare_numeric("ARDL fitted values", read_numeric("ardl_fitted.csv"), ardl_fitted),
  compare_numeric("ARDL residuals", read_numeric("ardl_resid.csv"), ardl_resid),
  compare_numeric("ARDL sigma2", read_numeric("ardl_sigma2.csv"), ardl_sigma2),
  compare_numeric("ARDL nobs", read_numeric("ardl_nobs.csv"), length(ardl_fitted)),
  compare_numeric("NARDL long-run coefficients", read_numeric("nardl_bigbt.csv"), nardl_lr),
  compare_numeric("NARDL fitted values", read_numeric("nardl_fitted.csv"), nardl_fitted),
  compare_numeric("NARDL residuals", read_numeric("nardl_resid.csv"), nardl_resid),
  compare_numeric("NARDL sigma2", read_numeric("nardl_sigma2.csv"), nardl_sigma2),
  compare_numeric("NARDL nobs", read_numeric("nardl_nobs.csv"), length(nardl_fitted))
)

write.csv(summary, file.path(expected_dir, "comparison_summary.csv"), row.names = FALSE)
write.csv(data.frame(engine = "R ardl.nardl", seconds = r_elapsed),
          file.path(expected_dir, "r_performance.csv"),
          row.names = FALSE)

if (!all(summary$pass)) {
  print(summary)
  stop("GAUSS ARDL/NARDL outputs differ from ardl.nardl reference outputs", call. = FALSE)
}

cat(sprintf("ardl_nardl_reference.R: PASS in %.3f seconds\n", r_elapsed))
