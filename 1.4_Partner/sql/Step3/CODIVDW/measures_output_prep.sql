DROP TABLE IF EXISTS #measures_output_prep
SELECT linkid
	,patid
	,ht
	,wt
	,MEASURE_DATE
INTO #measures_output_prep
FROM (
	SELECT linkid
		,v.PERSON_ID AS patid
		,ht
		,wt
		,v.MEASURE_DATE
		,CASE 
			WHEN DATEDIFF(day, DATEADD(year, DATEDIFF(YEAR, birth_date, v.MEASURE_DATE), birth_date), v.MEASURE_DATE) < 0
				THEN DATEDIFF(YEAR, birth_date, v.MEASURE_DATE) - 1
			ELSE DATEDIFF(YEAR, birth_date, v.MEASURE_DATE)
			END AS AGE
	FROM (
		SELECT DISTINCT PERSON_ID
			,MEASURE_DATE
			,ENC_ID
			,HT
			,WT
		FROM (
			SELECT v2.person_id
				,v2.enc_id
				,v2.measure_date
				,max(v2.ht) ht
				,max(v2.wt) wt
			FROM @SCHEMA.@VITAL_SIGNS v2
			JOIN #distinct_cohort dc ON dc.patid = v2.person_id
			GROUP BY v2.person_id
				,v2.enc_id
				,v2.measure_date
			) v1
		WHERE wt IS NOT NULL
			AND ht IS NOT NULL
		) v
	JOIN #distinct_cohort d ON d.patid = v.PERSON_ID
	) data
WHERE age >= 2;


