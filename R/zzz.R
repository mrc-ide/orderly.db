.onLoad <- function(...) {
  # nocov start
  schema <- system.file("orderly.db.json", package = "orderly3.db",
                        mustWork = TRUE)
  orderly3::orderly_plugin_register(
    "orderly3.db", orderly_db_config, orderly_db_serialise, schema)
  # nocov end
}
