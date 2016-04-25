
#' @include urls.R cran_data.R
#' @importFrom jsonlite fromJSON

num_rev_deps <- function(package, version = NULL) {

  if (package %in% r_base_packages) return(NA)

  url <- sprintf(urls$revdeps, package)
  deps <- fromJSON(url)
  length(unlist(deps))
}

#' @include urls.R cran_data.R
#' @importFrom jsonlite fromJSON
#' @importFrom description dep_types

num_deps <- function(package, version = NULL) {
  if (package %in% r_base_packages) return(NA)

  pkg <- crandb_package(package, version)

  has_deps <- intersect(names(pkg), dep_types)
  pkgs <- lapply(pkg[has_deps], names)

  ## "R" itself might be in 'Depends'
  pkgnames <- setdiff(unique(unlist(pkgs)), "R")

  length(setdiff(pkgnames, r_base_packages))
}
