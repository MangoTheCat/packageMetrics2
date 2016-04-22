
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
  pkg <- crandb_package(package, version = "all")
  pkg$timeline[[1]]
}

last_release <- function(package, version = NULL) {
  pkg <- crandb_package(package, version = "all")
  pkg$timeline[[length(pkg$timeline)]]
}
