
`%||%` <- function(l, r) if (is.null(l)) r else l

drop_space <- function(x) {
  grep("^\\s*$", value = TRUE, invert = TRUE, x)
}

str_trim <- function(x) {
  sub("^\\s+", "", sub("\\s+$", "", x))
}
