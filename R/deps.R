
#' @include urls.R cran_data.R
#' @importFrom jsonlite fromJSON

num_rev_deps <- function(package, version = NULL) {

  type <- package_type(package)

  if (type == "base") {
    NA

  } else if (type == "CRAN") {
    url <- sprintf(urls$revdeps, package)
    deps <- fromJSON(url)
    length(unlist(deps))

  } else if (type == "BioC") {
    bioc_num_rev_deps(package, version)

  } else {
    stop("Unknown package type")
  }
}

bioc_num_rev_deps <- function(package, version) {
  page <- get_bioc_page(package, version)
  table <- html_table(html_nodes(page, "table.details")[[1]])
  rows <- c("Depends On Me", "Imports Me", "Suggests Me")
  pkgs <- lapply(rows, function(x) {
    strsplit(table[table[,1] == x, 2], ",")[[1]]
  })
  length(drop_space(unique(str_trim(unlist(pkgs)))))
}

#' @include urls.R cran_data.R
#' @importFrom jsonlite fromJSON
#' @importFrom description desc_get_deps

num_deps <- function(package, version = NULL) {

  if (is_base_package(package)) {
    NA

  } else {
    pkgs <- desc_get_deps(file = package)$package

    ## "R" itself might be in 'Depends', omit base packages
    length(setdiff(unique(pkgs), c("R", r_base_packages)))
  }
}

#' @importFrom memoise memoise
#' @importFrom httr GET stop_for_status content
#' @importFrom xml2 read_html
#' @importFrom rvest html_attr html_node

get_bioc_page <- memoise(function(package, version) {
  url <- sprintf(urls$bioc_pkg, package)
  res <- GET(url)
  stop_for_status(res)
  read_html(content(res, type = "raw"))
})
