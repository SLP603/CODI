DROP TABLE IF EXISTS #distinct_cohort
SELECT linkid
	,patid
	,birth_date
	,count(linkid) AS cnt
INTO #distinct_cohort
FROM #cohort_demographic_insurance_prep
GROUP BY linkid
	,patid
	,birth_date;

