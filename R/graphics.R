#' plot windrose for currents
#'
#' this is a wrapper around \code{\link[clifro]{windrose}}
#'
#' @export
#' @param x tibble of tiltometer data
#' @param legend_title title of legend
#' @param title character, or NA. Title of the plot, or NA to skip
#' @param speed.cuts character, numeric, or NA.
#' \itemize{
#' \item NA - the default, auto compute 5 quantiles
#' \item character - "quantile-3" or "quantile-4", computer 3 or 4 quantiles
#' \item numeric - explicit cut points in a vector
#' }
#' @param ... further arguments passed to \code{\link[ggplot2]{theme}}
#' @return ggplot

#Add quantiles, change colors, # wedges
tiltometer_rose <- function(x = read_tiltometer(),
                            legend_title = "Current Speed",
                            title = NA,
                            speed.cuts = NA,
                            ...){

  if (inherits(speed.cuts, "character") && !is.na(speed.cuts)){

    speed.cuts <- switch(speed.cuts[1],
                         "quantile-3" = quantile(x$speed, probs = c(0, (1/3), (2/3))),
                         "quantile-4" = quantile(x$speed, probs = c(0, 0.25, 0.5, 0.75)),
                         stop("speed_cuts method not known")
    )

    gg = clifro::windrose(x$speed,
                          x$dir,
                          legend_title = legend_title,
                          speed_cuts = speed.cuts,
                          ...)
  } else {

    gg = clifro::windrose(x$speed,
                          x$dir,
                          legend_title = legend_title,
                          ...)
  }

  if(!is.na(title[1])){
    gg = gg + ggplot2::labs(title = title[1])
  }

  return(gg)
}

#' Plot U and V vectors - possibly with low currents hidden from view
#'
#' @export
#' @param x tibble of tiltometer data
#' @param min_speed numeric, hide currents at or below this speed
#' @return ggplot2 object
draw_uv <- function(x = read_tiltometer(),
                    min_speed = 10,
                    main = "U-V currents"){

  # determine the start of each segment
  m <- abs(min_speed[1])
  x0 <- sqrt(m^2/(1 + x$v^2/x$u^2))
  y0 <- sqrt(m^2 - x0^2)

  x <- x %>%
    dplyr::arrange(.data$date) %>%
    dplyr::mutate(
      x0 = ifelse(.data$speed < m, .data$u, x0 * sign(.data$u)),
      y0 = ifelse(.data$speed < m, .data$v, y0 * sign(.data$v))) %>%
    dplyr::filter(.data$speed >= m)


  xr <- range(x$u)
  yr <- range(x$v)
  r <- c(min(c(xr[1], yr[1])), max(c(xr[2], yr[2])) )
  ggplot2::ggplot(data = x, ggplot2::aes(x = u, y = v)) +
    ggplot2::coord_fixed(ratio = 1,
                         xlim = r,
                         ylim = r) +
    ggplot2::labs(title = main) +
    ggplot2::geom_segment(ggplot2::aes(x = x0,
                                       y = y0,
                                       xend = u,
                                       yend = v),
                          alpha = 0.1)
}


