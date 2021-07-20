DROP TABLE IF EXISTS #study_cohort_exclusion;
SELECT *
INTO #study_cohort_exclusion
FROM (
	SELECT PERSON_ID AS patid
		,birth_date
		,CASE 
			WHEN DATEDIFF(day, DATEADD(year, DATEDIFF(YEAR, birth_date, '1/1/2017'), birth_date), '1/1/2017') < 0
				THEN DATEDIFF(YEAR, birth_date, '1/1/2017') - 1
			ELSE DATEDIFF(YEAR, birth_date, '1/1/2017')
			END AS study_age_yrs
		,CASE 
			WHEN exc.patid IS NOT NULL
				THEN 1
			ELSE 0
			END AS exclusion
	FROM @SCHEMA.@DEMOGRAPHICS d
	LEFT JOIN (
		SELECT DISTINCT @PERSON_ID_PATID patid
		FROM @SCHEMA.@SESSION
		WHERE session_date >= '1-Jun-2016'
			AND session_date < '1-Jan-2017'
			--AND programid IN (
			--	SELECT programid
			--	FROM #study_programs
			--	)
		) exc ON exc.patid = d.PERSON_ID
	) a
WHERE study_age_yrs BETWEEN 2
		AND 19;
