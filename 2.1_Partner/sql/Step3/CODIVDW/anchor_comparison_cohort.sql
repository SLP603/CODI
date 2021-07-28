DROP TABLE IF EXISTS #anchor_comparison_cohort;

SELECT #cohort.linkid
	,#cohort.patid
	,#RAND_ENC.random_encounterid
INTO #anchor_comparison_cohort
FROM #cohort
LEFT JOIN #RAND_ENC ON #cohort.patid = #RAND_ENC.PERSON_ID
WHERE cast(in_study_cohort as int) = 0;
