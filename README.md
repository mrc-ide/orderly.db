# orderly.db

<!-- badges: start -->
[![Project Status: Concept – Minimal or no implementation has been done yet, or the repository is only intended to be a limited example, demo, or proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![R-CMD-check](https://github.com/mrc-ide/orderly.db/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mrc-ide/orderly.db/actions/workflows/R-CMD-check.yaml)
[![codecov.io](https://codecov.io/github/mrc-ide/orderly.db/coverage.svg?branch=main)](https://codecov.io/github/mrc-ide/orderly.db?branch=main)
<!-- badges: end -->

This is an [`orderly2`](https://mrc-ide.github.io/orderly2) plugin for database access. We expect this package to be part of the group of packages that becomes the next version of [`orderly`](https://vaccineimpact.org/orderly), though this particular package may take a while to end up on CRAN.

See `[vignette("introduction", package = "orderly.db")]` for details, and for information for migrating from `orderly`.

**WARNING: We may update the metadata schema and API significantly, and we are not yet at a version that we anticipate providing an upgrade path to the final form, please use at even more of your own risk than usual.**

## Installation

Please install from our [r-universe](https://mrc-ide.r-universe.dev/):

```r
install.packages(
  "orderly.db",
  repos = c("https://mrc-ide.r-universe.dev", "https://cloud.r-project.org"))
```

If you prefer, you can install from GitHub with `remotes`:

```r
remotes::install_github("mrc-ide/orderly.db")
```

## License

MIT © Imperial College of Science, Technology and Medicine
