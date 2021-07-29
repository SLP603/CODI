
suppressWarnings(library("DBI"))
suppressWarnings(library("here"))
suppressWarnings(library("SqlRender"))
suppressWarnings(suppressPackageStartupMessages(library("dplyr")))

patientlist_location <- list.files(here("FROM_DCC"), pattern = "hfco_participants.csv" )
patientlist <- read.csv(here("FROM_DCC",patientlist_location), stringsAsFactors = F, 
                        colClasses =c("linkid"="character"))
result <- tryCatch({
  
  conn <- getNewDBConnection()
  
  cat("Loading index_site data from DCC...\n")
  tempResult1 <- run_db_query(db_conn=conn, query_text="DROP TABLE IF EXISTS ##hfco_participants;")
  DatabaseConnector::insertTable(connection = conn, data = patientlist, tableName = "##hfco_participants", tempTable=T)

  hfco_query <- "
    SELECT p.linkid
    	,s.sessionid
    	,s.programid
    	,program_name
    	,session_date
    FROM ##hfco_participants p
    LEFT JOIN @SCHEMA.@LINK l ON p.linkid = l.@LINKID_COLUMN_VALUE
    LEFT JOIN @SCHEMA.@SESSION s ON s.@PERSON_ID_PATID = l.@PERSON_ID_PATID
        AND s.session_date >= '1/1/2017'
    LEFT JOIN @SCHEMA.@PROGRAM pr ON pr.programid = s.programid
    ORDER BY p.linkid, s.session_date DESC;"
  hfco_query <- renderSqlText(query_text = hfco_query, render = T)
  andromeda <- Andromeda::andromeda()
  hfco_result <- DatabaseConnector::querySqlToAndromeda(connection = conn, 
                                                        sql = SqlRender::splitSql(hfco_query)[[2]], 
                                                        andromeda = andromeda,
                                                        snakeCaseToCamelCase = F,
                                                        andromedaTableName = "hfco_participants")
}, error = function(err) {
  stop(err)
}, finally = function(){
  tryCatch({DBI::dbDisconnect(conn)})
})

tryCatch({
  dir.create(here("output", paste0("Step_", CODISTEP)), showWarnings = F, recursive = T)
  writeOutput_andromeda("hfco_participant_result", hfco_result, andromedaTableName = "hfco_participants")
}, finally = {
  tryCatch({Andromeda::close(hfco_result)})
})

message(paste0("CODI Step ", CODISTEP, " done!"))
