DROP TABLE IF EXISTS measures_output_prep
SELECT linkid
	,v.PERSON_ID AS patid
	,ht
	,wt
	,v.MEASURE_DATE
INTO measures_output_prep
FROM @SCHEMA.@VITAL_SIGNS v
JOIN #distinct_cohort d ON d.patid = v.PERSON_ID
WHERE CASE 
		WHEN DATEDIFF(day, DATEADD(year, DATEDIFF(YEAR, birth_date, v.MEASURE_DATE), birth_date), v.MEASURE_DATE) < 0
			THEN DATEDIFF(YEAR, birth_date, v.MEASURE_DATE) - 1
		ELSE DATEDIFF(YEAR, birth_date, v.MEASURE_DATE)
		END AS study_age_yrs_2017 >= 2
	AND wt IS NOT NULL
	AND ht IS NOT NULL;
