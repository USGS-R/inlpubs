## ----"setup", include=FALSE---------------------------------------------------
library(inlpubs)
svg_orcid <- "<svg style='height:1em;position:relative;margin-left:.25em;vertical-align:middle;' viewBox='0 0 512 512' aria-describedby='orcid' role='img'><desc id='orcid'>ORCiD</desc><path fill='#A6CE39' d='M294.75 188.19h-45.92V342h47.47c67.62 0 83.12-51.34 83.12-76.91 0-41.64-26.54-76.9-84.67-76.9zM256 8C119 8 8 119 8 256s111 248 248 248 248-111 248-248S393 8 256 8zm-80.79 360.76h-29.84v-207.5h29.84zm-14.92-231.14a19.57 19.57 0 1 1 19.57-19.57 19.64 19.64 0 0 1-19.57 19.57zM300 369h-81V161.26h80.6c76.73 0 110.44 54.83 110.44 103.85C410 318.39 368.38 369 300 369z'></path></svg>"
svg_email <- "<svg style='height:1em;position:relative;margin-left:.25em;vertical-align:middle;' viewBox='0 0 512 512' aria-describedby='email' role='img'><desc id='email'>Email</desc><path fill='#4682B4' d='M502.3 190.8c3.9-3.1 9.7-.2 9.7 4.7V400c0 26.5-21.5 48-48 48H48c-26.5 0-48-21.5-48-48V195.6c0-5 5.7-7.8 9.7-4.7 22.4 17.4 52.1 39.5 154.1 113.6 21.1 15.4 56.7 47.8 92.2 47.6 35.7.3 72-32.8 92.3-47.6 102-74.1 131.6-96.3 154-113.7zM256 320c23.2.4 56.6-29.2 73.4-41.4 132.7-96.3 142.8-104.7 173.4-128.7 5.8-4.5 9.2-11.5 9.2-18.9v-19c0-26.5-21.5-48-48-48H48C21.5 64 0 85.5 0 112v19c0 7.4 3.4 14.3 9.2 18.9 30.6 23.9 40.7 32.4 173.4 128.7 16.8 12.2 50.2 41.8 73.4 41.4z'/></svg>"
cit <- inlpubs::pubs$citation
dt_opt <- list(
  "dom" = "Blfrtip",
  "pagingType" = "full",
  "lengthMenu" = list(
    c(10L, 25L, 50L, -1L),
    c("10", "25", "50", "all")
  ),
  "buttons" = list(
    list(
      "extend" = "copyHtml5",
      "titleAttr" = "Copy visible data (tab deliminated) to clipboard",
      "title" = NULL,
      "exportOptions" = list(
        "columns" =  ":visible",
        "rows" = ":visible"
      )
    ),
    list(
      "extend" = "csvHtml5",
      "titleAttr" = "Save all rows in a CSV (comma deliminated) file format",
      "filename" = "inlpubs-text-mining"
    )
  )
)

## ----"bib_stats", echo=FALSE, results="asis"----------------------------------
institutions <- vapply(cit, function(x) {
  desc <- attr(unclass(x)[[1]], "bibtype")
  if (is.null(x$institution)) character(1) else x$institution
}, character(1))
is <- institutions %in% "U.S. Geological Survey"
percent_usgs <- format(round(sum(is) / length(is) * 100, 1), nsmall = 1)
years <- table(pubs$year)
mean_years <- format(round(mean(years), 1), nsmall = 1)
sd_years <- format(round(sd(years), 1), nsmall = 1)

## ----"ref_typ_tbl", echo=FALSE, results="asis"--------------------------------
m <- do.call("rbind", lapply(cit, function(x) {
  desc <- attr(unclass(x)[[1]], "bibtype")
  type <- if (is.null(x$type)) character(1) else x$type
  institution <- if (is.null(x$institution)) "" else x$institution
  if (desc == "TechReport") desc <- institution
  c(desc, type)
}))
d <- data.frame(m[!duplicated(m), , drop = FALSE], stringsAsFactors = FALSE)
d <- d[order(d[, 1], d[, 2]), ]
is <- d[, 2] == ""
d[is, 2] <- d[is, 1]
d[is, 1] <- NA
d[, 3] <- as.integer(table(m)[d[, 2]])
d <- d[order(d[, 1], d[, 3], decreasing = TRUE, na.last = FALSE), ]
ran <- vapply(seq_len(nrow(d)), function(i) {
  d[i, is.na(d[i, 1]) + 1L]
  is <- m[, 1] == d[i, 2] | m[, 2] == d[i, 2]
  ran <- range(pubs$year[is])
  if (identical(ran[1], ran[2])) format(ran[1]) else paste(ran, collapse = "--")
}, character(1))
d[d[, 2] == "Article", 2] <- "Article from a journal"
d[d[, 2] == "InProceedings", 2] <- "Article in a conference proceedings"
d[d[, 2] == "Proceedings", 2] <- "Proceedings of a conference"
d[d[, 2] == "MastersThesis", 2] <- "Master's thesis"
d[, 2] <- sprintf(
  "%s <span style='color:#808080;font-size:small;'>(%s)</span>",
  d[, 2], ran
)
d[, 4] <- d[, 3] / sum(d[, 3]) * 100
d[, 4] <- formatC(round(d[, 4], digits = 1), format = "f", digits = 1)
nm <- as.character(na.omit(unique(d[, 1])))
grp <- lapply(nm, function(x) range(which(d[, 1] %in% x)))
names(grp) <- nm
d <- rbind(d, c("", "Total", sum(d[, 3]), ""))
rownames(d) <- NULL
d[, 1] <- NULL
x <- knitr::kable(d,
  format = "html",
  col.names = c("Type of publication", "Count", "Percent"),
  align = c("l", "r", "r"), escape = FALSE
)
x <- kableExtra::kable_styling(x, c("row-border", "condensed"),
  full_width = FALSE, position = "left"
)
for (i in seq_along(grp)) {
  x <- kableExtra::pack_rows(x, names(grp)[i], grp[[i]][1], grp[[i]][2])
}
kableExtra::row_spec(x, row = nrow(d), italic = TRUE)

## ----"graph_prod", echo=FALSE, results="asis", fig.height=3, fig.cap=sprintf("<b>Figure 1.</b> &nbsp; Distribution of INL Project Office publications (%s--%s). USGS and non-USGS publication types are distinguished by color.", min(pubs$year), max(pubs$year))----

tbl <- table(pubs$year)
d1 <- data.frame(
  x = as.Date(sprintf("%s-01-01", names(tbl))), y1 = as.integer(tbl),
  y2 = NA_integer_, stringsAsFactors = FALSE
)
is <- vapply(pubs$citation, function(x) {
  !is.null(x$institution) && x$institution %in% "U.S. Geological Survey"
}, logical(1))
tbl <- table(pubs$year[is])
d2 <- data.frame(
  x = as.Date(sprintf("%s-01-01", names(tbl))), y2 = as.integer(tbl),
  stringsAsFactors = FALSE
)
d1$y2[match(d2$x, d1$x)] <- d2$y2
ylab <- "Number of publications per year"
cols <- c("Non-USGS" = "#B47846", "USGS" = "#4682B4")
inlmisc::PlotGraph(d1,
  ylab = ylab, col = cols, fill = "tozeroy", fillcolor = cols,
  lty = 1, center.date.labels = TRUE, seq.date.by = "year"
)
graphics::legend("topright", rev(names(cols)),
  fill = rev(cols), border = NA, inset = c(0.02, 0.05),
  cex = 0.7, box.lty = 1, box.lwd = 0.5, xpd = NA, bg = "#FFFFFFE7"
)

## ----"tm_data", echo=FALSE, results="asis"------------------------------------
m <- MineText(pubs, lowfreq = 3L)
tm_dat <- data.frame("term" = rownames(m), "count" = rowSums(m), "support" = rowSums(m > 0))
top_word <- stringi::stri_trans_totitle(tm_dat[1, "term"])
top_count <- format(tm_dat[1, "count"], big.mark = ",")

## ----"tm_tbl", echo=FALSE, results="asis"-------------------------------------
tbl <- DT::datatable(tm_dat,
  options = dt_opt,
  extensions = "Buttons",
  class = "hover row-border compact",
  colnames = c("Word", "Frequency count", "No. of publications"),
  rownames = FALSE,
  escape = FALSE,
  width = 600,
  elementId = "htmlwidget-tm-tbl"
)
tbl <- DT::formatCurrency(tbl, "count", currency = "", digits = 0)
tbl <- DT::formatCurrency(tbl, "support", currency = "", digits = 0)
tbl

