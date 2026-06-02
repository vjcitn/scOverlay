get_example_sce <- function() {
  data_env <- new.env(parent = emptyenv())
  data("sce_overlay_example", package = "scOverlay", envir = data_env)
  return(data_env$sce_overlay_example)
}
