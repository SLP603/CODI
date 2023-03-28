DROP TABLE IF EXISTS #cohort_demographic_age_filter;
SELECT *
INTO #cohort_demographic_age_filter 
FROM (
  SELECT 
  	linkid,
  	patid,
  	encN,
  	birth_date,
  	sex,
  	race,
  	hispanic,
  	yr,
  	loc_start --,
  	--study_age_yrs_2017,
  	--study_age_yrs_2018,
  	--study_age_yrs_2019,
    --study_age_yrs_2020,
    --study_age_yrs_2021,
    --study_age_yrs_2022
  FROM 
  	#cohort_demographic_age 
  WHERE 
  	(yr = 2017 AND study_age_yrs_2017 BETWEEN 2 AND 19) OR
  	(yr = 2018 AND study_age_yrs_2018 BETWEEN 2 AND 19) OR
  	(yr = 2019 AND study_age_yrs_2019 BETWEEN 2 AND 19) OR
    (yr = 2020 AND study_age_yrs_2020 BETWEEN 2 AND 19) OR
    (yr = 2021 AND study_age_yrs_2021 BETWEEN 2 AND 19) OR
    (yr = 2022 AND study_age_yrs_2022 BETWEEN 2 AND 19)
) a;
