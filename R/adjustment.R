adjust_single_series <- function(SA, original, var, date_col, start, frequency, use_original, ...) {
  if (all(is.na(original[[var]]))) {
    SA[[var]] <- NA
  } else {
    tsversion <- stats::ts(original[[var]], start = start, frequency = frequency)

    omit_leading <- leading_nas(tsversion)
    omit_trailing <- trailing_nas(tsversion)

    tryCatch({
      adjusted <- seasonal::seas(tsversion, ...)
      adjusted <- tibble::as_tibble(adjusted$data)

      # Put the original dates in. Drop any that correspond to leading or trailing NAs
      original_dates <- original[[date_col]]
      original_dates <- original_dates[(1+omit_leading):(length(original_dates)-omit_trailing)]
      adjusted$date <- original_dates

      # Get only the needed series (and rename them)
      adjusted <- adjusted[, c("date", "final")]
      adjusted <- dplyr::rename_(adjusted, .dots = stats::setNames(c("date", "final"), c(date_col, var)))

      # Merge in
      SA <- dplyr::left_join(SA, adjusted, by = date_col)
    },
    error=function(cond) {
      if (use_original) {
        warning(paste0("Error seasonally adjusting series (keeping original data): ", cond))
        SA <<- dplyr::left_join(SA, original[, c(date_col, var)], by = date_col)
      } else {
        warning(paste0("Error seasonally adjusting series (replacing series with NAs): ", cond))
        SA[[var]] <<- NA
      }
    })
  }

  return(SA)
}

seas_adjust_group <- function(original, date_col, frequency, group_vars, use_original, ...) {
  # Regularise time series
  original <- regularise(original, date_col, frequency, group_vars)

  # Get start date
  start <- get_start_date(original[[date_col]], frequency)

  # Create a copy of only the non-adjusted vars.
  # We'll merge the adjusted data on column by column once we've adjusted it.
  SA <- original[, date_col, drop = FALSE]

  for (var in setdiff(colnames(original), c(date_col, names(group_vars)))) {
    SA <- adjust_single_series(SA, original, var, date_col, start, frequency_number(frequency), use_original, ...)
  }
  return(dplyr::bind_cols(SA, group_vars))
}
