test_that("arrangeNestedPlots requires named plot list", {
  sce <- get_example_sce()
  p <- plotOverlay(sce = sce, foreground = "SOX10", background = "solid")

  expect_error(
    arrangeNestedPlots(
      sce = sce,
      plots = list(p),
      group_col = "sample",
      outer_col = "sample_type"
    ),
    "named list"
  )
})

test_that("arrangeNestedPlots validates grouping columns", {
  sce <- get_example_sce()
  p <- plotOverlay(sce = sce, foreground = "SOX10", background = "solid")
  plots <- list(sample1 = p)

  expect_error(
    arrangeNestedPlots(
      sce = sce,
      plots = plots,
      group_col = "missing_group",
      outer_col = "sample_type"
    ),
    "`group_col` must be one of colnames\\(colData\\(sce\\)\\)"
  )

  expect_error(
    arrangeNestedPlots(
      sce = sce,
      plots = plots,
      group_col = "sample",
      outer_col = "missing_outer"
    ),
    "`outer_col` must be one of colnames\\(colData\\(sce\\)\\)"
  )
})

test_that("arrangeNestedPlots returns patchwork", {
  sce <- get_example_sce()
  groups <- unique(as.character(SummarizedExperiment::colData(sce)$sample))
  plots <- stats::setNames(vector("list", length(groups)), groups)

  for (g in groups) {
    plots[[g]] <- plotOverlay(
      sce,
      foreground = "SOX10",
      background = "solid",
      fg_subset_cells = as.character(SummarizedExperiment::colData(sce)$sample) == g,
      title = g
    )
  }

  out <- arrangeNestedPlots(
    sce = sce,
    plots = plots,
    group_col = "sample",
    outer_col = "sample_type"
  )

  expect_s3_class(out, "patchwork")
})

test_that("plotGeneOverlay returns named list of ggplot", {
  sce <- get_example_sce()

  expect_silent(
    out <- plotGeneOverlay(
      sce,
      genes = c("SOX10", "S100B"),
      reduced_dim = "TSNE",
      background = "cluster"
    )
  )

  expect_type(out, "list")
  expect_setequal(names(out), c("SOX10", "S100B"))
  expect_s3_class(out[["SOX10"]], "ggplot")
  expect_s3_class(out[["S100B"]], "ggplot")
})

test_that("plotGeneOverlay rejects conflicting foreground in dots", {
  sce <- get_example_sce()

  expect_error(
    plotGeneOverlay(
      sce = sce,
      genes = c("SOX10", "S100B"),
      foreground = "cluster"
    ),
    "`foreground` cannot be supplied through `...` in `plotGeneOverlay()`; use `genes` instead.",
    fixed = TRUE
  )
})

test_that("plotGeneOverlay accepts allowed plotting arguments in dots", {
  sce <- get_example_sce()

  expect_silent(
    out <- plotGeneOverlay(
      sce = sce,
      genes = c("SOX10", "S100B"),
      background = "cluster",
      reduced_dim = "TSNE",
      fg_order = "ascending",
      fg_palette = "gray_red"
    )
  )

  expect_type(out, "list")
  expect_setequal(names(out), c("SOX10", "S100B"))
  expect_s3_class(out[["SOX10"]], "ggplot")
  expect_s3_class(out[["S100B"]], "ggplot")
})

test_that("plotGeneOverlay validates inputs and skips missing genes", {
  sce <- get_example_sce()

  expect_error(
    plotGeneOverlay(data.frame(), genes = "SOX10"),
    "`sce` must be a SingleCellExperiment object"
  )
  expect_error(
    plotGeneOverlay(sce, genes = 1),
    "`genes` must be a non-empty character vector without NA values"
  )
  expect_error(
    plotGeneOverlay(sce, genes = character(0)),
    "`genes` must be a non-empty character vector without NA values"
  )
  expect_error(
    plotGeneOverlay(sce, genes = c("SOX10", NA_character_)),
    "`genes` must be a non-empty character vector without NA values"
  )

  expect_warning(
    out <- plotGeneOverlay(
      sce,
      genes = c("S100B", "MISSING_GENE", "SOX10"),
      reduced_dim = "TSNE",
      background = "solid"
    ),
    "MISSING_GENE"
  )
  expect_identical(names(out), c("S100B", "SOX10"))
  expect_s3_class(out[["S100B"]], "ggplot")
  expect_s3_class(out[["SOX10"]], "ggplot")

  expect_error(
    plotGeneOverlay(sce, genes = c("MISSING_ONE", "MISSING_TWO")),
    "None of the requested `genes` were found in rownames\\(sce\\)"
  )
})
