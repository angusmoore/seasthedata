library(tibble)
library(dplyr)
library(magrittr)

## FIND DATE COLUMN ================
test_that("Find date column", {
    date_seq <- seq.Date(from = as.Date("2017-01-01"), by = "month", length.out = 3)

    # Expect error for data without date column
    no_date <- tibble(x = c(1,2,3), y = rnorm(3))
    expect_error(get_date_col(no_date))

    # Expect error if two date columns
    two_dates <- tibble(d1 = date_seq, d2 = date_seq, y = rnorm(3))
    expect_error(get_date_col(two_dates))

    # Check gets it right
    one_date <- tibble(actual_dates = date_seq, x1 = rnorm(3), x2 = rnorm(3))
    expect_equal(get_date_col(one_date), "actual_dates")
})

## FIND DATA FREQUENCY ================
test_that("Find frequency of data", {
    # Set up fake data first
    yearly <- seq.Date(from = as.Date("2001-01-01"), by = "year", length.out = 10)
    yearly_drop <- yearly[c(1:5,7:10)] # Correctly handle missing observations

    quarterly <- seq.Date(from = as.Date("2001-01-01"), by = "quarter", length.out = 10)
    quarterly_drop <- quarterly[c(1:5,7:10)] # Correctly handle missing observations

    monthly <- seq.Date(from = as.Date("2001-01-01"), by = "month", length.out = 10)
    monthly_drop <- monthly[c(1:5,7:10)] # Correctly handle missing observations

    daily <- seq.Date(from = as.Date("2001-01-01"), by = "day", length.out = 10)
    daily_drop <- daily[c(1:5,7:10)] # Correctly handle missing observations

    expect_equal(find_frequency(yearly), "year")
    expect_equal(find_frequency(yearly_drop), "year")
    expect_equal(find_frequency(quarterly), "quarter")
    expect_equal(find_frequency(quarterly_drop), "quarter")
    expect_equal(find_frequency(monthly), "month")
    expect_equal(find_frequency(monthly_drop), "month")
    expect_equal(find_frequency(daily), "day")
    expect_equal(find_frequency(daily_drop), "day")
})

## REGULARISE TIME SERIES ================
test_that("Regularise time series", {
    quarterly <- seq.Date(from = as.Date("2001-01-01"), by = "quarter", length.out = 10)
    non_missing <- tibble(dates = quarterly, y1 = rnorm(10), y2 = rnorm(10))
    missing <- non_missing[c(1:5,7:10), ]

    expect_equal(regularise(non_missing, frequency = "quarter"), non_missing) # should be no-op

    shouldbe <- non_missing
    shouldbe[6, c("y1", "y2")] <- NA
    expect_equal(regularise(missing, frequency = "quarter"), shouldbe)

    # Wrongly passing in ungrouped data, so that there are duplicate groups
    duplicate <- bind_rows(missing, non_missing)
    expect_error(regularise(duplicate, frequency = "quarter"))

    # Regularise grouped data (check that group variables are correctly applied to widened observations)
    grouped_missing <- mutate(missing, group = "A")
    expect_false(any(is.na(regularise(grouped_missing, frequency = "quarter")$group)))
})