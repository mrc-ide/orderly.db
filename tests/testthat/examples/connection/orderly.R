orderly::orderly_artefact("Some data", "data.rds")
con <- orderly.db::orderly_db_connection()
dat <- orderly.db::orderly_db_query("SELECT * FROM mtcars")

dat_cmp <- DBI::dbReadTable(con, "mtcars")
stopifnot(isTRUE(all.equal(dat, dat_cmp)))

saveRDS(dat, "data.rds")
