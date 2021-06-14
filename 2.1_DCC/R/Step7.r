#Steps 7 and 8 are combined in one file
library(tidyr)
library(readr)
library(eeptools)

#for growthcleanr
library(remotes)
library(data.table)
library(foreach)
library(doParallel)
library(Hmisc)
library(bit64)

#remotes::install_github("carriedaymont/growthcleanr", INSTALL_opts=c("--no-multiarch"))
library(growthcleanr)

library(dplyr)

options(scipen=999)

# read csv, matched_data
matched_data <- read_csv("output/matched_data.csv", na = "NULL")

# read csv, cohort_demographic
cohort_demographic <- read_csv("output/demo_index_site_final.csv", na = "NULL")

# read csv, demo_bd_sex_recon for growthcleanr
demo_bd_sex_recon <- read_csv("output/demo_bd_sex_recon.csv", na = "NULL")

Outcome_Vitals_PartnerFiles <- list.files(path="./partner_step_6_out", pattern="OUTCOME_VITALS_*.csv", full.names=TRUE, recursive=FALSE)
Outcome_Lab_Results_PartnerFiles <- list.files(path="./partner_step_6_out", pattern="OUTCOME_LAB_RESULTS_*.csv", full.names=TRUE, recursive=FALSE)
Exposure_Dose_PartnerFiles <- list.files(path="./partner_step_6_out", pattern="EXPOSURE_DOSE_*.csv", full.names=TRUE, recursive=FALSE)
HF_Participants_PartnerFiles <- list.files(path="./partner_step_6_out", pattern="HF_PARTICIPANTS_*.csv", full.names=TRUE, recursive=FALSE)
ADI_Out_PartnerFiles <- list.files(path="./partner_step_6_out", pattern="ADI_OUT_*.csv", full.names=TRUE, recursive=FALSE)
Diet_Nutr_Enc_PartnerFiles <- list.files(path="./partner_step_6_out", pattern="DIET_NUTR_ENC_*.csv", full.names=TRUE, recursive=FALSE)

# read csv, measures_output
for(partner in Outcome_Vitals_PartnerFiles){
  cat(paste0("loading partner file: ", partner,"\n"))
  pattern <- "OUTCOME_VITALS_\\s*(.*?)\\s*.csv$"
  partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
  Outcome_Vitals_temp <- read.csv(partner, na = "NULL")
  #assign(paste0("Outcome_Vitals_", toupper(partner_id)), Outcome_Vitals_temp)
  measures_outputData[[partner_id]] <- Outcome_Vitals_temp
}

measures_output <- bind_rows(measures_outputData)

# read csv, OUTCOME_LAB_RESULTS
for(partner in Outcome_Lab_Results_PartnerFiles){
  cat(paste0("loading partner file: ", partner,"\n"))
  pattern <- "OUTCOME_LAB_RESULTS_\\s*(.*?)\\s*.csv$"
  partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
  Outcome_Lab_Results_temp <- read.csv(partner, na = "NULL")
  #assign(paste0("Outcome_Lab_", toupper(partner_id)), Outcome_Lab_Results_temp)
  OUTCOME_LAB_RESULTS_Data[[partner_id]] <- demo_enc_vital_temp
}

OUTCOME_LAB_RESULTS <- rbind(OUTCOME_LAB_RESULTS_Data)

# read csv, EXPOSURE_DOSE
for(partner in Exposure_Dose_PartnerFiles){
  cat(paste0("loading partner file: ", partner,"\n"))
  pattern <- "EXPOSURE_DOSE_\\s*(.*?)\\s*.csv$"
  partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
  Exposure_Dose_temp <- read.csv(partner, na = "NULL")
  #assign(paste0("PSM_matched_data_", toupper(partner_id)), Exposure_Dose_temp)
  EXPOSURE_DOSE_Data[[partner_id]] <- demo_enc_vital_temp
}

EXPOSURE_DOSE <- rbind(EXPOSURE_DOSE_Data)

# read csv, HF_PARTICIPANTS
for(partner in HF_Participants_PartnerFiles){
  cat(paste0("loading partner file: ", partner,"\n"))
  pattern <- "HF_PARTICIPANTS_\\s*(.*?)\\s*.csv$"
  partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
  HF_Participants_temp <- read.csv(partner, na = "NULL")
  #assign(paste0("HF_Participants_", toupper(partner_id)), HF_Participants_temp)
  HF_PARTICIPANTS_Data[[partner_id]] <- HF_Participants_temp
}

HF_PARTICIPANTS <- rbind(HF_PARTICIPANTS_Data)

# read csv, ADI_OUT
for(partner in ADI_Out_PartnerFiles){
  cat(paste0("loading partner file: ", partner,"\n"))
  pattern <- "ADI_OUT_\\s*(.*?)\\s*.csv$"
  partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
  ADI_Out_temp <- read.csv(partner, na = "NULL")
  #assign(paste0("ADI_Out_", toupper(partner_id)), ADI_Out_temp)
  ADI_OUR_Data[[partner_id]] <- ADI_Out_temp
}

ADI_OUT <- rbind(ADI_OUT_Data)

# read csv, DIET_NUTR_ENC
for(partner in Diet_Nutr_Enc_PartnerFiles){
  cat(paste0("loading partner file: ", partner,"\n"))
  pattern <- "DIET_NUTR_ENC_\\s*(.*?)\\s*.csv$"
  partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
  Diet_Nutr_Enc_temp <- read.csv(partner, na = "NULL")
  #assign(paste0("Diet_Nutr_Enc_", toupper(partner_id)), Diet_Nutr_Enc_temp)
  DIET_NUTR_ENC_Data[[partner_id]] <- ADI_Out_temp
}

DIET_NUTR_ENC <- rbind(DIET_NUTR_ENC_Data)

# for merging and printing out
cohort_demographic_u <- cohort_demographic %>% unique()

cohort_demographic_u <- left_join(matched_data, cohort_demographic_u, by = 'linkid')


# convert to match growthcleanr format
demo_bd_sex_recon$sex[demo_bd_sex_recon$sex == "F"] <- 1
demo_bd_sex_recon$sex[demo_bd_sex_recon$sex == "M"] <- 0

# left join ht weights with age, sex, (USE RECON demo HERE)
measures_demo <- left_join(measures_output, demo_bd_sex_recon, by = "linkid")


# calculate age in days from birth date to measurement date
measures_demo$agedays <- as.numeric(difftime(measures_demo$measure_date, 
                                             measures_demo$birth_date, 
                                             units = "days")) 

# convert height from inches to CM
measures_demo$HEIGHTCM <- measures_demo$ht * 2.54

# convert weight from pounds to Kg
measures_demo$WEIGHTKG <- measures_demo$wt * 0.45359237

# convert wide to long
measures_demo_long <- gather(measures_demo, param, measurement, c(HEIGHTCM, WEIGHTKG), factor_key = TRUE)

# prep for growthcleanr
measures_demo_long <- as.data.table(measures_demo_long)
setkey(measures_demo_long, linkid, param, agedays)

# clean measurements, creates new column for whether to include measurement
cleaned_measures_demo_long <- measures_demo_long[, clean_value:=
                                                   cleangrowth(linkid, param, agedays, sex, measurement,
                                                               parallel = T)]


# write to file all outputs
# cohort_demo 
cohort_demo <- cohort_demographic_u %>% select(linkid, birth_date, sex, race, hispanic, in_study_cohort) %>% 
  mutate(age = floor(age_calc(birth_date, enddate = as.Date("2017-01-01"), units = "years")),
         study = in_study_cohort) %>% 
  select(linkid, birth_date, age, sex, race, hispanic, study)

# convert to output format
cohort_demo$study[cohort_demo$study == 0] <- 2

write_csv(cohort_demo, path = "output/cohort_demo.csv")

# cleaned_measures_demo_long
write_csv(cleaned_measures_demo_long, path = "output/measures_output_cleaned.csv")

# OUTCOME_LAB_RESULTS
write_csv(OUTCOME_LAB_RESULTS, path = "output/OUTCOME_LAB_RESULTS.csv")

# EXPOSURE_DOSE
write_csv(EXPOSURE_DOSE, path = "output/EXPOSURE_DOSE.csv")

# HF_PARTICIPANTS
write_csv(HF_PARTICIPANTS, path = "output/HF_PARTICIPANTS.csv")

# ADI_OUT
write_csv(ADI_OUT, path = "output/ADI_OUT.csv")

# DIET_NUTR_ENC
write_csv(DIET_NUTR_ENC, path = "output/DIET_NUTR_ENC.csv")

cohort_demo %>% group_by(linkid)
cleaned_measures_demo_long %>% group_by(linkid)
OUTCOME_LAB_RESULTS %>% group_by(linkid)
EXPOSURE_DOSE %>% group_by(linkid) # this has more IDs than demo
HF_PARTICIPANTS %>% group_by(linkid)
ADI_OUT %>% group_by(linkid)
DIET_NUTR_ENC %>% group_by(linkid)

