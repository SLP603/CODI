/*CHORDS Change: 
	Changed d.dx = s.referencedComponentId to d.dx = s.mapTarget
	because referencedComponentId are all snomed codes and diagnoses.dx are (mostly) ICD codes.
*/
DROP TABLE IF EXISTS #coconditions;
SELECT d.DIAGNOSES_ID AS diagnosisid
	,d.PERSON_ID AS patid
	,d.ADATE AS admit_date
	,d.DX_CODETYPE AS dx_type
	,d.dx
	,s.mapTarget
	,code
	,condition
INTO #coconditions
FROM @SCHEMA.@DIAGNOSES d
JOIN #snomed2icd s ON d.dx = s.mapTarget
JOIN #comorb_codes c ON UPPER(RTRIM(LTRIM(c.code))) LIKE UPPER(RTRIM(LTRIM(s.mapTarget))) + '%'
JOIN #anchor_date a ON a.patid = d.PERSON_ID
WHERE ADATE < a.measure_date
	AND ADATE >= DATEADD(MONTH, -8, a.measure_date);

