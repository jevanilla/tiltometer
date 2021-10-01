#' retreive example type tiltometer file name
#'
#' @export
#' @return filename
example_filename <- function(){
  system.file("exampledata/2006052_Halfway_TCM_Current.csv.gz",
              package="tiltometer")
}

#' clip tiltometer table by date
#'
#' @export
#' @param x tibble, tiltometer
#' @param deploy POSIXt or NA, if not NA, clip data before this time
#' @param recover POSIXt or NA, if not NA, clip data before this time
#' @return tibble
clip_tiltometer <- function(x,
                            deploy = NA,
                            recover = NA) {

  if (!is.na(deploy)) {
    x <- x %>%
      dplyr::filter(date >= deploy[1])
  }

  if (!is.na(recover)) {
    x <- x %>%
      dplyr::filter(date <= recover[1])
  }

  x
}

#' read tiltometer data file
#'
#' @export
#' @param filename character, the name of the file
#' @param deploy POSIXt or NA, if not NA, clip data before this time
#' @param recover POSIXt or NA, if not NA, clip data before this time
#' @return tibble
read_tiltometer <- function(filename = example_filename(),
                            deploy = NA,
                            recover = NA){
  stopifnot(inherits(filename, "character"))
  stopifnot(file.exists(filename[1]))
  x <- suppressMessages(readr::read_csv(filename[1]))
  #cleaning up the header
  h <- colnames(x)
  lut <- c("ISO 8601 Time" = "date",
           "Speed (cm/s)" = "speed",
           "Heading (degrees)" = "dir",
           "Velocity-N (cm/s)" = "v",
           "Velocity-E (cm/s)" = "u")
  colnames(x) <- lut[h]
#adapted from: https://stackoverflow.com/questions/8613237/extract-info-inside-all-parenthesis-in-r
  attr(x, "units") <- stringr::str_extract(h, "(?<=\\().*?(?=\\))")
  attr(x, "filename") <- filename[1]
  #use the spec attr for original colnames
  #attr(x, "original_colnames") <- h


  x <- clip_tiltometer(x,
                       deploy = deploy,
                       recover = recover)

  return(x)

}


