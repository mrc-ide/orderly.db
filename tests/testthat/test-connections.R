test_that("validate connections when one is present", {
  config <- list(db = list(driver = c("RSQLite", "SQLite"),
                           path = ":memory:"))
  obj <- connections$new(config)
  con1 <- obj$open(NULL)
  expect_identical(obj$open(NULL), con1)
  expect_identical(obj$open("db"), con1)
  expect_error(obj$open("db2"),
               "database must be one of 'db'")
})


test_that("validate connections when one is present", {
  cfg <- list(driver = c("RSQLite", "SQLite"), path = ":memory:")
  config <- list(db1 = cfg, db2 = cfg)
  obj <- connections$new(config)

  expect_error(
    obj$open(NULL),
    "'database' must be given if there is more than one database")

  con1 <- obj$open("db1")
  con2 <- obj$open("db2")
  expect_equal(con1$database, "db1")
  expect_equal(con2$database, "db2")
  expect_false(identical(con1$connection, con2$connection))
  expect_identical(obj$open("db1"), con1)
  expect_identical(obj$open("db2"), con2)
})


test_that("find and clean local connections", {
  clear_local_connections()
  env <- new.env()
  key <- "/some/path"
  config <- list(db = list(driver = c("RSQLite", "SQLite"), path = ":memory:"))
  obj <- local_connections(key, config, env)
  expect_s3_class(obj, "connections")
  expect_identical(local_connections(key, config, env), obj)

  con <- obj$open(NULL)
  expect_true(DBI::dbIsValid(con$connection))
  rm(env)
  gc()

  expect_false(DBI::dbIsValid(con$connection))
})
