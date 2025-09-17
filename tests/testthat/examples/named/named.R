dat1 <- orderly.db::orderly_db_query("SELECT * FROM mtcars", name = "input")
orderly::orderly_artefact("Some data", "data.rds")

saveRDS(dat1, "data.rds")
