pars <- orderly::orderly_parameters(mpg_min = NULL)
dat <- orderly.db::orderly_db_query("SELECT * FROM mtcars WHERE mpg > ?mpg_min")
orderly::orderly_artefact(description = "Some data", files = "data.rds")

saveRDS(dat, "data.rds")
