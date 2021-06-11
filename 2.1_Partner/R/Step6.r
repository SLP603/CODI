
suppressWarnings(library("DBI"))
suppressWarnings(library("here"))
suppressWarnings(library("SqlRender"))
suppressWarnings(suppressPackageStartupMessages(library("dplyr")))

patientlist_location <- list.files(here("FROM_DCC"), pattern = "index_site_*" )
patientlist <- read.csv(here("FROM_DCC",patientlist_location), stringsAsFactors = F, 
                           colClasses =c("linkid"="character", "site"="character", "index_site"="character", 
                                         "inclusion" = "numeric", "exclusion" = "numeric"))

result <- tryCatch({
  
  conn <- getNewDBConnection()

  cat("Loading index_site data from DCC...\n")
  tempResult1 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "patientlist.sql"))
  dbWriteTable(conn, "#patientlist", patientlist, immediate = T, row.names=F, overwrite=T)
  
  tempResult2 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "delete_index_site.sql"))
  tempResult3 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "tract_aldi.sql"))
  tempResult4 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "study_cohort.sql"))
  tempResult5 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort.sql"))
  tempResult6 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "anchor_study_cohort.sql"))
  tempResult7 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "encounters_vital_join.sql"))
  tempResult8 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "rand_enc.sql"))
  tempResult9 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "anchor_comparison_cohort.sql"))
  tempResult10 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "anchor_date.sql"))
  tempResult11 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "delete_from_cohort.sql"))
  tempResult12 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_out.sql"))
  tempResult13 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "outcome_vitals.sql"))
  tempResult14 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "lab_codes.sql"))
  tempResult15 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "outcome_lab_results.sql"))
  tempResult16 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "exposure_dose.sql"))
  tempResult17 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "hf_participants.sql"))
  tempResult19 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "adi_out.sql"))
  tempResult20 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "type_enc_out.sql"))
  tempResult21 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "diet_nutr_enc.sql"))
  
  OUTCOME_VITALS <- run_db_query(db_conn = conn, "SELECT * FROM #OUTCOME_VITALS;")
  OUTCOME_LAB_RESULTS <- run_db_query(db_conn = conn, "SELECT * FROM #OUTCOME_LAB_RESULTS;")
  EXPOSURE_DOSE <- run_db_query(db_conn = conn, "SELECT * FROM #EXPOSURE_DOSE; -- for GOTR and HFC")
  HF_PARTICIPANTS <- run_db_query(db_conn = conn, "SELECT * FROM #HF_PARTICIPANTS; -- for GOTR and HFC")
  ADI_OUT <- run_db_query(db_conn = conn, "SELECT * FROM #ADI_OUT; -- for GOTR and HFC")
  DIET_NUTR_ENC <- run_db_query(db_conn = conn, "SELECT * FROM #DIET_NUTR_ENC;")
  
  
}, error = function(err) {
  stop(err)
}, finally = function(){
  tryCatch({DBI::dbDisconnect(conn)})
})

writeOutput("OUTCOME_VITALS", OUTCOME_VITALS)
writeOutput("OUTCOME_LAB_RESULTS", OUTCOME_LAB_RESULTS)
writeOutput("EXPOSURE_DOSE", EXPOSURE_DOSE)
writeOutput("HF_PARTICIPANTS", HF_PARTICIPANTS)
writeOutput("ADI_OUT", ADI_OUT)
writeOutput("DIET_NUTR_ENC", DIET_NUTR_ENC)

message(paste0("CODI Step ", CODISTEP + 1, " done!"))
