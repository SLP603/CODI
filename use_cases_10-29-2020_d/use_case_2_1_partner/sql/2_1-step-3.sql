--use ch_VDW;
--go
-- Usecase 2.1

-- STEP 3 - Load data needed for propensity score matching (PSM)
-- Build the dataset that will go into the PSM computation.
-- PS calculated using age, sex, all co-occurring conditions in the Co-occurring conditions table (except obesity!),
-- pediatric medical complexity algorithm, percent of 95% percentile BMI, distance from program, primary language,
-- race, ethnicity, insurance coverage (categorized as Tricare, Public non-tricare, Other).


------- Update According to Data Partner Environment ----------
---------------------------------------------------------------

DECLARE @file_path varchar(100), 
		@input_file varchar(255), 
		@file_path_DCC_out varchar(255),
		@pmca_path varchar(255)
DECLARE @snomed2icd_path varchar(255), @bmiperc_path varchar(255),@comob_path varchar(255)

SET @file_path = 'C:\\codi_data\\reference\\' -- edit this for \reference file path
SET @file_path_DCC_out = 'C:\\Users\\hzhang\\Documents\\use_case_tests_hl_sql_scripts\\DCC_out\\' -- edit this for \DCC_out file path

SET @input_file = @file_path_DCC_out + 'index_site_kp.csv' -- edit this
SET @pmca_path = @file_path + 'pmca-version-3.1_icd10-code-list.csv'
SET @snomed2icd_path = @file_path + 'snomed2icd.csv'
SET @bmiperc_path = @file_path + 'bmiagerev.csv'
SET @comob_path = @file_path + 'comorb_codes.csv'

------ LOAD TABLES FROM FILES -----

------ LOAD DCC Data ----
DROP TABLE IF EXISTS #patientlist
CREATE TABLE #patientlist (
	linkid varchar(255),
	site varchar(10),
	index_site varchar(10),
	inclusion int,
	exclusion int
)
EXECUTE dbo.CreateTempTable '#patientlist', @input_file 

SELECT * FROM #patientlist;

DROP TABLE IF EXISTS #bmiage;
CREATE TABLE #bmiage (
    sex char(1),
    agemos integer,
    l double precision,
    m double precision,
    s double precision,
    p3 double precision,
    p5 double precision,
    p10 double precision,
    p25 double precision,
    p50 double precision,
    p75 double precision,
    p85 double precision,
    p90 double precision,
    p95 double precision,
    p97 double precision
);

EXECUTE dbo.CreateTempTable '#bmiage', @bmiperc_path 

-- Load the PMCA codes from Excel
-- Build up all codes from ICD10 and SNOMED that correspond to PMCA inputs.
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

------ END LOAD TABLES FROM FILES -----

DROP TABLE IF EXISTS #study_programs;
CREATE TABLE #study_programs (programid varchar(15))
-- TODO: Enumerate Denver-specific programids.
INSERT INTO #study_programs (programid)
VALUES 
('cwmp')
--, ('hf'),
-- ;

-- Enumerates all patids of children of the correct age
--	with a 2017 intervention and
--	no late 2016 intervention.
DROP TABLE IF EXISTS #study_cohort;
GO
SELECT 
	PERSON_ID AS patid, 
	birth_date, 
	(SELECT year from dbo.get_age(birth_date, '1/1/2017')) AS study_age_yrs
INTO #study_cohort
 FROM dbo.DEMOGRAPHICS
 WHERE PERSON_ID IN (
	SELECT patid 
	FROM dbo.session
		 WHERE DATEPART(YEAR, session_date) = 2017
		 AND programid IN (SELECT programid from #study_programs)
	EXCEPT 
	SELECT patid  
	FROM dbo.session
		WHERE session_date >= '1-Jun-2016' AND session_date < '1-Jan-2017'
		AND programid IN (SELECT programid from #study_programs)
 )
AND (SELECT year from dbo.get_age(birth_date, '1/1/2017')) BETWEEN 2 AND 19;
GO


DROP TABLE IF EXISTS #cohort;
GO
CREATE TABLE #cohort (
	linkid varchar(255) PRIMARY KEY,
	patid varchar(255) ,
	ageyrs integer, -- Is this the right unit?
	sex varchar(2),
	pmca integer,
	bmi double precision,
	bmi_percent_of_p95 double precision,
	distance_from_program double precision, -- In what units?
	pat_pref_language_spoken varchar(3),
	race varchar(2),
	hispanic varchar(2),
	insurance varchar(20),
	in_study_cohort bit default(0),
	index_site_flag varchar(5),
	inclusion int, 
	exclusion int		
);

INSERT INTO #cohort
(linkid, d.patid, sex, pat_pref_language_spoken, race, hispanic, in_study_cohort, index_site_flag, ageyrs, inclusion, exclusion)
SELECT #patientlist.linkid, d.PERSON_ID, GENDER, PRIMARY_LANGUAGE, RACE1, hispanic, 
	   CASE WHEN s.patid IS NOT NULL THEN 1 ELSE 0 END AS in_study_cohort,
	   CASE WHEN UPPER(#patientlist.site) = UPPER(#patientlist.index_site) THEN 'T' ELSE 'F' END AS index_site_flag,
	   (SELECT year from dbo.get_age(d.birth_date, '1/1/2017')),
	   inclusion,
	   exclusion
FROM dbo.DEMOGRAPHICS d
JOIN dbo.link ON link.patid = d.PERSON_ID
JOIN #patientlist ON #patientlist.linkid = link.linkid
LEFT OUTER JOIN #study_cohort s ON d.PERSON_ID = s.patid
WHERE exclusion != 1
;

SELECT * FROM #cohort;
SELECT * FROM #patientlist WHERE inclusion = 1;
SELECT * FROM #cohort WHERE in_study_cohort = 1;

DROP TABLE IF EXISTS #anchor_study_cohort;
GO
SELECT linkid, ENCOUNTERS.PERSON_ID AS patid, first_session_date, MAX(measure_date) AS measure_date
INTO #anchor_study_cohort
FROM dbo.ENCOUNTERS
JOIN dbo.VITAL_SIGNS on VITAL_SIGNS.ENC_ID = ENCOUNTERS.ENC_ID
JOIN
( SELECT #cohort.linkid, session.patid, MIN(session_date) as first_session_date
	FROM dbo.session
	JOIN #cohort ON #cohort.patid = session.patid 
	WHERE DATEPART(YEAR, session_date) = 2017
	AND #cohort.in_study_cohort = 1
	GROUP BY #cohort.linkid, session.patid) first_session ON first_session.patid = ENCOUNTERS.PERSON_ID AND  measure_date < first_session_date
WHERE ENCOUNTERS.ENCTYPE = 'AV'
AND ht IS NOT NULL
AND wt IS NOT NULL
GROUP BY linkid, ENCOUNTERS.PERSON_ID, first_session_date

SELECT * FROM #anchor_study_cohort;

DROP TABLE IF EXISTS #anchor_comparison_cohort;
GO
SELECT linkid, #cohort.patid, (
  SELECT top 1 ENC_ID
	FROM ( SELECT ENCOUNTERS.ENC_ID, ENCOUNTERS.PERSON_ID, measure_date
	FROM dbo.ENCOUNTERS  
	JOIN dbo.VITAL_SIGNS on VITAL_SIGNS.ENC_ID = ENCOUNTERS.ENC_ID
	WHERE ENCOUNTERS.ENCTYPE = 'AV'
	AND ht IS NOT NULL
	AND wt IS NOT NULL
	AND measure_date between '1/1/2017' AND '12/31/2017' 
	AND ENCOUNTERS.PERSON_ID = #cohort.patid
	) a 
	order by NEWID()
) as random_encounterid
INTO #anchor_comparison_cohort
FROM #cohort
WHERE in_study_cohort = 0


SELECT * FROM #anchor_comparison_cohort ORDER BY linkid;

DROP TABLE IF EXISTS #anchor_date;
GO
SELECT #anchor_study_cohort.*, VITAL_SIGNS.ht, VITAL_SIGNS.wt, VITAL_SIGNS.ENC_ID
INTO #anchor_date
FROM #anchor_study_cohort
JOIN #cohort ON #cohort.patid = #anchor_study_cohort.patid
JOIN dbo.VITAL_SIGNS ON VITAL_SIGNS.PERSON_ID = #anchor_study_cohort.patid AND VITAL_SIGNS.measure_date = #anchor_study_cohort.measure_date
JOIN dbo.ENCOUNTERS ON VITAL_SIGNS.ENC_ID = ENCOUNTERS.ENC_ID
WHERE ENCOUNTERS.ENCTYPE = 'AV'
UNION
SELECT linkid, #anchor_comparison_cohort.patid, NULL as first_session, VITAL_SIGNS.measure_date, VITAL_SIGNS.ht, VITAL_SIGNS.wt,  #anchor_comparison_cohort.random_encounterid as encounterid 
FROM #anchor_comparison_cohort
JOIN dbo.VITAL_SIGNS ON VITAL_SIGNS.ENC_ID = #anchor_comparison_cohort.random_encounterid

SELECT * FROM #anchor_date;

DELETE #cohort
WHERE patid in 
	(SELECT patid FROM #cohort WHERE patid NOT IN (select patid FROM #anchor_date))


-- For each patient count the number of body systems and see if any condition is chronic
DROP TABLE IF EXISTS #pmca_input
SELECT
	DIAGNOSES.PERSON_ID AS patid,
	COUNT(DISTINCT body_system) AS body_system,
	MAX(severity) AS severity
INTO #pmca_input
FROM dbo.DIAGNOSES 
JOIN ( SELECT icd10 AS dx, '10' AS dx_type, body_system,
		CASE WHEN progressive IN ('Yes', 'yes') THEN 2 ELSE 1 END AS severity
		FROM #pmca
		UNION ALL
		SELECT referencedComponentId, 'SM', body_system,
				CASE WHEN progressive IN ('Yes', 'yes') THEN 2 ELSE 1 END AS severity
		FROM #pmca 
		JOIN #snomed2icd ON icd10 = mapTarget)  pmca_codes ON pmca_codes.dx = DIAGNOSES.dx AND pmca_codes.dx_type = DIAGNOSES.DX_CODETYPE
JOIN #anchor_date on #anchor_date.patid = DIAGNOSES.PERSON_ID
WHERE DIAGNOSES.ADATE between  DATEADD(MONTH, -8, #anchor_date.measure_date) and #anchor_date.measure_date
GROUP BY DIAGNOSES.PERSON_ID;

SELECT
	DIAGNOSES.PERSON_ID AS patid,
	COUNT(DISTINCT body_system) AS body_system,
	MAX(severity) AS severity
FROM dbo.DIAGNOSES 
JOIN ( SELECT icd10 AS dx, '10' AS dx_type, body_system,
		CASE WHEN progressive IN ('Yes', 'yes') THEN 2 ELSE 1 END AS severity
		FROM #pmca
		UNION ALL
		SELECT referencedComponentId, 'SM', body_system,
				CASE WHEN progressive IN ('Yes', 'yes') THEN 2 ELSE 1 END AS severity
		FROM #pmca 
		JOIN #snomed2icd ON icd10 = mapTarget
		)  pmca_codes ON pmca_codes.dx = DIAGNOSES.dx AND pmca_codes.dx_type = DIAGNOSES.DX_CODETYPE
JOIN #anchor_date on #anchor_date.patid = DIAGNOSES.PERSON_ID
WHERE DIAGNOSES.ADATE between  DATEADD(MONTH, -8, #anchor_date.measure_date) and #anchor_date.measure_date
GROUP BY DIAGNOSES.PERSON_ID;

SELECT * FROM #pmca_input ORDER BY patid;

UPDATE #cohort
SET pmca = (
	SELECT CASE WHEN body_system > 1 OR severity > 1 THEN 2 ELSE 1 END
	FROM #pmca_input
	WHERE #cohort.patid = #pmca_input.patid
);

UPDATE #cohort
SET pmca = 0
WHERE pmca IS NULL;

-- Calculate BMI
UPDATE #bmiage 
SET sex = CASE WHEN sex = '0' THEN 'M' WHEN sex = '1' THEN 'F' END;


DROP TABLE IF EXISTS #annotated_measures;
SELECT 
	#anchor_date.patid,
	ht, 
	wt,
	measure_date, 
	(wt * .4535924) / SQUARE(ht * .0254) AS bmi,
	p95, 
	100 * (((wt * .4535924) / SQUARE(ht * .0254)) / p95) AS bmi_percent_of_p95,
	'VITAL' as src,
	DEMOGRAPHICS.GENDER AS sex, 
	DATEDIFF(DAY, birth_date, measure_date) agedays,
	(select year*12+month from dbo.get_age (birth_date, measure_date)) as agemos
INTO #annotated_measures
FROM #anchor_date 
JOIN dbo.DEMOGRAPHICS ON DEMOGRAPHICS.PERSON_ID = #anchor_date.patid
JOIN #bmiage ON DEMOGRAPHICS.GENDER = #bmiage.sex AND #bmiage.agemos = (select year*12+month from dbo.get_age (birth_date, #anchor_date.measure_date))

SELECT * FROM #annotated_measures;

UPDATE #cohort
SET bmi = (
	SELECT bmi
	FROM #annotated_measures
	WHERE #cohort.patid = #annotated_measures.patid
);
GO

DROP TABLE IF EXISTS #tmpbmi;
SELECT patid, MAX(bmi_percent_of_p95) AS bmi_percent_of_p95
INTO #tmpbmi
FROM #annotated_measures
GROUP BY patid;

UPDATE #cohort
SET bmi_percent_of_p95 = (
	SELECT #tmpbmi.bmi_percent_of_p95 
	FROM #tmpbmi
	WHERE #cohort.patid = #tmpbmi.patid
);
GO

-- Get Insurance 
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
JOIN #anchor_date ON #anchor_date.ENC_ID = ENCOUNTERS.ENC_ID


UPDATE #cohort
SET insurance = (SELECT insurance_type
		FROM #insurance
		WHERE #cohort.patid = #insurance.PERSON_ID)
;
UPDATE #cohort
SET insurance = 'Other or unknown'
WHERE insurance IS NULL

-- calculate co-conditions ---
DROP TABLE IF EXISTS #coconditions;
SELECT 
	DIAGNOSES.DIAGNOSES_ID AS diagnosisid, 
	DIAGNOSES.PERSON_ID AS patid, 
	DIAGNOSES.ADATE AS admit_date, 
	DIAGNOSES.DX_CODETYPE AS dx_type,
	DIAGNOSES.dx, 
	#snomed2icd.mapTarget,
	code,
	condition
INTO #coconditions
FROM dbo.DIAGNOSES 
JOIN #snomed2icd ON dbo.DIAGNOSES.dx = #snomed2icd.referencedComponentId
JOIN #comorb_codes on UPPER(TRIM(#comorb_codes.code)) LIKE '%'+UPPER(TRIM(#snomed2icd.mapTarget))+'%'
JOIN #anchor_date ON #anchor_date.patid = DIAGNOSES.PERSON_ID 
WHERE ADATE < #anchor_date.measure_date 
AND ADATE >= DATEADD(MONTH, -8, #anchor_date.measure_date)

SELECT * FROM #coconditions;

DROP TABLE IF EXISTS #diagnosis_CC_ind_any;
SELECT 
patid,
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
	(select patid, condition, count(diagnosisid) as cnt
		from  #coconditions
		group by patid, condition
	) conditions
order by patid

-- merge with CC indicators with cohort
DROP TABLE IF EXISTS cohort_CC
SELECT 
	#cohort.linkid,
	#cohort.ageyrs,
	#cohort.sex,
	#cohort.pmca,
	#cohort.bmi,
	#cohort.bmi_percent_of_p95,
	#cohort.pat_pref_language_spoken,
	#cohort.race,
	#cohort.hispanic,
	#cohort.insurance,
	#cohort.in_study_cohort,
	#cohort.index_site_flag,
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
	cohort_CC
FROM #cohort 
LEFT JOIN #diagnosis_CC_ind_any ON #cohort.patid = #diagnosis_CC_ind_any.patid


SET NOCOUNT ON
SELECT * FROM cohort_CC;
