DROP TABLE IF EXISTS #anchor_study_cohort;

SELECT linkid
	,e.PERSON_ID AS patid
	,first_session_date
	,MAX(measure_date) AS measure_date
INTO #anchor_study_cohort
FROM @SCHEMA.@ENCOUNTERS e
JOIN (
	SELECT DISTINCT v1.PERSON_ID
		,v1.MEASURE_DATE
		,v1.ENC_ID
		,v1.HT
		,v2.WT
	FROM @SCHEMA.VITAL_SIGNS v1
	JOIN @SCHEMA.VITAL_SIGNS v2 ON v1.enc_id = v2.enc_id
	WHERE v1.ht IS NOT NULL
		AND v2.wt IS NOT NULL
	) v ON v.ENC_ID = e.ENC_ID
JOIN (
	SELECT c.linkid
		,s.@PERSON_ID_PATID AS patid
		,MIN(session_date) AS first_session_date
	FROM @SCHEMA.@SESSION s
	JOIN #cohort c ON c.patid = s.@PERSON_ID_PATID
	WHERE DATEPART(YEAR, session_date) = 2017
		AND cast(c.in_study_cohort as int) = 1
	GROUP BY c.linkid
		,s.@PERSON_ID_PATID
	) first_session ON first_session.patid = e.PERSON_ID
	AND measure_date < first_session_date
WHERE e.ENCTYPE = 'AV'
GROUP BY linkid
	,e.PERSON_ID
	,first_session_date;
