############################ Description #############################
# DCC code for combining matched IDs from 2.1.4
#
library(dplyr)
library(readr)

options(scipen=999)

stepFivePartnerFiles <- list.files(path="./partner_step_5_out", pattern="*.csv", full.names=TRUE, recursive=FALSE)

for(partner in stepFivePartnerFiles){
  cat(paste0("loading partner file: ", partner,"\n"))
  pattern <- "PSM_matched_data_\s*(.*?)\\s*.csv$"
  partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
  PSM_matched_data_temp <- read.csv(partner, na = "NULL")
  
  PSM_matched_data_temp <- mutate(PSM_matched_data_temp, index_site = partner_id)

  assign(paste0("PSM_matched_data_", toupper(partner_id)), PSM_matched_data_temp)
  participantsData[[partner_id]] <- demo_enc_vital_temp

  if (length(participants) > 0){
    participants <- c(participants, partner_id)
  } else {
    participants <- list(partner_id)
  }
}

PSM_matched_data <- bind_rows(participantsData)

matched_data <- PSM_matched_data %>% group_by(linkid) %>% select(linkid, in_study_cohort, index_site)


# write out to DCC_out
write_csv(matched_data, path = "output/matched_data.csv")