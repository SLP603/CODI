
patientlist_location <- list.files(here("FROM_DCC"), pattern = paste0("matched_data_", PartnerID, ".csv" ), ignore.case = T)
if (length(patientlist_location) == 0){
  stop(paste0("matched_data_", PartnerID, ".csv not found in the FROM_DCC folder."))
}
patientlist <- read.csv(here("FROM_DCC",patientlist_location), stringsAsFactors = F, 
                           colClasses =c("linkid"="character", "in_study_cohort"="character", "index_site"="character"))
result <- tryCatch({
  
  conn <- getNewDBConnection()

  cat("Loading index_site data from DCC...\n")
  tempResult1 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "patientlist.sql"))
  DatabaseConnector::insertTable(connection = conn, data = patientlist, tableName = "#patientlist", tempTable=T)
  
  tempResult2 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "delete_index_site.sql"))
  tempResult3 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "tract_aldi.sql"))
  tempResult4 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "study_cohort.sql"))
  tempResult5 <- run_db_query(db_conn=conn, 
                              sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort.sql"))
  ## Only for CHORDS healthcare partners
  if (tolower(PartnerID) != "hfc" && tolower(PartnerID) != 'gotr' && tolower(PartnerID) != 'dh'){
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
    tempResult6 <- run_db_query(db_conn=conn, 
                                sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "delete_from_cohort.sql"))
    tempResult7 <- run_db_query(db_conn=conn, 
                                sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_out.sql"))

    tempResult13 <- run_db_query(db_conn=conn, 
                                 sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "outcome_vitals.sql"))
    tempResult14 <- run_db_query(db_conn=conn, 
                                 sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "lab_codes.sql"))
    tempResult15 <- run_db_query(db_conn=conn, 
                                 sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "outcome_lab_results.sql"))
    #tempResult16 <- run_db_query(db_conn=conn, 
    #                             sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "hf_participants.sql"))
    tempResult17 <- run_db_query(db_conn=conn, 
                                 sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "type_enc_out.sql"))
    tempResult18 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "diet_nutr_enc.sql"))
  }
  tempResult19 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "adi_out.sql"))
  tempResult20 <- run_db_query(db_conn=conn, 
                               sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "exposure_dose.sql"))
  
}, error = function(err) {
  stop(err)
}, finally = function(){
  tryCatch({DBI::dbDisconnect(conn)})
})

tryCatch({
  ## Only for CHORDS healthcare partners
  ADI_OUT <- run_db_query_andromeda(db_conn = conn, "SELECT * FROM #ADI_OUT; -- for GOTR and HFC", andromedaTableName = "ADI_OUT")
  EXPOSURE_DOSE <- run_db_query_andromeda(db_conn = conn, "SELECT * FROM #EXPOSURE_DOSE; -- for GOTR and HFC", andromedaTableName = "EXPOSURE_DOSE")
  writeOutput_andromeda("ADI_OUT", ADI_OUT, andromedaTableName = "ADI_OUT")
  writeOutput_andromeda("EXPOSURE_DOSE", EXPOSURE_DOSE, andromedaTableName = "EXPOSURE_DOSE")
  
  if (tolower(PartnerID) != "hfc" && tolower(PartnerID) != 'gotr'&& tolower(PartnerID) != 'dh'){
    OUTCOME_VITALS <- run_db_query_andromeda(db_conn = conn, "SELECT * FROM #OUTCOME_VITALS;", andromedaTableName = "OUTCOME_VITALS")
    OUTCOME_LAB_RESULTS <- run_db_query_andromeda(db_conn = conn, "SELECT * FROM #OUTCOME_LAB_RESULTS;", andromedaTableName = "OUTCOME_LAB_RESULTS")
    #HF_PARTICIPANTS <- run_db_query_andromeda(db_conn = conn, "SELECT * FROM #HF_PARTICIPANTS; -- for GOTR and HFC", andromedaTableName = "cohort_CC")
    DIET_NUTR_ENC <- run_db_query_andromeda(db_conn = conn, "SELECT * FROM #DIET_NUTR_ENC;", andromedaTableName = "DIET_NUTR_ENC")
    writeOutput_andromeda("DIET_NUTR_ENC", DIET_NUTR_ENC, andromedaTableName = "DIET_NUTR_ENC")
    writeOutput_andromeda("OUTCOME_VITALS", OUTCOME_VITALS, andromedaTableName = "OUTCOME_VITALS")
    writeOutput_andromeda("OUTCOME_LAB_RESULTS", OUTCOME_LAB_RESULTS, andromedaTableName = "OUTCOME_LAB_RESULTS")
    #writeOutput_andromeda("HF_PARTICIPANTS", HF_PARTICIPANTS, andromedaTableName = "cohort_CC")
  }
}, finally = {
  if(exists("OUTCOME_VITALS")){
    Andromeda::close(OUTCOME_VITALS)
  }
  if(exists("OUTCOME_LAB_RESULTS")){
    Andromeda::close(OUTCOME_LAB_RESULTS)
  }
  if(exists("EXPOSURE_DOSE")){
    Andromeda::close(EXPOSURE_DOSE)
  }
  if(exists("ADI_OUT")){
    Andromeda::close(ADI_OUT)
  }
  if(exists("DIET_NUTR_ENC")){
    Andromeda::close(DIET_NUTR_ENC)
  }
})

message(paste0("CODI Step ", CODISTEP, " done!"))
