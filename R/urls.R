
urls <- list(
  crandb =
    "http://crandb.r-pkg.org",
  basesvn =
    "https://github.com/wch/r-source.git/branches/tags/R-%s/src/library/",
  bioc_pkg =
    "https://www.bioconductor.org/packages/release/bioc/html/%s.html"
)

urls$revdeps <- paste0(urls$crandb, "/-/revdeps/%s")
