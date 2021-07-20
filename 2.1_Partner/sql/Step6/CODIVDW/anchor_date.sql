DROP TABLE IF EXISTS #anchor_date;

SELECT a.*
	,v.ht
	,v.wt
	,v.ENC_ID
INTO #anchor_date
FROM #anchor_study_cohort a
JOIN #cohort c ON c.patid = a.patid
JOIN @SCHEMA.@VITAL_SIGNS v ON v.PERSON_ID = a.patid
	AND v.measure_date = a.measure_date
JOIN @SCHEMA.@ENCOUNTERS e ON v.ENC_ID = e.ENC_ID
WHERE e.ENCTYPE = 'AV'

UNION

SELECT linkid
	,a.patid
	,NULL AS first_session
	,v.measure_date
	,v.ht
	,v.wt
	,a.random_encounterid AS encounterid
FROM #anchor_comparison_cohort a
JOIN @SCHEMA.@VITAL_SIGNS v ON v.ENC_ID = a.random_encounterid;