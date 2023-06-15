test_that("null-or-value works", {
  expect_equal(1 %||% NULL, 1)
  expect_equal(1 %||% 2, 1)
  expect_equal(NULL %||% NULL, NULL)
  expect_equal(NULL %||% 2, 2)
})


test_that("validate symbol", {
  expect_equal(check_symbol_from_str("a::b", "thing"),
               c("a", "b"))
  expect_error(check_symbol_from_str("a:b", "thing"),
               "Expected fully qualified name for thing")
})


test_that("can interpolate into sql", {
  expect_equal(
    sql_str_sub("SELECT * FROM mtcars WHERE mpg > ?x", list(x = 1)),
    "SELECT * FROM mtcars WHERE mpg > 1")
  expect_equal(
    sql_str_sub(c("SELECT * FROM mtcars", "WHERE mpg > ?x"), list(x = 1)),
    c("SELECT * FROM mtcars", "WHERE mpg > 1"))
})
