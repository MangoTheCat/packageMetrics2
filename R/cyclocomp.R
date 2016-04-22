
#' @importFrom cyclocomp cyclocomp_package

mean_cyclocomp <- function(package, version = NULL) {
  cc <- cyclocomp_package(package)
  mean(cc$cyclocomp)
}
