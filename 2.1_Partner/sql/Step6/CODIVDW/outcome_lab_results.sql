DROP TABLE IF EXISTS #OUTCOME_LAB_RESULTS;

SELECT a.linkid
	,LOINC
	,PX
	,CODETYPE
	,RESULT_DT
	,MODIFIER
	,RESULT_UNIT
	,RESULT_NUM
	,[NORMAL_LOW_C]
	,--norm_range_low, 
	[NORMAL_HIGH_C] norm_range_high
	,MODIFIER_LOW
	,MODIFIER_HIGH
	,abn_ind
INTO #OUTCOME_LAB_RESULTS
FROM @LAB_RESULTS_SCHEMA.@LAB_RESULTS l
JOIN #anchor_date a ON a.patid = l.PERSON_ID
JOIN #patientlist p ON p.linkid = a.linkid
WHERE RESULT_DT >= DATEADD(month, - 8, a.measure_date)
	AND LOINC IN (
		SELECT code
		FROM #lab_codes
		)
ORDER BY linkid;
