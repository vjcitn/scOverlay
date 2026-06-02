#' scOverlay: Dual-scale overlay plots for single-cell embeddings
#'
#' scOverlay provides functions to overlay gene expression or metadata values
#' on top of contextual embeddings (clusters, samples, cell types) with
#' independent colour scales.
#'
#' @name scOverlay
#' @keywords internal
#'
#' @importFrom SingleCellExperiment colData
#' @importFrom SummarizedExperiment rownames
#' @importFrom ggplot2 ggplot scale_colour_gradientn scale_colour_manual
#' @importFrom ggplot2 theme_classic theme_void labs annotate aes
#' @importFrom rlang .data
#' @importFrom stats na.omit

NULL
