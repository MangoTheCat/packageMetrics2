
my_gp_checks <- c(
  "lintr_assignment_linter",            # <- is used, not =
  "lintr_line_length_linter",           # lines are shorter than 80
  NULL
)

#' @importFrom goodpractice gp

get_gp_results <- function(package, version = NULL) {
  gp_cache_file <- file.path(dirname(getwd()), "gp-data.rda")
  if (file.exists(gp_cache_file)) {
    readRDS(gp_cache_file)
  } else {
    gp_res <- gp(package, checks = my_gp_checks)
    saveRDS(gp_res, gp_cache_file)
    gp_res
  }
}

#' @importFrom goodpractice failed_positions

gp_get_num_fails <- function(gp, chk) {
  pos <- failed_positions(gp)
  length(pos[[chk]])
}

gp_arrow_assign <- function(package, version = NULL) {
  gp <- get_gp_results(package, version)
  gp_get_num_fails(gp, "lintr_assignment_linter")
}

gp_line_length <- function(package, version = NULL) {
  gp <- get_gp_results(package, version)
  gp_get_num_fails(gp, "lintr_line_length_linter")
}
