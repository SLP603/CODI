-- Usecase 2.1

------- Update According to Data Partner Environment ----------
---------------------------------------------------------------

------ LOAD DCC Data ----
DECLARE @file_path varchar(100), 
		@file_path_DCC_out varchar(255),
		@input_file varchar(255), 
		@input_file_adi varchar(255),
		@pmca_path varchar(255)
DECLARE @snomed2icd_path varchar(255), @bmiperc_path varchar(255),@comob_path varchar(255)

SET @file_path = 'C:\\codi_data\\reference\\' -- edit this to where ref files are stored
SET @file_path_DCC_out = 'C:\\Users\\hzhang\\Documents\\use_case_tests_hl_sql_scripts\\DCC_out\\' -- edit this to where files from DCC are stored
SET @input_file = @file_path_DCC_out + 'matched_data.csv'
SET @input_file_adi = @file_path + 'CO_tract_adi.csv'

-- import #patientlist from matched_data
DROP TABLE IF EXISTS #patientlist
--GO
CREATE TABLE #patientlist (
	linkid varchar(255),
	in_study_cohort int,
	index_site varchar(2)
)
EXECUTE dbo.CreateTempTable '#patientlist', @input_file 

SET NOCOUNT ON

SELECT * FROM #patientlist;

/* EDIT THE FOLLOWING */

/* Uncomment and edit UPPER(' ') for CH, DH, and KP. 
   Comment out entire line for GOTR and HFC. */

DELETE #patientlist WHERE index_site <> UPPER('CH'); -- EDIT THIS

/* END OF EDITS */


SELECT * FROM #patientlist;

-- import tract_adi
DROP TABLE IF EXISTS #tract_adi
--GO
CREATE TABLE #tract_adi (
	census_tract varchar(255),
	block_group_count int,
	natrank_avg varchar(255),
	staterank_avg varchar(255)
)
EXECUTE dbo.CreateTempTable '#tract_adi', @input_file_adi 

SELECT * FROM #tract_adi;

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

SELECT * FROM #study_cohort;

DROP TABLE IF EXISTS #cohort;
GO
CREATE TABLE #cohort (
	linkid varchar(255) PRIMARY KEY,
	patid varchar(255) ,
	race varchar(2),
	hispanic varchar(2),
	sex varchar(2),
	birth_date date,
	in_study_cohort bit default(0),
	index_site_flag varchar(5),
	ageyrs int
);

INSERT INTO #cohort
(linkid, d.patid, sex, birth_date, race, hispanic, in_study_cohort, ageyrs)
SELECT #patientlist.linkid, d.PERSON_ID, GENDER, d.birth_date, RACE1, hispanic, 
	   CASE WHEN s.patid IS NOT NULL THEN 1 ELSE 0 END,
	   --CASE WHEN UPPER(#patientlist.site) = UPPER(#patientlist.index_site) THEN 'T' ELSE 'F' END,
	  (SELECT year from dbo.get_age(d.birth_date, '1/1/2017'))
FROM dbo.DEMOGRAPHICS d
JOIN dbo.link ON link.patid = d.PERSON_ID
JOIN #patientlist ON #patientlist.linkid = link.linkid
LEFT OUTER JOIN #study_cohort s ON d.PERSON_ID = s.patid;

SELECT * FROM #cohort;

--- calculate index date
DROP TABLE IF EXISTS #anchor_study_cohort;
GO
SELECT 
	linkid, 
	ENCOUNTERS.PERSON_ID AS patid, 
	first_session_date, 
	MAX(measure_date) AS measure_date
INTO #anchor_study_cohort
FROM dbo.ENCOUNTERS
JOIN dbo.VITAL_SIGNS on VITAL_SIGNS.ENC_ID = ENCOUNTERS.ENC_ID
JOIN
( SELECT linkid, session.patid, MIN(session_date) as first_session_date
	FROM dbo.session
	JOIN #cohort ON #cohort.patid = session.patid 
	WHERE DATEPART(YEAR, session_date) = 2017
	AND #cohort.in_study_cohort = 1
	GROUP BY linkid, session.patid ) first_session ON first_session.patid = ENCOUNTERS.PERSON_ID AND  measure_date < first_session_date
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

SELECT * FROM #anchor_comparison_cohort;

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

SELECT * FROM #cohort;

DROP TABLE IF EXISTS cohort_out;
GO
SELECT 
	#cohort.linkid,
	#cohort.race,
	#cohort.hispanic,
	#cohort.sex,
	#cohort.birth_date,
	#cohort.in_study_cohort,
	#cohort.ageyrs
INTO cohort_out
FROM #cohort;

SELECT * FROM cohort_out;

--- HEALTH OUTCOME
DROP TABLE IF EXISTS OUTCOME_VITALS;
GO
SELECT 
		#anchor_date.linkid, 
		ENCOUNTERS.ADATE AS admit_date, 
		ENCOUNTERS.ENCTYPE AS enc_type,
		VITAL_SIGNS.measure_date,
		VITAL_SIGNS.ht, 
		VITAL_SIGNS.wt,
		CASE
			WHEN VITAL_SIGNS.ht IS NOT NULL AND VITAL_SIGNS.wt IS NOT NULL THEN (VITAL_SIGNS.wt * .4535924) / SQUARE(VITAL_SIGNS.ht * .0254)
			ELSE null 
		END AS bmi,
		diastolic,
		systolic
INTO OUTCOME_VITALS
FROM #anchor_date
JOIN dbo.VITAL_SIGNS ON VITAL_SIGNS.PERSON_ID = #anchor_date.patid
JOIN dbo.ENCOUNTERS ON ENCOUNTERS.ENC_ID =  VITAL_SIGNS.ENC_ID
JOIN #patientlist ON #patientlist.linkid = #anchor_date.linkid
WHERE VITAL_SIGNS.measure_date >= DATEADD(month, -8, #anchor_date.measure_date)
ORDER BY linkid

SELECT * FROM OUTCOME_VITALS;

--- LAB RESULTS 
DROP TABLE IF EXISTS #lab_codes
GO
CREATE TABLE #lab_codes (
	test_type varchar(255),	
	coding_system varchar(50),
	code varchar(50),	
	notes varchar(255)
)

BULK
INSERT #lab_codes 
FROM 'c:\codi_data\use_case_tests\lab_codes.csv' WITH
(	
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a'
)


DROP TABLE IF EXISTS OUTCOME_LAB_RESULTS;
GO
SELECT
	#anchor_date.linkid, 
	LOINC,
	PX, 
	CODETYPE,
	RESULT_DT, 
	MODIFIER, 
	RESULT_UNIT, 
	RESULT_NUM, 
	[NORMAL_LOW_C], --norm_range_low, 
	[NORMAL_HIGH_C]norm_range_high, 
	MODIFIER_LOW, 
	MODIFIER_HIGH, 
	abn_ind
INTO OUTCOME_LAB_RESULTS
FROM dbo.LAB_RESULTS
JOIN #anchor_date ON #anchor_date.patid = LAB_RESULTS.PERSON_ID
JOIN #patientlist ON #patientlist.linkid = #anchor_date.linkid
WHERE RESULT_DT >= DATEADD(month, -8, #anchor_date.measure_date)
AND LOINC IN (SELECT code FROM #lab_codes)
ORDER BY linkid

SELECT * FROM OUTCOME_LAB_RESULTS;

--- Exposure  
DROP TABLE IF EXISTS EXPOSURE_DOSE;
GO
SELECT 
	link.linkid, 
	program_name, 
	session_date, 
	dose, 
	screening, 
	counseling, 
	intervention_activity, 
	intervention_nutrition,
	intervention_navigation
	program_description,
	aim_activity, 
	aim_nutrition, 
	aim_weight, 
	prescribed_total_dose, 
	prescribed_program_duration,
	prescribed_session_frequency,
	prescribed_session_length
	program_setting, 
	program_mode, 
	location_address
	location_latitude,
	location_longitude,
	location_geocode,
	location_boundary_year,
	location_geolevel
INTO EXPOSURE_DOSE
FROM 
	dbo.session
JOIN dbo.program ON program.programid = session.programid
JOIN dbo.link ON session.patid = link.patid
JOIN #patientlist ON #patientlist.linkid = link.linkid
WHERE session_date >= '1/1/2017'
ORDER BY linkid

SELECT * FROM EXPOSURE_DOSE;

--- HF Participants
DROP TABLE IF EXISTS HF_PARTICIPANTS;
GO
SELECT 
	link.linkid,
	session.session_id,
	session.programid, 
	program_name, 
	session_date
INTO 
	HF_PARTICIPANTS
FROM
	dbo.session
JOIN dbo.program ON program.programid = session.programid
JOIN dbo.link ON session.patid = link.patid
JOIN #patientlist ON #patientlist.linkid = link.linkid
WHERE session_date >= '1/1/2017'
AND session.programid ='hf'
ORDER BY linkid, session_date desc

SELECT * FROM HF_PARTICIPANTS;


-- ADI WIP

SELECT * FROM #cohort;
SELECT * FROM dbo.census_location;

DROP TABLE IF EXISTS #ADI_OUT;
GO
SELECT 
	#cohort.linkid,
	#cohort.patid,
	dbo.census_location.loc_start,
	dbo.census_location.loc_end,
	dbo.census_location.geocode,
	dbo.census_location.latitude,
	dbo.census_location.longitude,
	#tract_adi.block_group_count,
	#tract_adi.natrank_avg,
	#tract_adi.staterank_avg
INTO #ADI_OUT
FROM #cohort
	LEFT JOIN dbo.census_location ON #cohort.patid = dbo.census_location.PERSON_ID
	LEFT JOIN #tract_adi ON dbo.census_location.geocode = #tract_adi.census_tract
ORDER BY linkid
;

SELECT * FROM #ADI_OUT ORDER BY linkid;

DROP TABLE IF EXISTS ADI_OUT;
GO
SELECT 
	linkid,
	loc_start,
	loc_end,
	geocode,
	latitude,
	longitude,
	block_group_count,
	natrank_avg,
	staterank_avg
INTO ADI_OUT
FROM #ADI_OUT;


SELECT * FROM ADI_OUT ORDER BY linkid;

-- dietician or nutritionist encounter WIP

SELECT * FROM #anchor_date;


DROP TABLE IF EXISTS #TYPE_ENC_OUT;
GO
SELECT 
	#anchor_date.linkid, 
	ENCOUNTERS.ADATE AS admit_date, 
	ENCOUNTERS.ENCTYPE AS enc_type,
	ENCOUNTERS.PROVIDER,
	PROVIDER_SPECIALTY.SPECIALTY,
	PROVIDER_SPECIALTY.SPECIALTY2,
	PROVIDER_SPECIALTY.SPECIALTY3,
	PROVIDER_SPECIALTY.SPECIALTY4,
	PROVIDER_TYPE
INTO #TYPE_ENC_OUT
FROM #anchor_date
	JOIN dbo.ENCOUNTERS ON dbo.ENCOUNTERS.PERSON_ID = #anchor_date.patid
	JOIN dbo.PROVIDER_SPECIALTY ON ENCOUNTERS.PROVIDER = dbo.PROVIDER_SPECIALTY.PROVIDER
WHERE ENCOUNTERS.ADATE >= DATEADD(month, -8, #anchor_date.measure_date)
ORDER BY linkid

SELECT * FROM #TYPE_ENC_OUT;

-- Map to SPECIALTY and PROVIDER_TYPE for now
DROP TABLE IF EXISTS #DIET_NUTR_ENC;
GO
SELECT 
	#TYPE_ENC_OUT.linkid,
	#TYPE_ENC_OUT.admit_date,
	#TYPE_ENC_OUT.enc_type,
	#TYPE_ENC_OUT.SPECIALTY,
	#TYPE_ENC_OUT.SPECIALTY2,
	#TYPE_ENC_OUT.SPECIALTY3,
	#TYPE_ENC_OUT.SPECIALTY4,
	#TYPE_ENC_OUT.PROVIDER_TYPE,
	YEAR(#TYPE_ENC_OUT.admit_date) AS yr
INTO #DIET_NUTR_ENC
FROM #TYPE_ENC_OUT
WHERE 
	SPECIALTY IN (
		'NUT'
	) OR
	SPECIALTY2 IN (
		'NUT'
	) OR
	SPECIALTY3 IN (
		'NUT'
	) OR
	SPECIALTY4 IN (
		'NUT'
	) OR
	PROVIDER_TYPE IN (
		'020',
		'021'
	)
;

	/*provider_specialty_primary IN ('136A00000X', -- Dietetic Technician, Registered
								   '133V00000X', -- Dietitian, Registered
								   '133VN1101X', -- Nutrition, Gerontological
								   '133VN1006X', -- Nutrition, Metabolic
								   '133VN1201X', -- Nutrition, Obesity and Weight Management
								   '133VN1301X', -- Nutrition, Oncology
								   '133VN1004X', -- Nutrition, Pediatric
								   '133VN1401X', -- Nutrition, Pediatric Critical Care
								   '133VN1005X', -- Nutrition, Renal
								   '133VN1501X', -- Nutrition, Sports Dietetics
								   '133N00000X' -- Nutritionist
								   )
	*/

DROP TABLE IF EXISTS DIET_NUTR_ENC;
GO
SELECT 
	#DIET_NUTR_ENC.linkid,
	#DIET_NUTR_ENC.yr,
	COUNT(#DIET_NUTR_ENC.linkid) AS enc_count
INTO DIET_NUTR_ENC
FROM #DIET_NUTR_ENC
GROUP BY linkid, yr
;

SELECT * FROM DIET_NUTR_ENC;

-- convert the following to CSV
--SELECT * FROM cohort_out;
SELECT * FROM OUTCOME_VITALS;
SELECT * FROM OUTCOME_LAB_RESULTS;
SELECT * FROM EXPOSURE_DOSE; -- for GOTR and HFC
SELECT * FROM HF_PARTICIPANTS; -- for GOTR and HFC
SELECT * FROM ADI_OUT; -- for GOTR and HFC
SELECT * FROM DIET_NUTR_ENC;