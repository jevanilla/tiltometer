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



