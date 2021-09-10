#' plot windrose for currents
#'
#' this is a wrapper around \code{\link[clifro]{windrose}}
#'
#' @export
#' @param x tibble of current data
#' @return ggplot

tiltometer_rose <- function(x){
  clifro::windrose(x$speed, x$dir)
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


