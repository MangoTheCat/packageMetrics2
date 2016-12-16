
r_base_packages <- c(
  "base", "compiler", "datasets", "grDevices", "graphics", "grid",
  "methods", "parallel", "profile", "splines", "stats", "stats4",
  "tcltk", "tools", "translations", "utils"
)

## These only work after downloading the package, in general.

package_type <- function(package) {
  if (package %in% r_base_packages) return("base")
  if (is_cran_package(package)) return("CRAN")
  if (is_bioc_package(package)) return("BioC")
  NA
}

is_base_package <- function(package) {
  package %in% r_base_packages
}

#' @importFrom desc desc_get

is_cran_package <- function(package) {
  identical(
    desc_get(file = package, "Repository"),
    c(Repository = "CRAN")
  )
}

#' @importFrom desc desc_fields

is_bioc_package <- function(package) {
  "biocViews" %in% desc_fields(file = package)
}

#' @importFrom memoise memoise

crandb_package <- memoise(function(package, version = NULL) {
  url <- paste0(urls$crandb, "/", package, "/", version)
  fromJSON(url)
})

first_release <- function(package, version = NULL) {
  "!DEBUG Finding first release"

  type <- package_type(package)

  if (is.na(type)) {
    NA

  } else if (type == "base") {
    NA

  } else if (type == "CRAN") {
    pkg <- crandb_package(package, version = "all")
    pkg$timeline[[1]]

  } else if (type == "BioC") {
    NA

  } else {
    NA
  }
}

last_release <- function(package, version = NULL) {
  "!DEBUG Finding last release"

  type <- package_type(package)

  if (is.na(type)) {
    NA

  } else if (type == "base") {
    NA

  } else if (type == "CRAN") {
    pkg <- crandb_package(package, version = "all")
    pkg$timeline[[length(pkg$timeline)]]

  } else if (type == "BioC") {
    NA

  } else {
    NA
  }
}

#' @importFrom parsedate parse_date

num_recent_updates <- function(package, version = NULL, interval = "6 months") {
  "!DEBUG Counting reset updates"

  type <- package_type(package)

  if (is.na(type)) {
    NA

  } else if (type == "base") {
    NA

  } else if (type == "CRAN") {
    pkg <- crandb_package(package, version = "all")
    releases <- parse_date(unlist(pkg$timeline))
    sum(Sys.time() - releases <= 24 * 7)

  } else if (type == "BioC") {
    NA

  } else {
    NA
  }
}
