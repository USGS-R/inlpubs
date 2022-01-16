test_that("all publications are accounted for", {
  m <- MineText(pubs, c("title", "abstract", "annotation", "citation"))
  expect_true(all(rownames(pubs) %in% colnames(m)))
})

test_that("when all the text components are NA an empty table is returned", {
  d <- pubs[is.na(pubs$annotation), ]
  m <- MineText(d, "annotation")
  expect_true(nrow(m) == 0L)
})
