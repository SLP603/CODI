
suppressWarnings(suppressPackageStartupMessages(library("DatabaseConnector")))
suppressWarnings(library("SqlRender"))
suppressWarnings(suppressPackageStartupMessages(library("dplyr")))
suppressWarnings(suppressPackageStartupMessages(library("Andromeda")))
options(andromedaTempFolder = here("AndromedaTemp"))

getConnectionString <- function(){
  
  connectionString <- "jdbc:sqlserver://"
  
  if(ServerName == "" || DatabaseName == ""){
    stop("Server name or database name is empty.  Check the Setup.r file")
  }
  
  if(nchar(PortNumber) > 0) {
    connectionString <- paste0(connectionString, ServerName, ":", PortNumber, ";databaseName=", DatabaseName, ";")
  }
  else{
    connectionString <- paste0(connectionString, ServerName, ";databaseName=", DatabaseName, ";")
  }
  
  if(nchar(SQLServerUserName) > 0){
    connectionString <- paste0(connectionString, "user=", SQLServerUserName,";password=", SQLServerPassword, ";")
  } 
  else {
    connectionString <- paste0(connectionString, "integratedSecurity=true")
  }
  
  if(nchar(extraSettings) > 0) {
    connectionString <- paste0(connectionString, ";", extraSettings, ";")
  }
  
  
  
  return(connectionString)
}

getNewDBConnection <- function(){
  if(length(dir(path = file.path(dirname(here()), "SqlServerDriver"), pattern = "*.jar")) ==0){
    DatabaseConnector::downloadJdbcDrivers("sql server", file.path(dirname(here()), "SqlServerDriver"))
    Sys.setenv("PATH_TO_AUTH_DLL" = file.path(dirname(here()), "SqlServerDriver"))
  }
  connection_string <- getConnectionString()
  connectionDetails <- createConnectionDetails(dbms = "sql server", connectionString = connection_string, pathToDriver = file.path(dirname(here()), "SqlServerDriver"))
  db_conn <-connect(connectionDetails)
  return(db_conn)
}

run_db_query_andromeda <- function(db_conn = NULL, query_text = NULL, renderSql = T, sql_location = NULL, andromedaTableName = NULL, ...){
  if (is.null(query_text) && is.null(sql_location)) {
    stop("No query argument or file location was passed to function")
  }
  if(is.null(query_text) && !is.null(sql_location)){
    print(paste0("Reading Sql From ", sql_location))
    query_text = readSql(here(sql_location))
  }
  if(is.null(andromedaTableName)){
    stop("Andromeda table name must be set to return correct output")
  }
  
  tryCatch({
    if (!is.null(db_conn)){
      andromeda <- Andromeda::andromeda()
      sqlResult <- DatabaseConnector::querySqlToAndromeda(snakeCaseToCamelCase = F,connection = db_conn, sql = query_text, andromeda = andromeda, andromedaTableName = andromedaTableName)
    }
  }, error = function(err){
    cat(query_text)
    cat("\r\n")
    stop(err)
  })
  return(sqlResult);
}

run_db_query <- function(db_conn = NULL, query_text = NULL, renderSql = T, sql_location = NULL, ...) {
  if (is.null(query_text) && is.null(sql_location)) {
    stop("No query argument or file location was passed to function")
  }
  if(is.null(query_text) && !is.null(sql_location)){
    print(paste0("Reading Sql From ", sql_location))
    query_text = readSql(here(sql_location))
  }

  rendered_sql_query <- renderSqlText(query_text = query_text, render = renderSql)
  tryCatch({
    if (!is.null(db_conn)){
      #lowSqlResult <- DBI::dbGetQuery(conn = db_conn, statement = rendered_sql_query, immediate = TRUE)
      lowSqlResult <- DatabaseConnector::executeSql(connection = db_conn, sql = rendered_sql_query)
      return(lowSqlResult)
    }
  }, error = function(err){
    cat(rendered_sql_query)
    cat("\r\n")
    stop(err)
  })
}

renderSqlText <- function(query_text, render=T){
  query_text <- paste("SET NOCOUNT ON;", query_text, sep="\r\n")
  if (render){
    query_text <- SqlRender::render(sql = query_text,
                                    warnOnMissingParameters = FALSE,
                                    ALERT = ALERT,
                                    ASSET_DELIVERY = ASSET_DELIVERY,
                                    CENSUS_DEMOG = CENSUS_DEMOG,
                                    CENSUS_LOCATION = CENSUS_LOCATION,
                                    COST = COST,
                                    CURRICULUM_COMPONENT = CURRICULUM_COMPONENT,
                                    DEMOGRAPHICS = DEMOGRAPHICS,
                                    DIAGNOSES = DIAGNOSES,
                                    ENCOUNTERS = ENCOUNTERS,
                                    FAMILY_HISTORY = FAMILY_HISTORY,
                                    IDENTIFIER = IDENTIFIER,
                                    IDENTITY_HASH_BUNDLE = IDENTITY_HASH_BUNDLE,
                                    LAB_RESULTS = LAB_RESULTS,
                                    LINK = LINK,
                                    PRESCRIBING = PRESCRIBING,
                                    PROCEDURES = PROCEDURES,
                                    PROGRAM = PROGRAM,
                                    PROVIDER_SPECIALTY = PROVIDER_SPECIALTY,
                                    REFERRAL = REFERRAL,
                                    SESSION = SESSION,
                                    SESSION_ALERT = SESSION_ALERT,
                                    VITAL_SIGNS = VITAL_SIGNS,
                                    SCHEMA = SCHEMA,
                                    PERSON_ID_PATID = PERSON_ID_PATID,
                                    BENEFIT = BENEFIT,
									PartnerID = PartnerID,
									LINKID_COLUMN_VALUE = LINKID_COLUMN_VALUE)
  }
  return(query_text)
}

checkJava <- function(downloadDirectory){
  #checks if rJava can be loaded
  javaInstalled <- try(suppressWarnings(library("rJava")), silent=TRUE)
  if(inherits(javaInstalled, "try-error")){
    if(Sys.info()[["machine"]] =="x86"){
      stop("64 bit Java 1.8 or greater is not installed.  Contact your IT department to install the Java runtime environment")
    }
    if (file.exists(file.path(downloadDirectory, "java_runtime", "bin", "java.exe"))){
      Sys.setenv("JAVA_HOME"=file.path(downloadDirectory, "java_runtime"))
      javaInstalled <- try(suppressWarnings(library("rJava")), silent=TRUE)
      if(inherits(javaInstalled, "try-error")){
        stop("64 bit Java 1.8 or greater is not installed.  Contact your IT department to install the Java runtime environment")
      }
    } else {
      download.file("https://github.com/ACCORDSD2VDEV/CODI_HELPER_FILES/raw/main/java-runtime.zip", file.path(downloadDirectory,"java-runtime.zip"))
      unzip(zipfile = "java-runtime.zip", overwrite = T, exdir = "java_runtime")
      Sys.setenv("JAVA_HOME"=file.path(downloadDirectory, "java_runtime"))
      unlink("java-runtime.zip")
    }
  }
}

writeOutput <- function(fileName, data){
  outputFile <- here("output", paste0("Step_", CODISTEP), paste0(fileName, "_", PartnerID, ".csv"))
  cat(paste0("Writing Results to outputFile:\n\t", outputFile, "\n"))
  write.csv(x = data, 
            file = outputFile, 
            row.names = F, 
            quote = T, na = "NULL")
}

writeOutput_andromeda <- function(fileName, data, andromedaTableName){
  outputFile <- here("output", paste0("Step_", CODISTEP), paste0(fileName, "_", PartnerID, ".csv"))
  if(file.exists(outputFile)){
    file.remove(outputFile)
  }
  cat(paste0("Writing Results to outputFile:\n\t", outputFile, "\n"))
  writeOutputFile <- function(batch, fileName) {
    colnames(batch) <- tolower(colnames(batch))
    suppressWarnings(write.table(x = batch, 
              file = outputFile, 
              row.names = F,
              sep=",",
              quote = T,
              col.names = !file.exists(outputFile),
              append = T, 
              na = "NULL"))
  }
  result <- batchApply(data[[andromedaTableName]], writeOutputFile, fileName, batchSize = 100)
}