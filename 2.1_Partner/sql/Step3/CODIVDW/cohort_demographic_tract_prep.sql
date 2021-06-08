DROP TABLE IF EXISTS #cohort_demographic_tract_prep;

SELECT linkid
	,patid
	,site
	,yr
	,TRACT
	,latitude
	,longitude
	,STATE
	,COUNTY
	,ZIP
INTO #cohort_demographic_tract_prep
FROM #cohort_demographic_insurance_prep;
