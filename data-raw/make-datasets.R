#!/usr/bin/env Rscript

# Script requirements:
# - Working directory is the package path

# read and parse author data
message("Read and parse author data.")
checkmate::assertFileExists("data-raw/authors.tsv", access = "r")
d <- utils::read.table(
  file = "data-raw/authors.tsv",
  header = TRUE,
  sep = "\t",
  quote = "",
  colClasses = "character",
  check.names = FALSE,
  strip.white = TRUE,
  encoding = "UTF-8"
)
checkmate::assertDataFrame(
  d,
  types = "character",
  ncols = 6,
  .var.name = "authors.tsv"
)
checkmate::assert_names(colnames(d),
  identical.to = c(
    "Author key",
    "Last",
    "First",
    "Middle",
    "Email",
    "ORCID"
  ),
  .var.name = "colnames(authors.tsv)"
)
d <- d[order(d$Last, d$First, d$Middle), ]
if (any(is <- duplicated(d$`Author key`))) {
  bad <- paste(sQuote(d$`Author key`[is]), collapse = ",")
  txt <- sprintf("Duplicated author key(s): {%s}.", bad)
  stop(txt, call. = FALSE)
}
authors <- do.call("c", apply(d, 1, function(x) {
  args <- list("given" = x[["First"]], "family" = x[["Last"]])
  if (!is.na(x["Middle"])) args$given <- c(args$given, x[["Middle"]])
  if (!is.na(x["Email"])) args$email <- x[["Email"]]
  if (!is.na(x["ORCID"])) args$comment <- c("ORCID" = x[["ORCID"]])
  do.call(utils::person, args)
}))
names(authors) <- d$`Author key`
if (any(is <- duplicated(authors))) {
  bad <- paste(sQuote(format(authors[is])), collapse = ",")
  txt <- sprintf("Duplicated author entry(s): {%s}", bad)
  stop(txt, call. = FALSE)
}

# define function that takes author keys and returns author entries
GetPerson <- function(x, authors) {
  checkmate::assertCharacter(x, any.missing = FALSE, unique = TRUE, .var.name = "GetPerson")
  if (any(is <- !(x %in% names(authors)))) {
    bad <- paste(sQuote(x[is]), collapse = ",")
    txt <- sprintf("Missing entry for the following author key(s): {%s}.", bad)
    stop(txt, call. = FALSE)
  }
  authors[x]
}

# define function to read and parse markdown text
ParseMarkdown <- function(filename, citation_keys = NULL) {
  checkmate::assertFileExists(filename, access = "r")
  checkmate::assertCharacter(citation_keys, any.missing = FALSE, unique = TRUE, null.ok = TRUE)
  label <- sQuote(basename(filename))
  md <- readLines(filename, encoding = "UTF-8")
  idxs <- which(grepl("^ *(#{1,6}) *([^\n]+?) *#* *(?:\n+|$)", md))
  keys <- trimws(gsub("#", "", md[idxs]))
  if (any(is <- duplicated(keys))) {
    bad <- paste(sQuote(keys[is]), collapse = ",")
    txt <- sprintf("In %s file: duplicated key(s): {%s}.", label, bad)
    stop(txt, call. = FALSE)
  }
  md[idxs] <- "<<citation-key>>"
  x <- paste(md, collapse = "\n")
  entries <- strsplit(unlist(strsplit(x, "<<citation-key>>"))[-1], "\n\n")
  names(entries) <- keys
  entries <- vapply(entries, function(x) {
    entry <- paste(
      trimws(x[nchar(x) > 0L]),
      collapse = "\n\n"
    )
    entry <- stringi::stri_escape_unicode(entry)
    tools::showNonASCII(entry)
    entry
  }, character(1))
  if (is.null(citation_keys)) {
    return(entries)
  }
  out <- rep(NA_character_, length(citation_keys))
  names(out) <- citation_keys
  idxs <- match(names(entries), names(out))
  if (anyNA(idxs)) {
    bad <- paste(
      sQuote(names(entries)[which(is.na(idxs))]),
      collapse = ","
    )
    txt <- sprintf("In %s file: citation entry not found for key(s): {%s}.", label, bad)
    stop(txt, call. = FALSE)
  }
  out[idxs] <- entries
  out
}

# get citation data
message("Read and parse citation data.")
cit <- ParseMarkdown("data-raw/citations.md")
citations <- lapply(seq_along(cit), function(i) {
  d <- utils::read.table(
    header = TRUE,
    sep = "|",
    quote = "",
    row.names = 1,
    colClasses = "character",
    strip.white = TRUE,
    allowEscapes = TRUE,
    encoding = "UTF-8",
    text = cit[[i]]
  )
  checkmate::assertDataFrame(
    d,
    types = "character",
    any.missing = FALSE,
    min.rows = 5,
    ncols = 1,
    .var.name = "citations.md"
  )
  d <- d[-(1:2), , drop = FALSE]
  checkmate::assert_names(
    rownames(d),
    must.include = c("bibtype", "title", "author"),
    .var.name = "citations.md"
  )
  args <- stats::setNames(
    split(d$Value, seq(nrow(d))),
    rownames(d)
  )
  args$author <- GetPerson(
    trimws(strsplit(args$author, ",")[[1]]),
    authors
  )
  args$key <- names(cit)[i]
  do.call(utils::bibentry, args)
})
names(citations) <- names(cit)
citations <- do.call(c, citations)
checkmate::assertClass(citations, "bibentry")
year <- vapply(citations, function(x) as.integer(x$year), integer(1))
text <- vapply(citations, function(x) format(x, style = "text"), character(1))
idxs <- order(year, text, decreasing = c(TRUE, FALSE), method = "radix")
citations <- citations[idxs]

# get abstract data
message("Read and parse abstract data.")
abstracts <- ParseMarkdown("data-raw/abstracts.md", names(citations))

# get annotation data
message("Read and parse annotion data.")
annotations <- ParseMarkdown("data-raw/annotations.md", names(citations))

# make dataset
message("Make dataset and save to disk.")
pubs <- data.frame(
  "key" = names(citations),
  "year" = vapply(citations, function(x) as.integer(x$year), integer(1)),
  "citation" = I(citations),
  "abstract" = abstracts,
  "annotation" = annotations,
  row.names = names(citations),
  stringsAsFactors = FALSE
)
pubs <- structure(pubs, class = append("pubs_data", class(pubs)))

# save dataset
checkmate::assertPathForOutput("data/pubs.rda", overwrite = TRUE)
save(pubs, file = "data/pubs.rda")

# auto compress dataset
tools::resaveRdaFiles(file.path(getwd(), "data"), compress = "auto")
