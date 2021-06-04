DROP TABLE IF EXISTS #cohort_tract;
SELECT linkid
	,site
	,yr
	,TRACT
INTO #cohort_tract
FROM #cohort_demographic_insurance_prep;
