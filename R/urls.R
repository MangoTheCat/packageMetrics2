
urls <- list(
  crandb =
    "http://crandb.r-pkg.org",
  basesvn =
    "https://github.com/wch/r-source.git/branches/tags/R-%s/src/library/"
)

urls$revdeps <- paste0(urls$crandb, "/-/revdeps/%s")
