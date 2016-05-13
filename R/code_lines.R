
compiled_code_lines <- function(package, version = NULL) {

  src_dir <- file.path(package, "src")

  if (!file.exists(src_dir)) return(0)

  files <- list.files(
    src_dir,
    recursive = TRUE,
    full.names = TRUE,
    pattern = paste0(
      "(\\.c|\\.cc|\\.cxx|\\.C|\\.cpp|\\.h|\\.hh|\\.hpp|\\.hxx|",
      "\\.f90|\\.f95|\\.f03|\\.f|\\.for)$"
    )
  )
  code_lines(files)  
}

r_code_lines <- function(package, version = NULL) {
  files <- list.files(
    file.path(package, "R"),
    full.names = TRUE,
    pattern = "[.][rRsSq]$"
  )
  code_lines(files)  
}

code_lines <- function(files) {
  lc <- vapply(files, function(f) length(readLines(f)), 1L)
  sum(lc)
}

#' @importFrom callr r_eval

function_lines <- function(package, version = NULL) {
  fun <- function(package) {
    files <- list.files(
      file.path(package, "R"),
      pattern = "[.][rRsSq]$",
      full.names = TRUE
    )
    exprs <- lapply(files, lintr::get_source_expressions)
    exprs <- unlist(lapply(exprs, "[[", "expressions"), recursive = FALSE)

    ## Drop the expression that belongs to the file itself
    Filter(function(x) is.null(x$file_lines), exprs)
  }

  pd <- r_eval(fun, args = list(package), mode = "expert")
  src <- vapply(pd, "[[", "", "content")
  mean(vapply(strsplit(src, "\n"), length, 1L))
}
