.onLoad <- function(...) {
  # nocov start
  schema <- system.file("orderly.db.json", package = "orderly3.db",
                        mustWork = TRUE)
  orderly3::orderly_plugin_register(
    "orderly3.db",
    config = orderly_db_config,
    serialise = orderly_db_serialise,
    cleanup  = orderly_db_cleanup ,
    schema = schema)
  # nocov end
}
