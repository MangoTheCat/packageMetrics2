
#' @importFrom covr package_coverage percent_coverage
#' @importFrom withr with_envvar

author_test_coverage <- function(pkg, by = c("line", "expression")) {

  message("Calculating test coverage for ", pkg)
  cov <- with_envvar(
    c("R_LIBS_USER" = paste(.libPaths(), collapse = .Platform$path.sep)),
    package_coverage(pkg)
  )

  percent_coverage(cov, by = by)
}
