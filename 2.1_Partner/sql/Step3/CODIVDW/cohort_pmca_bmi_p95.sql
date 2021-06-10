DROP TABLE IF EXISTS #cohort_pmca_bmi_p95;

SELECT c.*
	,b.bmi_percent_of_p95 AS bmi_percent_of_p95_update
INTO #cohort_pmca_bmi_p95
FROM #cohort_pmca_bmi c
LEFT JOIN #tmpbmi b ON c.patid = b.patid;

UPDATE #cohort_pmca_bmi_p95
SET bmi_percent_of_p95 = bmi_percent_of_p95_update
WHERE bmi_percent_of_p95_update IS NOT NULL;

