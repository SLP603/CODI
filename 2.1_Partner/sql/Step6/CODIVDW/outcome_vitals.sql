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
JOIN (
	SELECT DISTINCT PERSON_ID
		,MEASURE_DATE
		,ENC_ID
		,HT
		,WT
		,diastolic
		,systolic
	FROM (
		SELECT v2.person_id
			,v2.enc_id
			,v2.measure_date
			,max(v2.ht) ht
			,max(v2.wt) wt
			,max(v2.diastolic) diastolic
			,max(v2.systolic) systolic
		FROM @SCHEMA.@VITAL_SIGNS v2
		JOIN #anchor_date ad on ad.patid = v2.person_id
		GROUP BY v2.person_id
			,v2.enc_id
			,v2.measure_date
		) v1
	) v ON v.PERSON_ID = a.patid
JOIN @SCHEMA.@ENCOUNTERS e ON e.ENC_ID = v.ENC_ID
JOIN #patientlist p ON p.linkid = a.linkid
WHERE v.measure_date >= DATEADD(month, -8, a.measure_date)
ORDER BY a.linkid;

