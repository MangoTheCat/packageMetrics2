
my_gp_checks <- c(
  "lintr_assignment_linter",            # <- is used, not =
  "lintr_line_length_linter",           # lines are shorter than 80
  "truefalse_not_tf",                   # TRUE/FALSE instead of T/F
  "lintr_trailing_semicolon_linter",    # no trailing semicolons
  "lintr_attach_detach_linter",
  "lintr_setwd_linter",
  "lintr_sapply_linter",
  "lintr_library_require_linter",
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

gp_truefalse_not_tf <- function(package, version = NULL) {
  gp <- get_gp_results(package, version)
  gp_get_num_fails(gp, "truefalse_not_tf")
}

gp_trailing_semicolon <- function(package, version = NULL) {
  gp <- get_gp_results(package, version)
  gp_get_num_fails(gp, "lintr_trailing_semicolon_linter")
}

gp_attach_detach <- function(package, version = NULL) {
  gp <- get_gp_results(package, version)
  gp_get_num_fails(gp, "lintr_attach_detach_linter")
}

gp_setwd <- function(package, version = NULL) {
  gp <- get_gp_results(package, version)
  gp_get_num_fails(gp, "lintr_setwd_linter")
}

gp_sapply <- function(package, version = NULL) {
  gp <- get_gp_results(package, version)
  gp_get_num_fails(gp, "lintr_sapply_linter")
}

gp_library_require <- function(package, version = NULL) {
  gp <- get_gp_results(package, version)
  gp_get_num_fails(gp, "lintr_library_require_linter")
}
