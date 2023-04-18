test_that("validate connections when one is present", {
  config <- orderly_db_config(
    list(db = list(driver = "RSQLite::SQLite",
                   args = list(dbname = ":memory:"))),
    "config.yml")
  obj <- connections$new(config)
  con1 <- obj$open(NULL, NULL)
  expect_identical(obj$open(NULL, NULL), con1)
  expect_identical(obj$open("db", NULL), con1)
  expect_error(obj$open("db2"),
               "database must be one of 'db'")
  expect_error(obj$open("db", "something"),
               "instance must be one of 'default'")
})


test_that("validate connections when two are present", {
  cfg <- list(driver = "RSQLite::SQLite",
              args = list(dbname = ":memory:"))
  config <- orderly_db_config(
    list(db1 = cfg, db2 = cfg),
    "config.yml")

  obj <- connections$new(config)

  expect_error(
    obj$open(NULL),
    "'database' must be given if there is more than one database")

  con1 <- obj$open("db1", NULL)
  con2 <- obj$open("db2", NULL)
  expect_equal(con1$database, "db1")
  expect_equal(con2$database, "db2")
  expect_equal(con1$instance, "default")
  expect_equal(con2$instance, "default")
  expect_false(identical(con1$connection, con2$connection))
  expect_identical(obj$open("db1", "default"), con1)
  expect_identical(obj$open("db2", "default"), con2)
})


test_that("find and clean local connections", {
  clear_local_connections()
  env <- new.env()
  key <- "/some/path"
  config <- orderly_db_config(
    list(db = list(driver = "RSQLite::SQLite",
                   args = list(dbname = ":memory:"))),
    "config.yml")
  obj <- local_connections(key, config, env)
  expect_s3_class(obj, "connections")
  expect_identical(local_connections(key, config, env), obj)

  con <- obj$open(NULL, NULL)
  expect_true(DBI::dbIsValid(con$connection))
  obj$close_all()

  expect_false(DBI::dbIsValid(con$connection))
})


test_that("changing the configuration invalidates connections", {
  clear_local_connections()
  env <- new.env()
  key <- "/some/path"
  cfg <- list(driver = "RSQLite::SQLite",
              args = list(dbname = ":memory:"))
  config1 <- orderly_db_config(
    list(db1 = cfg),
    "config.yml")
  config2 <- orderly_db_config(
    list(db1 = cfg, db2 = cfg),
    "config.yml")
  obj1 <- local_connections(key, config1, env)
  con1 <- obj1$open("db1", NULL)
  expect_true(DBI::dbIsValid(con1$connection))
  obj2 <- local_connections(key, config2, env)
  expect_false(DBI::dbIsValid(con1$connection))
})
