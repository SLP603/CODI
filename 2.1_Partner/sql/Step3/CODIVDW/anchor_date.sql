DROP TABLE IF EXISTS #anchor_date;

SELECT DISTINCT a.*
	,v1.ht
	,v2.wt
	,v1.ENC_ID
INTO #anchor_date
FROM #anchor_study_cohort a
JOIN #cohort c ON c.patid = a.patid
JOIN @SCHEMA.@VITAL_SIGNS v1 ON v1.PERSON_ID = a.patid
	AND v1.measure_date = a.measure_date
JOIN @SCHEMA.@VITAL_SIGNS v2 ON v2.PERSON_ID = a.patid
	AND v2.measure_date = a.measure_date
	and v1.ENC_ID = v2.ENC_ID
JOIN @SCHEMA.@ENCOUNTERS e ON v1.ENC_ID = e.ENC_ID
WHERE e.ENCTYPE = 'AV'

UNION

SELECT DISTINCT linkid
	,a.patid
	,NULL AS first_session
	,v1.measure_date
	,v1.ht
	,v2.wt
	,a.random_encounterid AS encounterid
FROM #anchor_comparison_cohort a
JOIN @SCHEMA.@VITAL_SIGNS v1 ON v1.ENC_ID = a.random_encounterid
JOIN @SCHEMA.@VITAL_SIGNS v2 ON v2.ENC_ID = a.random_encounterid
	and v1.ENC_ID = v2.ENC_ID
;