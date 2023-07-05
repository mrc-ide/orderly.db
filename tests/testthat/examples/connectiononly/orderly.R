orderly2::orderly_artefact("Some data", "data.rds")
orderly.db::orderly_db_connection("con")

dat <- DBI::dbReadTable(con, "mtcars")
saveRDS(dat, "data.rds")
