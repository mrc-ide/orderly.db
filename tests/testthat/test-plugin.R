test_that("basic plugin use works", {
  root <- test_prepare_example("minimal",
                               list(source = list(mtcars = mtcars_db)))
  env <- new.env()
  id <- orderly_run_quietly("minimal", root = root, envir = env)
  expect_type(id, "character")

  path <- file.path(root, "archive", "minimal", id)
  expect_setequal(dir(path), c("data.rds", "orderly.R"))
  expect_equal(readRDS(file.path(path, "data.rds")),
               mtcars_db)

  meta <- orderly2::orderly_metadata(id, root)
  meta_db <- meta$custom$orderly.db
  expect_equal(names(meta_db), "query")

  expect_length(meta_db$query, 1)
  expect_setequal(names(meta_db$query[[1]]),
                  c("database", "query", "rows", "cols"))
  expect_equal(meta_db$query[[1]]$database, "source")
  expect_equal(meta_db$query[[1]]$rows, nrow(mtcars_db))
  expect_equal(meta_db$query[[1]]$cols, as.list(names(mtcars_db)))
  expect_equal(meta_db$query[[1]]$query, "SELECT * FROM mtcars")
})


test_that("allow connection", {
  root <- test_prepare_example("connection",
                               list(source = list(mtcars = mtcars_db)))
  env <- new.env()
  id <- orderly_run_quietly("connection", root = root, envir = env)

  expect_type(id, "character")

  path <- file.path(root, "archive", "connection", id)
  expect_setequal(dir(path), c("data.rds", "orderly.R"))
  expect_equal(readRDS(file.path(path, "data.rds")),
               mtcars_db)

  ## Connection should now have been invalidated:
  expect_false(DBI::dbIsValid(env$con))

  meta <- orderly2::orderly_metadata(id, root)
  meta_db <- meta$custom$orderly.db
  expect_setequal(names(meta_db), c("query", "connection"))

  expect_length(meta_db$query, 1)
  expect_setequal(names(meta_db$query[[1]]),
                  c("database", "query", "rows", "cols"))
  expect_equal(meta_db$query[[1]]$database, "source")
  expect_equal(meta_db$query[[1]]$rows, nrow(mtcars_db))
  expect_equal(meta_db$query[[1]]$cols, as.list(names(mtcars_db)))
  expect_equal(meta_db$query[[1]]$query, "SELECT * FROM mtcars")

  expect_length(meta_db$connection, 1)
  expect_mapequal(meta_db$connection[[1]],
                  list(database = "source"))
})


test_that("allow connection without data", {
  root <- test_prepare_example("connectiononly",
                               list(source = list(mtcars = mtcars_db)))
  env <- new.env()
  id <- orderly_run_quietly("connectiononly", root = root, envir = env)

  expect_type(id, "character")

  path <- file.path(root, "archive", "connectiononly", id)
  expect_setequal(dir(path), c("data.rds", "orderly.R"))
  expect_equal(readRDS(file.path(path, "data.rds")),
               mtcars_db)

  meta <- orderly2::orderly_metadata(id, root)
  meta_db <- meta$custom$orderly.db
  expect_setequal(names(meta_db), "connection")

  expect_length(meta_db$connection, 1)
  expect_mapequal(meta_db$connection[[1]],
                  list(database = "source"))
})


test_that("validate plugin configuration", {
  expect_error(
    orderly_db_config(list(), "orderly_config.yml"),
    "must contain at least one database")
  expect_error(
    orderly_db_config(list(db = list()), "orderly_config.yml"),
    "Fields missing from orderly_config.yml:orderly.db:db: driver")
  expect_error(
    orderly_db_config(list(db = list(driver = NULL, args = NULL)),
                      "orderly_config.yml"),
    "'orderly_config.yml:orderly.db:db:driver' must be a scalar")
  expect_error(
    orderly_db_config(list(db = list(driver = "db", args = NULL)),
                      "orderly_config.yml"),
    paste("Expected fully qualified name for",
          "orderly_config.yml:orderly.db:db:driver"))
  expect_error(
    orderly_db_config(list(db = list(driver = "pkg::db", args = NULL)),
                      "orderly_config.yml"),
    "'orderly_config.yml:orderly.db:db:args' must be named")

  ## Success:
  expect_equal(
    orderly_db_config(
      list(db = list(driver = "pkg::db", args = list(a = 1))),
      "orderly_config.yml"),
    list(db = list(driver = c("pkg", "db"),
                   args = list(a = 1),
                   instances = list(default = list(a = 1)),
                   default_instance = "default")))
})


test_that("validate db for sqlite", {
  db <- tempfile(tmpdir = normalizePath(tempdir(), mustWork = TRUE))
  ## Tweak so that things behave sensibly on windows:
  db <- gsub("\\", "/", db, fixed = TRUE)

  expected <- list(db = list(driver = c("RSQLite", "SQLite"),
                             args = list(dbname = db),
                             instances = list(default = list(dbname = db)),
                             default_instance = "default"))

  expect_equal(
    orderly_db_config(
      list(db = list(driver = "RSQLite::SQLite",
                     args = list(dbname = db))),
      "orderly_config.yml"),
    expected)
  withr::with_dir(
    dirname(db),
    expect_equal(
      orderly_db_config(
        list(db = list(driver = "RSQLite::SQLite",
                       args = list(dbname = basename(db)))),
        "orderly_config.yml"),
      expected))
})


test_that("must be specific if more than one db present", {
  root <- test_prepare_example("minimal",
                               list(source = list(mtcars = mtcars_db),
                                    other = list(iris = iris)))
  env <- new.env()
  expect_error(
    orderly_run_quietly("minimal", root = root, envir = env),
    "'database' must be given if there is more than one database")

  path_code <- file.path(root, "src", "minimal", "orderly.R")
  code <- readLines(path_code)
  code <- sub("orderly.db::orderly_db_query(",
              'orderly.db::orderly_db_query(database = "source",',
              code, fixed = TRUE)
  writeLines(code, path_code)

  id <- orderly_run_quietly("minimal", root = root, envir = env)
  expect_equal(
    readRDS(file.path(root, "archive", "minimal", id, "data.rds")),
    mtcars_db)
})


test_that("sensible error if no databases configured", {
  root <- test_prepare_example("minimal", list())
  expect_error(
    orderly_run_quietly("minimal", root = root, envir = env),
    "orderly_config.yml:orderly.db must contain at least one database",
    fixed = TRUE)
})


test_that("can construct a view, then read from it", {
  root <- test_prepare_example("view", list(source = list(mtcars = mtcars_db)))

  env <- new.env()
  id <- orderly_run_quietly("view", root = root, envir = env)
  expect_type(id, "character")

  path <- file.path(root, "archive", "view", id)
  expect_setequal(dir(path), c("data.rds", "orderly.R"))
  expect_equal(readRDS(file.path(path, "data.rds")),
               mtcars_db[c("mpg", "cyl")])

  path_db <- file.path(root, "source.sqlite")
  withr::with_db_connection(
    list(con = DBI::dbConnect(RSQLite::SQLite(), path_db)),
    ## View not present here, it was only available to the client that
    ## created it.
    expect_equal(DBI::dbListTables(con), "mtcars"))
})


test_that("can read a query from a file", {
  root <- test_prepare_example("query",
                               list(source = list(mtcars = mtcars_db)))
  env <- new.env()
  id <- orderly_run_quietly("query", root = root, envir = env)

  meta <- orderly2::orderly_metadata(id, root)
  meta_db <- meta$custom$orderly.db
  expect_equal(meta_db$query[[1]]$query,
               readLines(file.path(root, "src", "query", "query.sql")))
})


test_that("can run a report with instances", {
  root <- test_prepare_example("instance",
                               list(main = list(mtcars = mtcars_db[1:10, ]),
                                    dev = list(mtcars = mtcars_db)))
  env <- new.env()
  id <- orderly_run_quietly("instance", root = root, envir = env)

  d1 <- readRDS(file.path(root, "archive", "instance", id, "data1.rds"))
  d2 <- readRDS(file.path(root, "archive", "instance", id, "data2.rds"))
  expect_equal(d1, mtcars_db[1:10, ])
  expect_equal(d2, mtcars_db)
})


test_that("can interpolate parameters into query", {
  root <- test_prepare_example("interpolate",
                               list(source = list(mtcars = mtcars_db)))
  env <- new.env()
  id <- orderly_run_quietly("interpolate", list(mpg_min = 30),
                            root = root, envir = env)
  d <- readRDS(file.path(root, "archive", "interpolate", id, "data.rds"))
  cmp <- mtcars_db[mtcars_db$mpg > 30, ]
  rownames(cmp) <- NULL
  expect_equal(d, cmp)

  meta <- orderly2::orderly_metadata(id, root)
  meta_db <- meta$custom$orderly.db
  expect_equal(
    meta_db$query[[1]]$query,
    sql_str_sub("SELECT * FROM mtcars WHERE mpg > 30"))
})
