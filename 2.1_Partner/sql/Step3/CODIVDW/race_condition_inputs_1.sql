DROP TABLE IF EXISTS #race_condition_inputs_1
SELECT PERSON_ID AS patid
	,category
	,COUNT(DIAGNOSES_ID) AS count
	,MIN(ADATE) AS early_admit_date
INTO #race_condition_inputs_1
FROM @SCHEMA.@DIAGNOSES d
JOIN #race_con_codes r ON d.DX_CODETYPE = r.dx_type
	AND UPPER(RTRIM(LTRIM(d.DX))) = UPPER(RTRIM(LTRIM(r.dx)))
GROUP BY PERSON_ID
	,category;
