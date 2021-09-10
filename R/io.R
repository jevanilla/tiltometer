#' retreive example type tiltometer file name
#'
#' @export
#' @return filename
example_filename <- function(){
  system.file("exampledata/2006052_Halfway_TCM_Current.csv.gz",
              package="tiltometer")
}


#' read tiltometer data file
#'
#' @export
#' @param filename character, the name of the file
#' @return tibble
read_tiltometer <- function(filename = example_filename()){
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
  return(x)

}


