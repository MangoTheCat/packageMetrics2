
#' Collect Metrics about R Packages
#'
#' This package is used to collect metrics about CRAN, BioConductor or
#' other packages, for Valid-R.
#'
#' @docType package
#' @name packageMetrics2
NULL

package_metric <- list

#' @include coverage.R

pkg_metrics <- list(
  ATC = package_metric(
    code = "ATC",
    func = author_test_coverage,
    desc = "Author Test Coverage"
  )
)

#' @export

list_package_metrics <- function() {
  vapply(pkg_metrics, "[[", "", "desc")
}

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
  on.exit(unlink(pkg_dir, recursive = TRUE), add = TRUE)

  ## Trick to keep the names in the lapply below
  names(metrics) <- metrics

  with_dir(
    file.path(pkg_dir, "src"),
    with_libpaths(
      file.path(pkg_dir, "lib"),
      action = "prefix",
      lapply(metrics, function(met) { pkg_metrics[[met]]$func(package) })
    )
  )
}
