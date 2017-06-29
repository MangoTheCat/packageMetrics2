<!-- README.md is generated from README.Rmd. Please edit that file -->
packageMetrics2
===============

> Collect Metrics about R Packages

[![Project Status: WIP: Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip) [![Travis-CI Build Status](https://travis-ci.org/MangoTheCat/packageMetrics2.svg?branch=master)](https://travis-ci.org/MangoTheCat/packageMetrics2) [![](http://www.r-pkg.org/badges/version/packageMetrics2)](http://www.r-pkg.org/pkg/packageMetrics2) [![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/packageMetrics2)](http://www.r-pkg.org/pkg/packageMetrics2) [![Coverage Status](https://codecov.io/github/MangoTheCat/packageMetrics2/coverage.svg?branch=master)](https://codecov.io/github/MangoTheCat/packageMetrics2?branch=master)

This package is used to collect metrics about CRAN, BioConductor or other packages, for Valid-R.

Installation
------------

``` r
remotes::install_github("mangothecat/packageMetrics2")
```

Usage
-----

``` r
library(packageMetrics2)
```

See available metrics:

``` r
list_package_metrics()
```

    #>                                                 ARR 
    #>          "Number of times = is used for assignment" 
    #>                                                 ATC 
    #>                              "Author Test Coverage" 
    #>                                                 DWL 
    #>                               "Number of Downloads" 
    #>                                                 DEP 
    #>                               "Num of Dependencies" 
    #>                                                 DPD 
    #>                    "Number of Reverse-Dependencies" 
    #>                                                 CCP 
    #>                             "Cyclomatic Complexity" 
    #>                                                 FLE 
    #>         "Average number of code lines per function" 
    #>                                                 FRE 
    #>                             "Date of First Release" 
    #>                                                 LIB 
    #>               "Number of library and require calls" 
    #>                                                 LLE 
    #>    "Number of code lines longer than 80 characters" 
    #>                                                 LNC 
    #>                  "Number of lines of compiled code" 
    #>                                                 LNR 
    #>                         "Number of lines of R code" 
    #>                                                 LRE 
    #>                              "Date of Last Release" 
    #>                                                 NAT 
    #>                 "Number of attach and detach calls" 
    #>                                                 NTF 
    #> "Number of times T/F is used instead of TRUE/FALSE" 
    #>                                                 NUP 
    #>                  "Updates During the Last 6 Months" 
    #>                                                 OGH 
    #>                  "Whether the package is on GitHub" 
    #>                                                 SAP 
    #>                            "Number of sapply calls" 
    #>                                                 SEM 
    #>         "Number of trailing semicolons in the code" 
    #>                                                 SEQ 
    #>               "Number of 1:length(vec) expressions" 
    #>                                                 SWD 
    #>                             "Number of setwd calls" 
    #>                                                 VIG 
    #>                               "Number of vignettes"

Calculate metrics for a named package:

``` r
metrics <- package_metrics("remotes")
```

    #> Downloading remotes (latest)

    #> Installing remotes (latest) and dependencies

    #> Installing 1 packages: curl

    #> 
    #>   There is a binary version available (and will be installed) but
    #>   the source version is later:
    #>      binary source
    #> curl    2.6    2.7
    #> 
    #> package 'curl' successfully unpacked and MD5 sums checked

    #> Metrics:

    #> ARR

    #> Preparing: lintr

    #> ATC

    #> DWL

    #> DEP

    #> DPD

    #> CCP

    #> FLE

    #> FRE

    #> LIB

    #> LLE

    #> LNC

    #> LNR

    #> LRE

    #> NAT

    #> NTF

    #> NUP

    #> OGH

    #> SAP

    #> SEM

    #> SEQ

    #> SWD

    #> VIG

    #> 

``` r
head(metrics)
```

    #>                ARR                ATC                DWL 
    #>                "0" "94.2539388322521"            "69747" 
    #>                DEP                DPD                CCP 
    #>                "4"                "2" "2.68939393939394"

License
-------

MIT © Mango Solutions
