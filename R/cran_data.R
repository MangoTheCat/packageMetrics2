
r_base_packages <- c(
  "base", "compiler", "datasets", "grDevices", "graphics", "grid",
  "methods", "parallel", "profile", "splines", "stats", "stats4",
  "tcltk", "tools", "translations", "utils"
)                     

#' @importFrom memoise memoise

crandb_package <- memoise(function(package, version = NULL) {
  url <- paste0(urls$crandb, "/", package, "/", version)
  fromJSON(url)
})

first_release <- function(package, version = NULL) {
  if (package %in% r_base_packages) return(NA)
  pkg <- crandb_package(package, version = "all")
  pkg$timeline[[1]]
}

last_release <- function(package, version = NULL) {
  if(package %in% r_base_packages) return(NA)
  pkg <- crandb_package(package, version = "all")
  pkg$timeline[[length(pkg$timeline)]]
}

#' @importFrom parsedate parse_date

num_recent_updates <- function(package, version = NULL, interval = "6 months") {
  if (package %in% r_base_packages) return(NA)
  pkg <- crandb_package(package, version = "all")
  releases <- parse_date(unlist(pkg$timeline))
  sum(Sys.time() - releases <= 24 * 7)
}
