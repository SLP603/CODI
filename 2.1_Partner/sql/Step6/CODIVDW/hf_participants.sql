DROP TABLE IF EXISTS #HF_PARTICIPANTS;

SELECT l.@LINK_ID_COLUMN_VALUE as linkid
	,s.session_id
	,s.programid
	,program_name
	,session_date
INTO #HF_PARTICIPANTS
FROM @SCHEMA.@SESSION s
JOIN @SCHEMA.@PROGRAM pr ON pr.programid = s.programid
JOIN @SCHEMA.@LINK l ON s.patid = l.@PERSON_ID_PATID
JOIN #patientlist pl ON pl.linkid = l.@LINK_ID_COLUMN_VALUE
WHERE s.session_date >= '1/1/2017'
	AND s.programid = 'hf'
ORDER BY l.@LINK_ID_COLUMN_VALUE
	,s.session_date DESC
