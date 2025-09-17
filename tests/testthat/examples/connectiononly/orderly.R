orderly::orderly_artefact("Some data", "data.rds")
con <- orderly.db::orderly_db_connection()

dat <- DBI::dbReadTable(con, "mtcars")
saveRDS(dat, "data.rds")
