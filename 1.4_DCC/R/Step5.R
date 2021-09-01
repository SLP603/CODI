
library(tidyr)
library(readr)
library(eeptools)
library(Andromeda)
library(tools)

#for growthcleanr
library(devtools)
library(data.table)
library(foreach)
library(doParallel)
library(Hmisc)
library(bit64)


# install growthcleanr
# remotes::install_github("carriedaymont/growthcleanr", INSTALL_opts=c("--no-multiarch"))

library(growthcleanr)

library(dplyr)

options(scipen=999)

#read csv, cohort_demographic

## pull DCC saved demographics
demo_recon <- read_csv("output/demo_recon.csv", na = "NULL")

demo_recon %>% arrange(linkid)

# recode age and sex to growthcleanr format
# sex, 1 = female, 0 = male

demo_recon$sex[demo_recon$sex == "F"] <- 1
demo_recon$sex[demo_recon$sex == "M"] <- 0

cohort_tract_comorb_data <- list()
pmca_output_data <- list()
race_condition_inputs_data <- list()
measures_demo_long_data <- list()
cat("loading input files...\n")
cohort_tract_comorb_PartnerFiles <- list.files(path="./partner_step_4_out", pattern="cohort_tract_comorb_*", full.names=TRUE, recursive=FALSE, ignore.case = T)
cat("loading cohort_tract_comorb\n")
for(partner in cohort_tract_comorb_PartnerFiles){
        cat(paste0("loading partner file: ", partner,"\n"))
        pattern <- "cohort_tract_comorb_\\s*(.*?)\\s*.csv$"
        partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
        cohort_tract_comorb_temp <- readr::read_csv(partner, na = "NULL")
        cohort_tract_comorb_data[[partner_id]] <- cohort_tract_comorb_temp
}

cohort_tract_comorb <- bind_rows(cohort_tract_comorb_data)
cohort_tract_comorb %>% unique() %>% group_by(linkid) %>% arrange(linkid)


pmca_output_PartnerFiles <- list.files(path="./partner_step_4_out", pattern="pmca_output_*", full.names=TRUE, recursive=FALSE, ignore.case = T)
cat("loading pmca_output\n")
for(partner in pmca_output_PartnerFiles){
        cat(paste0("loading partner file: ", partner,"\n"))
        pattern <- "pmca_output_\\s*(.*?)\\s*.csv$"
        partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
        pmca_output_temp <- readr::read_csv(partner, na = "NULL")
        pmca_output_data[[partner_id]] <- pmca_output_temp
}

pmca_output <- bind_rows(pmca_output_data)


race_condition_inputs_PartnerFiles <- list.files(path="./partner_step_4_out", pattern="race_condition_inputs_*", full.names=TRUE, recursive=FALSE, ignore.case = T)
cat("race_condition_inputs\n")
for(partner in race_condition_inputs_PartnerFiles){
        cat(paste0("loading partner file: ", partner,"\n"))
        pattern <- "race_condition_inputs_\\s*(.*?)\\s*.csv$"
        partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
        race_condition_inputs_temp <- readr::read_csv(partner, na = "NULL")
        race_condition_inputs_data[[partner_id]] <- race_condition_inputs_temp
}

race_condition_inputs <- bind_rows(race_condition_inputs_data)
race_condition_inputs$linkid <- as.character(race_condition_inputs$linkid)
race_condition_inputs <- race_condition_inputs %>% dplyr::rename(CNT = count, DATE = early_admit_date)
race_condition_inputs <- race_condition_inputs %>% dplyr::mutate(category_form = dplyr::case_when(
        category == "Asthma" ~ "ASTHMA",
        category == "Celiac disease" ~ "CELIAC",
        category == "Cystic fibrosis" ~ "CF",
        category == "Hypercholesterolemia" ~ "HCL",
        category == "Schizophrenia" ~ "SCZ",
        category == "Sickle-cell disease" ~ "SCD",
        category == "Spina bifida" ~ "SB"
        ))


measures_output_PartnerFiles <- list.files(path="./partner_step_4_out", pattern="measures_output*", full.names=TRUE, recursive=FALSE, ignore.case = T)
cat("loading measures_output\n")
for(partner in measures_output_PartnerFiles){
        cat(paste0("loading partner file: ", partner,"\n"))
        if (tolower(tools::file_ext(partner)) == "csv"){
                pattern <- "measures_output_\\s*(.*?)\\s*.csv$"
                partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
                measures_output_temp <- readr::read_csv(partner, na = "NULL")
        }
        if (tolower(tools::file_ext(partner)) == "zip"){
                pattern <- "measures_output_\\s*(.*?)\\s*.zip$"
                partner_id <- tolower(regmatches(partner, regexec(pattern, partner))[[1]][2])
                measures_output_temp <- Andromeda::loadAndromeda(partner)
                measures_output_temp <- tibble::as_tibble(rename_with(measures_output_temp$measures_output, tolower))
                measures_output_temp$measure_date <- as.Date(measures_output_temp$measure_date)
        }
        measures_demo_temp <- left_join(measures_output_temp, demo_recon, by = "linkid")

        measures_demo_temp$agedays <- as.numeric(difftime(measures_demo_temp$measure_date,
                                                          measures_demo_temp$birth_date,
                                                        units = "days"))
        # convert height from inches to CM
        measures_demo_temp$HEIGHTCM <- measures_demo_temp$ht * 2.54

        # convert weight from pounds to Kg
        measures_demo_temp$WEIGHTKG <- measures_demo_temp$wt * 0.45359237

        # wide to long for measurement type
        measures_demo_long_temp <- gather(measures_demo_temp, param, measurement, c(HEIGHTCM, WEIGHTKG), factor_key=TRUE)

        measures_demo_long_data[[partner_id]] <- measures_demo_long_temp
}
measures_demo_long <- bind_rows(measures_demo_long_data)


## pull bmiagerev
cat("## pull bmiagerev\n")
bmiagerev <- read_csv("csv/bmiagerev.csv") %>% dplyr::rename(agemos = Agemos, sex = Sex)


# test unique only
cat("# test unique only\n")
measures_demo_long <- measures_demo_long %>% unique()

measures_demo_long <- as.data.table(measures_demo_long)
setkey(measures_demo_long, linkid, param, agedays)


# clean measurements
cat("# clean measurements(takes a long time to run(3+ hrs))\n")
cleaned_measures_demo_long <- measures_demo_long[, clean_value:=
                                                         cleangrowth(linkid, param, agedays, sex, measurement,
                                                                     parallel = T, num.batches = 6, quietly = F)]

# keep those marked include only
cat("# keep those marked include only\n")
measures_demo_long_kept <- cleaned_measures_demo_long[clean_value=='Include']


write_csv(measures_demo_long_kept, path = "output/measures_demo_long_kept.csv")


# 1.4.6 here
# reconcile PMCA

# pmca_output$linkid %>% length()
# (pmca_output %>% unique())$linkid %>% length()


#pmca_output %>% unique() %>% group_by(linkid) %>% filter(pmca >= 1) %>% duplicated() %>% count()
#pmca_output$pmca <- ifelse()

# count unique body systems and filter by uniques
cat("# count unique body systems and filter by uniques\n")
pmca_recon <- pmca_output %>%
        group_by(linkid) %>%
        dplyr::mutate(count_bs = dplyr::n_distinct(body_system_name, na.rm = TRUE)) %>%
        unique()

#pmca_recon %>% View()

# pmca_recon %>% arrange(linkid) %>% ifelse(pmca == 1,)

# add max pmca
cat("# add max pmca\n")
pmca_recon_count <- pmca_recon %>%
        group_by(linkid) %>%
        dplyr::arrange(linkid) %>%
        dplyr::mutate(pmca_max = max(pmca))

# pmca_recon_count$pmca_all <- ifelse(pmca == 2,
#                                     2,
#                                     ifelse(pmca == 1 & )
#                                     )

pmca_recon_count$pmca_max <- ifelse(pmca_recon_count$count_bs >= 2,
                                    2,
                                    pmca_recon_count$pmca_max)

pmca_recon_count_max <- pmca_recon_count %>% select(linkid, pmca_max) %>% unique()

write_csv(pmca_recon_count_max, path = "output/pmca_recon_count_max.csv")


#### weight category for random BMI ####
cat("#### weight category for random BMI ####\n")
# spread to wide format again by date
measures_demo_wide_kept <- measures_demo_long_kept %>% spread(param, measurement)

# filter by measure dates that occur in 2017, 2018, 2019
cat("# filter by measure dates that occur in 2017, 2018, 2019\n")
measures_demo_wide_kept_CY <- measures_demo_wide_kept %>% filter(measure_date >= "2017-01-01" & measure_date < "2020-01-01")

# pull yr var based on measure_date
cat("# pull yr var based on measure_date\n")
measures_demo_wide_kept_CY <- measures_demo_wide_kept_CY %>%
        dplyr::mutate(yr = year(measure_date))

measures_demo_wide_kept_CY <- measures_demo_wide_kept_CY %>%
        filter(!is.na(HEIGHTCM) & !is.na(WEIGHTKG)) %>%
        dplyr::mutate(bmi = WEIGHTKG/(HEIGHTCM * 0.01))

# select 1 random row per linkid, per yr
cat("# select 1 random row per linkid, per yr\n")
set.seed(1492)
measures_demo_wide_rand <- measures_demo_wide_kept_CY %>%
        group_by(linkid, yr) %>%
        sample_n(1)

# add age in months
cat("# add age in months\n")
measures_demo_wide_rand$agemos <- floor(age_calc(measures_demo_wide_rand$birth_date, enddate = measures_demo_wide_rand$measure_date,
                                           units = "months", precise = TRUE))
measures_demo_wide_rand$sex <- measures_demo_wide_rand$sex %>% as.numeric()

# join with bmiagerev
cat("# join with bmiagerev\n")
measures_demo_wide_rand_z <- left_join(measures_demo_wide_rand, bmiagerev, by = c("agemos", "sex"))

# calculate z
cat("# calculate z\n")
measures_demo_wide_rand_z <- measures_demo_wide_rand_z %>%
        dplyr::mutate(z = ((bmi/M)^L - 1)/(L*S))

# convert to percentiles
cat("# convert to percentiles\n")
measures_demo_wide_rand_z_perc <- measures_demo_wide_rand_z %>%
        dplyr::mutate(bmi_percentile = case_when(
                z < -1.881 ~ 3, # Underweight
                z < -1.645 ~ 5, #Underweight
                z < -1.282 ~ 10,
                z < -0.675 ~ 25,
                z > 1.881 ~ 97, # Obese
                z > 1.645 ~ 95, # Obese
                z > 1.282 ~ 90, # Overweight
                z > 1.036 ~ 85, # Overweight
                z > 0.675 ~ 75,
                TRUE ~ 50
        )
)

# convert to bmi categories
cat("# convert to bmi categories\n")
measures_demo_wide_rand_z_perc_cat <- measures_demo_wide_rand_z_perc %>%
        dplyr::mutate(wt_category = case_when(
                is.na(bmi_percentile) ~ 'Missing',
                bmi_percentile >= 95 & bmi >= (1.4 * P95) ~ 'Class III Obese',
                bmi_percentile >= 95 & bmi >= (1.2 * P95) ~ 'Class II Obese',
                bmi_percentile >= 95 ~ 'Class I Obese',
                bmi_percentile >= 85 ~ 'Overweight',
                bmi_percentile <= 5 ~ 'Underweight',
                TRUE ~ 'Normal'
))


cleaned_measures_demo_long %>% filter(linkid == 100000)
measures_demo_wide_kept %>% filter(linkid == 100000)
measures_demo_wide_kept_CY %>% filter(linkid == 100000) %>% arrange(measure_date)

write_csv(measures_demo_wide_rand_z_perc_cat, path = "output/measures_demo_cat.csv")


measures_demo_wide_rand_z_perc_cat




# outputs in terms of counts by yr/wt/(var) groupings
cat("# outputs in terms of counts by yr/wt/(var) groupings\n")
demo_recon %>% group_by(linkid)
pmca_recon_count_max %>% group_by(linkid)

# age
cat("# age\n")
measures_demo_wide_rand_z_perc_cat$age <- floor(age_calc(measures_demo_wide_rand_z_perc_cat$birth_date,
                                                         enddate = measures_demo_wide_rand_z_perc_cat$measure_date,
                                                         units = "years", precise = TRUE))

age_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        select(linkid, yr, age, wt_category) %>%
        group_by(yr, age, wt_category) %>%
        dplyr::summarise(count = n())
age_group_counts

# sex
cat("# sex\n")
sex_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        select(linkid, yr, sex, wt_category) %>%
        group_by(yr, sex, wt_category) %>%
        dplyr::summarise(count = n())
sex_group_counts

# race
cat("# race\n")
race_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        select(linkid, yr, race, wt_category) %>%
        group_by(yr, race, wt_category) %>%
        dplyr::summarise(count = n())
race_group_counts

# ethnicity
cat("# ethnicity\n")
ethn_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        select(linkid, yr, hispanic, wt_category) %>%
        group_by(yr, hispanic, wt_category) %>%
        dplyr::summarise(count = n())
ethn_group_counts


# insurance
cat("# insurance\n")
insurance_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        select(linkid, yr, insurance_type, wt_category) %>%
        group_by(yr, insurance_type, wt_category) %>%
        dplyr::summarise(count = n())
insurance_group_counts

# tract
cat("# tract\n")
tract_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        left_join(cohort_tract_comorb, by = c("linkid", "yr")) %>%
        select(linkid, yr, tract, wt_category) %>%
        group_by(yr, tract, wt_category) %>%
        dplyr::summarise(count = n())
tract_group_counts

# PMCA
cat("# PMCA\n")
pmca_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        left_join(pmca_recon_count_max, by = "linkid") %>%
        select(linkid, yr, pmca_max, wt_category) %>%
        group_by(yr, pmca_max, wt_category) %>%
        dplyr::summarise(count = n())
pmca_group_counts

## co occurring conditions ##
cat("## co occurring conditions ##\n")
# Acanthosis_Nigricans
cat("# Acanthosis_Nigricans\n")
acanthosis_nigricans_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        left_join(cohort_tract_comorb, by = c("linkid", "yr")) %>%
        select(linkid, yr, acanthosis_nigricans, wt_category) %>%
        group_by(yr, acanthosis_nigricans, wt_category) %>%
        dplyr::summarise(count = n())
acanthosis_nigricans_group_counts

# measures_demo_wide_rand_z_perc_cat %>% group_by(linkid) %>% select(linkid, wt_category, yr) %>% unique()
# cohort_tract_comorb %>% group_by(linkid) %>% select(linkid, yr) %>% unique()
#
# left_join(measures_demo_wide_rand_z_perc_cat %>% group_by(linkid) %>% select(linkid, wt_category, yr) %>% unique(), cohort_tract_comorb %>% group_by(linkid) %>% select(linkid, yr, acanthosis_nigricans) %>% unique(),
#           by =  c("linkid", "yr")) %>% View()

# adhd
cat("# adhd\n")
adhd_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        left_join(cohort_tract_comorb, by = c("linkid", "yr")) %>%
        select(linkid, yr, adhd, wt_category) %>%
        group_by(yr, adhd, wt_category) %>%
        dplyr::summarise(count = n())
#adhd_group_counts %>% View()


# anxiety
cat("# anxiety\n")
anxiety_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        left_join(cohort_tract_comorb, by = c("linkid", "yr")) %>%
        select(linkid, yr, anxiety, wt_category) %>%
        group_by(yr, anxiety, wt_category) %>%
        dplyr::summarise(count = n())
anxiety_group_counts


# asthma
cat("# asthma\n")
asthma_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        left_join(cohort_tract_comorb, by = c("linkid", "yr")) %>%
        select(linkid, yr, asthma, wt_category) %>%
        group_by(yr, asthma, wt_category) %>%
        dplyr::summarise(count = n())
asthma_group_counts

# autism
cat("# autism\n")
autism_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        left_join(cohort_tract_comorb, by = c("linkid", "yr")) %>%
        select(linkid, yr, autism, wt_category) %>%
        group_by(yr, autism, wt_category) %>%
        dplyr::summarise(count = n())
autism_group_counts


# depression
cat("# depression\n")
depression_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        left_join(cohort_tract_comorb, by = c("linkid", "yr")) %>%
        select(linkid, yr, depression, wt_category) %>%
        group_by(yr, depression, wt_category) %>%
        dplyr::summarise(count = n())
depression_group_counts

# diabetes
cat("# diabetes\n")
diabetes_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        left_join(cohort_tract_comorb, by = c("linkid", "yr")) %>%
        select(linkid, yr, diabetes, wt_category) %>%
        group_by(yr, diabetes, wt_category) %>%
        dplyr::summarise(count = n())
diabetes_group_counts


# eating_disorders
cat("# eating_disorders\n")
eating_disorders_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        left_join(cohort_tract_comorb, by = c("linkid", "yr")) %>%
        select(linkid, yr, eating_disorders, wt_category) %>%
        group_by(yr, eating_disorders, wt_category) %>%
        dplyr::summarise(count = n())
eating_disorders_group_counts


# hyperlipidemia
cat("# hyperlipidemia\n")
hyperlipidemia_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        left_join(cohort_tract_comorb, by = c("linkid", "yr")) %>%
        select(linkid, yr, hyperlipidemia, wt_category) %>%
        group_by(yr, hyperlipidemia, wt_category) %>%
        dplyr::summarise(count = n())
hyperlipidemia_group_counts

# hypertension
cat("# hypertension\n")
hypertension_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        left_join(cohort_tract_comorb, by = c("linkid", "yr")) %>%
        select(linkid, yr, hypertension, wt_category) %>%
        group_by(yr, hypertension, wt_category) %>%
        dplyr::summarise(count = n())
hypertension_group_counts

# NAFLD
cat("# NAFLD\n")
NAFLD_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        left_join(cohort_tract_comorb, by = c("linkid", "yr")) %>%
        select(linkid, yr, nafld, wt_category) %>%
        group_by(yr, nafld, wt_category) %>%
        dplyr::summarise(count = n())
NAFLD_group_counts

# Obstructive_sleep_apnea
cat("# Obstructive_sleep_apnea\n")
Obstructive_sleep_apnea_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        left_join(cohort_tract_comorb, by = c("linkid", "yr")) %>%
        select(linkid, yr, obstructive_sleep_apnea, wt_category) %>%
        group_by(yr, obstructive_sleep_apnea, wt_category) %>%
        dplyr::summarise(count = n())
Obstructive_sleep_apnea_group_counts


# PCOS
cat("# PCOS\n")
PCOS_group_counts <- measures_demo_wide_rand_z_perc_cat %>%
        left_join(cohort_tract_comorb, by = c("linkid", "yr")) %>%
        select(linkid, yr, pcos, wt_category) %>%
        group_by(yr, pcos, wt_category) %>%
        dplyr::summarise(count = n())
PCOS_group_counts


# write outputs
cat("# write outputs\n")
write_csv(age_group_counts, path = "output/age_group_counts.csv")
write_csv(sex_group_counts, path = "output/sex_group_counts.csv")
write_csv(race_group_counts, path = "output/race_group_counts.csv")
write_csv(ethn_group_counts, path = "output/ethn_group_counts.csv")
write_csv(insurance_group_counts, path = "output/insurance_group_counts.csv")
write_csv(tract_group_counts, path = "output/tract_group_counts.csv")
write_csv(pmca_group_counts, path = "output/pmca_group_counts.csv")


write_csv(acanthosis_nigricans_group_counts, path = "output/acanthosis_nigricans_group_counts.csv")
write_csv(adhd_group_counts, path = "output/adhd_group_counts.csv")
write_csv(anxiety_group_counts, path = "output/anxiety_group_counts.csv")
write_csv(asthma_group_counts, path = "output/asthma_group_counts.csv")
write_csv(autism_group_counts, path = "output/autism_group_counts.csv")
write_csv(depression_group_counts, path = "output/depression_group_counts.csv")
write_csv(diabetes_group_counts, path = "output/diabetes_group_counts.csv")
write_csv(eating_disorders_group_counts, path = "output/eating_disorders_group_counts.csv")
write_csv(hyperlipidemia_group_counts, path = "output/hyperlipidemia_group_counts.csv")
write_csv(hypertension_group_counts, path = "output/hypertension_group_counts.csv")
write_csv(NAFLD_group_counts, path = "output/NAFLD_group_counts.csv")
write_csv(Obstructive_sleep_apnea_group_counts, path = "output/Obstructive_sleep_apnea_group_counts.csv")
write_csv(PCOS_group_counts, path = "output/PCOS_group_counts.csv")



#### NORC input style ####
cat("#### NORC input style ####\n")

#measures_demo_wide_rand_z_perc_cat %>% View()

#cohort_tract_comorb %>% View()

# grab all required inputs to start
cat("# grab all required inputs to start\n")
NORC_input_prep <- measures_demo_wide_rand_z_perc_cat %>%
        left_join(cohort_tract_comorb, by = c("linkid", "yr")) %>%
        left_join(race_condition_inputs, by = "linkid") %>%
        select(linkid,
               birth_date,
               sex,
               race,
               hispanic,
               latitude,
               longitude,
               state,
               zip,
               tract,
               county,
               yr,
               WEIGHTKG,
               HEIGHTCM,
               bmi,
               wt_category,
               age,
               category,
               CNT,
               DATE
               )
NORC_input_prep <- NORC_input_prep %>% group_by(linkid) %>% distinct()

# concatenate STATE to COUNTY to generate COUNTY_FIPS
cat("# concatenate STATE to COUNTY to generate COUNTY_FIPS\n")
NORC_input_prep$COUNTY_FIPS <- paste0(NORC_input_prep$STATE, NORC_input_prep$COUNTY)

# pull demo set of columns for prep, and rename
cat("# pull demo set of columns for prep, and rename\n")
NORC_input_prep_demo <- NORC_input_prep %>% select(linkid,
                                                   DOB = birth_date,
                                                   SEX = sex,
                                                   RACE = race,
                                                   ETHNICITY = hispanic,
                                                   LAT = latitude,
                                                   LNG = longitude,
                                                   STATE_FIPS = state,
                                                   zip,
                                                   CENSUS_TRACT = tract,
                                                   COUNTY_FIPS = county)

# filter by distinct
cat("# filter by distinct\n")
NORC_input_prep_demo <- NORC_input_prep_demo %>% group_by(linkid) %>% distinct()

# pull BMI  set of columns for prep, and rename
cat("# pull BMI  set of columns for prep, and rename\n")
NORC_input_prep_bmi_prep <- NORC_input_prep %>% select(linkid,
                                                       yr,
                                                       WEIGHT = WEIGHTKG,
                                                       HEIGHT = HEIGHTCM,
                                                       BMI = bmi,
                                                       WTCAT = wt_category,
                                                       AGEYR = age)

# convert from long to wide to tag on CY for each column
cat("# convert from long to wide to tag on CY for each column\n")
NORC_input_prep_bmi <- pivot_wider(NORC_input_prep_bmi_prep,
                                   id_cols = linkid,
                                   names_from = yr,
                                   names_glue = "{.value}{yr}",
                                   values_from = c(WEIGHT,
                                                   HEIGHT,
                                                   BMI,
                                                   WTCAT,
                                                   AGEYR))

#NORC_input_prep_bmi %>% View()


# merge the results
cat("# merge the results\n")
NORC_input_prep_merged <- left_join(NORC_input_prep_demo, NORC_input_prep_bmi, by = "linkid")

# handle race_conditions inputs

# check if race_condition_inputs has rows
if(length(race_condition_inputs$linkid) != 0){

        # convert long to wide to add category as part of column name
        NORC_input_prep_race_condition_test <- pivot_wider(race_condition_inputs,
                                                           id_cols = linkid,
                                                           names_from = category,
                                                           names_glue = "{category}{.value}",
                                                           values_from = c(CNT, DATE))

        # populate columns names if missing
        if(!("HCLCNT" %in% colnames(race_condition_inputs))) {
                NORC_input_prep_race_condition_test$HCLCNT <- NA
        }
        if(!("HCLDATE" %in% colnames(race_condition_inputs))) {
                NORC_input_prep_race_condition_test$HCLDATE <- NA
        }


        if(!("CFCNT" %in% colnames(race_condition_inputs))) {
                NORC_input_prep_race_condition_test$CFCNT <- NA
        }
        if(!("CFDATE" %in% colnames(race_condition_inputs))) {
                NORC_input_prep_race_condition_test$CFDATE <- NA
        }


        if(!("SCDCNT" %in% colnames(race_condition_inputs))) {
                NORC_input_prep_race_condition_test$SCDCNT <- NA
        }
        if(!("SCDDATE" %in% colnames(race_condition_inputs))) {
                NORC_input_prep_race_condition_test$SCDDATE <- NA
        }


        if(!("SBCNT" %in% colnames(race_condition_inputs))) {
                NORC_input_prep_race_condition_test$SBCNT <- NA
        }
        if(!("SBDATE" %in% colnames(race_condition_inputs))) {
                NORC_input_prep_race_condition_test$SBDATE <- NA
        }


        if(!("ASTHMACNT" %in% colnames(race_condition_inputs))) {
                NORC_input_prep_race_condition_test$ASTHMACNT <- NA
        }
        if(!("ASTHMADATE" %in% colnames(race_condition_inputs))) {
                NORC_input_prep_race_condition_test$ASTHMADATE <- NA
        }


        if(!("CELIACCNT" %in% colnames(race_condition_inputs))) {
                NORC_input_prep_race_condition_test$CELIACCNT <- NA
        }
        if(!("CELIACDATE" %in% colnames(race_condition_inputs))) {
                NORC_input_prep_race_condition_test$CELIACDATE <- NA
        }


        if(!("SCZCNT" %in% colnames(race_condition_inputs))) {
                NORC_input_prep_race_condition_test$SCZCNT <- NA
        }
        if(!("SCZDATE" %in% colnames(race_condition_inputs))) {
                NORC_input_prep_race_condition_test$SCZDATE <- NA
        }


        # join with NORC_input_prep_merged
        NORC_input_final <- left_join(NORC_input_prep_merged, NORC_input_prep_race_condition_test, by = "linkid")

} else { # just attached columns and fill with null to merged

        NORC_input_final <- NORC_input_prep_merged %>% mutate(
                HCLCNT = NA,
                HCLDATE = NA,
                CFCNT = NA,
                CFDATE = NA,
                SCDCNT = NA,
                SCDDATE = NA,
                SBCNT = NA,
                SBDATE = NA,
                ASTHMACNT = NA,
                ASTHMADATE = NA,
                CELIACCNT = NA,
                CELIACDATE = NA,
                SCZCNT = NA,
                SCZDATE = NA
        )
}




cat("# leaving a 'merged' version for now, there will be duplicate rows due to the way yrs and location vars work right now\n")
#NORC_input_final %>% View()

NORC_input_final <- NORC_input_final %>% select(linkid,
                                                   DOB,
                                                   SEX,
                                                   RACE,
                                                   ETHNICITY,
                                                   LAT,
                                                   LNG,
                                                   STATE_FIPS,
                                                   zip	,
                                                   CENSUS_TRACT,
                                                   COUNTY_FIPS,
                                                   WEIGHT2017,
                                                   HEIGHT2017,
                                                   BMI2017,
                                                   WTCAT2017,
                                                   AGEYR2017,
                                                   WEIGHT2018,
                                                   HEIGHT2018,
                                                   BMI2018,
                                                   WTCAT2018,
                                                   AGEYR2018,
                                                   WEIGHT2019,
                                                   HEIGHT2019,
                                                   BMI2019,
                                                   WTCAT2019,
                                                   AGEYR2019,
                                                   HCLCNT,
                                                   HCLDATE,
                                                   CFCNT,
                                                   CFDATE,
                                                   SCDCNT,
                                                   SCDDATE,
                                                   SBCNT,
                                                   SBDATE,
                                                   ASTHMACNT,
                                                   ASTHMADATE,
                                                   CELIACCNT,
                                                   CELIACDATE,
                                                   SCZCNT,
                                                   SCZDATE)

cat("writing NORC_input_final\n")
write_csv(NORC_input_final, path = "output/NORC_input_final.csv")
message("CODI Step 5 Done")
