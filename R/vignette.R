
num_vignettes <- function(package, version = NULL) {
  "!DEBUG Counting number of vignettes"

  vig <- unclass(browseVignettes(package = package))

  if (length(vig) == 0) {
    0

  } else {
    nrow(vig[[1]])
  }
}
