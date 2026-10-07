# scOverlay package review

**Review date:** 2026-10-07
**Scope:** Distinctiveness in the Bioconductor ecosystem, implementation of
Bioconductor principles, and correctness and realism of package examples.

## Overall assessment

`scOverlay` is a focused, useful visualization package with a well-defined
workflow: show one variable as context and another on top, optionally restricting
the foreground while retaining the full embedding. Its integration with
`SingleCellExperiment`, ordinary `ggplot2`/patchwork output, and support for
grouped comparisons make it a plausible Bioconductor contribution.

The largest immediate correctness issue is that all three getting-started
examples in the README use the small synthetic dataset but refer to features or
metadata that dataset does not contain. These examples will error or select no
cells. The vignette is substantially more realistic because it uses the bundled
MPNST data subset, but its derivation is not reproducible from the checked-in
data-preparation script, and one displayed plot title appears inconsistent with
its sample filter. A nested-group edge case also merits attention.

## Distinctiveness

The package's distinctiveness is its *combination* of capabilities rather than a
new plotting primitive: independent colour scales for background and
foreground, foreground-only filtering that preserves global context, and
multi-panel group/nested-group helpers with shared scales and legends. The
description and core interface state this clearly
(`/home/runner/work/scOverlay/scOverlay/DESCRIPTION:9-15`,
`/home/runner/work/scOverlay/scOverlay/R/plotOverlay.R:24-39`).

This is a credible niche alongside broader single-cell visualization packages
such as `scater` and `dittoSeq`, and expression-density tools such as `Nebulosa`.
The implementation uses established `ggplot2`, `ggnewscale`, patchwork, and
rasterization facilities rather than proposing a distinct statistical
visualization method. Position the package as a convenient, reproducible
two-layer comparison workflow that complements those tools; avoid broad claims
that layered views or independent scales are unprecedented. A short comparison
table in the README or vignette could explain when this workflow is preferable
to a standard reduced-dimension plot, split plot, or density visualization.

## Bioconductor principles and implementation

### Strengths

- The API accepts `SingleCellExperiment` and retrieves embeddings, assays, and
  cell annotations through Bioconductor accessors. It returns standard
  `ggplot2`/patchwork objects and does not introduce a parallel data container
  (`/home/runner/work/scOverlay/scOverlay/R/plotOverlay.R:41-45`,
  `/home/runner/work/scOverlay/scOverlay/R/plotOverlay.R:183-189`).
- Package metadata includes a clear purpose, license, dependencies, URLs, and
  relevant `biocViews`; the namespace is generated and uses explicit imports
  (`/home/runner/work/scOverlay/scOverlay/DESCRIPTION:9-42`,
  `/home/runner/work/scOverlay/scOverlay/NAMESPACE:1-21`).
- Public functions document inputs and outputs, validate common invalid
  arguments, and keep assay choice and variable type explicit. Tests cover
  subsetting, missing values, scale consistency, palettes, and grouped layouts
  (`/home/runner/work/scOverlay/scOverlay/R/plotOverlay.R:266-338`,
  `/home/runner/work/scOverlay/scOverlay/tests/testthat/test-plotOverlay-core.R:74-202`,
  `/home/runner/work/scOverlay/scOverlay/tests/testthat/test-grouped-functions.R:191-314`).

No custom S4 class is needed for this plotting-focused API; using established
Bioconductor containers and accessors is the more appropriate design. The README
indicates that Bioconductor availability is still in process, and that a formal
citation is pending. Complete and verify release-facing citation information
when the package is submitted or released
(`/home/runner/work/scOverlay/scOverlay/README.md:25-36`,
`/home/runner/work/scOverlay/scOverlay/README.md:114-122`).

### Correctness concern: nested grouping

`plotOverlayPerNestedGroup()` creates one foreground subset per inner-group
label, without including the outer-group label in that subset
(`/home/runner/work/scOverlay/scOverlay/R/plotOverlayPerNestedGroup.R:363-398`).
`arrangeNestedPlots()` can then place a plot under each outer group that shares
that inner label (`/home/runner/work/scOverlay/scOverlay/R/arrangeNestedPlots.R:86-106`).
If an inner label occurs under more than one outer label, the same combined
foreground is therefore repeated in multiple rows, rather than showing the
outer-specific cells. The documentation describes the common nested case and
notes the association assumption (`/home/runner/work/scOverlay/scOverlay/R/plotOverlayPerNestedGroup.R:47-54`),
but does not require uniqueness. Consider either validating that each inner
group has one outer parent or defining panels by the inner/outer pair.

## Examples and vignette

### High priority: README examples do not match their dataset

The README loads `sce_overlay_example` and then requests `CDH19`,
`scDblFinder.score`, and `PRRX1`
(`/home/runner/work/scOverlay/scOverlay/README.md:53-89`). The checked-in
generator defines only `SOX10`, `S100B`, and `Gene1`–`Gene48`, and its metadata
columns are `sample`, `sample_type`, `cluster`, `celltype.main`, and
`tumor_stage` (`/home/runner/work/scOverlay/scOverlay/data-raw/make_sce_overlay_example.R:7-8`,
`/home/runner/work/scOverlay/scOverlay/data-raw/make_sce_overlay_example.R:36-43`).
Consequently, the first and third README calls cannot resolve the requested
features, and the second cannot resolve `scDblFinder.score`. Its filter
`cluster == "1"` also matches none of the fixture's `"C1"`–`"C5"` cluster labels.
Replace those examples with variables present in this fixture, or load and
clearly identify the MPNST fixture used by the vignette. Treat this as a
release-blocking documentation/reproducibility defect.

### Vignette realism and reproducibility

The vignette uses a reduced subset of an actual MPNST progression dataset,
identifies the EGA accession, and describes the subset's purpose and contents.
Its examples cover plausible marker expression, cell metadata, doublet scores,
sample comparisons, and plot export
(`/home/runner/work/scOverlay/scOverlay/vignettes/scOverlay.Rmd:68-80`,
`/home/runner/work/scOverlay/scOverlay/vignettes/scOverlay.Rmd:135-164`).
This makes the scientific context more realistic than the separate toy fixture.

However, the only checked-in preparation script constructs
`sce_overlay_example`; it creates synthetic counts and assigns PCA-plus-noise
coordinates to dimensions named `"TSNE"` and `"UMAP"`
(`/home/runner/work/scOverlay/scOverlay/data-raw/make_sce_overlay_example.R:18-27`,
`/home/runner/work/scOverlay/scOverlay/data-raw/make_sce_overlay_example.R:45-52`).
The MPNST object has a source citation in its data documentation, but no
corresponding derivation script is present
(`/home/runner/work/scOverlay/scOverlay/R/data.R:22-42`). Keep the toy
coordinates clearly identified as illustrative rather than scientific
embeddings; document the MPNST subset-generation steps and any applicable data
access constraints so users can understand how the distributed object was
derived.

The vignette is well ordered, progressing from a quick start through layer
semantics, grouped plots, palettes, rasterization, and saving. Improve the
polish and trustworthiness of the examples by:

- Checking that the quick-start title `"CDH19 in 50PNF"` agrees with the
  selected sample `"38ANF1"`
  (`/home/runner/work/scOverlay/scOverlay/vignettes/scOverlay.Rmd:116-129`).
- Aligning the quick-start prose about changing background point size with the
  call, which does not set `bg_point_size`
  (`/home/runner/work/scOverlay/scOverlay/vignettes/scOverlay.Rmd:84-93`).
- Showing at least one explicit alternative assay where appropriate, and
  explaining the biological or analytical interpretation of representative
  plots, rather than only demonstrating syntax.
- Rendering or otherwise checking the README and vignette examples against the
  packaged objects as part of release preparation.

## Prioritized recommendations

1. **Fix README example/data mismatches** and execute each getting-started
   example against its stated dataset.
2. **Resolve the nested-label edge case** by enforcing a true nesting
   relationship or using outer/inner-specific panels.
3. **Improve example provenance**: distinguish synthetic coordinate fixtures
   from real embeddings and document the MPNST subset derivation.
4. **Clarify package positioning** as a complementary two-layer visualization
   workflow, with a concise comparison to adjacent Bioconductor visualization
   tools.
5. **Polish the vignette examples**: reconcile the sample/title and point-size
   description, and add brief interpretation and assay-selection examples.

## Review boundary

This is a source and documentation review, not an exhaustive comparison against
every Bioconductor visualization package or a rendered `R CMD check`. The
repository environment used for this review did not provide an `R` executable,
so the examples were assessed against the checked-in source, fixtures, and
tests rather than executed.
