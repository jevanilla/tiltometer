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
#' @param flip plotting water, not wind, default TRUE
#' @param ... further arguments passed to \code{\link[ggplot2]{theme}}
#' @return ggplot

#Add change colors, # wedges
tiltometer_rose <- function(x = read_tiltometer(),
                            legend_title = "Current Speed",
                            title = NA,
                            speed.cuts = NA,
                            flip = TRUE,
                            ...){
if (FALSE){
  legend_title = "Current Speed"
  title = NA
  speed.cuts = NA
}

    if (flip == TRUE) {
      x <- x %>% dplyr::mutate(dir = (.data$dir + 180) %% 360)
    }

  #https://math.stackexchange.com/questions/1319615/how-to-calculate-opposite-direction-angle

  site <- factor(x$Site)

  if (inherits(speed.cuts, "character") || is.na(speed.cuts)){

    speed.cuts <- switch(speed.cuts[1],
                         "quantile-3" = quantile(x$speed, probs = c(0, (1/3), (2/3))),
                         "quantile-4" = quantile(x$speed, probs = c(0, 0.25, 0.5, 0.75)),
                         ggplot2::cut_interval(x$speed, 5)
    )

    gg = clifro::windrose(x$speed,
                          x$dir,
                          legend_title = legend_title,
                          speed_cuts = speed.cuts,
                          facet = site,
                          ...)
  } else {

    gg = clifro::windrose(x$speed,
                          x$dir,
                          legend_title = legend_title,
                          facet = site,
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
#' @param alpha numeric, 0.1 default
#' @param facet character, name of the column to facet upon (like "Site") or NULL to skip
#' @param main character, title
#' @return ggplot2 object
draw_uv <- function(x = read_tiltometer(),
                    min_speed = 10,
                    main = "U-V currents",
                    facet = NULL,
                    alpha = 0.1){


  normalizeSite <- function(x, key, min_speed = 10) {
      # determine the start of each segment
      m <- abs(min_speed[1])
      x0 <- sqrt(m^2/(1 + x$v^2/x$u^2))
      y0 <- sqrt(m^2 - x0^2)

      x %>% dplyr::mutate(
                    x0 = ifelse(.data$speed < m, .data$u, x0 * sign(.data$u)),
                    y0 = ifelse(.data$speed < m, .data$v, y0 * sign(.data$v))) %>%
            dplyr::filter(.data$speed >= m)
  }

  x <- x %>%
    dplyr::group_by(.data$Site) %>%
    dplyr::arrange(.data$DateTime) %>%
    dplyr::group_map(normalizeSite, .keep = TRUE, min_speed = min_speed) %>%
    dplyr::bind_rows()


  xr <- range(x$u)
  yr <- range(x$v)
  r <- c(min(c(xr[1], yr[1])), max(c(xr[2], yr[2])) )
  gg <- ggplot2::ggplot(data = x, ggplot2::aes(x = .data$u, y = .data$v)) +
        ggplot2::coord_fixed(ratio = 1,
                         xlim = r,
                         ylim = r) +
        ggplot2::labs(title = main) +
        ggplot2::geom_segment(ggplot2::aes(x = x0,
                                       y = y0,
                                       xend = .data$u,
                                       yend = .data$v),
                          alpha = alpha[1])

  if (!is.null(facet)){
    gg <- gg + ggplot2::facet_wrap(facet)
  }

  gg
}


