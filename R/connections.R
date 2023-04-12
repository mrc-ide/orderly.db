connections <- R6::R6Class(
  "connections",

  private = list(
    connections = NULL,

    finalize = function() {
      self$close_all()
    }
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
