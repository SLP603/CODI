
snomed2icd <- readr::read_csv(here("csv", "snomed2icd.csv"),col_types = cols(.default = "c")) 
demo_recon_loc_location <- list.files(here("FROM_DCC"), pattern = "demo_recon_loc_.*\\.csv$" )
demo_recon_loc <- readr::read_csv(here("FROM_DCC",demo_recon_loc_location), col_types = list(linkid=col_character(), site=col_character(), yr=col_integer()))

result <- tryCatch({
  
  conn <- getNewDBConnection()
  tempResult1 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "snomed2icd.sql"))
  cat("Loading SNOMED to ICD codes...\n")
  DatabaseConnector::insertTable(connection = conn, data = snomed2icd, tableName = "#snomed2icd", tempTable=T)
  
  cat("Loading demo_recon_loc from DCC...\n")
  tempResult2 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "demo_recon_loc.sql"))
  DatabaseConnector::insertTable(connection = conn, data = demo_recon_loc, tableName = "#demo_recon_loc", tempTable=T)

  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "pmca.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "comorb_codes.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "race_con_codes.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "demo_recon_loc_link.sql"))
  
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "enc_counts.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "enc_test.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "ec_test_latest_loc_date.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_demographic.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_demographic_age.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_demographic_age_filter.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "geocode_tract.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "demo_recon_loc_tract.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "insurance.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_demographic_insurance_prep.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_demographic_tract_prep.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "coconditions.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "diagnosis_CC_ind_any.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_demographic_tract.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_tract.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "cohort_tract_comorb.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "distinct_cohort.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "pmca_input.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "pmca_input_system.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "pmca_input_single.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "pmca_output_single_system.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "pmca_output_prep.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "pmca_output.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "measures_output_prep.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "measures_output.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "race_condition_inputs_1.sql"))
  run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "race_condition_inputs.sql"))
  
  cohort_tract_comorb <- run_db_query_andromeda(db_conn=conn, "SELECT DISTINCT * FROM #cohort_tract_comorb ORDER BY linkid;", andromedaTableName ="cohort_tract_comorb" )
  pmca_output <- run_db_query_andromeda(db_conn=conn, "SELECT DISTINCT * FROM #pmca_output ORDER BY pmca;", andromedaTableName = "pmca_output")
  measures_output <- run_db_query_andromeda(db_conn=conn, "SELECT DISTINCT linkid, ht, wt, cast(measure_date as varchar) measure_date, insurance_type FROM #measures_output;", andromedaTableName = "measures_output")
  race_condition_inputs <- run_db_query_andromeda(db_conn=conn, "SELECT DISTINCT linkid, category, count, cast(early_admit_date as varchar) early_admit_date FROM #race_condition_inputs;", andromedaTableName = "race_condition_inputs")
  
}, error = function(err) {
  stop(err)
}, finally = function(){
  tryCatch({DBI::dbDisconnect(conn)})
})

dir.create(here("output", paste0("Step_", CODISTEP)), showWarnings = F, recursive = T)

tryCatch({
  writeOutput_andromeda("cohort_tract_comorb", cohort_tract_comorb, andromedaTableName = "cohort_tract_comorb")
  writeOutput_andromeda("pmca_output", pmca_output, andromedaTableName = "pmca_output")
  #writeOutput_andromeda("measures_output", measures_output, andromedaTableName = "measures_output")
  cat("Saving measures_output to ", paste0("./output/Step_3/measures_output_", PartnerID, ".zip"), "\n")
  Andromeda::saveAndromeda(andromeda = measures_output, fileName = paste0("./output/Step_3/measures_output_", PartnerID, ".zip"), maintainConnection = T)
  writeOutput_andromeda("race_condition_inputs", race_condition_inputs, andromedaTableName = "race_condition_inputs")
})

message(paste0("CODI Step ", CODISTEP, " and ", CODISTEP + 1, " done!"))


