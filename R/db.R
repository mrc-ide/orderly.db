orderly_db_view <- function(query, as, database = NULL) {
  assert_scalar_character(as)
  assert_character(query)
  ctx <- orderly3::orderly_plugin_context("orderly3.db")
  con <- open_connection(ctx$path, ctx$config, database)
  sql <- sprintf("CREATE TEMPORARY VIEW %s AS\n%s", as, query)
  DBI::dbExecute(con$connection, sql)
  info <- list(database = con$database, as = as, query = query)
  orderly3::orderly_plugin_add_metadata("orderly3.db", "view", info)
  invisible()
}


orderly_db_query <- function(query, as, database = NULL) {
  assert_scalar_character(as)
  assert_character(query)
  ctx <- orderly3::orderly_plugin_context("orderly3.db")
  con <- open_connection(ctx$path, ctx$config, database)
  d <- DBI::dbGetQuery(con$connection, query)
  ctx$env[[as]] <- d
  info <- list(database = con$database, as = as, query = query,
               rows = nrow(d), cols = names(d))
  orderly3::orderly_plugin_add_metadata("orderly3.db", "query", info)
  invisible()
}


orderly_db_connection <- function(as, database = NULL) {
  assert_scalar_character(as)
  ctx <- orderly3::orderly_plugin_context("orderly3.db")
  con <- open_connection(ctx$path, ctx$config, database)
  ctx$env[[as]] <- con$connection
  info <- list(database = con$database)
  orderly3::orderly_plugin_add_metadata("orderly3.db", "connection", info)
}
