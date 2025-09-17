# orderly.db

<!-- badges: start -->
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/mrc-ide/orderly.db/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mrc-ide/orderly.db/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/mrc-ide/orderly.db/graph/badge.svg)](https://app.codecov.io/gh/mrc-ide/orderly.db)
<!-- badges: end -->

This is an [`orderly`](https://mrc-ide.github.io/orderly/) plugin for database access.

See `[vignette("introduction", package = "orderly.db")]` for details, and for information for migrating from `orderly`.

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
