DROP TABLE IF EXISTS cohort_demographic_insurance_prep;
SELECT #demo_recon_loc_tract.*
	,CASE 
		WHEN DATEDIFF(day, DATEADD(year, DATEDIFF(YEAR, birth_date, '1/1/2017'), birth_date), '1/1/2017') < 0
			THEN DATEDIFF(YEAR, birth_date, '1/1/2017') - 1
		ELSE DATEDIFF(YEAR, birth_date, '1/1/2017')
		END AS age
	,-- assuming this is for age
	CASE 
		WHEN BENEFIT_CAT IS NULL
			THEN 'Other or unknown'
		ELSE BENEFIT_CAT
		END AS insurance_type -- assuming this is for insurance_type
INTO #cohort_demographic_insurance_prep
FROM #demo_recon_loc_tract
JOIN @SCHEMA.@DEMOGRAPHICS d ON #demo_recon_loc_tract.patid = d.PERSON_ID
LEFT JOIN #insurance ON #insurance.PERSON_ID = #demo_recon_loc_tract.patid;


