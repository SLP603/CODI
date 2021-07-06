DROP TABLE IF EXISTS #study_cohort_inclusion;
SELECT PERSON_ID AS patid
	,birth_date
	,CASE 
		WHEN DATEDIFF(day, DATEADD(year, DATEDIFF(YEAR, birth_date, '1/1/2017'), birth_date), '1/1/2017') < 0
			THEN DATEDIFF(YEAR, birth_date, '1/1/2017') - 1
		ELSE DATEDIFF(YEAR, birth_date, '1/1/2017')
		END AS study_age_yrs
	,CASE 
		WHEN inc.patid IS NOT NULL
			THEN 1
		ELSE 0
		END AS inclusion
INTO #study_cohort_inclusion
FROM @SCHEMA.@DEMOGRAPHICS d
LEFT JOIN (
	SELECT DISTINCT @PERSON_ID_PATID COLLATE
	FROM @SCHEMA.@SESSION
	WHERE DATEPART(YEAR, session_date) = 2017
	) inc ON inc.patid = d.PERSON_ID
WHERE CASE 
		WHEN DATEDIFF(day, DATEADD(year, DATEDIFF(YEAR, birth_date, '1/1/2017'), birth_date), '1/1/2017') < 0
			THEN DATEDIFF(YEAR, birth_date, '1/1/2017') - 1
		ELSE DATEDIFF(YEAR, birth_date, '1/1/2017')
		END BETWEEN 2
		AND 19;
