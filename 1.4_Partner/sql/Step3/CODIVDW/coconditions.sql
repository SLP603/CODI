/*CHORDS Change: 
	Changed d.dx = s.referencedComponentId to d.dx = s.mapTarget
	because referencedComponentId are all snomed codes and diagnoses.dx are (mostly) ICD codes.
*/

DROP TABLE IF EXISTS #coconditions;
WITH cte_comorb_codes as (
	SELECT distinct *
	FROM #snomed2icd s
	JOIN #comorb_codes c 
		ON UPPER(RTRIM(LTRIM(c.code))) LIKE UPPER(RTRIM(LTRIM(s.mapTarget))) + '%'
		and mapTarget != ''
)

SELECT DISTINCT d.DIAGNOSES_ID AS diagnosisid
	,d.PERSON_ID AS patid
	,d.ADATE AS admit_date
	,d.DX_CODETYPE AS dx_type
	,d.dx
	,s.mapTarget
	,code
	,condition
INTO #coconditions
FROM @SCHEMA.@DIAGNOSES d
JOIN cte_comorb_codes s ON d.dx = s.mapTarget
WHERE ADATE >= '12/31/2016';
