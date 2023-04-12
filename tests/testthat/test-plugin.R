test_that("basic plugin use works", {
  root <- test_prepare_example("minimal",
                               list(source = list(mtcars = mtcars_db)))
  env <- new.env()
  id <- orderly3::orderly_run("minimal", root = root, envir = env)
  expect_type(id, "character")

  path <- file.path(root, "archive", "minimal", id)
  expect_setequal(dir(path), c("data.rds", "orderly.R"))
  expect_equal(readRDS(file.path(path, "data.rds")),
               mtcars_db)

  meta <- outpack::outpack_root_open(root)$metadata(id, TRUE)
  meta_db <- meta$custom$orderly$plugins$orderly3.db
  expect_equal(names(meta_db), "query")

  expect_length(meta_db$query, 1)
  expect_setequal(names(meta_db$query[[1]]),
                  c("as", "database", "query", "rows", "cols"))
  expect_equal(meta_db$query[[1]]$as, "dat1")
  expect_equal(meta_db$query[[1]]$database, "source")
  expect_equal(meta_db$query[[1]]$rows, nrow(mtcars_db))
  expect_equal(meta_db$query[[1]]$cols, as.list(names(mtcars_db)))
  expect_equal(meta_db$query[[1]]$query, "SELECT * FROM mtcars")
})


test_that("allow connection", {
  root <- test_prepare_example("connection",
                               list(source = list(mtcars = mtcars_db)))
  env <- new.env()
  id <- orderly3::orderly_run("connection", root = root, envir = env)

  expect_type(id, "character")

  path <- file.path(root, "archive", "connection", id)
  expect_setequal(dir(path), c("data.rds", "orderly.R"))
  expect_equal(readRDS(file.path(path, "data.rds")),
               mtcars_db)

  ## Save a copy of the connection out:
  con <- env$con
  expect_s4_class(con, "SQLiteConnection")
  expect_true(DBI::dbIsValid(con))
  expect_equal(DBI::dbListTables(con), "mtcars") # still works

  ## Force cleanup, check it closes connection:
  rm(env)
  gc()
  ## expect_false(DBI::dbIsValid(con)) # TODO

  meta <- outpack::outpack_root_open(root)$metadata(id, TRUE)
  meta_db <- meta$custom$orderly$plugins$orderly3.db
  expect_setequal(names(meta_db), c("query", "connection"))

  expect_length(meta_db$query, 1)
  expect_setequal(names(meta_db$query[[1]]),
                  c("as", "database", "query", "rows", "cols"))
  expect_equal(meta_db$query[[1]]$as, "dat")
  expect_equal(meta_db$query[[1]]$database, "source")
  expect_equal(meta_db$query[[1]]$rows, nrow(mtcars_db))
  expect_equal(meta_db$query[[1]]$cols, as.list(names(mtcars_db)))
  expect_equal(meta_db$query[[1]]$query, "SELECT * FROM mtcars")

  expect_length(meta_db$connection, 1)
  expect_mapequal(meta_db$connection[[1]],
                  list(database = "source", as = "con"))
})


test_that("allow connection without data", {
  root <- test_prepare_example("connectiononly",
                               list(source = list(mtcars = mtcars_db)))
  env <- new.env()
  id <- orderly3::orderly_run("connectiononly", root = root, envir = env)

  expect_type(id, "character")

  path <- file.path(root, "archive", "connectiononly", id)
  expect_setequal(dir(path), c("data.rds", "orderly.R"))
  expect_equal(readRDS(file.path(path, "data.rds")),
               mtcars_db)

  meta <- outpack::outpack_root_open(root)$metadata(id, TRUE)
  meta_db <- meta$custom$orderly$plugins$orderly3.db
  expect_setequal(names(meta_db), "connection")

  expect_length(meta_db$connection, 1)
  expect_mapequal(meta_db$connection[[1]],
                  list(database = "source", as = "con"))
})


test_that("validate plugin configuration", {
  expect_error(
    orderly_db_config(list(), "orderly_config.yml"),
    "must contain at least one database")
  expect_error(
    orderly_db_config(list(db = list()), "orderly_config.yml"),
    "Fields missing from orderly_config.yml:orderly3.db:db: driver, args")
  expect_error(
    orderly_db_config(list(db = list(driver = NULL, args = NULL)),
                      "orderly_config.yml"),
    "'orderly_config.yml:orderly3.db:db:driver' must be a scalar")
  expect_error(
    orderly_db_config(list(db = list(driver = "db", args = NULL)),
                      "orderly_config.yml"),
    paste("Expected fully qualified name for",
          "orderly_config.yml:orderly3.db:db:driver"))
  expect_error(
    orderly_db_config(list(db = list(driver = "pkg::db", args = NULL)),
                      "orderly_config.yml"),
    "'orderly_config.yml:orderly3.db:db:args' must be named")

  ## Success:
  expect_equal(
    orderly_db_config(
      list(db = list(driver = "pkg::db", args = list(a = 1))),
      "orderly_config.yml"),
    list(db = list(driver = c("pkg", "db"), args = list(a = 1))))
})


test_that("validate db for sqlite", {
  expect_error(
    orderly_db_config(
      list(db = list(driver = "RSQLite::SQLite",
                     args = list(dbname = ":memory:"))),
      "orderly_config.yml"),
    "Can't use an in-memory database with orderly3.db")

  db <- tempfile(tmpdir = normalizePath(tempdir(), mustWork = TRUE))
  ## Tweak so that things behave sensibly on windows:
  db <- gsub("\\", "/", db, fixed = TRUE)

  expected <- list(db = list(driver = c("RSQLite", "SQLite"),
                             args = list(dbname = db)))

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
    orderly3::orderly_run("minimal", root = root, envir = env),
    "'database' must be given if there is more than one database")

  path_code <- file.path(root, "src", "minimal", "orderly.R")
  code <- readLines(path_code)
  code <- sub("orderly3.db::orderly_db_query(",
              'orderly3.db::orderly_db_query(database = "source",',
              code, fixed = TRUE)
  writeLines(code, path_code)

  id <- orderly3::orderly_run("minimal", root = root, envir = env)
  expect_equal(
    readRDS(file.path(root, "archive", "minimal", id, "data.rds")),
    mtcars_db)
})


test_that("sensible error if no databases configured", {
  root <- test_prepare_example("minimal", list())
  expect_error(
    orderly3::orderly_run("minimal", root = root, envir = env),
    "orderly_config.yml:orderly3.db must contain at least one database",
    fixed = TRUE)
})


test_that("run function cleans up connections", {
  skip("FIXME")
  skip_if_not_installed("mockery")

  cars <- cbind(name = rownames(mtcars), mtcars)
  rownames(cars) <- NULL
  path <- test_prepare_example("minimal", list(cars = cars))

  con <- new.env() # just gives us a singleton
  mock_connect <- mockery::mock(con)
  mock_query <- mockery::mock(cars)
  mock_disconnect <- mockery::mock()
  mockery::stub(orderly_db_run, "orderly_db_connect", mock_connect)
  mockery::stub(orderly_db_run, "DBI::dbGetQuery", mock_query)
  mockery::stub(orderly_db_run, "orderly_db_disconnect", mock_disconnect)

  root <- orderly2:::orderly_root(path, FALSE)
  data <- list(data = list(a = list(query = "SELECT * from cars",
                                    database = "source")))
  tmp <- tempfile()
  env <- new.env(parent = topenv())
  meta <- orderly_db_run(data, root, list(), env, tmp)
  expect_equal(ls(env), "a")
  expect_equal(env$a, cars)

  mockery::expect_called(mock_connect, 1)
  expect_equal(mockery::mock_args(mock_connect)[[1]],
               list("source", root$config$orderly2.db))

  mockery::expect_called(mock_query, 1)
  expect_identical(mockery::mock_args(mock_query)[[1]][[1]], con)
  expect_equal(mockery::mock_args(mock_query)[[1]][[2]], "SELECT * from cars")

  mockery::expect_called(mock_disconnect, 1)
  expect_equal(mockery::mock_args(mock_disconnect)[[1]],
               list(list(source = con)))
})


test_that("can construct a view, then read from it", {
  root <- test_prepare_example("view", list(source = list(mtcars = mtcars_db)))

  env <- new.env()
  id <- orderly3::orderly_run("view", root = root, envir = env)
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
