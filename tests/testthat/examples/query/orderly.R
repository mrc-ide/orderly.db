dat1 <- orderly.db::orderly_db_query(query = "query.sql")
orderly2::orderly_artefact("Some data", "data.rds")

saveRDS(dat1, "data.rds")
