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
  ctx <- orderly::orderly_plugin_context("orderly.db", parent.frame())
  query <- check_query(query, ctx)
  con <- open_connection(ctx$path, ctx$config, ctx$envir, database, instance)
  sql <- sprintf("CREATE TEMPORARY VIEW %s AS\n%s", as, query)
  DBI::dbExecute(con$connection, sql)
  info <- list(database = con$database,
               as = as,
               query = query,
               instance = instance)
  orderly::orderly_plugin_add_metadata("orderly.db", "view", info)
  invisible()
}


##' Extract data from a database
##'
##' @title Extract data from a database
##'
##' @param query Query to evaluate
##'
##' @param database The name of the database. This can be omitted (or
##'   `NULL`) where you only have a single database, but must be
##'   specified if you have more than one database configured.
##'
##' @param instance The instance of the database (within a given
##'   `database`). This can be omitted (or `NULL`) where you have not
##'   used instances or where you have only one configured.
##'
##' @param name An optional name that you can use to look up this
##'   query in your metadata.
##'
##' @return The extracted data
##' @export
orderly_db_query <- function(query, database = NULL, instance = NULL,
                             name = NULL) {
  ctx <- orderly::orderly_plugin_context("orderly.db", parent.frame())
  con <- open_connection(ctx$path, ctx$config, ctx$envir, database, instance)
  query <- check_query(query, ctx)
  if (!is.null(name)) {
    assert_scalar_character(name)
  }
  d <- DBI::dbGetQuery(con$connection, query)
  info <- list(database = con$database,
               instance = instance,
               query = query,
               rows = nrow(d),
               cols = names(d),
               name = name)
  orderly::orderly_plugin_add_metadata("orderly.db", "query", info)
  d
}


##' Create a persistent connection object to the database
##'
##' @title Create connection to database
##'
##' @inheritParams orderly_db_query
##'
##' @return The connection object
##' @export
orderly_db_connection <- function(database = NULL, instance = NULL) {
  ctx <- orderly::orderly_plugin_context("orderly.db", parent.frame())
  con <- open_connection(ctx$path, ctx$config, ctx$envir, database, instance)
  info <- list(database = con$database,
               instance = instance)
  orderly::orderly_plugin_add_metadata("orderly.db", "connection", info)
  con$connection
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
