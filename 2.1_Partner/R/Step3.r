
suppressWarnings(library("DBI"))
suppressWarnings(library("here"))
suppressWarnings(library("SqlRender"))
suppressWarnings(suppressPackageStartupMessages(library("dplyr")))


snomed2icd <- read.csv(here("csv", "snomed2icd.csv"), stringsAsFactors = F) %>%
  mutate_all(as.character)
patientlist_location <- list.files(here("FROM_DCC"), pattern = "index_site_*" )
patientlist <- read.csv(here("FROM_DCC",patientlist_location), stringsAsFactors = F, 
                           colClasses =c("linkid"="character", "site"="character", "index_site"="character", 
                                         "inclusion" = "numeric", "exclusion" = "numeric"))

result <- tryCatch({
  
  conn <- getNewDBConnection()
  tempResult1 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "snomed2icd.sql"))
  cat("Loading SNOMED to ICD codes...\n")
  dbWriteTable(conn, "#snomed2icd", snomed2icd, immediate = T, row.names=F, overwrite=T)
  
  cat("Loading index_site data from DCC...\n")
  tempResult2 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "patientlist.sql"))
  dbWriteTable(conn, "#patientlist", patientlist, immediate = T, row.names=F, overwrite=T)
  
  tempResult3 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "bmiage.sql"))
  tempResult4 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "pmca.sql"))
  tempResult5 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "comorb_codes.sql"))
  tempResult6 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "study_cohort.sql"))
  tempResult7 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort.sql"))
  tempResult8 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "anchor_study_cohort.sql"))
  tempResult9 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "encounters_vital_join.sql"))
  tempResult10 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "rand_enc.sql"))
  tempResult11 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "anchor_comparison_cohort.sql"))
  tempResult12 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "anchor_date.sql"))
  tempResult13 <- run_db_query(db_conn=conn, 
                             sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_clean.sql"))
  tempResult14 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "pcma_input.sql"))
  tempResult15 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_pmca.sql"))
  tempResult16 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "annotated_measures.sql"))
  tempResult17 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_pmca_bmi.sql"))
  tempResult18 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "tmpbmi.sql"))
  tempResult19 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_pmca_bmi_p95.sql"))
  tempResult20 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "insurance.sql"))
  tempResult21 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_pmca_bmi_p95_insurance.sql"))
  tempResult22 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "coconditions.sql"))
  tempResult23 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "diagnosis_CC_ind_any.sql"))
  tempResult24 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_CC.sql"))
  

  
}, error = function(err) {
  stop(err)
}, finally = function(){
  tryCatch({DBI::dbDisconnect(conn)})
})
dir.create(here("output", paste0("Step_", CODISTEP)), showWarnings = F, recursive = T)

step_3_result <- run_db_query(db_conn=conn, "SELECT * FROM #cohort_CC")
writeOutput("step_3_result", step_3_result)

message(paste0("CODI Step ", CODISTEP, " done!"))

result <- tryCatch({
  source(here("R", "MITRE", "R_2_1-step-4.R"))
  step4Output <- matched_data_id
}, error = function(err) {
  stop(err)
}, finally = function(){
  tryCatch({DBI::dbDisconnect(conn)})
})


writeOutput("PSM_matched_data", step4Output)
message(paste0("CODI Step ", CODISTEP + 1, " done!"))
