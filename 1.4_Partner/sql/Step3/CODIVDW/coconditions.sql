DROP TABLE IF EXISTS #coconditions;
SELECT d.DIAGNOSES_ID
	,-- we cannot fill
	d.PERSON_ID AS patid
	,d.ADATE
	,d.DX_CODETYPE
	,d.dx
	,s.mapTarget
	,code
	,condition
	,DATEPART(YEAR, ADATE) AS year
INTO #coconditions co
FROM @SCHEMA.@DIAGNOSES d
JOIN #snomed2icd s ON d.dx = s.referencedComponentId
JOIN #comorb_codes cm ON UPPER(TRIM(sm.code)) LIKE '%' + UPPER(TRIM(s.mapTarget)) + '%'
WHERE ADATE >= '12/31/2016';
