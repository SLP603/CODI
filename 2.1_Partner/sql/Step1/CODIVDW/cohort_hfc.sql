DROP TABLE IF EXISTS #cohort;
CREATE TABLE #cohort (
		patid VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CS_AS PRIMARY KEY
		,ageyrs INTEGER
		,-- Is this the right unit?
		sex VARCHAR(2)
		,
		-- enumerate conditions,
		pmca INTEGER
		,bmi_percent_of_p95 DOUBLE PRECISION
		,distance_from_program DOUBLE PRECISION
		,-- In what units?
		pat_pref_language_spoken VARCHAR(3)
		,race VARCHAR(2)
		,hispanic VARCHAR(2)
		,insurance VARCHAR(1)
		,in_study_cohort VARCHAR(1)
		);

INSERT INTO #cohort (
	patid
	,ageyrs
	,sex
	,pat_pref_language_spoken
	,race
	,hispanic
	,in_study_cohort
	)
SELECT d.PERSON_ID COLLATE SQL_Latin1_General_CP1_CS_AS
	,CASE 
		WHEN DATEDIFF(day, DATEADD(year, DATEDIFF(YEAR, d.birth_date, '1/1/2017'), d.birth_date), '1/1/2017') < 0
			THEN DATEDIFF(YEAR, d.birth_date, '1/1/2017') - 1
		ELSE DATEDIFF(YEAR, d.birth_date, '1/1/2017')
		END
	,GENDER
	,PRIMARY_LANGUAGE
	,RACE1
	,hispanic
	,CASE 
		WHEN s.patid IS NOT NULL
			THEN 'T'
		ELSE 'F'
		END
-- TODO: Read study_cohort from the DCC file.
FROM @SCHEMA.@DEMOGRAPHICS d
LEFT OUTER JOIN #study_cohort s ON d.PERSON_ID = s.patid COLLATE SQL_Latin1_General_CP1_CS_AS;
