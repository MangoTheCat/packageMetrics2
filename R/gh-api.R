
gh_url <- function(endpoint) {
  paste0("https://api.github.com", endpoint)
}

#' @importFrom jsonlite fromJSON

gh <- function(endpoint) {
  url <- gh_url(endpoint)
  download(tmp <- tempfile(), url)
  fromJSON(tmp, simplifyVector = FALSE)
}

get_slug <- function(owner, repo) {
  if (is.null(repo)) owner else paste0(owner, "/", repo)
}

gh_releases <- function(owner, repo = NULL) {
  slug <- get_slug(owner, repo)
  endpoint <- paste0("/repos/", slug, "/releases")
  rel <- gh(endpoint)
  names <- vapply(rel, "[[", "tag.name", FUN.VALUE = "")
  urls <- vapply(rel, "[[", "tarball_url", FUN.VALUE = "")
  structure(urls, names = names)
}

gh_tags <- function(owner, repo = NULL) {
  slug <- get_slug(owner, repo)
  endpoint <- paste0("/repos/", slug, "/tags")
  tags <- gh(endpoint)
  names <- vapply(tags, "[[", "name", FUN.VALUE = "")
  urls <- vapply(tags, "[[", "tarball_url", FUN.VALUE = "")
  structure(urls, names = names)
}

gh_download_url <- function(owner, repo = NULL,
                            format = c("tarball", "zipball"),
                            ref = "master") {
  format <- match.arg(format)
  slug <- get_slug(owner, repo)
  endpoint <- paste0("/repos/", slug, "/", format, "/", ref)
  gh_url(endpoint)
}
