DROP TABLE IF EXISTS #cohort;
CREATE TABLE #cohort (
		person_id VARCHAR(255) PRIMARY KEY
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
	person_id
	,ageyrs
	,sex
	,pat_pref_language_spoken
	,race
	,hispanic
	,in_study_cohort
	)
SELECT d.PERSON_ID
	,CASE 
		WHEN DATEDIFF(day, DATEADD(year, DATEDIFF(YEAR, birth_date, '1/1/2017'), birth_date), '1/1/2017') < 0
			THEN DATEDIFF(YEAR, birth_date, '1/1/2017') - 1
		ELSE DATEDIFF(YEAR, birth_date, '1/1/2017')
		END
	,GENDER
	,PRIMARY_LANGUAGE
	,RACE1
	,hispanic
	,CASE 
		WHEN s.person_id IS NOT NULL
			THEN 'T'
		ELSE 'F'
		END
-- TODO: Read study_cohort from the DCC file.
FROM @SCHEMA.@DEMOGRAPHICS d
LEFT OUTER JOIN #study_cohort s ON d.PERSON_ID = s.person_id;
