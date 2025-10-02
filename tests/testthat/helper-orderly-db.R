options(outpack.schema_validate =
          requireNamespace("jsonvalidate", quietly = TRUE) &&
          packageVersion("jsonvalidate") >= "1.4.0")

mtcars_db <- cbind(name = rownames(mtcars), mtcars)
rownames(mtcars_db) <- NULL

test_prepare_example <- function(examples, data) {
  tmp <- tempfile()
  withr::defer_parent(unlink(tmp, recursive = TRUE))
  suppressMessages(orderly::orderly_init(tmp))

  nms <- names(data)
  dbs <- set_names(sprintf("%s.sqlite", nms), nms)

  if (identical(examples, "instance")) {
    cfg_plugins <- list(
      db = list(
        driver = "RSQLite::SQLite",
        args = NULL,
        instances = lapply(dbs, function(x) list(dbname = x))))
  } else {
    cfg_plugins <- lapply(dbs, function(x) {
      list(driver = "RSQLite::SQLite", args = list(dbname = x))
    })
  }

  cfg <- list(minimum_orderly_version = "1.99.90",
              plugins = list(orderly.db = cfg_plugins))
  writeLines(jsonlite::toJSON(cfg, auto_unbox = TRUE, null = "null"),
             file.path(tmp, "orderly_config.json"))

  for (nm_db in names(data)) {
    con <- DBI::dbConnect(RSQLite::SQLite(),
                          dbname = file.path(tmp, dbs[[nm_db]]))
    d <- data[[nm_db]]
    for (nm_data in names(data[[nm_db]])) {
      DBI::dbWriteTable(con, nm_data, data[[nm_db]][[nm_data]])
    }
    DBI::dbDisconnect(con)
  }

  fs::dir_create(file.path(tmp, "src"))
  for (i in examples) {
    fs::dir_copy(file.path("examples", i), file.path(tmp, "src"))
  }

  tmp
}


clear_local_connections <- function() {
  rm(list = names(local), envir = local)
}


orderly_run_quietly <- function(..., echo = FALSE) {
  suppressMessages(orderly::orderly_run(..., echo = echo))
}
