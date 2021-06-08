DROP TABLE IF EXISTS #pmca_output
SELECT linkid
	,body_system
	,body_system_name
	,severity
	,CASE 
		WHEN body_system = 1
			AND severity = 1
			THEN 1
		WHEN body_system IS NULL
			AND severity IS NULL
			THEN 0
		ELSE 2
		END AS pmca
INTO #pmca_output
FROM #pmca_output_prep;
