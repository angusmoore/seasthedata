library(tibble)
library(dplyr)
library(magrittr)

## SANITY CHECKS ===============
test_that("Sanity checks", {
  # Test that only accepts data.frame or tibble
  expect_error(seasthedata(c(1, 2, 3)))
  expect_error(seasthedata(1))

  # Error if wrong frequency data
  data <- tibble(date = seq.Date(from = as.Date("2001-01-01"), by = "year", length.out = 10), y = rnorm(10))
  expect_error(seasthedata(data))
  expect_error(seasthedata(data, frequency = "foo"))
})

## SMOKE TESTS ===============
ungrouped <- tibble(
  dates = seq.Date(from = as.Date("1949-01-01"), by = "month", length.out = 144),
  y = as.vector(AirPassengers))
twocolumns <-  tibble(
  dates = seq.Date(from = as.Date("1949-01-01"), by = "month", length.out = 144),
  y1 = as.vector(AirPassengers),
  y2 = as.vector(AirPassengers))
grouped <- bind_rows(mutate(ungrouped, group = "A"), mutate(ungrouped, group = "B")) %>%
  group_by(group)
grouped_twice <- bind_rows(mutate(grouped, group2 = "C"), mutate(grouped, group2 = "D")) %>%
  group_by(group, group2)

# Simple ungrouped data
test_that("Smoke tests - Ungrouped data", {
  expect_error(seasthedata(ungrouped), NA)
  expect_error(seasthedata(twocolumns), NA)
})

test_that("Smoke tests - Grouped data", {
  # Grouped data
  expect_error(seasthedata(grouped), NA)

  # Multiple grouping variables
  expect_error(seasthedata(grouped_twice), NA)

  # Error if forgotten a grouping variable
  expect_error(seasthedata(ungroup(grouped)))
})

test_that("Missing data", {
  # Missing dates, single series
  missing <- filter(ungrouped, dates != as.Date("1949-05-01"))
  missingshouldbe <- mutate(ungrouped, y = ifelse(dates == as.Date("1949-05-01"), NA, y))
  expect_equal(seasthedata(missing, use_original = TRUE), missingshouldbe)
  expect_warning(seasthedata(missing, use_original = TRUE), "internal NAs")
  shouldbe <- tibble(dates = ungrouped$dates, y = NA)
  expect_equal(seasthedata(missing, use_original = FALSE), shouldbe)

  # Missing dates in one group
  grouped <- bind_rows(mutate(ungrouped, group = "A"), mutate(missing, group = "B")) %>%
    group_by(group)
  out <- filter(seasthedata(grouped, use_original = FALSE), group == "B")
  expect_true(all(is.na(out$y)))
  out <- select(ungroup(filter(seasthedata(grouped, use_original = TRUE), group == "B")), -group)
  expect_equal(out, missingshouldbe)

  # But leading and trailing observations from one of the groups should make no difference
  chopped <- ungrouped[10:100, ]
  unbalanced <- bind_rows(mutate(ungrouped, group = "full"), mutate(chopped, group = "chop")) %>%
    group_by(group)
  expect_error(seasthedata(unbalanced), NA)

  # leading (or trailing) NAs should be trimmed and ignored
  foo <- data.frame(date = seq.Date(from = as.Date("2000-01-01"), by = "quarter", length.out = 40), x = rnorm(40))
  foo$x[1:2] <- NA
  expect_error(seasthedata(foo), NA)
  foo$x[39:40] <- NA
  expect_error(seasthedata(foo), NA)

  # If series is all NA (#13)
  foo <- data.frame(x = seq.Date(from = as.Date("2000-01-01"), by = "month", length.out = 100), y = NA)
  expect_error(
    seasthedata(foo),
    NA
  )
})
