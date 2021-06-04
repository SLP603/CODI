DROP TABLE IF EXISTS #coconditions;
SELECT d.DIAGNOSES_ID
	,-- we cannot fill
	d.PERSON_ID AS patid
	,d.ADATE
	,d.DX_CODETYPE
	,d.dx
	,sm.mapTarget
	,code
	,condition
	,DATEPART(YEAR, ADATE) AS year
INTO #coconditions
FROM @SCHEMA.@DIAGNOSES d
JOIN #snomed2icd sm ON d.dx = sm.referencedComponentId
JOIN #comorb_codes cm ON UPPER(RTRIM(LTRIM(cm.code))) LIKE '%' + UPPER(RTRIM(LTRIM(sm.mapTarget))) + '%'
WHERE ADATE >= '12/31/2016';
