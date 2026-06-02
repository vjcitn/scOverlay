<!-- badges: start -->
<!-- [![R-CMD-check](https://github.com/bernatgel/scOverlay/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bernatgel/scOverlay/actions/workflows/R-CMD-check.yaml)
[![Bioconductor status](https://bioconductor.org/shields/build/release/bioc/scOverlay.svg)](https://bioconductor.org/packages/scOverlay) -->
[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic--2.0-blue.svg)](https://opensource.org/license/artistic-2-0)
<!-- badges: end -->

# scOverlay: Multilayer plots for single-cell data

<p align="center">
  <img width="6000" height="1500" alt="scOverlay example plot" src="https://github.com/user-attachments/assets/8403e754-a709-4e9d-80ad-ced2aa681fbb"/>
</p>


## Description

`scOverlay` creates layered visualizations of single-cell data stored in
`SingleCellExperiment` objects. It is designed to show one layer of information
as context, such as clusters, samples or gene expression, while overlaying a
second layer of information on top of it.

The package is especially useful to highlight subsets of cells, gene expression,
metadata annotations or quality-control scores while preserving the global
structure of a t-SNE, UMAP or other reduced-dimension representation.

## Installation

`scOverlay` is a Bioconductor package (in process). Once available from Bioconductor, it
can be installed with:

```r
if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}

BiocManager::install("scOverlay")
```

The development version can be installed from GitHub with:

```r
if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
}

remotes::install_github("bernatgel/scOverlay")
```

## Getting started

```r
library(scOverlay)

data("sce_overlay_example")

plotOverlay(
    sce = sce_overlay_example,
    foreground = "CDH19",
    background = "cluster",
    reduced_dim = "TSNE"
)
```

`background` and `foreground` can be a gene, a cell annotation
from `colData(sce)`, `"solid"` or `"none"`.

```r
plotOverlay(
    sce = sce_overlay_example,
    foreground = "scDblFinder.score",
    background = "cluster",
    fg_subset_cells = quote(cluster == "1"),
    fg_palette = "red",
    reduced_dim = "TSNE"
)
```

Grouped plots can be created with `plotOverlayPerGroup()`:

```r
plotOverlayPerGroup(
    sce = sce_overlay_example,
    group_col = "sample_type",
    foreground = "PRRX1",
    background = "cluster",
    reduced_dim = "TSNE",
    fg_limits = "shared",
    shared_legend = TRUE
)
```

## Documentation

The package vignette provides a more complete introduction to the layered
plotting model, palettes, foreground subsetting, grouped plots, rasterization
and saving figures.

- Bioconductor landing page: <https://bioconductor.org/packages/scOverlay>
- Vignette: <https://bioconductor.org/packages/release/bioc/vignettes/scOverlay/inst/doc/scOverlay.html>
- Development repository: <https://github.com/bernatgel/scOverlay> 

Bioconductor links will become active once the package is available from Bioconductor.

## Main features

- Layered visualization of single-cell embeddings.
- Support for gene expression and cell metadata in both background and foreground layers.
- Foreground subsetting without removing the full embedding context.
- Grouped and nested grouped plots.
- Shared scales and shared legends for grouped visualizations.
- Named categorical palettes for consistent colours across panels.
- Optional rasterization of dense point layers.
- Standard `ggplot2` output objects that can be further customized.

## Citation

If you use `scOverlay` in published work, please cite it with:

```r
citation("scOverlay")
```

A formal citation will be added once available.

## License

`scOverlay` is distributed under the Artistic-2.0 license.

## Bug reports and feature requests

Please use the GitHub issue tracker to report bugs or request features:

<https://github.com/bernatgel/scOverlay/issues>
