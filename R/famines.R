#' World famines data from Our World in Data
#'
#' Year, country, and mortality data for 77 famines.
#'
#' @format A data frame with 77 rows and 6 variables.
#' \describe{
#'   \item{location}{Famine location, typically a single country}
#'   \item{iso_a3}{ISO code of famine location}
#'   \item{region}{Region}
#'   \item{year_start}{Year the famine began}
#'   \item{year_end}{Year the famine ended}
#'   \item{deaths_estimate}{Estimated mortality}
#' }
#'
#' @source The _Our World in Data_ Dataset of Famines.
#' \url{https://ourworldindata.org/famines#the-our-world-in-data-dataset-of-famines}
"famines"
