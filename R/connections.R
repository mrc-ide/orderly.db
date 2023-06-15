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

    open = function(database, instance) {
      database <- self$resolve_database(database)
      instance <- self$resolve_instance(database, instance)
      key <- paste(database, instance, sep = ":")
      if (is.null(private$connections[[key]])) {
        cfg <- self$config[[database]]
        stopifnot(!is.null(cfg))
        driver <- getExportedValue(cfg$driver[[1L]], cfg$driver[[2L]])
        args <- cfg$instances[[instance]]
        stopifnot(!is.null(args))
        private$connections[[key]] <-
          do.call(DBI::dbConnect, c(list(driver()), args))
      }
      list(database = database,
           instance = instance,
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

    resolve_instance = function(database, instance) {
      cfg <- self$config[[database]]
      if (is.null(instance)) {
        instance <- cfg$default_instance
      } else {
        match_value(instance, names(cfg$instances))
      }
      instance
    },

    close_all = function() {
      for (con in private$connections) {
        DBI::dbDisconnect(con)
      }
      private$connections <- list()
    }
  ))


open_connection <- function(path, config, env, database, instance) {
  connections <- local_connections(path, config, env)$open(database, instance)
}


## It is important that different calls to the same database use the
## same connection (e.g., if one establishes a view). To make this
## work, we keep a stash of connection objects stored against their
## working directory (the key here).
local <- new.env(parent = emptyenv())
local_connections <- function(key, config, env) {
  obj <- local[[key]]
  if (is.null(obj)) {
    local[[key]] <- connections$new(config)
  } else if (!identical(obj$config, config)) {
    obj$close_all()
    local[[key]] <- connections$new(config)
  }
  local[[key]]
}


local_connections_close <- function(key) {
  obj <- local[[key]]
  if (!is.null(obj)) {
    obj$close_all()
    local[[key]] <- NULL
  }
}
