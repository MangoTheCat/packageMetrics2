
#' Collect Metrics about R Packages
#'
#' This package is used to collect metrics about CRAN, BioConductor or
#' other packages, for Valid-R.
#'
#' @docType package
#' @name packageMetrics2
NULL

package_metric <- list

#' @include coverage.R downloads.R deps.R cyclocomp.R vignette.R

pkg_metrics <- list(
  ATC = package_metric(
    code = "ATC",
    func = author_test_coverage,
    desc = "Author Test Coverage"
  ),
  DWL = package_metric(
    code = "DWL",
    func = download_counts,
    desc = "Number of Downloads"
  ),
  DEP = package_metric(
    code = "DEP",
    func = num_deps,
    desc = "Num of Dependencies"
  ),
  DPD = package_metric(
    code = "DPD",
    func = num_rev_deps,
    desc = "Number of Reverse-Dependencies"
  ),
  CCP = package_metric(
    code = "CCP",
    func = mean_cyclocomp,
    desc = "Cyclomatic Complexity"
  ),
  FRE = package_metric(
    code = "FRE",
    func = first_release,
    desc = "Date of First Release"
  ),
  LRE = package_metric(
    code = "LRE",
    func = last_release,
    desc = "Date of Last Release"
  ),
  NUP = package_metric(
    code = "NUP",
    func = num_recent_updates,
    desc = "Updates During the Last 6 Months"
  ),
  VIG = package_metric(
    code = "VIG",
    func = num_vignettes,
    desc = "Number of vignettes"
  )
)

#' List all implemented metrics
#'
#' @return A named character vector of metrics descriptions.
#'   The named are the three letter metrics ids.
#'
#' @export

list_package_metrics <- function() {
  vapply(pkg_metrics, "[[", "", "desc")
}

#' Calculate all or the specified metrics for a package
#'
#' @param package Package name, character scalar.
#' @param version Version number, character scalar. If \code{NULL},
#'   then the latest version is used.
#' @param metrics The ids of the metrics to calculate. The default
#'   is to calculate all implemented metrics.
#' @return A named character vector. The names are the three letter
#'   metrics ids.
#'
#' @seealso \code{\link{package_metrics_csv}} to calculate the
#'   metrics and write the output to a CSV file.
#'
#' @export
#' @importFrom withr with_dir with_libpaths

package_metrics <- function(package, version = NULL,
                            metrics = names(list_package_metrics())) {

  all_metrics <- list_package_metrics()
  if (any(! metrics %in% names(all_metrics))) {
    stop(
      "Unknown metrics: ",
      paste(setdiff(metrics, names(all_metrics)), collapse = ", ")
    )
  }

  pkg_dir <- install_package_tmp(package, version)

  ## Trick to keep the names in the lapply below
  names(metrics) <- metrics

  res <- with_dir(
    file.path(pkg_dir, "src"),
    with_libpaths(
      file.path(pkg_dir, "lib"),
      action = "prefix",
      lapply(metrics, function(met) { pkg_metrics[[met]]$func(package) })
    )
  )

  ## metrics can return a scalar number or a named vector,
  ## we flatten the list, to get a single named numeric vector
  unlist(res)
}

#' Calculate metrics and write them to a CSV file
#'
#' @param file Output file name.
#' @inheritParams package_metrics
#'
#' @seealso \code{\link{package_metrics}} to calculate the metrics,
#' without writing them to a file.
#'
#' @export

package_metrics_csv <- function(package, file, version = NULL,
                                metrics = names(list_package_metrics())) {

  met <- package_metrics(package, version, metrics)

  met[is.na(met)] <- -1

  df <- data.frame(
    stringsAsFactors = FALSE,
    metric = names(met),
    value = unname(met)
  )

  write.table(
    df,  file = file,
    row.names = FALSE, col.names = FALSE,
    sep = ",", qmethod = "double", dec = "."
  )
}
