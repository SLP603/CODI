DROP TABLE IF EXISTS #pmca_output_single_system
SELECT a.patid
	,a.body_system
	,b.body_system_name
	,a.severity
INTO #pmca_output_single_system
FROM #pmca_input_single a
LEFT JOIN #pmca_input_system b ON a.patid = b.patid;
