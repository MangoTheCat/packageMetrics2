
#' @importFrom covr package_coverage percent_coverage
#' @importFrom withr with_envvar

author_test_coverage <- function(pkg, by = c("line", "expression")) {
  "!DEBUG Running covr for author test coverage"

  tryCatch(
    {
      cov <- with_envvar(
        c("R_LIBS_USER" = paste(.libPaths(), collapse = .Platform$path.sep)),
        package_coverage(pkg)
      )
      percent_coverage(cov, by = by)
    },
    error = function(e) NA_real_
  )
}
