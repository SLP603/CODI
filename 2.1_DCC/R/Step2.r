###################### Description #######################
# DCC code for reconciling demographic variables
# Reads in CSVs from data partners,
# reconciles DOB, sex, race, ethnicity based on (in order):
# 1. majority
# 2. most encounter counts
# 3. random site
#
# send csv of reconciled variables per linkid

library(dplyr)
library(tidyr)
library(readr)
library(utils)

setwd(".")

#actual read csv, modify file paths as needed
stepOnePartnerFiles <- list.files(path="./partner_step_1_out", pattern="*.csv", full.names=TRUE, recursive=FALSE)

participants <- list()
participantsData <- list()

for(partner in stepOnePartnerFiles){
  cat(paste0("loading partner file: ", partner,"\n"))
  pattern <- "study_cohort_demographic_\\s*(.*?)\\s*.csv$"
  partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
  study_cohort_demographic_temp <- read.csv(partner, na = "NULL")

  demo_enc_vital_temp <- dplyr::mutate(study_cohort_demographic_temp, site = partner_id) #%>%
    #select(linkid, birth_date, sex, race, hispanic, yr, encN, site, loc_start, inclusion, exclusion)

  assign(paste0("demo_enc_vital_", toupper(partner_id)), demo_enc_vital_temp)
  participantsData[[partner_id]] <- demo_enc_vital_temp

  if (length(participants) > 0){
    participants <- c(participants, partner_id)
  } else {
    participants <- list(partner_id)
  }
}
cat("merge into one tibble\n")
# merge into one tibble
demo_enc_vital_prep <- bind_rows(participantsData)

# merge into one tibble
# demo_enc_vital_prep <- rbind(demo_enc_vital_CH, 
#                              demo_enc_vital_DH, 
#                              demo_enc_vital_GOTR, 
#                              demo_enc_vital_HFC, 
#                              demo_enc_vital_KP)

#demo_enc_vital_prep %>% select(linkid, encN, enc_count) %>% View()

# check inclusion flags across sites
demo_enc_vital_prep %>% select(linkid, site, inclusion) %>% group_by(linkid)

# reconcile inclusion flags across sites
demo_enc_vital_prep <- demo_enc_vital_prep %>% 
  group_by(linkid) %>%
  arrange(linkid, inclusion) %>%
  dplyr::mutate(include = max(inclusion))


# reconcile exclusion flags across sites
demo_enc_vital_prep <- demo_enc_vital_prep %>% 
  group_by(linkid) %>%
  arrange(linkid, inclusion) %>%
  dplyr::mutate(exclude = max(exclusion))

# reconcile the demographics (birth_date, sex) for growthcleanr and export for DCC only
demo_bd_sex <- demo_enc_vital_prep %>% select(linkid, site, encN, birth_date, sex)

demo_bd_sex_prep <- demo_bd_sex %>% 
  group_by(linkid, site) %>%
  dplyr::mutate(sum_encn = sum(encN))


#### BD majority, then enc, then rand ####
demo_bd <- demo_bd_sex_prep %>% 
  group_by(linkid) %>% 
  dplyr::count(birth_date) %>% 
  slice_max(n, n = 1) # has ties?

dev_bd_join <- left_join(demo_bd_sex_prep, demo_bd, by = c("linkid", "birth_date")) # join back

demo_bd_recon <- dev_bd_join %>% 
  group_by(linkid) %>% 
  arrange(linkid, n, desc(sum_encn)) %>% 
  select(linkid, birth_date, sum_encn, n) %>% 
  slice_max(n, n = 1) %>% 
  slice_max(sum_encn, n = 1) # break ties with sum_encn

demo_bd_recon_final_prep <- demo_bd_recon[!duplicated(demo_bd_recon),]

# roll random site for each linkid
set.seed(1492)
demo_bd_recon_final <- sample_n(demo_bd_recon_final_prep, 1, replace = TRUE)



#### Sex majority, then enc, then rand ####
demo_sex <- demo_bd_sex_prep %>% 
  group_by(linkid) %>% 
  dplyr::count(sex) %>% 
  slice_max(n, n = 1) # has ties?

dev_sex_join <- left_join(demo_bd_sex_prep, demo_sex, by = c("linkid", "sex")) # join back

demo_sex_recon <- dev_sex_join %>% 
  group_by(linkid) %>% 
  arrange(linkid, n, desc(sum_encn)) %>% 
  select(linkid, sex, sum_encn, n) %>% 
  slice_max(n, n = 1) %>% 
  slice_max(sum_encn, n = 1) # break ties with sum_encn

demo_sex_recon_final_prep <- demo_sex_recon[!duplicated(demo_sex_recon),]

# roll random site for each linkid
set.seed(1492)
demo_sex_recon_final <- sample_n(demo_sex_recon_final_prep, 1, replace = TRUE)


# final merge of recon vars 
demo_bd_sex_recon <- left_join(demo_bd_recon_final, demo_sex_recon_final, by = "linkid") %>% 
  arrange(linkid) %>% 
  select(linkid, birth_date, sex)
#demo_bd_sex_recon %>% View()

#length(unique(demo_enc_vital_prep$linkid))
#length(unique(demo_bd_sex_recon$linkid))

# write output to csv for site to read in
# write.csv(demo_bd_sex_recon, 
#          file = "DCC_out/demo_bd_sex_recon.csv", 
#          na = "NULL",
#          row.names = FALSE)

# check 
# demo_enc_vital_prep %>% select(linkid, site, inclusion, include, exclusion, exclude) %>% group_by(linkid)
# 
# 
# demo_enc_vital_prep %>% select(-inclusion, -exclusion) %>% group_by(linkid)

# join by patid to get linkid
# demo_enc_vital_prep_link <- left_join(demo_enc_vital_prep, codi_link, by = "patid")
demo_enc_vital_prep_link <- demo_enc_vital_prep

demo_enc_vital_prep_link <- demo_enc_vital_prep_link %>% 
  group_by(linkid, site)

#preserve demo variables plus linkids
demo_link <- demo_enc_vital_prep_link %>% 
  select(linkid, site, birth_date, sex, race, hispanic, most_recent_well_child_visit, enc_count, include, exclude) %>% 
  arrange(linkid)

# keep unique rows
demo_link_u <- unique(demo_link)

# there are missing LINKIDs for now (im using 5 sites from excel and SD links), 
# just going to test existing ones for now

demo_enc_vital <- demo_link_u 

demo_enc_vital$linkid[demo_enc_vital$linkid == "NULL"] <- NA

# demo_enc_vital$patid[demo_enc_vital$patid == "NULL"] <- NA

demo_enc_vital$site[demo_enc_vital$site == "NULL"] <- NA

demo_enc_vital$birth_date[is.null(demo_enc_vital$birth_date)] <- NA

demo_enc_vital$sex[demo_enc_vital$sex == "NULL"] <- NA

demo_enc_vital$race[demo_enc_vital$race == "NULL"] <- NA

demo_enc_vital$hispanic[demo_enc_vital$hispanic == "NULL"] <- NA

#demo_enc_vital$most_recent_well_child_visit[demo_enc_vital$most_recent_well_child_visit == "NULL"] <- NA

demo_enc_vital$enc_count[demo_enc_vital$enc_count == "NULL"] <- NA

####################################
### Selecting Index data partner ###
####################################
# Check following in order
#
#####################################################
# 1. if only 1 data partner for id, that one is index
demo_index_site_prep <- demo_enc_vital %>% 
  group_by(linkid) %>% 
  dplyr::mutate(n_distinct_sites = n_distinct(site))


demo_index_site_prep$index_site_1 <- ifelse(demo_index_site_prep$n_distinct_sites == 1 & 
                                              demo_index_site_prep$site != "GOTR" &
                                              demo_index_site_prep$site != "HFC", # if
                                            demo_index_site_prep$site, # then
                                            NA) # else

demo_index_site_prep

# test progress here
table(demo_index_site_prep$index_site_1)
#####################################################################################################################
# 2. if multiple sites, select site based on most recently received well-child check (between 6/1/2016 - 12/31/2019)

cat("select site based on most recently received well-child check\n")
#saves most recent well child visit and ties, warning just means max was checking groups of size 0 where there was no date
demo_index_site_prep_2 <- demo_index_site_prep %>% 
  group_by(linkid) %>% 
  filter(!is.na(most_recent_well_child_visit)) %>% # test here
  slice(which(most_recent_well_child_visit==max(most_recent_well_child_visit, na.rm = TRUE)))

# counts whether linkid has ties in most recent dates
demo_index_site_prep_2 <- demo_index_site_prep_2 %>% 
  group_by(linkid, most_recent_well_child_visit) %>% 
  dplyr::mutate(n_rwcv_date = n()) %>%
  group_by(linkid)


demo_index_site_prep_2$index_site_2 <- ifelse(is.na(demo_index_site_prep_2$index_site_1) & 
                                                demo_index_site_prep_2$n_rwcv_date == 1 &
                                                demo_index_site_prep_2$site != "GOTR" &
                                                demo_index_site_prep_2$site != "HFC", #if
                                              demo_index_site_prep_2$site, # then
                                              NA) # else


demo_index_site_prep_2

# preserve index_site_2 only
demo_index_site_prep_2_site <- select(demo_index_site_prep_2, linkid, index_site_2) %>% 
  group_by(linkid) %>%
  distinct()


cat("merge with prep 1\n")
# merge with prep 1
demo_index_site_prep_2_merged <- left_join(demo_index_site_prep, demo_index_site_prep_2_site, by = "linkid")

# sum(is.na(demo_index_site_prep$index_site_1))
# sum(is.na(demo_index_site_prep_2$index_site_2))

# recent_well_child <- rbind(recent_well_child_CH,
#                            recent_well_child_DH,
#                            recent_well_child_GOTR,
#                            recent_well_child_HFC,
#                            recent_well_child_KP
#                         )

#############################################################################################
# 3. The organization with the greatest number of encounters between 1/1/2017 and 12/31/2017

# length(demo_index_site_prep$patid)
# length(unique(demo_index_site_prep$patid))
# 
# length(demo_index_site_prep$linkid)
# length(unique(demo_index_site_prep$linkid))

#saves max encounters and ties, warning just means max was checking groups of size 0 where there was no date
demo_index_site_prep_3 <- demo_index_site_prep_2_merged %>% 
  group_by(linkid) %>% 
  filter(!is.na(enc_count)) %>% # test here
  slice(which(enc_count==max(enc_count, na.rm = TRUE))) #%>%
#slice(which(is.na(index_site) & is.na(index_site_2) & site != "CH" & site != "DH"))

# counts whether linkid has ties in encounter numbers
demo_index_site_prep_3 <- demo_index_site_prep_3 %>% 
  group_by(linkid, enc_count) %>% 
  dplyr::mutate(n_enc_count = n()) %>%
  group_by(linkid)



demo_index_site_prep_3$index_site_3 <- ifelse((is.na(demo_index_site_prep_3$index_site_1) & 
                                                 is.na(demo_index_site_prep_3$index_site_2) & 
                                                 demo_index_site_prep_3$n_enc_count == 1 &
                                                 demo_index_site_prep_2$site != "GOTR" &
                                                 demo_index_site_prep_2$site != "HFC"), # end of if
                                              demo_index_site_prep_3$site, # then
                                              NA) # else

# preserve index_site_2 only
demo_index_site_prep_3_site <- select(demo_index_site_prep_3, linkid, index_site_3) %>% 
  group_by(linkid) %>%
  distinct()



# merge with prep 2 merged
demo_index_site_prep_3_merged <- left_join(demo_index_site_prep_2_merged, demo_index_site_prep_3_site, by = "linkid")


# 4. if there are still NA for index_site then choose random among available sites, 
# could be due to ties or just no available data for them to break


# keep only NAs for all 3 steps so far
demo_index_site_prep_4 <- demo_index_site_prep_3_merged %>% 
  slice(which(is.na(index_site_1) & is.na(index_site_2) & is.na(index_site_3)))

# keep only id and distinct site
demo_index_site_prep_4_distinct <- demo_index_site_prep_4 %>% 
  select(linkid, site) %>% 
  distinct()

# remove HFC and GOTR from consideration
demo_index_site_prep_4_distinct$site[demo_index_site_prep_4_distinct$site == "GOTR"] <- NA
demo_index_site_prep_4_distinct$site[demo_index_site_prep_4_distinct$site == "HFC"] <- NA
demo_index_site_prep_4_distinct_cs <- demo_index_site_prep_4_distinct[complete.cases(demo_index_site_prep_4_distinct), ]

# roll random site for each linkid
set.seed(1492)
demo_index_site_prep_4_random <- sample_n(demo_index_site_prep_4_distinct_cs, 1, replace = TRUE)

# rename to index_site_4
demo_index_site_prep_4_random <- demo_index_site_prep_4_random %>% select(linkid, index_site_4 = site)

# set.seed(1492)
# test_sample <- sample_n(demo_index_site_prep_4, 1, replace = TRUE)

# merge with prep 3 merged
demo_index_site_prep_4_merged <- left_join(demo_index_site_prep_3_merged, demo_index_site_prep_4_random, by = "linkid")



###########################################################
############# build final index site table ################
###########################################################

cat("build final index site table\n")

demo_index_site <- demo_index_site_prep_4_merged

demo_index_site$index_site <- ifelse(!is.na(demo_index_site$index_site_1), # checks index_site_1
                                     demo_index_site$index_site_1, 
                                     
                                     ifelse(!is.na(demo_index_site$index_site_2), # checks index_site_2
                                            demo_index_site$index_site_2,
                                            
                                            ifelse(!is.na(demo_index_site$index_site_3), # checks index_site_3
                                                   demo_index_site$index_site_3,
                                                   
                                                   ifelse(!is.na(demo_index_site$index_site_4), # checks index_site_4
                                                          demo_index_site$index_site_4,
                                                          NA) # otherwise NA, should never be used
                                            )
                                     )
)

demo_index_site_final <- demo_index_site %>% select(linkid, birth_date, sex, race, hispanic, index_site, include, exclude)

dir.create(file.path("./output"), showWarnings = FALSE)

write.csv(demo_index_site_final, file ="./output/demo_index_site_final.csv", row.names = FALSE)

cat("Creating partner outputs for Step 3")
for(returnPartner in participants){
  
  demo_rwc_ec_temp_index <- left_join(get(paste0("demo_enc_vital_", toupper(returnPartner))), demo_index_site_final, by = "linkid")
  
  demo_rwc_ec_temp_index$index_site_flag <- ifelse(demo_rwc_ec_temp_index$site == demo_rwc_ec_temp_index$index_site,
                                                 TRUE,
                                                 FALSE)
  table(demo_rwc_ec_temp_index$index_site_flag)
  
  #Change for CHORDS: set 'index_site' to empty string if different from 'site' to mask info from being shared between
  # partner sites
  demo_rwc_ec_temp_index$index_site <- ifelse(demo_rwc_ec_temp_index$site == demo_rwc_ec_temp_index$index_site,
                                              demo_rwc_ec_temp_index$index_site,
                                              "")
  
  index_site_temp <- demo_rwc_ec_temp_index %>% select(linkid, site, index_site, include, exclude) %>% unique()
  
  # rename include and exclude back to inclusion/exclusion
  index_site_temp <- index_site_temp %>% 
    group_by(linkid) %>% 
    select(linkid, site, index_site, inclusion = include, exclusion = exclude)
  
  write.csv(index_site_temp, file = paste0("./output/index_site_", returnPartner, ".csv"), na = "", row.names = F)
}

message("Done running CODI Step 2")
