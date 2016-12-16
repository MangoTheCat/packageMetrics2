
#' @importFrom cyclocomp cyclocomp_package

mean_cyclocomp <- function(package, version = NULL) {
  "!DEBUG Calculating cyclomatic complexity"

  ## It fails on some packages, e.g. BiocInstaller
  cc <- tryCatch(
    cyclocomp_package(package),
    error = function(e) list(cyclocomp = NA)
  )
  mean(cc$cyclocomp)
}
