DROP TABLE IF EXISTS #cohort_pmca_bmi
SELECT p.*
	,a.bmi AS bmi_update
INTO #cohort_pmca_bmi
FROM #cohort_pmca p
LEFT JOIN #annotated_measures a ON p.patid = a.patid;

UPDATE #cohort_pmca_bmi
SET bmi = bmi_update
WHERE bmi_update IS NOT NULL;
