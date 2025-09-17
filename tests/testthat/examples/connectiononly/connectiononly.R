orderly::orderly_artefact(description = "Some data", files = "data.rds")
con <- orderly.db::orderly_db_connection()

dat <- DBI::dbReadTable(con, "mtcars")
saveRDS(dat, "data.rds")
