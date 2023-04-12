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
      ## This probably belongs elsewhere really, but it is always
      ## called here.
      if (is.null(config)) {
        stop("Your database set up is not configured?")
      }
      stopifnot(length(config) > 0)
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


open_connection <- function(path, config, database) {
  connections <- local_connections(path, config)$open(database)
}


close_all_connections <- function(path, config) {
  local_connections(path, config)$close_all()
}


local <- new.env(parent = emptyenv())
local_connections <- function(key, config) {
  obj <- local[[key]]
  if (is.null(obj) || !identical(obj$config, config)) {
    local[[key]] <- connections$new(config)
  }
  local[[key]]
}
