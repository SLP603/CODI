###################### Description #######################
# DCC code for reconciling demographic variables
# Reads in CSVs from data partners,
# reconciles DOB, sex, race, ethnicity based on (in order):
# 1. majority
# 2. most encounter counts
# 3. random site
#
# send csv of reconciled variables per linkid

options(scipen=999) # prevent scientific notation

library(dplyr)
library(tidyr)
library(readr)
library(here)
library(utils)

setwd(".")

#actual read csv, modify file paths as needed
stepOnePartnerFiles <- list.files(path="./partner_step_1_out", pattern="*.csv", full.names=TRUE, recursive=FALSE)

participants <- list()
participantsData <- list()

for(partner in stepOnePartnerFiles){
  pattern <- "study_cohort_demographic_\\s*(.*?)\\s*.csv$"
  partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
  study_cohort_demographic_temp <- read.csv(partner, na = "NULL")

  demo_enc_vital_temp <- dplyr::mutate(study_cohort_demographic_temp, site = partner_id) %>%
    select(linkid, birth_date, sex, race, hispanic, yr, encN, site, loc_start)

  assign(paste0("demo_enc_vital_", toupper(partner_id)), demo_enc_vital_temp)
  participantsData[[partner_id]] <- demo_enc_vital_temp

  if (length(participants) > 0){
    participants <- c(participants, partner_id)
  } else {
    participants <- list(partner_id)
  }
}

# merge into one tibble
demo_enc_vital_prep <- bind_rows(participantsData)

# convert to proper classes
demo_enc_vital_prep$linkid <- as.numeric(demo_enc_vital_prep$linkid)
demo_enc_vital_prep$birth_date <- as.Date(demo_enc_vital_prep$birth_date)

demo_enc_vital_prep$race[demo_enc_vital_prep$race == "NULL"] <- NA
#demo_enc_vital_prep$race <- as.numeric(demo_enc_vital_prep$race)

demo_enc_vital_prep$yr <- as.numeric(demo_enc_vital_prep$yr)
demo_enc_vital_prep$loc_start <- as.Date(demo_enc_vital_prep$loc_start)
demo_enc_vital_prep$encN <- as.numeric(demo_enc_vital_prep$encN)


demo_enc_vital_prep_link <- demo_enc_vital_prep %>%
  group_by(linkid, site) %>%
  dplyr::mutate(sum_encn = sum(encN))

#preserve demo variables plus linkids, patikds
demo_link <- demo_enc_vital_prep_link %>% select(linkid, site, birth_date, sex, race, hispanic, sum_encn) %>% arrange(linkid)

# keep unique rows
demo_link_u <- unique(demo_link)

demo_enc_vital <- demo_link_u

length(unique(demo_link$linkid))
length(unique(demo_link_u$linkid))

# BD majority, then enc
demo_enc_vital_bd <- demo_enc_vital %>%
  group_by(linkid) %>%
  dplyr::count(birth_date) %>%
  slice_max(n, n = 1) # has ties?

dev_bd_join <- left_join(demo_enc_vital, demo_enc_vital_bd, by = c("linkid", "birth_date")) # join back

demo_enc_vital_bd_recon <- dev_bd_join %>%
  group_by(linkid) %>%
  arrange(linkid, n, desc(sum_encn)) %>%
  select(linkid, birth_date, sum_encn, n) %>%
  slice_max(n, n = 1) %>%
  slice_max(sum_encn, n = 1) # break ties with sum_encn

demo_enc_vital_bd_recon_final_prep <- demo_enc_vital_bd_recon[!duplicated(demo_enc_vital_bd_recon),]

# roll random site for each linkid
set.seed(1492)
demo_enc_vital_bd_recon_final <- sample_n(demo_enc_vital_bd_recon_final_prep, 1, replace = TRUE)

# Sex majority, then enc
demo_enc_vital_sex <- demo_enc_vital %>%
  group_by(linkid) %>%
  dplyr::count(sex) %>%
  slice_max(n, n = 1) # has ties?

dev_sex_join <- left_join(demo_enc_vital, demo_enc_vital_sex, by = c("linkid", "sex")) # join back

demo_enc_vital_sex_recon <- dev_sex_join %>%
  group_by(linkid) %>%
  arrange(linkid, n, desc(sum_encn)) %>%
  select(linkid, sex, sum_encn, n) %>%
  slice_max(n, n = 1) %>%
  slice_max(sum_encn, n = 1) # break ties with sum_encn

demo_enc_vital_sex_recon_final_prep <- demo_enc_vital_sex_recon[!duplicated(demo_enc_vital_sex_recon),]

# roll random site for each linkid
set.seed(1492)
demo_enc_vital_sex_recon_final <- sample_n(demo_enc_vital_sex_recon_final_prep, 1, replace = TRUE)

# Race majority, then enc
demo_enc_vital_race <- demo_enc_vital %>%
  group_by(linkid) %>%
  dplyr::count(race) %>%
  slice_max(n, n = 1) # has ties?

dev_race_join <- left_join(demo_enc_vital, demo_enc_vital_race, by = c("linkid", "race")) # join back

demo_enc_vital_race_recon <- dev_race_join %>%
  group_by(linkid) %>%
  arrange(linkid, n, desc(sum_encn)) %>%
  select(linkid, race, sum_encn, n) %>%
  slice_max(n, n = 1) %>%
  slice_max(sum_encn, n = 1) # break ties with sum_encn

demo_enc_vital_race_recon_final_prep <- demo_enc_vital_race_recon[!duplicated(demo_enc_vital_race_recon),]

# roll random site for each linkid
set.seed(1492)
demo_enc_vital_race_recon_final <- sample_n(demo_enc_vital_race_recon_final_prep, 1, replace = TRUE)


# test
identical(demo_enc_vital %>% group_by(linkid) %>% dplyr::count(race) %>% slice_max(n, n = 1),
          demo_enc_vital_race_recon_final %>% select(linkid, race, n))


# hispanic majority, then enc
demo_enc_vital_hispanic <- demo_enc_vital %>%
  group_by(linkid) %>%
  dplyr::count(hispanic) %>%
  slice_max(n, n = 1) # has ties?

dev_hispanic_join <- left_join(demo_enc_vital, demo_enc_vital_hispanic, by = c("linkid", "hispanic")) # join back

demo_enc_vital_hispanic_recon <- dev_hispanic_join %>%
  group_by(linkid) %>%
  arrange(linkid, n, desc(sum_encn)) %>%
  select(linkid, hispanic, sum_encn, n, site) %>%
  slice_max(n, n = 1) %>%
  slice_max(sum_encn, n = 1) # break ties with sum_encn

demo_enc_vital_hispanic_recon_final_prep <- demo_enc_vital_hispanic_recon[!duplicated(demo_enc_vital_hispanic_recon),]

# roll random site for each linkid
set.seed(1492)
demo_enc_vital_hispanic_recon_final <- sample_n(demo_enc_vital_hispanic_recon_final_prep, 1, replace = TRUE)

### check

identical(demo_enc_vital %>% group_by(linkid) %>% dplyr::count(hispanic) %>% slice_max(n, n = 1),
          demo_enc_vital_hispanic_recon_final %>% select(linkid, hispanic, n))


# final merge of recon vars
demo_enc_vital_recon <- demo_enc_vital_bd_recon_final %>%
  left_join(demo_enc_vital_sex_recon_final, by = "linkid") %>% arrange(linkid) %>%
  left_join(demo_enc_vital_race_recon_final, by = "linkid") %>% arrange(linkid) %>%
  left_join(demo_enc_vital_hispanic_recon_final, by = "linkid") %>% arrange(linkid) %>%
  select(linkid, birth_date, sex, race, hispanic)
demo_enc_vital_recon %>% View()

length(unique(demo_enc_vital_prep$linkid))
length(unique(demo_enc_vital_recon$linkid))

dir.create(file.path("./DCC_out"), showWarnings = FALSE)

# write output to csv for site to read in
write.csv(demo_enc_vital_recon,
          file = "DCC_out/demo_recon.csv",
          na = "NULL",
          row.names = FALSE)


demo_loc_prep <- demo_enc_vital_prep %>% select(linkid, site, yr, loc_start)

demo_loc_prep %>% group_by(linkid, yr) %>%
  arrange(linkid, yr, desc(loc_start)) %>% View()
# for each LINKID, keeps last address date per CY
demo_loc_prep_tie <- demo_loc_prep %>% group_by(linkid, yr) %>%
  arrange(linkid, yr, desc(loc_start)) %>%
  slice_max(loc_start, n = 1)

# roll random site for each linkid
set.seed(1492)
demo_loc <- sample_n(demo_loc_prep_tie, 1, replace = TRUE)

demo_loc %>% View()

# preserve demo_loc up to this point
demo_loc_norm <- demo_loc

# keep ties for now, also keeps LINKIDs that have at least 1 address
# demo_loc <- demo_loc_prep_tie

length(unique(demo_loc$linkid)) *3

demo_recon_loc <- left_join(demo_enc_vital_recon, demo_loc_norm, by = "linkid")

demo_recon_loc %>% View()
demo_recon_loc %>% filter(is.na(yr)) %>% arrange(linkid) %>% View()

dir.create(file.path("./output"), showWarnings = FALSE)

for(returnPartner in participants){
  demo_recon_loc_temp <- demo_recon_loc %>% filter(site == returnPartner) %>% select(linkid, site, yr)
  write.csv(demo_recon_loc_temp, file = paste0("./output/demo_recon_loc_", returnPartner, ".csv"), na = "", row.names = F)
}

