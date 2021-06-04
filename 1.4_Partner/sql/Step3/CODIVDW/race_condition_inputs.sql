DROP TABLE IF EXISTS #race_condition_inputs
SELECT dbo.link.linkid
	,category
	,count
	,early_admit_date
INTO #race_condition_inputs
FROM #race_condition_inputs_1 a
LEFT JOIN @SCHEMA.@LINK b ON a.patid = b.patid;


