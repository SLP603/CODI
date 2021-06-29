DROP TABLE IF EXISTS #ENCOUNTERS_VITAL_JOIN;

SELECT DISTINCT height.ENC_ID
	,height.PERSON_ID
	,height.ENCTYPE
	,height.measure_date
	,ht
	,wt
INTO #ENCOUNTERS_VITAL_JOIN
FROM (
	SELECT e.ENC_ID
		,e.PERSON_ID
		,e.ENCTYPE
		,v.measure_date
		,ht
	FROM @SCHEMA.ENCOUNTERS e
	JOIN @SCHEMA.VITAL_SIGNS v ON e.ENC_ID = v.ENC_ID
	WHERE e.ENCTYPE = 'AV'
		AND ht IS NOT NULL
		AND v.measure_date BETWEEN '1/1/2017'
			AND '12/31/2017'
	) height
JOIN (
	SELECT e.ENC_ID
		,e.PERSON_ID
		,e.ENCTYPE
		,v.measure_date
		,wt
	FROM @SCHEMA.ENCOUNTERS e
	JOIN @SCHEMA.VITAL_SIGNS v ON e.ENC_ID = v.ENC_ID
	WHERE e.ENCTYPE = 'AV'
		AND wt IS NOT NULL
		AND v.measure_date BETWEEN '1/1/2017'
			AND '12/31/2017'
	) weight ON weight.ENC_ID = height.ENC_ID
	AND weight.PERSON_ID = height.PERSON_ID
WHERE ht IS NOT NULL
	AND wt IS NOT NULL;

