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

Outcome_Vitals_PartnerFiles <- list.files(path="./partner_step_6_out", pattern="OUTCOME_VITALS_*", full.names=TRUE, recursive=FALSE, ignore.case = T)
Outcome_Lab_Results_PartnerFiles <- list.files(path="./partner_step_6_out", pattern="OUTCOME_LAB_RESULTS_*", full.names=TRUE, recursive=FALSE, ignore.case = T)
Exposure_Dose_PartnerFiles <- list.files(path="./partner_step_6_out", pattern="EXPOSURE_DOSE_*", full.names=TRUE, recursive=FALSE, ignore.case = T)
HF_Participants_PartnerFiles <- list.files(path="./partner_step_6_out", pattern="HF_PARTICIPANTS_*", full.names=TRUE, recursive=FALSE, ignore.case = T)
ADI_Out_PartnerFiles <- list.files(path="./partner_step_6_out", pattern="ADI_OUT_*", full.names=TRUE, recursive=FALSE, ignore.case = T)
Diet_Nutr_Enc_PartnerFiles <- list.files(path="./partner_step_6_out", pattern="DIET_NUTR_ENC_*", full.names=TRUE, recursive=FALSE, ignore.case = T)

measures_outputData <- list()
OUTCOME_LAB_RESULTS_Data <- list()
EXPOSURE_DOSE_Data <- list()
HF_PARTICIPANTS_Data <- list()
ADI_OUT_Data <- list()
DIET_NUTR_ENC_Data <- list()

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
  Outcome_Lab_Results_temp <- readr::read_csv(partner, na = "NULL", col_types = cols(.default = "c"))
  #assign(paste0("Outcome_Lab_", toupper(partner_id)), Outcome_Lab_Results_temp)
  OUTCOME_LAB_RESULTS_Data[[partner_id]] <- Outcome_Lab_Results_temp
}

OUTCOME_LAB_RESULTS <- bind_rows(OUTCOME_LAB_RESULTS_Data)

# read csv, EXPOSURE_DOSE
for(partner in Exposure_Dose_PartnerFiles){
  cat(paste0("loading partner file: ", partner,"\n"))
  pattern <- "EXPOSURE_DOSE_\\s*(.*?)\\s*.csv$"
  partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
  Exposure_Dose_temp <- readr::read_csv(partner, na = "NULL", col_types = cols(.default = "c"))
  #assign(paste0("PSM_matched_data_", toupper(partner_id)), Exposure_Dose_temp)
  EXPOSURE_DOSE_Data[[partner_id]] <- Exposure_Dose_temp
}

EXPOSURE_DOSE <- bind_rows(EXPOSURE_DOSE_Data)

## HFCO did not have data for 2017 so was only used to document any participation.  Individual sites don't have this
## participant data so it's obtained by submitting a list of all linkids used in query to DH then they put
## a query through their HFCO datamart to determine who is a participant based on the HFCO participant query from
## step 6.
# read csv, HF_PARTICIPANTS
##for(partner in HF_Participants_PartnerFiles){
##  cat(paste0("loading partner file: ", partner,"\n"))
##  pattern <- "HF_PARTICIPANTS_\\s*(.*?)\\s*.csv$"
##  partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
##  HF_Participants_temp <- read.csv(partner, na = "NULL")
##  #assign(paste0("HF_Participants_", toupper(partner_id)), HF_Participants_temp)
##  HF_PARTICIPANTS_Data[[partner_id]] <- HF_Participants_temp
##}

hfco_data<-readr::read_csv(HF_Participants_PartnerFiles[1], na="NULL", col_types = cols(.default = "c"))
HF_PARTICIPANTS <- hfco_data[ which(hfco_data$sessionid !='NULL'),]
##HF_PARTICIPANTS <- rbind(HF_PARTICIPANTS_Data)

# read csv, ADI_OUT
for(partner in ADI_Out_PartnerFiles){
  cat(paste0("loading partner file: ", partner,"\n"))
  pattern <- "ADI_OUT_\\s*(.*?)\\s*.csv$"
  partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
  ADI_Out_temp <- readr::read_csv(partner, na = "NULL", col_types = cols(.default = "c"))
  #assign(paste0("ADI_Out_", toupper(partner_id)), ADI_Out_temp)
  ADI_OUT_Data[[partner_id]] <- ADI_Out_temp
}

ADI_OUT <- bind_rows(ADI_OUT_Data)

# read csv, DIET_NUTR_ENC
for(partner in Diet_Nutr_Enc_PartnerFiles){
  cat(paste0("loading partner file: ", partner,"\n"))
  pattern <- "DIET_NUTR_ENC_\\s*(.*?)\\s*.csv$"
  partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
  Diet_Nutr_Enc_temp <- readr::read_csv(partner, na = "NULL",col_types = cols(.default = "c"))
  #assign(paste0("Diet_Nutr_Enc_", toupper(partner_id)), Diet_Nutr_Enc_temp)
  DIET_NUTR_ENC_Data[[partner_id]] <- Diet_Nutr_Enc_temp
}

DIET_NUTR_ENC <- bind_rows(DIET_NUTR_ENC_Data)

# for merging and printing out
cohort_demographic_u <- cohort_demographic %>% unique()

cohort_demographic_u <- left_join(matched_data, cohort_demographic_u, by = 'linkid')


# convert to match growthcleanr format
cohort_demographic_bday <- cohort_demographic_u %>% select(linkid, birth_date, sex) %>% unique()

# left join ht weights with age, sex, (USE RECON demo HERE)
measures_demo_bday <- left_join(measures_output, cohort_demographic_bday, by = "linkid") %>% unique()
demo_bd_sex_recon_sans_bday <- demo_bd_sex_recon %>% select(linkid, sex)
measures_demo <- left_join(measures_demo_bday, demo_bd_sex_recon_sans_bday, by = "linkid") %>% unique()

measures_demo$sex <- with(measures_demo, coalesce(sex.x, sex.y))
measures_demo <- select(measures_demo, linkid, admit_date, enc_type, measure_date, ht, wt, bmi, diastolic, systolic, birth_date, sex)

measures_demo$sex[measures_demo$sex == "F"] <- 1
measures_demo$sex[measures_demo$sex == "M"] <- 0

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
# If ages are missing the program will fail.  If sex is missing it will only show as "missing"
cleaned_measures_demo_long <- measures_demo_long[, clean_value:= cleangrowth(linkid, param, agedays, sex, measurement, quietly = F, parallel = T, num.batches = 6)]

# write to file all outputs
# cohort_demo 
cohort_demo <- cohort_demographic_u %>% select(linkid, birth_date, sex, race, hispanic, in_study_cohort) %>% 
  mutate(age = floor(age_calc(birth_date, enddate = as.Date("2017-01-01"), units = "years")),
         study = in_study_cohort) %>% 
  select(linkid, birth_date, age, sex, race, hispanic, study)

# convert to output format
cohort_demo$study[cohort_demo$study == 0] <- 2

write_csv(cohort_demo, file = "output/cohort_demo.csv")

# cleaned_measures_demo_long
write_csv(cleaned_measures_demo_long, file = "output/measures_output_cleaned.csv")

# OUTCOME_LAB_RESULTS
write_csv(as.data.frame(OUTCOME_LAB_RESULTS), file = "output/OUTCOME_LAB_RESULTS.csv")

# EXPOSURE_DOSE
write_csv(as.data.frame(EXPOSURE_DOSE), file = "output/EXPOSURE_DOSE.csv")

# HF_PARTICIPANTS
write_csv(as.data.frame(HF_PARTICIPANTS), file = "output/HF_PARTICIPANTS.csv")

# ADI_OUT
write_csv(as.data.frame(ADI_OUT), file = "output/ADI_OUT.csv")

# DIET_NUTR_ENC
write_csv(as.data.frame(DIET_NUTR_ENC), file = "output/DIET_NUTR_ENC.csv")

cohort_demo %>% group_by(linkid)
cleaned_measures_demo_long %>% group_by(linkid)
OUTCOME_LAB_RESULTS %>% group_by(linkid)
EXPOSURE_DOSE %>% group_by(linkid) # this has more IDs than demo
HF_PARTICIPANTS %>% group_by(linkid)
ADI_OUT %>% group_by(linkid)
DIET_NUTR_ENC %>% group_by(linkid)

