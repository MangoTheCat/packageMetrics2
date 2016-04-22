
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

  dir.create(pkg_dir <- tempfile())
  dir.create(src_dir <- file.path(pkg_dir, "src"))
  dir.create(lib_dir <- file.path(pkg_dir, "lib"))

  tmpfile <- download_version(
    package,
    version,
    type = "source",
    quiet = quiet
  )

  filename <- file.path(src_dir, paste0(package, "_", version, ".tar.gz"))
  file.copy(tmpfile, filename)
  unlink(tmpfile)

  install_local(filename, quiet = quiet, lib = lib_dir)

  untar(filename, exdir = src_dir)

  pkg_dir
}
