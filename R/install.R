
default_repos <- function() {
  c(BioCsoft  = "http://bioconductor.org/packages/3.2/bioc",
    BioCann   = "http://bioconductor.org/packages/3.2/data/annotation",
    BioCexp   = "http://bioconductor.org/packages/3.2/data/experiment",
    BioCextra = "http://bioconductor.org/packages/3.2/extra",
    CRAN      = "http://cran.rstudio.com")
}

#' Download, extract and install a specific version of a package
#'
#' @param package Package name, character scalar.
#' @param version Version number, character scalar. If \code{NULL} then
#'   the latest available version is used.
#' @param quiet Whether to show the output of the download/install
#'   process.
#' @return A path to a directory where the package is downloaded,
#'   extracted and installed. Subdirectory \code{src/<package>}
#'   contains the extracted source package, \code{src} also contained
#'   the tarball. Subdirectory \code{lib} contains the library with
#'   the installed package(s). The dependencies are also installed here.
#'
#' @importFrom remotes install_local
#' @importFrom withr with_options
#' @include cran_data.R
#' @keywords internal

install_package_tmp <- function(package, version, quiet = TRUE) {
  with_options(
    list(repos = default_repos()),
    install_package_tmp2(package, version, quiet = quiet)
  )
}

install_package_tmp2 <- function(package, version, quiet) {

  pkg_dir <- get_pkg_dir(package, version)

  ## If the cached dir is good, nothing to do
  if (check_cached_dir(package, version)) return(pkg_dir)

  ## Otherwise start clean
  unlink(pkg_dir, recursive = TRUE)

  dir.create(pkg_dir, recursive = TRUE)
  dir.create(src_dir <- file.path(pkg_dir, "src"))
  dir.create(lib_dir <- file.path(pkg_dir, "lib"))

  message("Downloading ", package, " ", version %||% "(latest)")
  tmpfile <- if (is_base_package(package)) {
    download_base_package(package, version, quiet)

  } else {
    download_package(package, version, quiet)
  }

  filename <- file.path(src_dir, paste0(package, "_", version, ".tar.gz"))
  file.copy(tmpfile, filename)
  unlink(tmpfile)

  if (! is_base_package(package)) {
    message("Installing ", package, " ", version %||% "(latest)",
            " and dependencies")
    install_local(filename, quiet = quiet, lib = lib_dir, dependencies = TRUE)
  }

  untar(filename, exdir = src_dir)

  pkg_dir
}

get_pkg_dir <- function(package, version) {
  file.path(
    dirname(tempdir()),
    "packageMetrics2",
    paste0(package, "-", version)
  )
}

check_cached_dir <- function(package, version,
                             pkg_dir = get_pkg_dir(package, version)) {

  src_dir <- file.path(pkg_dir, "src")
  lib_dir <- file.path(pkg_dir, "lib")

  if (!file.exists(pkg_dir) ||
      !file.exists(src_dir) ||
      !file.exists(lib_dir)) return(FALSE)

  can_attach <- with_libpaths(
    lib_dir,
    action = "prefix",
    suppressPackageStartupMessages(require(
      package,
      quietly = TRUE,
      warn.conflicts = TRUE,
      character.only = TRUE
    ))
  )
  if (!can_attach) return(FALSE)

  if (!file.exists(file.path(src_dir, package))) return(FALSE)

  TRUE
}

#' @include urls.R

download_base_package <- function(package, version, quiet) {
  if (version != packageDescription(package)$Version) {
    stop("R version and base package version must match")
  }

  url <- sprintf(
    paste0(urls$basesvn, package),
    gsub(".", "-", fixed = TRUE, paste(version, collapse = "."))
  )

  cmd <- paste("svn export", url)
  tarfile <- paste0(package, "_", version, ".tar.gz")

  dir.create(tmp <- tempfile())
  on.exit(unlink(file.path(tmp, package), recursive = TRUE), add = TRUE)
  with_dir(
    tmp,
    {
      system(cmd, intern = quiet)
      tar(tarfile = tarfile, files = package)
    }
  )

  file.path(tmp, tarfile)
}

#' @importFrom remotes download_version

download_package <- function(package, version, quiet) {
  download_version(
    package,
    version,
    type = "source",
    quiet = quiet
  )
}
