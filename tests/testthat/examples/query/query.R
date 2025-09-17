dat1 <- orderly.db::orderly_db_query(query = "query.sql")
orderly::orderly_artefact(description = "Some data", files = "data.rds")

saveRDS(dat1, "data.rds")
