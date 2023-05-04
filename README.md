# orderly3.db

<!-- badges: start -->
[![Project Status: Concept – Minimal or no implementation has been done yet, or the repository is only intended to be a limited example, demo, or proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![R-CMD-check](https://github.com/vimc/orderly3.db/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/vimc/orderly3.db/actions/workflows/R-CMD-check.yaml)
[![codecov.io](https://codecov.io/github/vimc/orderly3.db/coverage.svg?branch=main)](https://codecov.io/github/vimc/orderly3.db?branch=main)
<!-- badges: end -->

This is an [`orderly3`](https://mrc-ide.github.io/orderly3) plugin for database access. We expect this package to be part of the group of packages that becomes the next version of [`orderly`](https://vaccineimpact.org/orderly), though this particular package may take a while to end up on CRAN.

See `[vignette("introduction", package = "orderly3.db")]` for details, and for information for migrating from `orderly`.

**WARNING: We may update the metadata schema and API significantly until the package name changes from `orderly3.db` to `orderly.db`, and we are not yet at a version that we anticipate providing an upgrade path to the final form, please use at even more of your own risk than usual.**

## Installation

To install `orderly3.db`:

```r
remotes::install_github("vimc/orderly3.db", upgrade = FALSE)
```

## License

MIT © Imperial College of Science, Technology and Medicine
