orderly2::orderly_artefact("Some data", "data.rds")
orderly.db::orderly_db_connection("con")
orderly.db::orderly_db_query(as = "dat", query = "SELECT * FROM mtcars")

dat_cmp <- DBI::dbReadTable(con, "mtcars")
stopifnot(isTRUE(all.equal(dat, dat_cmp)))

saveRDS(dat, "data.rds")
