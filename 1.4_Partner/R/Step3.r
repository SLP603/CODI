
suppressWarnings(library("DBI"))
suppressWarnings(library("here"))
suppressWarnings(library("SqlRender"))
suppressWarnings(suppressPackageStartupMessages(library("dplyr")))

if (DATAMODEL == "CHORDSVDW") {
	sqlType <- "CHORDSVDW"
} else if (DATAMODEL == "CODIVDW"){
	sqlType <- "CODIVDW"
} else {
	stop("DATAMODEL not found or missing.  Check the DATAMODEL variable in Setup.r")
}

snomed2icd <- read.csv(here("csv", "snomed2icd.csv"), stringsAsFactors = F) %>%
  mutate_all(as.character)

result <- tryCatch({
  
  conn <- getNewDBConnection()
  tempResult <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType, "snomed2icd.sql"))
  dbWriteTable(conn, "#snomed2icd", snomed2icd, immediate = T, row.names=F, overwrite=T)
  
}, error = function(err) {
  stop(err)
}, finally = function(){
  tryCatch({DBI::dbDisconnect(conn)})
})

dir.create(here(paste0("Step", CODISTEP), "output"), showWarnings = F)

message(paste0("CODI Step ", CODISTEP, " done!"))
