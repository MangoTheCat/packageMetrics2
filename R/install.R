
default_repos <- function() {
  c(remotes::bioc_install_repos(),
    RForge = "http://R-Forge.R-project.org",
    CRAN = "https://cran.rstudio.com"
    )
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

install_package_tmp <- function(package, version, quiet = TRUE,
                                source = NULL) {
  with_options(
    list(repos = default_repos()),
    install_package_tmp2(package, version, quiet = quiet, source = source)
  )
}

install_package_tmp2 <- function(package, version, quiet, source) {

  pkg_dir <- get_pkg_dir(package, version)

  ## If the cached dir is good, nothing to do
  if (check_cached_dir(package, version)) return(pkg_dir)

  ## Otherwise start clean
  unlink(pkg_dir, recursive = TRUE)

  dir.create(pkg_dir, recursive = TRUE)
  dir.create(src_dir <- file.path(pkg_dir, "src"))
  dir.create(lib_dir <- file.path(pkg_dir, "lib"))

  message("Downloading ", package, " ", version %||% "(latest)")

  type <- package_source_type(package, source)

  tmpfile <- if (is.na(type)) {
    stop("Unknown package source: ", source)

  } else if (type == "base") {
    download_package_base(package, version, quiet)

  } else if (type %in% c("CRAN", "BioC")) {
    download_package_cranlike(package, version, quiet)

  } else if (type == "GitHub") {
    download_package_github(package, version, source)

  } else if (type == "RForge") {
    download_package_cranlike(package, version)

  } else if (type == "URL") {
    download_package_url(package, source)
  }

  filename <- file.path(src_dir, paste0(package, "_", version, ".tar.gz"))
  file.copy(tmpfile, filename)
  unlink(tmpfile)

  if (! is_base_package(package)) {
    message("Installing ", package, " ", version %||% "(latest)",
            " and dependencies")
    install_local(
      filename,
      quiet = quiet,
      lib = lib_dir,
      dependencies = TRUE,
      INSTALL_opts = "--with-keep.source"
    )
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

package_source_type <- function(package, source) {

  if (is.null(source)) {
    "CRAN"                              # works for BioC as well

  } else if (tolower(source) == "cran") {
    "CRAN"

  } else if (tolower(source) == "base") {
    "base"

  } else if (tolower(source) == "bioc") {
    "BioC"

  } else if (tolower(source) == "recommended") {
    "CRAN"

  } else if (grepl("^github-", tolower(source))) {
    "GitHub"

  } else if (tolower(source) == "rforge") {
    "RForge"

  } else if (grepl("^url-", tolower(source))) {
    "URL"

  } else {
    NA_character_
  }
}

#' @include urls.R

download_package_base <- function(package, version, quiet) {
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

      lines <- readLines(file.path(package, "DESCRIPTION.in"))
      lines <- gsub("@VERSION@", version, lines, fixed = TRUE)
      writeLines(lines, file.path(package, "DESCRIPTION"))

      tar(tarfile = tarfile, files = package)
    }
  )

  file.path(tmp, tarfile)
}

#' @importFrom remotes download_version

download_package_cranlike <- function(package, version, quiet) {
  download_version(
    package,
    version,
    type = "source",
    quiet = quiet
  )
}

download_package_github <- function(package, version, source) {

  slug <- sub("^github-", "", source)

  ## Handle subdirectories
  dir <- sub("^[^/]+/[^/]+", "", slug)
  slug <- sub("^([^/]+/[^/]+).*$", "\\1", perl = TRUE, slug)

  url <- NULL

  ## If no version, then just a snapshot
  if (is.null(version)) url <- gh_download_url(slug)

  ## Try releases first
  if (is.null(url)) {
    releases <- gh_releases(slug)
    if (version %in% names(releases)) {
      url <- releases[version]
    } else if (paste0("v", version) %in% names(releases)) {
      url <- releases[paste0("v", version)]
    }
  }

  ## Otherwise try tags
  if (is.null(url)) {
    tags <- gh_tags(slug)
    if (version %in% names(tags)) {
      url <- tags[version]
    } else if (paste0("v", version) %in% names(tags)) {
      url <- tags[paste0("v", version)]
    }
  }

  ## Otherwise just download a snapshot
  url <- gh_download_url(slug)

  download(tmp <- tempfile(fileext = ".tar.gz"), url)

  build_tar_gz(tmp, dir)
}

#' @importFrom withr with_dir
#' @importFrom callr rcmd_safe

build_tar_gz <- function(targz, dir) {

  dir.create(tmpdir <- tempfile())
  untar(targz, exdir = tmpdir)
  pkgdir <- file.path(tmpdir, list.files(tmpdir))

  build_status <- with_dir(
    tmpdir,
    rcmd_safe("build", file.path(basename(pkgdir), dir))
  )
  unlink(pkgdir, recursive = TRUE)
  report_system_error("Build failed", build_status)

  ## replace previous handler, no need to clean up any more
  on.exit(NULL)

  file.path(
    tmpdir,
    list.files(tmpdir, pattern = "\\.tar\\.gz$")
  )
}

report_system_error <- function(msg, status) {

  if (status$status == 0) return()

  if (status$stderr == "") {
    stop(
      msg, ", unknown error, standard output:\n",
      status$stdout,
      call. = FALSE
    )

  } else {
    stop(
      paste0("\n", msg, ", standard output:\n\n"),
      status$stdout, "\n",
      "Standard error:\n\n", status$stderr,
      call. = FALSE
    )
  }
}

download_package_url <- function(package, source) {
  url <- sub("^url-", "", source)
  download(tmp <- tempfile(fileext = ".tar.gz"), url)
  tmp
}
