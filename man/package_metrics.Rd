% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/package.R
\name{package_metrics}
\alias{package_metrics}
\title{Calculate all or the specified metrics for a package}
\usage{
package_metrics(package, version = NULL,
  metrics = names(list_package_metrics()), source = NULL)
}
\arguments{
\item{package}{Package name, character scalar.}

\item{version}{Version number, character scalar. If \code{NULL},
then the latest version is used.}

\item{metrics}{The ids of the metrics to calculate. The default
is to calculate all implemented metrics.}

\item{source}{Where to get the package sources. CRAN and BioC
packages are found automatically, others need to be specified.}
}
\value{
A named character vector. The names are the three letter
  metrics ids.
}
\description{
Calculate all or the specified metrics for a package
}
\seealso{
\code{\link{package_metrics_csv}} to calculate the
  metrics and write the output to a CSV file.
}
