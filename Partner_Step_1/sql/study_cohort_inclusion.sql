DROP TABLE IF EXISTS #study_cohort_inclusion;
SELECT PERSON_ID AS patid
	,birth_date
	,CASE 
		WHEN DATEDIFF(day, DATEADD(year, DATEDIFF(YEAR, birth_date, '1/1/2017'), birth_date), '1/1/2017') < 0
			THEN DATEDIFF(YEAR, birth_date, '1/1/2017') - 1
		ELSE DATEDIFF(YEAR, birth_date, '1/1/2017')
		END AS study_age_yrs
	,CASE 
		WHEN PERSON_ID IN (
				(
					SELECT patid
					FROM @SCHEMA.@SESSION
					WHERE DATEPART(YEAR, session_date) = 2017
						AND programid IN (
							SELECT programid
							FROM #study_programs
							)
					)
				)
			THEN 1
		ELSE 0
		END AS inclusion
INTO #study_cohort_inclusion
FROM @SCHEMA.@DEMOGRAPHIC
WHERE CASE 
		WHEN DATEDIFF(day, DATEADD(year, DATEDIFF(YEAR, birth_date, '1/1/2017'), birth_date), '1/1/2017') < 0
			THEN DATEDIFF(YEAR, birth_date, '1/1/2017') - 1
		ELSE DATEDIFF(YEAR, birth_date, '1/1/2017')
		END BETWEEN 2
		AND 19;
