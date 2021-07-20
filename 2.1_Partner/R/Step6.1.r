
suppressWarnings(library("DBI"))
suppressWarnings(library("here"))
suppressWarnings(library("SqlRender"))
suppressWarnings(suppressPackageStartupMessages(library("dplyr")))

patientlist_location <- list.files(here("FROM_DCC"), pattern = "hfco_participants.csv" )
patientlist <- read.csv(here("FROM_DCC",patientlist_location), stringsAsFactors = F, 
                        colClasses =c("linkid"="character", "site"="character", "index_site"="character", 
                                      "inclusion" = "numeric", "exclusion" = "numeric"))
result <- tryCatch({
  
  conn <- getNewDBConnection()
  
  cat("Loading index_site data from DCC...\n")
  tempResult1 <- run_db_query(db_conn=conn, query_text="DROP TABLE IF EXISTS #hfco_participants;")
  DatabaseConnector::insertTable(connection = conn, data = patientlist, tableName = "#hfco_participants", tempTable=T)
  
}, error = function(err) {
  stop(err)
}, finally = function(){
  tryCatch({DBI::dbDisconnect(conn)})
})

hfco_query <- "
  SELECT p.linkid
  	,s.session_id
  	,s.programid
  	,program_name
  	,session_date
  FROM #hfco_participants p
  LEFT JOIN @SCHEMA.@LINK l ON p.linkid = l.@LINK_ID_COLUMN_VALUE
  LEFT JOIN @SCHEMA.@SESSION s ON s.@PERSON_ID_PATID = l.@PERSON_ID_PATID
  LEFT JOIN @SCHEMA.@PROGRAM pr ON pr.programid = s.programid
  WHERE s.session_date >= '1/1/2017'
  ORDER BY p.linkid, s.session_date DESC
  "
tryCatch({
  hfco_result <- run_db_query_andromeda(db_conn=conn, query_text = hfco_query, andromedaTableName = "hfco_participants")
  writeOutput_andromeda("hfco_participant_result", hfco_result, andromedaTableName = "hfco_participants")
}, finally = {
  Andromeda::close(step_3_result)
})

message(paste0("CODI Step ", CODISTEP, " done!"))
