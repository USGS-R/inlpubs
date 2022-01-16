#' Bibliographic Information of the INLPO
#'
#' Bibliographic information for reports, articles, maps, and theses related
#' to scientific monitoring and research conducted by the U.S. Geological Survey (USGS),
#' Idaho Water Science Center,
#' \href{https://www.usgs.gov/centers/idaho-water-science-center/science/idaho-national-laboratory-project-office}{Idaho National Laboratory Project Office}
#' (INLPO).
#'
#' @format An object of class \sQuote{pubs_data} that inherits behavior from the data frame class.
#'   Each record corresponds to a bibliographical item and contains the following variables:
#'   \describe{
#'     \item{\code{key}}{\href{https://en.wikipedia.org/wiki/BibTeX}{BibTeX} key for the citation entry;}
#'     \item{\code{year}}{year of publication;}
#'     \item{\code{citation}}{bibliographic entry of class \link[utils]{bibentry};}
#'     \item{\code{abstract}}{abstract text string;}
#'     \item{\code{annotation}}{Knobel and others (2005) annotation text string.}
#'   }
#'   Row names are the BibTeX key for the citation entry.
#'
#' @source Many of these publications are available through the
#'   \href{https://pubs.er.usgs.gov/}{USGS Publications Warehouse}.
#'
#' @references
#'    Knobel, L.L., Bartholomay, R.C., and Rousseau, J.P., 2005,
#'    Historical development of the U.S. Geological Survey hydrologic monitoring and investigative programs
#'    at the Idaho National Engineering and Environmental Laboratory, Idaho, 1949 to 2001:
#'    U.S. Geological Survey Open-File Report 2005--1223 (DOE/ID--22195), 93 p.,
#'    \doi{10.3133/ofr20051223}.
#'
#' @keywords datasets
#'
#' @examples
#' ## Display table structure
#' str(pubs, max.level = 1, nchar.max = 50)
#'
#' ## Print the citation key for each entry in the bibliography:
#' rownames(pubs[1:10, ])
#'
#' ## Print citation, authors, and abstract for Fisher and others (2012):
#' key <- "FisherOthers2012"
#' ref <- pubs[key, "citation"]
#' print(ref, style = "citation", bibtex = TRUE)
#' format(ref$author, c("given", "family"))
#' txt <- pubs[key, "abstract"]
#' cat(strwrap(txt), sep = "\n")
#'
#' ## Print list of authors:
#' authors <- do.call("c", pubs$citation$author)
#' authors <- authors[!duplicated(authors)]
#' cat(format(authors[1:10]), sep = "\n")
#'
#' \dontrun{
#' ## Export suggested citations from the bibliography:
#' txt <- sort(vapply(pubs$citation, function(x) {
#'   attr(unclass(x)[[1]], "textVersion")
#' }, character(1)))
#' txt <- head(c(rbind(txt, character(length(txt)))), -1)
#' txt <- strwrap(txt, width = 80, exdent = 2)
#' file <- tempfile(fileext = ".txt")
#' writeLines(txt, file)
#' file.show(file, title = "Suggested citations")
#' }

"pubs"
