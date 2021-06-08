DROP TABLE IF EXISTS #cohort_tract_comorb;
SELECT linkid
	,site
	,yr
	,latitude
	,longitude
	,STATE
	,ZIP
	,TRACT
	,COUNTY
	,acanthosis_nigricans
	,adhd
	,anxiety
	,asthma
	,autism
	,depression
	,diabetes
	,eating_disorders
	,hyperlipidemia
	,hypertension
	,NAFLD
	,Obstructive_sleep_apnea
	,PCOS
INTO #cohort_tract_comorb
FROM #cohort_demographic_tract;
