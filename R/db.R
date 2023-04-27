##' Create temporary view
##'
##' @title Create temporary view
##'
##' @param query Query to create view from
##'
##' @param as Name of the view in the database
##'
##' @inheritParams orderly_db_query
##'
##' @return Undefined
##' @export
orderly_db_view <- function(query, as, database = NULL, instance = NULL) {
  assert_scalar_character(as)
  ctx <- orderly3::orderly_plugin_context("orderly3.db")
  query <- check_query(query, ctx)
  con <- open_connection(ctx$path, ctx$config, ctx$env, database, instance)
  sql <- sprintf("CREATE TEMPORARY VIEW %s AS\n%s", as, query)
  DBI::dbExecute(con$connection, sql)
  info <- list(database = con$database, as = as, query = query)
  orderly3::orderly_plugin_add_metadata("orderly3.db", "view", info)
  invisible()
}


##' Extract data from a database
##'
##' @title Extract data from a database
##'
##' @param query Query to evaluate
##'
##' @param as Name of the object to create
##'
##' @param database The name of the database. This can be omitted (or
##'   `NULL`) where you only have a single database, but must be
##'   specified if you have more than one database configured.
##'
##' @param instance The instance of the database (within a given
##'   `database`). This can be omitted (or `NULL`) where you have not
##'   used instances or where you have only one configured.
##'
##' @return Undefined
##' @export
orderly_db_query <- function(query, as, database = NULL, instance = NULL) {
  assert_scalar_character(as)
  ctx <- orderly3::orderly_plugin_context("orderly3.db")
  con <- open_connection(ctx$path, ctx$config, ctx$env, database, instance)
  query <- check_query(query, ctx)
  d <- DBI::dbGetQuery(con$connection, query)
  ctx$env[[as]] <- d
  info <- list(database = con$database, as = as, query = query,
               rows = nrow(d), cols = names(d))
  orderly3::orderly_plugin_add_metadata("orderly3.db", "query", info)
  invisible()
}


##' Create a persistant connection object to the database
##'
##' @title Create connection to database
##'
##' @param as Name of the object create
##'
##' @inheritParams orderly_db_query
##'
##' @return Undefined
##' @export
orderly_db_connection <- function(as, database = NULL, instance = NULL) {
  assert_scalar_character(as)
  ctx <- orderly3::orderly_plugin_context("orderly3.db")
  con <- open_connection(ctx$path, ctx$config, ctx$env, database, instance)
  ctx$env[[as]] <- con$connection
  info <- list(database = con$database, as = as)
  orderly3::orderly_plugin_add_metadata("orderly3.db", "connection", info)
}


check_query <- function(query, context) {
  assert_character(query)
  if (file_exists(query, workdir = context$src)) {
    ## Once outpack only copies some files over we'll want to copy
    ## this too, but that needs to wait for strict mode really.
    query <- readLines(file.path(context$src, query))
  }
  query <- sql_str_sub(query, context$parameters)
  query
}
