
suppressWarnings(library("DBI"))
suppressWarnings(library("here"))
suppressWarnings(library("SqlRender"))
suppressWarnings(suppressPackageStartupMessages(library("dplyr")))


snomed2icd <- read.csv(here("csv", "snomed2icd.csv"), stringsAsFactors = F) %>%
  mutate_all(as.character)
demo_recon_loc_location <- list.files(here("FROM_DCC"), pattern = "demo_recon_loc_*" )
demo_recon_loc <- read.csv(here("FROM_DCC",demo_recon_loc_location), stringsAsFactors = F, 
                           colClasses =c("linkid"="character", "site"="character", "yr"="numeric"))

result <- tryCatch({
  
  conn <- getNewDBConnection()
  tempResult1 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "snomed2icd.sql"))
  cat("Loading SNOMED to ICD codes...\n")
  dbWriteTable(conn, "#snomed2icd", snomed2icd, immediate = T, row.names=F, overwrite=T)
  
  cat("Loading demo_recon_loc from DCC...\n")
  tempResult2 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "demo_recon_loc.sql"))
  dbWriteTable(conn, "#demo_recon_loc", demo_recon_loc, immediate = T, row.names=F, overwrite=T)
  
  tempResult3 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "pmca.sql"))
  tempResult4 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "comorb_codes.sql"))
  tempResult5 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "race_con_codes.sql"))
  tempResult6 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "demo_recon_loc_link.sql"))
  tempResult7 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "enc_counts.sql"))
  tempResult8 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "enc_test.sql"))
  tempResult9 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "ec_test_latest_loc_date.sql"))
  tempResult10 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_demographic.sql"))
  tempResult11 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_demographic_age.sql"))
  tempResult12 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_demographic_age_filter.sql"))
  tempResult13 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "geocode_tract.sql"))
  tempResult14 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "demo_recon_loc_tract.sql"))
  tempResult15 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "insurance.sql"))
  tempResult16 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_demographic_insurance_prep.sql"))
  tempResult17 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_tract.sql"))
  tempResult18 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "coconditions.sql"))
  tempResult19 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "diagnosis_CC_ind_any.sql"))
  tempResult20 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_demographic_tract_prep.sql"))
  tempResult21 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_demographic_tract.sql"))
  tempResult22 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_tract_comorb.sql"))
  tempResult23 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "distinct_cohort.sql"))
  tempResult24 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "pmca_input.sql"))
  tempResult25 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "pmca_input_system.sql"))
  tempResult26 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "pmca_input_single.sql"))
  tempResult27 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "pmca_output_single_system.sql"))
  tempResult28 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "pmca_output_prep.sql"))
  tempResult29 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "pmca_output.sql"))
  tempResult30 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "measures_output_prep.sql"))
  tempResult31 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "measures_output.sql"))
  tempResult32 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "race_condition_inputs_1.sql"))
  tempResult33 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "race_condition_inputs.sql"))
  
  cohort_tract_comorb <- run_db_query(conn, "SELECT * FROM #cohort_tract_comorb ORDER BY linkid;")
  pmca_output <- run_db_query(conn, "SELECT * FROM #pmca_output ORDER BY pmca;")
  measures_output <- run_db_query(conn, "SELECT * FROM #measures_output;")
  race_condition_inputs <- run_db_query(conn, "SELECT * FROM #race_condition_inputs;")
  
}, error = function(err) {
  stop(err)
}, finally = function(){
  tryCatch({DBI::dbDisconnect(conn)})
})

dir.create(here("output", paste0("Step_", CODISTEP)), showWarnings = F, recursive = T)

writeOutput <- function(fileName, data){
  outputFile <- here("output", paste0("Step_", CODISTEP), paste0(fileName, "_", PartnerID, ".csv"))
  cat(paste0("Writing Results to outputFile:\n\t", outputFile, "\n"))
  write.csv(x = data, 
            file = outputFile, 
            row.names = F, 
            quote = T, na = "NULL")
}

writeOutput("cohort_tract_comorb", cohort_tract_comorb)
writeOutput("pmca_output", pmca_output)
writeOutput("measures_output", measures_output)
writeOutput("race_condition_inputs", race_condition_inputs)

message(paste0("CODI Step ", CODISTEP, " done!"))
