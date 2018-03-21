#' Easily seasonally adjust a tibble or data.frame of long data
#'
#' lubriseas will automatically seasonally adjust every column in your tibble
#' while respecting groups. Your data must contain exactly one column of dates.
#'
#' lubriseas is a wrapper around the seasonal library (https://github.com/christophsax/seasonal)
#'
#' @param original Your data, in original terms, to be seasonally adjusted.
#' @param frequency (Optional) The frequency of your data. Accepted options are
#' "quarter", "month", "day". If omitted, lubriseas will guess the frequency.
#' @param use_original (default: FALSE) If the series cannot be seasonally
#' adjusted, should the returned data have NAs for the relevant series (default)
#' or the original data.
#' @param ... Options to be passed to X13. See the documentation for the seas
#' function (https://cran.r-project.org/web/packages/seasonal/seasonal.pdf)
#'
#' @examples
#' library(dplyr)
#' library(tibble)
#' ungrouped_data <- tibble(dates = seq.Date(from = as.Date("1949-01-01"),
#'                          by = "month", length.out = 144),
#'                          y = as.vector(AirPassengers))
#' lubriseas(ungrouped_data)
#'
#' grouped_data <- bind_rows(mutate(ungrouped_data, group = "A"),
#'                           mutate(ungrouped_data, group = "B"))
#' grouped_data <- group_by(grouped_data, group)
#' lubriseas(grouped_data)
#'
#' @export
lubriseas <- function(original, frequency = NULL, use_original = FALSE, ...) {
  # Sanity check input
  if (!tibble::is_tibble(original) && !is.data.frame(original)) {
    stop("You data are not a tibble or data frame.")
  }

  date_col <- get_date_col(original)
  if (is.null(frequency)) {
    frequency <- find_frequency(original[[date_col]])
    message(paste0("Frequency not supplied, have determined it to be ", frequency))
  }

  if (frequency != "quarter" && frequency != "month" && frequency != "day") {
    stop(paste0("Do not know how to seasonally adjust data with frequency ", frequency))
  }

  # We use dplyr::do so that we respect grouping variables
  dplyr::do(original, seas_adjust_group(original = .,
                                        date_col = date_col,
                                        frequency = frequency,
                                        group_vars = dplyr::group_vars(original),
                                        use_original = use_original,
                                        ...))
}
