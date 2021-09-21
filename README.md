# seasthedata

 <!-- badges: start -->
 [![CI](https://github.com/angusmoore/seasthedata/actions/workflows/CI.yml/badge.svg)](https://github.com/angusmoore/seasthedata/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/angusmoore/seasthedata/branch/main/graph/badge.svg?token=KGtvZcW48b)](https://codecov.io/gh/angusmoore/seasthedata)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

`seasthedata` is an `R` package that makes it easy to seasonally adjust tidy data using X13. It is a thin wrapper around the `seasonal` library (see [github](https://github.com/christophsax/seasonal); [cran](https://cran.r-project.org/package=seasonal)).

The benefit of `seasthedata` is that it accepts `tibbles` or `data.frames` with date columns (instead of `ts`) and respects grouping variables. This means you can easily seasonally adjust a large number of series that are in long form.

## Installation

Install the package using the R `devtools` package:
  ```
library(devtools)
install_github("angusmoore/seasthedata", ref= "stable")
```

You may need to first install the `devtools` package if you don't already have it (`install.packages("devtools")`).

Installing may fail if `devtools` cannot correctly determine your proxy server. If so, you'll get the following error message when you try to install:
```
Installation failed: Timeout was reached: Connection timed out after 10000 milliseconds
```
If you get this message, try setting your proxy server with the following command, and then running the install again:
```
Sys.setenv(https_proxy = curl::ie_get_proxy_for_url("https://www.google.com"))
```

## Usage
The library is a thin wrapper around the `seasonal` library, which itself wraps
the US Census Bureau X13 binary.

```
library(seasthedata)
library(dplyr)
library(tibble)

# First, just seasonally adjust a tibble of data with a date column
ungrouped_data <- tibble(dates = seq.Date(from = as.Date("1949-01-01"), by = "month",
                        length.out = 144), y = as.vector(AirPassengers))
seasthedata(ungrouped_data)

# Now create some fake GROUPED data, where we have two series - group A and B
grouped_data <- bind_rows(mutate(ungrouped_data, group = "A"),
                          mutate(ungrouped_data, group = "B"))
grouped_data <- group_by(grouped_data, group)

seasthedata(grouped_data)
```

# Package documentation

Documentation for this package can be found [here](https://angusmoore.github.io/seasthedata/).
