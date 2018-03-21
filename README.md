[![Travis-CI Build Status](https://travis-ci.org/angusmoore/lubriseas.svg?branch=master)](https://travis-ci.org/angusmoore/lubriseas)
[![Coverage Status](https://coveralls.io/repos/github/angusmoore/lubriseas/badge.svg?branch=master)](https://coveralls.io/github/angusmoore/lubriseas?branch=master)

# lubriseas
`lubriseas` is an `R` package that makes it easy to seasonally adjust tidy data using X13. It is a thin wrapper around the `seasonal` library (see [github](https://github.com/christophsax/seasonal) [cran](https://cran.r-project.org/package=seasonal)).

The benefit of `lubriseas` is that it accepts `tibbles` or `data.frames` with date columns (instead of `ts`) and respects grouping variables. This means you can easily seasonally adjust a large number of series that are in long form.

## Installation

Install the package using the R `devtools` package:
  ```
library(devtools)
install_github("angusmoore/lubriseas")
```

You may need to first install the `devtools` package if you don't already have it (`install.packages("devtools")`).

Installing may fail if `devtools` cannot correctly determine your proxy server. If so, you'll get the following error message when you try to install:
```
Installation failed: Timeout was reached: Connection timed out after 10000 milliseconds
```
If you get this message, try setting your proxy server with the following command, and then running the install again:
```
httr::set_config(httr::use_proxy(curl::ie_get_proxy_for_url("http://www.google.com")))
```

## Usage
The library is a thin wrapper around the `seasonal` library, which itself wraps
the US Census Bureau X13 binary.

```
library(lubriseas)
library(dplyr)
library(tibble)

# First, just seasonally adjust a tibble of data with a date column
ungrouped_data <- tibble(dates = seq.Date(from = as.Date("1949-01-01"), by = "month",
                        length.out = 144), y = as.vector(AirPassengers))
lubriseas(ungrouped_data)

# Now create some fake GROUPED data, where we have two series - group A and B
grouped_data <- bind_rows(mutate(ungrouped_data, group = "A"),
                          mutate(ungrouped_data, group = "B"))
grouped_data <- group_by(grouped_data, group)

lubriseas(grouped_data)
```

# Package documentation

Documentation for this package can be found [here](https://angusmoore.github.io/lubriseas/lubriseas.pdf).
