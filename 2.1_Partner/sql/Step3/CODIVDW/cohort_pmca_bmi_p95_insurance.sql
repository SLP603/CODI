DROP TABLE IF EXISTS #cohort_pmca_bmi_p95_insurance
SELECT #cohort_pmca_bmi_p95.*
	,#insurance.insurance_type
INTO #cohort_pmca_bmi_p95_insurance
FROM #cohort_pmca_bmi_p95
LEFT JOIN #insurance ON #cohort_pmca_bmi_p95.patid = #insurance.PERSON_ID;


UPDATE #cohort_pmca_bmi_p95_insurance
SET insurance = insurance_type
WHERE insurance_type IS NOT NULL;


UPDATE #cohort_pmca_bmi_p95_insurance
SET insurance = 'Other or unknown'
WHERE insurance IS NULL;
