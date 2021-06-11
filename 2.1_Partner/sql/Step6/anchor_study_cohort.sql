DROP TABLE IF EXISTS #anchor_study_cohort;

SELECT linkid
	,e.PERSON_ID AS patid
	,first_session_date
	,MAX(measure_date) AS measure_date
INTO #anchor_study_cohort
FROM @SCHEMA.@ENCOUNTERS e
JOIN @SCHEMA.@VITAL_SIGNS v ON v.ENC_ID = e.ENC_ID
JOIN (
	SELECT c.linkid
		,s.@PERSON_ID_PATID as patid
		,MIN(session_date) AS first_session_date
	FROM @SCHEMA.@SESSION s
	JOIN #cohort c ON c.patid = s.@PERSON_ID_PATID
	WHERE DATEPART(YEAR, session_date) = 2017
		AND c.in_study_cohort = 1
	GROUP BY c.linkid
		,s.@PERSON_ID_PATID
	) first_session ON first_session.patid = e.PERSON_ID
	AND measure_date < first_session_date
WHERE e.ENCTYPE = 'AV'
	AND ht IS NOT NULL
	AND wt IS NOT NULL
GROUP BY linkid
	,e.PERSON_ID
	,first_session_date;
