connections <- R6::R6Class(
  "connections",

  private = list(
    connections = NULL
  ),

  public = list(
    config = NULL,

    initialize = function(config) {
      self$config <- config
      private$connections <- list()
      lockBinding("config", self)
    },

    open = function(database) {
      database <- self$resolve_database(database)
      key <- database # later database:instance
      if (is.null(private$connections[[key]])) {
        cfg <- self$config[[database]]
        stopifnot(!is.null(cfg))
        driver <- getExportedValue(cfg$driver[[1L]], cfg$driver[[2L]])
        private$connections[[key]] <-
          do.call(DBI::dbConnect, c(list(driver()), cfg$args))
      }
      list(database = database,
           connection = private$connections[[key]])
    },

    resolve_database = function(database) {
      if (is.null(database)) {
        if (length(self$config) > 1) {
          stop("'database' must be given if there is more than one database")
        }
        database <- names(self$config)
      } else {
        match_value(database, names(self$config))
      }
      database
    },

    close_all = function() {
      for (con in private$connections) {
        DBI::dbDisconnect(con)
      }
      private$connections <- list()
    }
  ))


open_connection <- function(path, config, env, database) {
  connections <- local_connections(path, config, env)$open(database)
}


## It is important that different calls to the same database use the
## same connection (e.g., if one establishes a view). To make this
## work, we keep a stash of connection objects stored against their
## working directory (the key here).
##
## We register a cleanup hook against the calling environment so that
## cleanup is automatic; once 'env' is removed then we clean up all
## connections and remove the connection pool from the cache.  This
## happens fairly naturally from orderly_run in the case where 'env'
## is not the global environment (or if the report is run in its own
## session, in which case cleanup happens as the session cleans up).
##
## For interactive use, we'll practically never clean up as there is
## nohing we can use to detect that cleanup should occur until the end
## of the session.
##
## If we allow plugins to clean up, this would be nicer really; in
## that case we'd be a bit more deterministic. Nothing really about
## the idea below would change except that we'd not need to register a
## finalser at all. This would also be useful for some sort of
## "orderly local clean" function which could then run this hook.
local <- new.env(parent = emptyenv())
local_connections <- function(key, config, env) {
  obj <- local[[key]]
  if (is.null(obj) || !identical(obj$config, config)) {
    local[[key]] <- connections$new(config)
    reg.finalizer(env, function(e) {
      local[[key]]$close_all()
      local[[key]] <- NULL
    })
  }
  local[[key]]
}
