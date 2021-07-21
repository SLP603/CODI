DROP TABLE IF EXISTS OUTCOME_VITALS;

SELECT a.linkid
	,e.ADATE AS admit_date
	,e.ENCTYPE AS enc_type
	,v.measure_date
	,v.ht
	,v.wt
	,CASE 
		WHEN v.ht IS NOT NULL
			AND v.wt IS NOT NULL
			THEN (v.wt * .4535924) / SQUARE(v.ht * .0254)
		ELSE NULL
		END AS bmi
	,diastolic
	,systolic
INTO #OUTCOME_VITALS
FROM #anchor_date a
JOIN @SCHEMA.@VITAL_SIGNS v ON v.PERSON_ID = a.patid
JOIN @SCHEMA.@ENCOUNTERS e ON e.ENC_ID = v.ENC_ID
JOIN #patientlist p ON p.linkid = a.linkid
WHERE v.measure_date >= DATEADD(month, - 8, a.measure_date)
ORDER BY a.linkid;
