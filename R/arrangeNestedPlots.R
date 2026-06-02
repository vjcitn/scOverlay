#' Arrange plots into a nested patchwork layout
#'
#' Internal helper used by \code{\link{plotOverlayPerNestedGroup}} to arrange a
#' named list of plots in rows defined by an outer grouping variable and columns
#' defined by an inner grouping variable. Each row contains the plots belonging
#' to one outer group, ordered according to \code{group_order} when provided, and
#' padded with spacer plots so all rows have the same number of columns.
#'
#' @param sce A \linkS4class{SingleCellExperiment} object.
#' @param plots A named list of \pkg{ggplot2} or \pkg{patchwork} plots. Names
#' should correspond to inner group values, or preferably to nested keys of the
#' form \code{outer__group}.
#' @param group_col A single character value with the name of the
#' \code{colData(sce)} column defining the inner groups.
#' @param outer_col A single character value with the name of the
#' \code{colData(sce)} column defining the outer groups.
#' @param group_order Optional character vector specifying the order of the
#' inner groups. Defaults to the order observed in \code{group_col}.
#' @param outer_order Optional character vector specifying the order of the
#' outer groups. Defaults to the order observed in \code{outer_col}.
#' @param spacer Optional plot used to pad rows with fewer panels. Defaults to
#' an empty \pkg{ggplot2} plot.
#'
#' @return A \pkg{patchwork} object with one row per outer group and one or more
#' plots per row, padded on the right with spacers when needed.
#'
#' @keywords internal
  
arrangeNestedPlots <- function(
        sce,
        plots,
        group_col,
        outer_col,
        group_order = NULL,
        outer_order = NULL,
        spacer = NULL
) {
    .validate_sce(sce)
    .validate_coldata_column(sce, group_col, "group_col")
    .validate_coldata_column(sce, outer_col, "outer_col")

    if (!is.list(plots)) {
        stop("`plots` must be a named list of plots.", call. = FALSE)
    }

    if (is.null(names(plots)) || any(is.na(names(plots))) ||
            any(names(plots) == "")) {
        stop("`plots` must be a named list.", call. = FALSE)
    }

    group_vals <- as.character(SingleCellExperiment::colData(sce)[[group_col]])
    outer_vals <- as.character(SingleCellExperiment::colData(sce)[[outer_col]])

    valid <- !is.na(group_vals) & !is.na(outer_vals)
    group_vals <- group_vals[valid]
    outer_vals <- outer_vals[valid]

    if (length(group_vals) == 0L) {
        stop(
            "`group_col` and `outer_col` do not define any valid nested groups.",
            call. = FALSE
        )
    }

    if (!is.null(outer_order)) {
        outers <- as.character(outer_order)
    } else {
        outers <- unique(outer_vals)
    }
    outers <- outers[outers %in% outer_vals]

    if (!is.null(group_order)) {
        groups <- as.character(group_order)
    } else {
        groups <- unique(group_vals)
    }

    if (length(outers) == 0L) {
        stop("No outer groups are available to arrange.", call. = FALSE)
    }

    if (is.null(spacer)) {
        spacer <- ggplot2::ggplot() + ggplot2::theme_void()
    }

    groups_by_outer <- lapply(outers, function(outer) {
        outer_groups <- unique(group_vals[outer_vals == outer])
        outer_groups <- groups[groups %in% outer_groups]
        return(outer_groups)
    })
    names(groups_by_outer) <- outers

    max_groups <- max(vapply(groups_by_outer, length, integer(1)))

    get_plot <- function(outer, group) {
        nested_key <- paste(outer, group, sep = "__")

        if (nested_key %in% names(plots)) {
            return(plots[[nested_key]])
        }

        if (group %in% names(plots)) {
            return(plots[[group]])
        }

        return(spacer)
    }

    all_plots <- list()

    for (outer in outers) {
        row_groups <- groups_by_outer[[outer]]

        row_plots <- lapply(row_groups, function(group) {
            return(get_plot(outer, group))
        })

        if (length(row_plots) < max_groups) {
            row_plots <- c(
                row_plots,
                rep(list(spacer), max_groups - length(row_plots))
            )
        }

        all_plots <- c(all_plots, row_plots)
    }

    arranged <- patchwork::wrap_plots(all_plots, ncol = max_groups)

    return(arranged)
}
