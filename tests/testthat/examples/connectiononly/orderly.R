orderly3::orderly_artefact("Some data", "data.rds")
orderly3.db::orderly_db_connection("con")

dat <- DBI::dbReadTable(con, "mtcars")
saveRDS(dat, "data.rds")
