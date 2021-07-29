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
		SELECT person_id
			,enc_id
			,measure_date
			,max(ht) ht
			,max(wt) wt
			,max(diastolic) diastolic
			,max(systolic) systolic
		FROM @SCHEMA.@VITAL_SIGNS
		GROUP BY person_id
			,enc_id
			,measure_date
		) v1
	) v ON v.PERSON_ID = a.patid
JOIN @SCHEMA.@ENCOUNTERS e ON e.ENC_ID = v.ENC_ID
JOIN #patientlist p ON p.linkid = a.linkid
WHERE v.measure_date >= DATEADD(month, - 8, a.measure_date)
ORDER BY a.linkid;

