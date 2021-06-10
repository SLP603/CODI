DROP TABLE IF EXISTS #tmpbmi;
SELECT patid
	,MAX(bmi_percent_of_p95) AS bmi_percent_of_p95
INTO #tmpbmi
FROM #annotated_measures
GROUP BY patid;
