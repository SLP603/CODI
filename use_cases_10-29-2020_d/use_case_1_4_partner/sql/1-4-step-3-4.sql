--use ch; -- edit this
--go
---- LOAD DATA FROM CSV FILES

DECLARE @file_path varchar(100),
		@file_path_DCC_out varchar(255),
		@input_file varchar(255), 
		@pmca_path varchar(255)
DECLARE @snomed2icd_path varchar(255),
		@bmiperc_path varchar(255),
		@comob_path varchar(255),
		@race_con_path varchar(255)

SET @file_path = 'C:\\codi_data\\reference\\' -- edit this to \reference\ folder location
SET @file_path_DCC_out = 'C:\\Users\\hzhang\\Documents\\use_case_tests_hl_sql_scripts\\DCC_out\\' -- edit this to \DCC_out\ folder location

SET @pmca_path = @file_path + 'pmca-version-3.1_icd10-code-list.csv'
SET @snomed2icd_path = @file_path + 'snomed2icd.csv'
SET @bmiperc_path = @file_path + 'bmiagerev.csv'
SET @comob_path = @file_path + 'comorb_codes.csv'
SET @race_con_path = @file_path + 'race-conditions.csv'

SET @input_file = @file_path_DCC_out + 'demo_recon_loc_ch.csv' -- edit this

-- Load the PMCA codes from Excel
DROP TABLE IF EXISTS #pmca;
CREATE TABLE #pmca (
	icd10 varchar(10) PRIMARY KEY,
	description varchar(255),
	body_system varchar(50),
	progressive varchar(3),
	heading varchar(10)
);
EXECUTE dbo.CreateTempTable '#pmca', @pmca_path

-- Load the translation from SNOMED to ICD10
DROP TABLE IF EXISTS #snomed2icd;
CREATE TABLE #snomed2icd (
	referencedComponentId varchar(20), -- SNOMED
	referencedComponentName varchar(255),
	mapTarget varchar(10), -- ICD10
	mapTargetName varchar(255)
);
EXECUTE dbo.CreateTempTable '#snomed2icd', @snomed2icd_path 

DROP TABLE IF EXISTS #comorb_codes;
CREATE TABLE #comorb_codes (
	condition varchar(255), -- comorb condition
	coding_system varchar(255), -- icd9 or icd10
	code varchar(10)
);
EXECUTE dbo.CreateTempTable '#comorb_codes', @comob_path 

DROP TABLE IF EXISTS #race_con_codes;
CREATE TABLE #race_con_codes (
	dx_type CHAR(2),
	dx VARCHAR(18),
	category VARCHAR(32)
);
EXECUTE dbo.CreateTempTable '#race_con_codes', @race_con_path 

----- END DATA LOAD FROM FILE


-- Load the LINKIDs from step 2
DROP TABLE IF EXISTS #demo_recon_loc;
CREATE TABLE #demo_recon_loc (
	linkid varchar(255),
	--birth_date date,
	--sex varchar(2),
	--race varchar(2),
	--hispanic varchar(4),
	site varchar(5),
	yr int --,
	--loc_start date,
	--census_location_id varchar(255)
);
EXECUTE dbo.CreateTempTable '#demo_recon_loc', @input_file

SELECT * FROM #demo_recon_loc;
/*
BULK
INSERT #demo_recon_loc 
FROM 'C:\Users\hzhang\Documents\use_case_tests_hl_sql_scripts\DCC_out\demo_recon_loc_ch.csv' WITH
(	
	FORMAT='CSV',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a'
)
*/

SELECT * FROM #demo_recon_loc;

-- link with patid
DROP TABLE IF EXISTS #demo_recon_loc_link;
SELECT 
	#demo_recon_loc.linkid,
	--#demo_recon_loc.birth_date,
	--#demo_recon_loc.sex,
	--#demo_recon_loc.race,
	--#demo_recon_loc.hispanic,
	#demo_recon_loc.site,
	#demo_recon_loc.yr,
	--#demo_recon_loc.loc_start,
	--#demo_recon_loc.census_location_id,
	dbo.link.patid
INTO #demo_recon_loc_link
FROM 
	#demo_recon_loc 
		LEFT JOIN dbo.link ON #demo_recon_loc.linkid = dbo.link.linkid
;

SELECT * FROM #demo_recon_loc_link;
go

-- grab location again
---------------------------------------------------------------

-- substitude for the age function in postgres 
CREATE OR ALTER FUNCTION dbo.get_age (@bdate varchar(10), @cap_date varchar(10))
RETURNS @age TABLE
( year int,
  month int,
  day int
)
AS
BEGIN
	DECLARE @yr int;
	DECLARE @month smallint;
	DECLARE @day int;
	DECLARE @temp_date date;
	SELECT @yr = CASE
			WHEN DATEDIFF(day, DATEADD(year, DATEDIFF(YEAR, @bdate , @cap_date), @bdate), @cap_date) <0 
			THEN DATEDIFF(YEAR, @bdate , @cap_date)-1
			ELSE DATEDIFF(YEAR, @bdate , @cap_date)
		   END;

	SELECT @temp_date = DATEADD(year, @yr, @bdate);
	SELECT @month = DATEDIFF(MONTH, @temp_date, @cap_date);

	SELECT @month = CASE
		   WHEN DATEDIFF(day, DATEADD(MONTH, @month , @temp_date), @cap_date) < 0
			 THEN @month -1
			 ELSE @month
		   END;

	SELECT @temp_date = DATEADD(MONTH, @month, @temp_date);
	SELECT @day = DATEDIFF(DAY, @temp_date, @cap_date);
	INSERT @age
	VALUES (@yr, @month, @day);
	RETURN
END;
GO


DROP VIEW IF EXISTS enc_counts;
GO
CREATE VIEW enc_counts AS
SELECT linkid, patid, yr, COUNT(ENC_ID) AS encN
FROM (
	SELECT link.linkid AS linkid, dbo.ENCOUNTERS.PERSON_ID as patid, ENC_ID,
		CASE WHEN ADATE >= '2017-1-1' AND ADATE < '2018-1-1' THEN 2017
			 WHEN  ADATE >= '2018-1-1' AND ADATE < '2019-1-1' THEN 2018
			 WHEN  ADATE >= '2019-1-1' AND ADATE < '2020-1-1' THEN 2019
		END AS yr
	FROM dbo.ENCOUNTERS
	JOIN dbo.link as link on link.patid = dbo.ENCOUNTERS.PERSON_ID
	WHERE ADATE >= '2017-1-1' AND ADATE < '2020-1-1'
) AS encounter_plus_year
GROUP BY linkid, patid, yr;
GO

--DROP TABLE IF EXISTS cohort_demographic;
DROP VIEW IF EXISTS cohort_demographic;
GO
CREATE VIEW cohort_demographic AS
SELECT 
	linkid, 
	dbo.DEMOGRAPHICS.PERSON_ID AS patid, 
	birth_date, 
	GENDER AS sex, 
	RACE1 AS race,
	hispanic, 
	yr, 
	encN, 
	loc_start, 
	loc_end, 
	geocode_boundary_year,
	geolevel,
	latitude, 
	longitude --, 
	--census_location_id
FROM (
	SELECT linkid, ec.patid, ec.yr, encN, 
		(SELECT MAX(loc_start) 
			FROM dbo.CENSUS_LOCATION 
			WHERE ec.patid = patid 
			AND loc_start <= CONVERT(datetime, '12-31-'+CAST( ec.yr AS VARCHAR(4)))
		) AS latest_loc_date
	FROM enc_counts ec
) AS enc_counts_loc
LEFT JOIN dbo.CENSUS_LOCATION ON CENSUS_LOCATION.PERSON_ID =  enc_counts_loc.patid 
				AND loc_start = enc_counts_loc.latest_loc_date 
JOIN  dbo.DEMOGRAPHICS ON DEMOGRAPHICS.PERSON_ID = enc_counts_loc.patid;
GO

SELECT * FROM cohort_demographic ORDER BY linkid;
SELECT * FROM cohort_demographic ORDER BY loc_start;

-- get study age per CY 
DROP VIEW IF EXISTS cohort_demographic_age;
GO
CREATE VIEW cohort_demographic_age AS
SELECT 
	*,
	(SELECT year from dbo.get_age(birth_date, '1/1/2017')) AS study_age_yrs_2017,
	(SELECT year from dbo.get_age(birth_date, '1/1/2018')) AS study_age_yrs_2018,
	(SELECT year from dbo.get_age(birth_date, '1/1/2019')) AS study_age_yrs_2019
FROM 
	cohort_demographic
;
GO

SELECT * FROM cohort_demographic_age ORDER BY study_age_yrs_2017;
SELECT * FROM cohort_demographic_age ORDER BY study_age_yrs_2018;
SELECT * FROM cohort_demographic_age ORDER BY study_age_yrs_2019;

DROP VIEW IF EXISTS cohort_demographic_age_filter;
GO
CREATE VIEW cohort_demographic_age_filter AS
SELECT 
	linkid,
	encN,
	birth_date,
	sex,
	race,
	hispanic,
	yr,
	loc_start --,
	--census_location_id
	--study_age_yrs_2017,
	--study_age_yrs_2018,
	--study_age_yrs_2019
FROM 
	cohort_demographic_age 
WHERE 
	(yr = 2017 AND study_age_yrs_2017 BETWEEN 2 AND 19) OR
	(yr = 2018 AND study_age_yrs_2018 BETWEEN 2 AND 19) OR
	(yr = 2019 AND study_age_yrs_2019 BETWEEN 2 AND 19)
;
GO

-- link geocode with tract
DROP TABLE IF EXISTS #geocode_tract; 
SELECT 
	dbo.CENSUS_LOCATION.PERSON_ID AS patid,
	dbo.CENSUS_LOCATION.loc_start,
	--dbo.CENSUS_LOCATION.census_location_id,
	dbo.CENSUS_LOCATION.geocode,
	dbo.CENSUS_LOCATION.latitude,
	dbo.CENSUS_LOCATION.longitude,
	CENSUS_DEMOG.TRACT,
	CENSUS_DEMOG.STATE,
	CENSUS_DEMOG.COUNTY,
	CENSUS_DEMOG.ZIP
INTO #geocode_tract
FROM
	dbo.CENSUS_LOCATION
		LEFT JOIN CENSUS_DEMOG ON dbo.census_location.geocode = CENSUS_DEMOG.GEOCODE
;
GO
--SELECT * FROM #geocode_tract ORDER BY patid;
--SELECT COUNT(patid) FROM #geocode_tract;
--SELECT COUNT(DISTINCT patid) FROM #geocode_tract;

--SELECT * FROM codi.census_location;

--SELECT * FROM cohort_demographic_age_filter ORDER BY linkid;

SELECT DISTINCT linkid FROM cohort_demographic_age_filter;


--SELECT * FROM #demo_recon_loc_link;
GO
-- this is final one
DROP TABLE IF EXISTS #demo_recon_loc_tract; 
GO
SELECT 
	#demo_recon_loc_link.linkid,
	#demo_recon_loc_link.patid,
	cohort_demographic_age_filter.birth_date,
	#demo_recon_loc_link.site,
	#demo_recon_loc_link.yr,
	cohort_demographic_age_filter.loc_start,
	--cohort_demographic_age_filter.census_location_id,
	#geocode_tract.geocode,
	#geocode_tract.TRACT,
	#geocode_tract.latitude,
	#geocode_tract.longitude,
	#geocode_tract.STATE,
	#geocode_tract.COUNTY,
	#geocode_tract.ZIP
INTO 
	#demo_recon_loc_tract
FROM
	#demo_recon_loc_link
		LEFT JOIN cohort_demographic_age_filter ON #demo_recon_loc_link.linkid = cohort_demographic_age_filter.linkid AND
		#demo_recon_loc_link.yr = cohort_demographic_age_filter.yr
		LEFT JOIN #geocode_tract ON #demo_recon_loc_link.patid = #geocode_tract.patid
;
GO
SELECT * FROM #demo_recon_loc_link;
SELECT * FROM cohort_demographic_age_filter;

SELECT * FROM #geocode_tract;
SELECT * FROM #demo_recon_loc_tract ORDER BY linkid;


--TEMP FIX
DROP TABLE IF EXISTS #insurance;
SELECT 
	ENCOUNTERS.ENC_ID, 
	ENCOUNTERS.PERSON_ID, 
	BENEFIT_CAT, 
	(SELECT CASE 
		WHEN BENEFIT_CAT IN ('CC', 'CP', 'MC', 'MD') THEN 'Public (non-military)'
		WHEN BENEFIT_CAT IN ('CO') THEN 'Private'
		ELSE 'Other or unknown' -- OG, NC, OT, UN, WC, NI
	END) as insurance_type
INTO #insurance	
FROM dbo.ENCOUNTERS
	LEFT JOIN (SELECT * FROM dbo.BENEFIT WHERE BENEFIT_TYPE = 'PR') BEN ON ENCOUNTERS.ENC_ID = BEN.ENC_ID
JOIN (
	SELECT ENCOUNTERS.PERSON_ID, MAX(ADATE) admin_date
	FROM 
		dbo.ENCOUNTERS 
			LEFT JOIN dbo.BENEFIT ON ENCOUNTERS.ENC_ID = BENEFIT.ENC_ID
	WHERE BENEFIT_CAT IS NOT NULL AND BENEFIT_TYPE = 'PR'
	GROUP BY ENCOUNTERS.PERSON_ID
) ei ON ei.PERSON_ID = ENCOUNTERS.PERSON_ID AND ei.admin_date = ENCOUNTERS.ADATE
--JOIN BENEFIT ON BENEFIT.ENC_ID = ENCOUNTERS.ENC_ID
;

GO


DROP TABLE IF EXISTS cohort_demographic_insurance_prep;
SELECT #demo_recon_loc_tract.*,
	(SELECT year from dbo.get_age(d.birth_date, '1/1/2017')) as age, -- assuming this is for age
	CASE WHEN BENEFIT_CAT IS NULL THEN 'Other or unknown' ELSE BENEFIT_CAT END as insurance_type -- assuming this is for insurance_type
INTO cohort_demographic_insurance_prep
FROM #demo_recon_loc_tract
JOIN dbo.DEMOGRAPHICS d ON #demo_recon_loc_tract.patid = d.PERSON_ID
LEFT JOIN #insurance ON #insurance.PERSON_ID = #demo_recon_loc_tract.patid
;

SELECT * FROM cohort_demographic_insurance_prep;

GO

DROP TABLE IF EXISTS #cohort_demographic_tract_prep;
GO
SELECT 
	linkid,
	patid,
	site,
	yr,
	TRACT,
	latitude,
	longitude,
	STATE,
	COUNTY,
	ZIP
INTO 
	#cohort_demographic_tract_prep
FROM 
	cohort_demographic_insurance_prep
;

SELECT * FROM #cohort_demographic_tract_prep;

SELECT * FROM cohort_demographic_insurance_prep;

-- output of tract by CY
DROP TABLE IF EXISTS cohort_tract;
SELECT 
	linkid,
	site,
	yr,
	TRACT
INTO 
	cohort_tract
FROM 
	cohort_demographic_insurance_prep
;


SELECT * FROM cohort_tract;

SELECT DISTINCT linkid FROM #cohort_demographic_tract_prep;

SELECT * FROM #comorb_codes;

DROP TABLE IF EXISTS #coconditions;
SELECT 
	DIAGNOSES.DIAGNOSES_ID, -- we cannot fill
	DIAGNOSES.PERSON_ID AS patid, 
	DIAGNOSES.ADATE, 
	DIAGNOSES.DX_CODETYPE,
	DIAGNOSES.dx, 
	#snomed2icd.mapTarget,
	code,
	condition,
	DATEPART(YEAR, ADATE) AS year
INTO #coconditions
FROM dbo.DIAGNOSES 
JOIN #snomed2icd ON dbo.DIAGNOSES.dx = #snomed2icd.referencedComponentId
JOIN #comorb_codes on UPPER(TRIM(#comorb_codes.code)) LIKE '%'+UPPER(TRIM(#snomed2icd.mapTarget))+'%'
WHERE ADATE >= '12/31/2016'
;

SELECT * FROM #coconditions;

DROP TABLE IF EXISTS #diagnosis_CC_ind_any;
SELECT 
patid, year,
(CASE WHEN 
	condition = 'Acanthosis_Nigricans' then 1 else 0 End) as acanthosis_nigricans,
(CASE WHEN 
	condition = 'ADHD' then 1 else 0 End) as adhd,
(CASE WHEN 
	condition = 'anxiety' then 1 else 0 End) as anxiety,
(CASE WHEN 
	condition = 'asthma' then 1 else 0 End) as asthma,
(CASE WHEN 
	condition = 'autism' then 1 else 0 End) as autism,
(CASE WHEN 
	condition = 'depression' then 1 else 0 End) as depression,
(CASE WHEN 
	condition = 'diabetes' then 1 else 0 End) as diabetes,
(CASE WHEN 
	condition = 'eating_disorders' then 1 else 0 End) as eating_disorders,
(CASE WHEN 
	condition = 'hyperlipidemia' then 1 else 0 End) as hyperlipidemia,
(CASE WHEN 
	condition = 'hypertension' then 1 else 0 End) as hypertension,
(CASE WHEN 
	condition = 'NAFLD' then 1 else 0 End) as NAFLD,
(CASE WHEN 
	condition = 'Obstructive_sleep_apnea' then 1 else 0 End) as Obstructive_sleep_apnea,
(CASE WHEN 
	condition = 'PCOS' then 1 else 0 End) as PCOS
INTO #diagnosis_CC_ind_any
from 
	(select patid, condition, year, count(DIAGNOSES_ID) as cnt
		from  #coconditions
		group by patid, year, condition
	) conditions
order by patid
;

SELECT * FROM #diagnosis_CC_ind_any;

GO

DROP TABLE IF EXISTS #cohort_demographic_tract;
SELECT 
	DISTINCT #cohort_demographic_tract_prep.*,
	CASE WHEN acanthosis_nigricans IS NULL THEN 0 ELSE acanthosis_nigricans END AS acanthosis_nigricans,
	CASE WHEN adhd IS NULL THEN 0 ELSE adhd END AS adhd,
	CASE WHEN anxiety IS NULL THEN 0 ELSE anxiety END AS anxiety,
	CASE WHEN asthma IS NULL THEN 0 ELSE asthma END AS asthma,
	CASE WHEN autism IS NULL THEN 0 ELSE autism END AS autism,
	CASE WHEN depression IS NULL THEN 0 ELSE depression END AS depression,
	CASE WHEN diabetes IS NULL THEN 0 ELSE diabetes END AS diabetes,
	CASE WHEN eating_disorders IS NULL THEN 0 ELSE eating_disorders END AS eating_disorders,
	CASE WHEN hyperlipidemia IS NULL THEN 0 ELSE hyperlipidemia END AS hyperlipidemia,
	CASE WHEN hypertension IS NULL THEN 0 ELSE hypertension END AS hypertension,
	CASE WHEN NAFLD IS NULL THEN 0 ELSE NAFLD END AS NAFLD,
	CASE WHEN Obstructive_sleep_apnea IS NULL THEN 0 ELSE Obstructive_sleep_apnea END AS Obstructive_sleep_apnea,
	CASE WHEN PCOS IS NULL THEN 0 ELSE PCOS END AS PCOS
INTO 
	#cohort_demographic_tract
FROM 
	#cohort_demographic_tract_prep
	LEFT JOIN #diagnosis_CC_ind_any ON #cohort_demographic_tract_prep.patid = #diagnosis_CC_ind_any.patid
;

GO
SELECT * FROM #cohort_demographic_tract;

DROP TABLE IF EXISTS cohort_tract_comorb;
SELECT 
	linkid,
	site,
	yr,
	latitude,
	longitude,
	STATE,
	ZIP,
	TRACT,
	COUNTY,
	acanthosis_nigricans,
	adhd,
	anxiety,
	asthma,
	autism,
	depression,
	diabetes,
	eating_disorders,
	hyperlipidemia,
	hypertension,
	NAFLD,
	Obstructive_sleep_apnea,
	PCOS
INTO 
	cohort_tract_comorb
FROM 
	#cohort_demographic_tract
;
SELECT * FROM cohort_tract_comorb;
SELECT * FROM cohort_tract;



DROP TABLE IF EXISTS #distinct_cohort
SELECT linkid, patid, birth_date, count(linkid) AS cnt
INTO #distinct_cohort
FROM cohort_demographic_insurance_prep
GROUP BY linkid, patid, birth_date
;

-- SELECT * FROM #pmca 

DROP TABLE IF EXISTS #pmca_input
SELECT 
	DIAGNOSES.PERSON_ID AS patid, 
	COUNT(DISTINCT body_system) AS body_system, 
	MAX(severity) AS severity
INTO 
	#pmca_input
FROM 
	dbo.DIAGNOSES JOIN ( 
		SELECT 
			icd10 AS dx, 
			'10' AS dx_type, 
			body_system,
			CASE WHEN progressive IN ('Yes', 'yes') THEN 2 ELSE 1 END AS severity
		FROM 
			#pmca
		UNION ALL
		SELECT 
			referencedComponentId, 
			'SM', 
			body_system,
			CASE WHEN progressive IN ('Yes', 'yes') THEN 2 ELSE 1 END AS severity
		FROM #pmca 
		JOIN #snomed2icd ON icd10 = mapTarget)  pmca_codes ON pmca_codes.dx = DIAGNOSES.dx AND pmca_codes.dx_type = DIAGNOSES.DX_CODETYPE
GROUP BY DIAGNOSES.PERSON_ID;

DROP TABLE IF EXISTS #pmca_input_system
SELECT 
	DIAGNOSES.PERSON_ID AS patid, 
	body_system AS body_system_name, 
	MAX(severity) AS severity
	--severity
INTO 
	#pmca_input_system
FROM 
	dbo.DIAGNOSES JOIN ( 
		SELECT 
			icd10 AS dx, 
			'10' AS dx_type, 
			body_system,
			CASE WHEN progressive IN ('Yes', 'yes') THEN 2 ELSE 1 END AS severity
		FROM 
			#pmca
		UNION ALL
		SELECT 
			referencedComponentId, 
			'SM', 
			body_system,
			CASE WHEN progressive IN ('Yes', 'yes') THEN 2 ELSE 1 END AS severity
		FROM #pmca 
		JOIN #snomed2icd ON icd10 = mapTarget)  pmca_codes ON pmca_codes.dx = DIAGNOSES.dx AND pmca_codes.dx_type = DIAGNOSES.DX_CODETYPE
GROUP BY DIAGNOSES.PERSON_ID, body_system;


DROP TABLE IF EXISTS #pmca_input_single
SELECT 
	* 
INTO #pmca_input_single
FROM #pmca_input 
WHERE body_system = 1;

DROP TABLE IF EXISTS #pmca_output_single_system
SELECT 
	#pmca_input_single.patid,
	#pmca_input_single.body_system,
	#pmca_input_system.body_system_name,
	#pmca_input_single.severity
INTO #pmca_output_single_system
FROM 
	#pmca_input_single
		LEFT JOIN #pmca_input_system ON #pmca_input_single.patid = #pmca_input_system.patid
;

SELECT * FROM #pmca_output_single_system;


DROP TABLE IF EXISTS #pmca_output_prep
SELECT 
	linkid, 
	#pmca_input.*,
	#pmca_output_single_system.body_system_name
INTO 
	#pmca_output_prep
FROM 
	#distinct_cohort
		LEFT JOIN #pmca_input ON #distinct_cohort.patid = #pmca_input.patid
		LEFT JOIN #pmca_output_single_system ON #distinct_cohort.patid = #pmca_output_single_system.patid
;


SELECT * FROM #pmca_output_prep WHERE patid IS NOT NULL;

DROP TABLE IF EXISTS pmca_output
SELECT 
	linkid, 
	body_system,
	body_system_name,
	severity,
	CASE 
        WHEN body_system = 1 AND severity = 1 THEN 1
		WHEN body_system IS NULL AND severity IS NULL THEN 0 
		ELSE 2
	END AS pmca
into pmca_output
FROM #pmca_output_prep 
;

SELECT * FROM pmca_output;

--SELECT * FROM pmca_output WHERE body_system IS NOT NULL ORDER BY body_system;
--SELECT * FROM pmca_output WHERE severity IS NOT NULL ORDER BY severity;

DROP TABLE IF EXISTS measures_output_prep
SELECT 
	linkid, 
	VITAL_SIGNS.PERSON_ID AS patid, 
	ht,
	wt, 
	VITAL_SIGNS.MEASURE_DATE
INTO measures_output_prep
FROM dbo.VITAL_SIGNS 
JOIN #distinct_cohort ON #distinct_cohort.patid = VITAL_SIGNS.PERSON_ID
WHERE (select year from dbo.get_age (birth_date, VITAL_SIGNS.MEASURE_DATE) ) >= 2
AND wt IS NOT NULL AND ht IS NOT NULL
;

DROP TABLE IF EXISTS measures_output
SELECT 
	measures_output_prep.linkid, 
	measures_output_prep.ht, 
	measures_output_prep.wt, 
	measures_output_prep.measure_date,
	cohort_demographic_insurance_prep.insurance_type
INTO measures_output
FROM 
	measures_output_prep
		LEFT JOIN cohort_demographic_insurance_prep ON measures_output_prep.linkid = cohort_demographic_insurance_prep.linkid
;

SELECT * FROM #cohort_demographic_tract_prep;

SELECT * FROM #race_con_codes;

DROP TABLE IF EXISTS #race_condition_inputs
SELECT 
	PERSON_ID AS patid, 
	category, 
	COUNT(DIAGNOSES_ID) AS count, 
	MIN(ADATE) AS early_admit_date
INTO #race_condition_inputs
FROM 
	dbo.DIAGNOSES 
		JOIN #race_con_codes ON dbo.DIAGNOSES.DX_CODETYPE = #race_con_codes.dx_type AND 
								UPPER(TRIM(dbo.DIAGNOSES.DX)) = UPPER(TRIM(#race_con_codes.dx))
GROUP BY PERSON_ID, category
;

SELECT * FROM #race_condition_inputs;

DROP TABLE IF EXISTS race_condition_inputs
SELECT 
	dbo.link.linkid,
	category, 
	count,
	early_admit_date
INTO race_condition_inputs
FROM
	#race_condition_inputs
		LEFT JOIN dbo.link ON #race_condition_inputs.patid = dbo.link.patid
;


-- SELECT * FROM cohort_tract;
SELECT * FROM cohort_tract_comorb ORDER BY linkid;
SELECT * FROM pmca_output ORDER BY pmca;
SELECT * FROM measures_output;
SELECT * FROM race_condition_inputs;

--- test
/*
SELECT * FROM #race_con_codes;

DROP TABLE IF EXISTS #race_condition_inputs
SELECT 
	patid, 
	category, 
	COUNT(diagnosisid) AS count, 
	MIN(admit_date) AS early_admit_date
INTO #race_condition_inputs
FROM 
	cdm.diagnosis 
		JOIN #snomed2icd ON cdm.diagnosis.dx = #snomed2icd.referencedComponentId
		JOIN #race_con_codes ON (cdm.diagnosis.dx_type = #race_con_codes.dx_type AND 
								UPPER(TRIM(cdm.diagnosis.dx)) LIKE UPPER(TRIM(#race_con_codes.dx))) OR
								UPPER(TRIM(#snomed2icd.mapTarget)) LIKE UPPER(TRIM(#race_con_codes.dx))


		
GROUP BY patid, category;

SELECT * FROM #race_condition_inputs;


DROP TABLE IF EXISTS #con_test
SELECT 
	*
INTO #con_test
FROM 
	cdm.diagnosis 
		JOIN #snomed2icd ON cdm.diagnosis.dx = #snomed2icd.referencedComponentId
		--JOIN #race_con_codes ON '%'+UPPER(TRIM(#snomed2icd.mapTarget))+'%' LIKE '%'+UPPER(TRIM(#race_con_codes.dx))+'%'
;


SELECT * FROM #con_test
JOIN #race_con_codes ON '%'+UPPER(TRIM(#con_test.mapTarget))+'%' LIKE UPPER(TRIM(#race_con_codes.dx))

SELECT UPPER(TRIM('J45.909')) AS Result;
*/

(SELECT linkid, yr, site, tract FROM cohort_tract_comorb EXCEPT SELECT linkid, yr, site, tract FROM cohort_tract) 
UNION ALL
(SELECT linkid, yr, site, tract FROM cohort_tract EXCEPT SELECT linkid, yr, site, tract FROM cohort_tract_comorb);