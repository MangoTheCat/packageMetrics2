
#' Try to find out whether the package is on GitHub
#'
#' We try to look for a \code{URL} and \code{BugReports}
#' field in the \code{DESCRIPTION} file, and check if
#' they point to GitHub.
#'
#' @param package Package name.
#' @param version Package version, ignored currently.
#' @return \code{1} if the package is on GitHub,
#'   \code{0} if we could not decide.
#'
#' @keywords internal
#' @importFrom desc desc_get

is_on_github <- function(package, version = NULL) {
  url <- desc_get(file = package, "URL")
  bug_reports <- desc_get(file = package, "BugReports")

  0 + (has_gh_link(url) || has_gh_link(bug_reports))
}

has_gh_link <- function(url) {
  !is.na(url) && grepl("https://github.com", url)
}
