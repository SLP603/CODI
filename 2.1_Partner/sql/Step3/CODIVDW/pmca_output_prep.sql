DROP TABLE IF EXISTS #pmca_output_prep
SELECT linkid
	,b.*
	,c.body_system_name
INTO #pmca_output_prep
FROM #distinct_cohort a
LEFT JOIN #pmca_input b ON a.patid = b.patid
LEFT JOIN #pmca_output_single_system c ON a.patid = c.patid;
