DROP TABLE IF EXISTS #cohort_out;

SELECT c.linkid
	,c.race
	,c.hispanic
	,c.sex
	,c.birth_date
	,c.in_study_cohort
	,c.ageyrs
INTO #cohort_out
FROM #cohort c;

