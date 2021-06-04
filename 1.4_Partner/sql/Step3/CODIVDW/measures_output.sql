DROP TABLE IF EXISTS #measures_output;
SELECT a.linkid
	,a.ht
	,a.wt
	,a.measure_date
	,b.insurance_type
INTO #measures_output
FROM #measures_output_prep a
LEFT JOIN cohort_demographic_insurance_prep b ON a.linkid = b.linkid;

