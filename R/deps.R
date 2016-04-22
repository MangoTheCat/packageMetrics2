
#' @include urls.R
#' @importFrom jsonlite fromJSON

num_rev_deps <- function(package, version = NULL) {
  url <- sprintf(urls$revdeps, package)
  deps <- fromJSON(url)
  length(unlist(deps))
}
