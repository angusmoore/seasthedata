seas_adjust_group <- function(original, date_col, frequency, group_vars, use_original, ...) {
  excl_vars <- c(group_vars, date_col)

  # Regularise time series
  original <- regularise(original, date_col, frequency, group_vars)
  start <- min(original[[date_col]])

  if (frequency == "quarter") {
    frequency <-  4
    start <- c(lubridate::year(start), lubridate::quarter(start))
  } else if (frequency == "month") {
    frequency <- 12
    start <- c(lubridate::year(start), lubridate::month(start))
  } else if (frequency == "day") {
    frequency <- 365
    start <- c(lubridate::year(start), lubridate::yday(start))
  }

  SA <- original[, excl_vars]

  for (var in colnames(original)) {
    if (!(var %in% excl_vars)) {
      tsversion <- stats::ts(original[[var]], start = start, frequency = frequency)
      if (any(is.na(tsversion))) {
        if (use_original) {
          warning("Time series has missing observations. Cannot seasonally adjust. Keeping original data.")
          SA <- dplyr::left_join(SA, original[, c(date_col, var)], by = date_col)
        } else {
          warning("Time series has missing observations. Cannot seasonally adjust. Replacing series with NAs.")
          SA[[var]] <- NA
        }
      } else {
        tryCatch({
          adjusted <- tibble::as_tibble(seasonal::seas(tsversion, ...))
          adjusted <- adjusted[, c("date", "final")]
          adjusted <- dplyr::rename_(adjusted, .dots = stats::setNames(c("date", "final"), c(date_col, var)))
          SA <- dplyr::left_join(SA, adjusted, by = date_col)
        },
        error=function(cond) {
          if (use_original) {
            warning("Time series has missing observations. Cannot seasonally adjust. Keeping original data.")
            SA <- dplyr::left_join(SA, original[, c(date_col, var)], by = date_col)
          } else {
            warning("Time series has missing observations. Cannot seasonally adjust. Replacing series with NAs.")
            SA[[var]] <- NA
          }
        })
      }
    }
  }
  return(SA)
}
