
#' @importFrom cranlogs cran_downloads

## The earliest day we have download count data for
cran_downloads_beginning <- "2012-01-01"

download_counts <- function(package, version = NULL) {
  dlc <- cran_downloads(
    package, from = cran_downloads_beginning,
    to = Sys.Date()
  )

  sum(dlc$count)
}
