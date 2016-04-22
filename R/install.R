
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
#' @importFrom remotes download_version install_local
#' @keywords internal

install_package_tmp <- function(package, version, quiet = TRUE) {

  ostmp <- dirname(tempdir())
  pkg_dir <- file.path(ostmp, paste0(package, "-", version))

  ## If the cached dir is good, nothing to do
  if (check_cached_dir(pkg_dir, package, version)) return(pkg_dir)

  ## Otherwise start clean
  unlink(pkg_dir, recursive = TRUE)

  dir.create(pkg_dir)
  dir.create(src_dir <- file.path(pkg_dir, "src"))
  dir.create(lib_dir <- file.path(pkg_dir, "lib"))

  message("Downloading ", package, " ", version %||% "(latest)")
  tmpfile <- download_version(
    package,
    version,
    type = "source",
    quiet = quiet
  )

  filename <- file.path(src_dir, paste0(package, "_", version, ".tar.gz"))
  file.copy(tmpfile, filename)
  unlink(tmpfile)

  message("Installing ", package, " ", version %||% "(latest)",
          " and dependencies")
  install_local(filename, quiet = quiet, lib = lib_dir, dependencies = TRUE)

  untar(filename, exdir = src_dir)

  pkg_dir
}

check_cached_dir <- function(pkg_dir, package, version) {

  src_dir <- file.path(pkg_dir, "src")
  lib_dir <- file.path(pkg_dir, "lib")

  if (!file.exists(pkg_dir) ||
      !file.exists(src_dir) ||
      !file.exists(lib_dir)) return(FALSE)

  can_attach <- with_libpaths(
    lib_dir,
    action = "prefix",
    require(
      package,
      quietly = TRUE,
      warn.conflicts = TRUE,
      character.only = TRUE
    )
  )
  if (!can_attach) return(FALSE)

  if (!file.exists(file.path(src_dir, package))) return(FALSE)

  TRUE
}
