DROP TABLE IF EXISTS cohort_demographic_insurance_prep;
SELECT r.*
	,CASE 
		WHEN DATEDIFF(day, DATEADD(year, DATEDIFF(YEAR, d.birth_date, '1/1/2017'), d.birth_date), '1/1/2017') < 0
			THEN DATEDIFF(YEAR, d.birth_date, '1/1/2017') - 1
		ELSE DATEDIFF(YEAR, d.birth_date, '1/1/2017')
		END AS age
	,-- assuming this is for age
	CASE 
		WHEN BENEFIT_CAT IS NULL
			THEN 'Other or unknown'
		ELSE BENEFIT_CAT
		END AS insurance_type -- assuming this is for insurance_type
INTO #cohort_demographic_insurance_prep
FROM #demo_recon_loc_tract r
JOIN @SCHEMA.@DEMOGRAPHICS d ON r.patid = d.PERSON_ID
LEFT JOIN #insurance i ON i.PERSON_ID = r.patid;


