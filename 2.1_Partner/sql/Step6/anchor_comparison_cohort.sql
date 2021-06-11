DROP TABLE IF EXISTS #anchor_comparison_cohort;

SELECT c.linkid
	,c.patid
	,r.random_encounterid
INTO #anchor_comparison_cohort
FROM #cohort c
LEFT JOIN #RAND_ENC r ON c.patid = r.PERSON_ID
WHERE in_study_cohort = 0;
